#!/usr/bin/bash

set -e

BIN_DIR=/usr/local/bin

if [ -f $BIN_DIR/solarcontrol ]
then
	CUR_VERSION=$($BIN_DIR/solarcontrol --version)
else
	CUR_VERSION=0
fi

# Check if we have a newer version
LAST_VERSION=$(git ls-remote --tags https://github.com/coldsource/solarcontrol.git | egrep -o 'tags/[0-9\.]+' | egrep -o '[0-9\.]+' | sort -Vr | head -n1)

if [ $CUR_VERSION == $LAST_VERSION ]
then
	exit
fi

echo "Upgrading core to v$LAST_VERSION"

# Clean build path
rm -rf /tmp/solarcontrol

# Clone repo
cd /tmp
git clone https://github.com/coldsource/solarcontrol
cd /tmp/solarcontrol
git checkout --quiet $LAST_VERSION

# Build
mkdir build
cd build
cmake ..
make

# Move binary
sudo mv /tmp/solarcontrol/build/solarcontrol $BIN_DIR/solarcontrol

# Upgrade database if needed
$BIN_DIR/solarcontrol --config /etc/solarcontrol.conf --upgrade

# Restart service
sudo /usr/bin/systemctl restart solarcontrol

# Clean
rm -rf /tmp/solarcontrol
