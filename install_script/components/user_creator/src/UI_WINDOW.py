# -*- coding: utf-8 -*-

################################################################################
## Form generated from reading UI file 'window.ui'
##
## Created by: Qt User Interface Compiler version 6.11.1
##
## WARNING! All changes made in this file will be lost when recompiling UI file!
################################################################################

from PySide6.QtCore import (QCoreApplication, QDate, QDateTime, QLocale,
    QMetaObject, QObject, QPoint, QRect,
    QSize, QTime, QUrl, Qt)
from PySide6.QtGui import (QBrush, QColor, QConicalGradient, QCursor,
    QFont, QFontDatabase, QGradient, QIcon,
    QImage, QKeySequence, QLinearGradient, QPainter,
    QPalette, QPixmap, QRadialGradient, QTransform)
from PySide6.QtWidgets import (QApplication, QCheckBox, QLabel, QLineEdit,
    QMainWindow, QMenuBar, QPushButton, QSizePolicy,
    QStatusBar, QVBoxLayout, QWidget)

class Ui_MainWindow(object):
    def setupUi(self, MainWindow):
        if not MainWindow.objectName():
            MainWindow.setObjectName(u"MainWindow")
        MainWindow.resize(800, 600)
        self.centralwidget = QWidget(MainWindow)
        self.centralwidget.setObjectName(u"centralwidget")
        self.createButton = QPushButton(self.centralwidget)
        self.createButton.setObjectName(u"createButton")
        self.createButton.setGeometry(QRect(270, 240, 96, 27))
        self.username_lineEdit = QLineEdit(self.centralwidget)
        self.username_lineEdit.setObjectName(u"username_lineEdit")
        self.username_lineEdit.setGeometry(QRect(60, 130, 113, 27))
        self.label = QLabel(self.centralwidget)
        self.label.setObjectName(u"label")
        self.label.setGeometry(QRect(60, 110, 70, 19))
        self.ros_domain_lineEdit = QLineEdit(self.centralwidget)
        self.ros_domain_lineEdit.setObjectName(u"ros_domain_lineEdit")
        self.ros_domain_lineEdit.setGeometry(QRect(60, 250, 113, 27))
        self.label_2 = QLabel(self.centralwidget)
        self.label_2.setObjectName(u"label_2")
        self.label_2.setGeometry(QRect(60, 230, 111, 19))
        self.password_lineEdit = QLineEdit(self.centralwidget)
        self.password_lineEdit.setObjectName(u"password_lineEdit")
        self.password_lineEdit.setGeometry(QRect(60, 190, 113, 27))
        self.label_4 = QLabel(self.centralwidget)
        self.label_4.setObjectName(u"label_4")
        self.label_4.setGeometry(QRect(60, 170, 70, 19))
        self.verticalLayoutWidget = QWidget(self.centralwidget)
        self.verticalLayoutWidget.setObjectName(u"verticalLayoutWidget")
        self.verticalLayoutWidget.setGeometry(QRect(270, 110, 160, 81))
        self.groups = QVBoxLayout(self.verticalLayoutWidget)
        self.groups.setObjectName(u"groups")
        self.groups.setContentsMargins(0, 0, 0, 0)
        self.label_3 = QLabel(self.verticalLayoutWidget)
        self.label_3.setObjectName(u"label_3")

        self.groups.addWidget(self.label_3)

        self.admin_checkbox = QCheckBox(self.verticalLayoutWidget)
        self.admin_checkbox.setObjectName(u"admin_checkbox")

        self.groups.addWidget(self.admin_checkbox)

        self.docker_checkbox = QCheckBox(self.verticalLayoutWidget)
        self.docker_checkbox.setObjectName(u"docker_checkbox")
        self.docker_checkbox.setChecked(True)

        self.groups.addWidget(self.docker_checkbox)

        MainWindow.setCentralWidget(self.centralwidget)
        self.menubar = QMenuBar(MainWindow)
        self.menubar.setObjectName(u"menubar")
        self.menubar.setGeometry(QRect(0, 0, 800, 24))
        MainWindow.setMenuBar(self.menubar)
        self.statusbar = QStatusBar(MainWindow)
        self.statusbar.setObjectName(u"statusbar")
        MainWindow.setStatusBar(self.statusbar)

        self.retranslateUi(MainWindow)

        QMetaObject.connectSlotsByName(MainWindow)
    # setupUi

    def retranslateUi(self, MainWindow):
        MainWindow.setWindowTitle(QCoreApplication.translate("MainWindow", u"MainWindow", None))
        self.createButton.setText(QCoreApplication.translate("MainWindow", u"create", None))
        self.label.setText(QCoreApplication.translate("MainWindow", u"username", None))
        self.ros_domain_lineEdit.setText(QCoreApplication.translate("MainWindow", u"2", None))
        self.label_2.setText(QCoreApplication.translate("MainWindow", u"ros domain id", None))
        self.label_4.setText(QCoreApplication.translate("MainWindow", u"password", None))
        self.label_3.setText(QCoreApplication.translate("MainWindow", u"groups", None))
        self.admin_checkbox.setText(QCoreApplication.translate("MainWindow", u"admin", None))
        self.docker_checkbox.setText(QCoreApplication.translate("MainWindow", u"docker", None))
    # retranslateUi

