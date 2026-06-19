from hcloud import Client
from hcloud.images import Image

from cryptography.hazmat.primitives import serialization as crypto_serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.backends import default_backend as crypto_default_backend

import os
from time import sleep
import subprocess
from pathlib import Path

# MAKE SURE THE DIRACTORY IS ONLY READABLE BY THIS PROGRAM BY FOR INSTANCE RUNNING IT AS A SYSTEMD SERVICE
import sqlite3
private_storage = Path("/var/lib/ros2-vps-creator/")

# TODO: check if this is the correct location

install_script_root = (Path(os.path.abspath(__file__)) / "../../../../install_script").resolve()
distro_root = (Path(os.path.abspath(__file__)) / ".." / '..').resolve()


#def createdb():
#    cx = sqlite3.connect(db_path)
#    cx.execute("""create table if not exists keys (
#                    id TEXT primary key,
#                    key TEXT NOT NULL
#               );""")
#
#    cx.execute("""create vps if not exists keys (
#                    id int primary key,
#                    SERVER_ID
#                    created_at //todo
#                    public key 
#                    private_key 
#                    external_management_blob
#               );""")

def readContensOfFile(file: Path) -> str:
    fp = file.open()
    contents = fp.read()
    fp.close()
    return contents


def replaceFile(file: Path, contents: str, mode=0o600):
    try:
        file.touch(mode=mode)
    except FileExistsError:
        pass
    f = file.open('r+')
    f.seek(0)
    f.write(contents)
    f.truncate()
    f.close()


def main():

    id_file = (private_storage / "current_id")
    vm_id = int(readContensOfFile(id_file)) + 1
    replaceFile(id_file, (str(vm_id)))

    vm_name = "vmGeneratorInstance" + str(vm_id)
    vm_dir = private_storage / vm_name
    vm_dir.mkdir()

    token = readContensOfFile(private_storage / "api_key").strip()
    client = Client(
            token=token,
            application_name="Default",
            application_version="v1.0.0" # what does this mean? Do you force me to use simver or is it a api
            )

    # machine
    selected_type = None
    for machine in client.server_types.get_all():
        if machine.name == 'cpx32':
            selected_type = machine

    if selected_type is None:
        print("type not found")
        return

    # ssh keys
    rsakey = rsa.generate_private_key(
        backend=crypto_default_backend(),
        public_exponent=65537,
        key_size=2048
    )

    private_key = rsakey.private_bytes(
        crypto_serialization.Encoding.PEM,
        crypto_serialization.PrivateFormat.PKCS8,
        crypto_serialization.NoEncryption()
    ).decode('ascii')
    replaceFile(vm_dir/"id_rsa", private_key)

    public_key = rsakey.public_key().public_bytes(
        crypto_serialization.Encoding.OpenSSH,
        crypto_serialization.PublicFormat.OpenSSH
    ).decode('ascii')
    replaceFile(vm_dir/"id_rsa.pub", public_key)

    key = client.ssh_keys.create(name=vm_name, public_key=public_key)

    # init script
    print("creating a server with id " + str(vm_id))
    cloud_init = readContensOfFile(distro_root / "cloud-init.yml")
    # TODO: change password within script

    server = client.servers.create(
        vm_name,
        selected_type,
        Image(name="ubuntu-24.04"),
        ssh_keys=[key],
        user_data=cloud_init,
    )

    server.action.wait_until_finished()
    print("now sleep")
    sleep(100)

    # upload and run install script
    dest = "root@"+server.server.public_net.ipv4.ip+":/opt/install"
    subprocess.call(['scp',
                     '-i', (vm_dir/"id_rsa").as_posix(),
                     '-o', 'StrictHostKeyChecking=accept-new',
                     "-r",
                     install_script_root.as_posix(),
                     dest
                     ])

    password = "still_testing"

    subprocess.call(['ssh',
                     '-i', (vm_dir/"id_rsa").as_posix(),
                     "root@"+server.server.public_net.ipv4.ip,
                     "--",
                     "systemd-run",
                     "--",
                     "bash",
                     "-c \"",
                     """
                     printf user:"""+password+""" | chpasswd
                     cat > /opt/askpass.sh <<EOD
                     echo -n """+password+"""
EOD

                     cloud-init status --wait
                     grdctl --system rdp set-credentials test testing
                     chmod o+x /opt/askpass.sh
                     systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
                     cd /opt/install
                     sudo --preserve-env --user=user bash process.bash
                     systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target
                     rm /opt/install
                     rm /opt/vm_askpass.sh
                     reboot
                     """,
                     "\""
                     ])


if __name__ == "__main__":
    main()


#    def requirents(it: BoundServerType) -> bool:
#        if it.architecture != "x86":
#            return False
#
#        # it should have enough to compile large c++ projects
#        if it.cores <= 3:
#            return False
#
#        if it.disk <= 50:
#            return False
#
#        has_a_nice_location_from_delft = False
#        for loc in it.locations:
#            if loc.available and loc.location.name in ["hel1", "fsn1", "nbg1"]:
#                has_a_nice_location_from_delft = True
#
#        if not has_a_nice_location_from_delft:
#            return False
#
#        return True
#
#    filterd_types = list(filter(requirents, types))
