#!/usr/bin/env bash
set -e

mkdir -p ~/.local/share/
sudo -A mv $(cd $(dirname $0) && pwd) ~/.local/share/user_creator
sudo -A  chown --recursive $USER ~/.local/share/user_creator
sudo -A  chmod u=rwx,g=,o= ~/.local/share/user_creator

cd ~/.local/share/user_creator

sudo apt install -y python3-venv python3-pip python3
rm -rf .venv || true
python3 -m venv .venv
source .venv/bin/activate
pip install .

mkdir ~/.local/share/applications/
tee ~/.local/share/applications/account-creation-tool.desktop <<EOF 
[Desktop Entry]
Name=User creation tool
Type=Application
Exec=bash -c 'source ~/.local/share/user_creator/.venv/bin/activate && python3 ~/.local/share/user_creator/src/main.py'
Terminal=true
EOF
