set -e
apt update
apt install -y wget \
    libnspr4 libnss3 libxkbfile1 xdg-utils
wget https://go.microsoft.com/fwlink/?LinkID=760868 --output-document /tmp/code.dep
dpkg -i /tmp/code.dep
rm /tmp/code.dep
