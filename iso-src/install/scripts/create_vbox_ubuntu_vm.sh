#!/usr/bin/env bash
set -euo pipefail

DATA_HOME="$HOME/.cache/share/ros_vm_tool"
ISO_DIR="$DATA_HOME/iso"

# i think only dirname could work
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

VM_NAME="practicum-ubuntu"
VM_USER="${VM_USER:-practicum}"
VM_PASSWORD="smr"
VM_MEMORY_MB="8192"
VM_CPUS="4"
VM_DISK_GB="48"

# TODO: validate all greps

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

require_cmd VBoxManage
require_cmd uname
require_cmd echo
require_cmd scp
# curl or wget


log() { echo '==>' "$*";}
die() { echo 'error: ' "$*" >&2; exit 1; }

detect_host_arch() {
  case "$(uname -m)" in
    x86_64|amd64) echo "amd64" ;;
    aarch64|arm64) echo "arm64" ;;
    *) die "unsupported host architecture: ${machine} (x86_64 and aarch64 are supported)" ;;
  esac
}

ISO_BASE_URL="https://cdimage.ubuntu.com/noble/daily-live/current"
iso_filename_for_arch() {
  local arch="$1"
  case "${arch}" in
    amd64) echo "noble-desktop-amd64.iso" ;;
    arm64) echo "noble-desktop-arm64.iso" ;;
    *) die "unknown arch: ${arch}" ;;
  esac
}

# Get the list of all supported using `VBoxManage list ostypes`
vbox_ostype_for_arch() {
  local arch="$1"
  case "${arch}" in
    amd64) echo "Ubuntu24_LTS_64" ;;
    arm64) echo "Ubuntu24_LTS_arm64"
      ;;
    *) die "unknown arch: ${arch}" ;;
  esac
}

# TODO: add zsync
download_iso() {
  local arch filename url dest
  arch="$(detect_host_arch)"
  filename="$(iso_filename_for_arch "${arch}")"
  url="${ISO_BASE_URL}/${filename}"
  dest="${ISO_DIR}/${filename}"

  mkdir -p ${ISO_DIR}

  if [ -e $dest ]; then
      log "reusing image. remove ${dest} if you wanna redownload disk image"
      return
  fi

  if command -v curl >/dev/null 2>&1; then
    log "Downloading ${url} using curl"
    curl -fL --progress-bar -o "${dest}.partial" "${url}"
    mv "${dest}.partial" "${dest}"
  elif command -v wget >/dev/null 2>&1; then
    log "Downloading ${url} using wget"
    wget -O "${dest}.partial" "${url}"
    mv "${dest}.partial" "${dest}"
  else
    die "need curl or wget to download the ISO"
  fi
  log "download completed"
}

# TODO: Handle already existing disks or vms
prepare_vm() {
  local  arch iso_path ostype disk_path disk_mb
  arch="$(detect_host_arch)"
  disk_path="$DATA_HOME/disk.vdi"
  disk_mb=$((VM_DISK_GB * 1024))
  iso_file="${ISO_DIR}/"$(iso_filename_for_arch "${arch}")""

  log "Creating VM ${VM_NAME} (${arch} ISO)"
  VBoxManage createvm --name "${VM_NAME}" --ostype "$(vbox_ostype_for_arch "${arch}")" --register
  VBoxManage modifyvm "${VM_NAME}" \
      --memory "${VM_MEMORY_MB}" \
      --cpus "${VM_CPUS}"

  VBoxManage modifyvm "${VM_NAME}" \
      --vram 64 \
      --graphicscontroller=vmsvga

  VBoxManage modifyvm "${VM_NAME}" \
      --boot1 dvd \
      --boot2 disk \
      --boot3 none \
      --boot4 none

  # create disk image
  mkdir -p "$(dirname "${disk_path}")"
  VBoxManage createmedium disk --filename "${disk_path}" --size "${disk_mb}" --format VDI
  VBoxManage storagectl "${VM_NAME}" --name SATA --add sata --controller IntelAhci

  VBoxManage storageattach "${VM_NAME}" --storagectl SATA --port 0 --device 0 \
      --type hdd --medium "${disk_path}"

  VBoxManage unattended install "${VM_NAME}" \
      --iso="${iso_file}" \
      --user="${VM_USER}" \
      --full-user-name="${VM_USER}" \
      --user-password="${VM_PASSWORD}" \
      --install-additions \
      --post-install-command="VBoxControl guestproperty set autoinstall y" \
      --locale=en_US \
      --country=NL \
      --time-zone=cest 
}


main() {

  #VBoxManage showvminfo "${VM_NAME}" &> /dev/null 
  #if [ $? -eq 0 ]; then
  #    log "VBoxManage showvminfo succeeds. Youre probably allready have a vm called ${VM_NAME}"
  #    log "installed. Please remove it. You can remove it with the virtual box gui or"
  #    log "you can use alongside the gui \`vboxmanage unregistervm ${VM_NAME} --delete-all\`"
  #    exit 1
  #fi
  download_iso
  prepare_vm 

  log "Starting VM for Ubuntu autoinstallation"
  VBoxManage startvm "${VM_NAME}" --type gui

  sleep 10s # wait until vm is up
  log "start waiting for proprity"

  VBoxManage guestproperty wait "${VM_NAME}" autoinstall

  sleep 5m # wait until vm has rebooted and guest additions loaded
            # yeah its to long but it needs to be here and 1m is to short

  VBoxManage guestcontrol \
      "${VM_NAME}" --user "${VM_USER}" --password "${VM_PASSWORD}" \
      copyto \
      -R $PWD/iso-src/install/ /home/practicum/install

   # run installscript with SUDO_ASKPASS
  VBoxManage guestcontrol "${VM_NAME}"  --user "${VM_USER}"  --password "${VM_PASSWORD}"       run       -- /usr/bin/env bash -c '
export DEBIAN_FRONTEND=noninteractive

# create askpass so tty is not needded
cat > /home/'"${VM_USER}"'/vm_askpass.sh <<EOF
#!/bin/bash
echo "'"${VM_PASSWORD}"'"
EOF
chmod u+x /home/'"${VM_USER}"'/vm_askpass.sh
export SUDO_ASKPASS=/home/'"${VM_USER}"'/vm_askpass.sh

# RUN the command within systemd because guestcontrol connection is volitle
nohup sudo -A systemd-run \
	--setenv=SUDO_ASKPASS="${SUDO_ASKPASS}" \
	-- bash -c " \
		cd /home/practicum/install/scripts
		sudo --preserve-env --user="'"${VM_USER}"'" bash LocalInstall.sh
		"
'

  exit
}

main
