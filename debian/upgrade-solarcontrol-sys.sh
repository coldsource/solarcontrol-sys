#!/usr/bin/bash

set -e

BIN_DIR=/usr/local/bin
VERSION=1.0
BIN_DIR=/tmp/bin

if [ $# -eq 1 ]
then
	if [ $1 == "--version" ]
	then
		echo $VERSION
		exit
	fi
fi

if [ -f $BIN_DIR/upgrade-solarcontrol-sys.sh ]
then
	CUR_VERSION=$($BIN_DIR/upgrade-solarcontrol-sys.sh --version)
else
	CUR_VERSION=0
fi

# Check if we have a newer version
LAST_VERSION=$(git ls-remote --tags https://github.com/coldsource/solarcontrol-sys.git | egrep -o 'tags/[0-9\.]+' | egrep -o '[0-9\.]+' | sort -Vr | head -n1)

if [ $CUR_VERSION == $LAST_VERSION ]
then
	exit
fi

echo "Upgrading system to v$LAST_VERSION"

# Clean build path
rm -rf /tmp/solarcontrol-sys

# Clone repo
cd /tmp
git clone https://github.com/coldsource/solarcontrol-sys
cd /tmp/solarcontrol-sys
git checkout --quiet $LAST_VERSION

# Move binary
sudo mv /tmp/solarcontrol-sys/debian/upgrade-solarcontrol-sys.sh $BIN_DIR/upgrade-solarcontrol-sys.sh
sudo mv /tmp/solarcontrol-sys/debian/upgrade-solarcontrol-core.sh $BIN_DIR/upgrade-solarcontrol-core.sh
sudo mv /tmp/solarcontrol-sys/debian/upgrade-solarcontrol-front.sh $BIN_DIR/upgrade-solarcontrol-front.sh

# Clean
rm -rf /tmp/solarcontrol-sys
