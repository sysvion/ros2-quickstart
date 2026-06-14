set -e

export VSCODE_VERSION="1.119.0"

sudo -A apt update
sudo -A apt install -y wget \
    libnspr4 libnss3 libxkbfile1 xdg-utils

if test "$(uname -m)" = "x86_64"; then
	wget "https://update.code.visualstudio.com/$VSCODE_VERSION/linux-deb-x64/stable" --output-document /tmp/code.deb
fi

if test "$(uname -m)" = "aarch64"; then
	wget "https://update.code.visualstudio.com/$VSCODE_VERSION/linux-deb-arm64/stable" --output-document /tmp/code.deb
fi

sudo -A dpkg -i /tmp/code.deb
sudo -A apt-get install -f -y # install passable missing dependencies 

rm /tmp/code.deb
