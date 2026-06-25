from hcloud import Client
from hcloud.images import Image
from hcloud.locations import Location

from cryptography.hazmat.primitives import serialization as crypto_serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.backends import default_backend as crypto_default_backend

import requests

import json
import os
from time import sleep
import subprocess
from pathlib import Path

# MAKE SURE THE DIRACTORY IS ONLY READABLE BY THIS PROGRAM BY FOR INSTANCE RUNNING IT AS A SYSTEMD SERVICE
private_storage = Path("/var/lib/ros2-vps-creator/")

install_script_root = (Path(os.path.abspath(__file__)) / "../../../../install_script").resolve()
distro_root = (Path(os.path.abspath(__file__)) / ".." / '..').resolve()


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


def pingSshIfPeerIsUp(
    ip: str,
    private_key_path: Path,
    user: str = "root"
):
    while True:
        res = subprocess.call(
            [
                "ssh",
                "-i", str(private_key_path),
                "-o", "StrictHostKeyChecking=accept-new",
                f"{user}@{ip}",
                "exit",
                "0",
            ]
        )

        if res == 0:
            return

        sleep(5)


def spinup(s_type: str,
           location: str,
           admin_password: str,
           guacamole_url_prefix: str,
           connection_user: str,
           connection_passwd: str):
    """
    Spinup a preconfigured vps

    parameters:
     - str s_type: the server type which determains if has shared resources or
        not. if it has 4 or 8 gb or ram. And other specs of the vps.
     - str location: which data center the vps is located:

    """

    id_file = (private_storage / "current_id")
    vm_id = int(readContensOfFile(id_file)) + 1
    replaceFile(id_file, (str(vm_id)))

    vm_name = "vpsGeneratorInstance" + str(vm_id)
    vm_dir = private_storage / vm_name
    vm_dir.mkdir()

    token = readContensOfFile(private_storage / "api_key").strip()
    client = Client(
            token=token,
            application_name="Default",
            application_version="v1.0.0" # what does this mean? Do you force me to use simver or is it a api
            )

    # machine
    selected_type = client.server_types.get_by_name(s_type)

    if selected_type is None:
        print("type not found")
        return

    selected_location = client.locations.get_by_name(location)

    if selected_location is None:
        print("location does not exist")
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

    # init script which 1) creates a account 2) installs ubuntu-desktop 3) setup gnome-remote-desktop
    cloud_init = readContensOfFile(distro_root / "cloud-init.yml")

    print("creating a server with id " + str(vm_id))
    server = client.servers.create(
        vm_name,
        selected_type,
        Image(name="ubuntu-24.04"),
        location=selected_location,
        ssh_keys=[key],
        user_data=cloud_init,
    )

    server.action.wait_until_finished()
    sleep(10)
    pingSshIfPeerIsUp(
            server.server.public_net.ipv4.ip,
            vm_dir/"id_rsa"
            )

    # upload and run install script
    dest = "root@"+server.server.public_net.ipv4.ip+":/opt/install"
    subprocess.call(['scp',
                     '-i', (vm_dir/"id_rsa").as_posix(),
                     '-o', 'StrictHostKeyChecking=accept-new',
                     "-r",
                     install_script_root.as_posix(),
                     dest
                     ])

    subprocess.call(['ssh',
                     '-i', (vm_dir/"id_rsa").as_posix(),
                     "root@"+server.server.public_net.ipv4.ip,
                     "--",
                     "systemd-run",
                     "--",
                     "bash",
                     "-c \"",
                     """
                     echo script loaded now waiting for cloud-init to finish
                     cloud-init status --wait
                     echo script has been started

                     printf pc_admin:"""+admin_password+""" | chpasswd
                     cat > /opt/askpass.sh <<EOD
                     echo -n """+admin_password+"""
EOD
                     grdctl --system rdp set-credentials """+connection_user+""" """+connection_passwd+"""
                     systemctl start gnome-remote-desktop

                     chmod o+rx /opt/askpass.sh
                     sudo --login --user=pc_admin bash -c ' cd /opt/install && bash process.bash'
                     cd ~
                     rm /opt/vm_askpass.sh
                     reboot
                     """,
                     "\""
                     ])

    # configuring webbrowser rdp viewer: guacamole

    # api doc found on a random github repo: ridvanaltun/guacamole-rest-api-documentation
    # source is in github apache/guacamole-client:/guacamole/src/main/java/org/apache/guacamole/rest/

    totp = input("guacamole totp: ")

    response = requests.post(guacamole_url_prefix+"/api/tokens",
                             data={
                                 "username": "guacadmin",
                                 "password": "guacadmin",
                                 "guac-totp": totp
                                 })
    response.raise_for_status()
    response_body = response.json()

    guacamole_connection = {
            "parentIdentifier": "ROOT",
            "name": vm_name,
            "protocol": "rdp",
            "parameters": {
                "hostname": server.server.public_net.ipv4.ip,
                "ignore-cert": True,
                "username": connection_user,
                "password": connection_passwd,
                "resize-method": "display-update",
                "normalize-clipboard": "preserve",
                },
            "attributes": {}
            }
    response = requests.post(guacamole_url_prefix+"/api/session/data/"+response_body["dataSource"]+"/connections",
                             headers={
                                 "guacamole-token": response_body["authToken"],
                                 "content-type": "application/json"
                                 },
                             data=json.dumps(guacamole_connection))

    response.raise_for_status()


if __name__ == "__main__":
    spinup(s_type="cpx32",
           location="nbg1",
           admin_password="still_testing",
           guacamole_url_prefix="https://guac.sysvion.nl",
           connection_user="ros2_vms",
           connection_passwd="patato_loving_queen_with_a_barrel_jack",
           )
