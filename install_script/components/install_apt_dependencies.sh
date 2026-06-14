set -e

##################
# Install Docker #
##################
echo "===> install docker" >> /tmp/install.log
sudo -A apt update
sudo -A apt install ca-certificates curl
sudo -A install -m 0755 -d /etc/apt/keyrings
sudo -A curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo -A chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo -A tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo -A apt update
sudo -A apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

##################################
# Install universal robot driver #
##################################

echo "===> install universal robots" >> /tmp/install.log
sudo -A apt install ros-jazzy-ur -y
