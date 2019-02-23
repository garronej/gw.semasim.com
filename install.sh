#!/bin/bash

# TODO: Test if debian or ubuntu distribution comply to requirements.

INSTALL_PATH=/usr/share/semasim
TARBALL_PATH=/tmp/semasim.tar.gz

if [[ $EUID -ne 0 ]]; then
    echo "This script require root privileges."
    exit 1
fi

if [ -d "$INSTALL_PATH" ]; then

    echo "Directory $INSTALL_PATH already exsist, uninstalling previous install"
    
    semasim_uninstaller run 2>/dev/null
    
    rm -rf $INSTALL_PATH

fi

RELEASES_INDEX=$(wget -qO- https://github.com/garronej/releases/releases/download/semasim-gateway/index.json)

CURRENT_VERSION=$(wget -qO- https://web.semasim.com/api/version)

DL_URL=$(echo $RELEASES_INDEX | grep -Po "\"$CURRENT_VERSION\_$(uname -m)\": *\K\"[^\"]*\"" | sed 's/^"\(.*\)"$/\1/')

wget $DL_URL -q --show-progress -O $TARBALL_PATH

mkdir $INSTALL_PATH

printf "Extracting"

tar -xzf $TARBALL_PATH -C $INSTALL_PATH --checkpoint=.100

echo -e "\nLaunching the installer..."

rm $TARBALL_PATH

cd $INSTALL_PATH && ./node dist/bin/installer install
