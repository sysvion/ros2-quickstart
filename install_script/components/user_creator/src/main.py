from PySide6.QtWidgets import QMainWindow, QApplication
from UI_WINDOW import Ui_MainWindow
import sys
import subprocess
import crypt
import time

class Window(QMainWindow):
    def __init__(self):
        QMainWindow.__init__(self)
        self.ui = Ui_MainWindow()
        self.ui.setupUi(self)
        self.ui.createButton.clicked.connect(self.create_account)

    def create_account(self, _):
        errors = []

        groups = ["users"]

        if self.ui.docker_checkbox.isChecked():
            groups.append("docker")

        if self.ui.admin_checkbox.isChecked():
            groups.append("admin")

        groupString = ""


        first = True
        for group in groups:
            if first:
                first = False
            else:
                groupString += ","

            groupString += group


        plaintext_passw = self.ui.password_lineEdit.text() 

        if plaintext_passw.strip() == "":
            errors.append("stripped password can not be \"\".")

        passw = crypt.crypt(plaintext_passw, crypt.mksalt(crypt.METHOD_SHA512))

        # WHY THE FUCK DOES ALL GENERATE PASSWORD FOR THE SHADOW FILE METHODS WORK AND I NEED TO USE CHPASSWD

        username = self.ui.username_lineEdit.text().strip() 
        if  username == "":
            errors.append("stripped username can not be \"\".")

        if len(errors) != 0:
            return
        

        subprocess.call([
            "sudo",
            "useradd",
            "--create-home",
            "--groups", groupString,
            "--skel", "/etc/skel",
            "--shell", "/usr/bin/bash",
            username
            ])
        
        subprocess.call([
            "bash",
            "-c",
            """
            echo '"""+username+""":"""+plaintext_passw+"""' | sudo chpasswd
            sudo tee /home/"""+username+"""/.profile <<EOF
# addad by acoount creation tool
export ROS_DOMAIN_ID="""+self.ui.ros_domain_lineEdit.text()+"""
source /opt/ros/jazzy/setup.bash
EOF
            """
        ])


def main():
    app = QApplication(sys.argv)
    window = Window()
    window.show()
    app.exec()


if __name__ == "__main__":
    main()
