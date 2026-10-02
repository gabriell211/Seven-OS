import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: root
    width: 790
    height: 580
    visible: true
    title: "Configurações"
    color: "#071021"

    Rectangle {
        anchors.fill: parent
        color: "#071021"
        border.width: 1
        border.color: "#285b9b"
        radius: 10
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 190
            Layout.fillHeight: true
            radius: 12
            color: "#0c172b"
            border.width: 1
            border.color: "#20385f"

            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 6

                Text {
                    text: "Configurações"
                    color: "#ffffff"
                    font.pixelSize: 18
                    font.bold: true
                    bottomPadding: 8
                }

                Repeater {
                    model: ["Sistema", "Tela", "Som", "Rede e Internet", "Aplicativos", "Privacidade", "Atualizações", "Sobre"]

                    Rectangle {
                        required property string modelData
                        required property int index
                        width: parent.width
                        height: 40
                        radius: 8
                        color: index === 0 ? "#155ee9" : "#101d35"

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            text: modelData
                            color: "#edf4ff"
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: content.implicitHeight
            clip: true

            Column {
                id: content
                width: parent.width
                spacing: 12

                Text {
                    text: "Sistema"
                    color: "#ffffff"
                    font.pixelSize: 22
                    font.bold: true
                }

                Rectangle {
                    width: parent.width
                    height: 125
                    radius: 12
                    color: "#0e1a31"
                    border.width: 1
                    border.color: "#203b67"

                    Column {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 8

                        Text { text: SevenSystem.osName; color: "#ffffff"; font.pixelSize: 18; font.bold: true }
                        Text { text: "Host: " + SevenSystem.hostname; color: "#a9bbd8"; font.pixelSize: 12 }
                        Text { text: "Kernel: " + SevenSystem.kernel; color: "#a9bbd8"; font.pixelSize: 12 }
                        Text { text: "Tempo ligado: " + SevenSystem.uptime; color: "#73b8ff"; font.pixelSize: 11 }
                    }
                }

                Repeater {
                    model: [
                        ["Tela", "Wayland / Seven Desktop ativo"],
                        ["Compatibilidade Windows", SevenSystem.windowsRuntimeAvailable ? "Wine 11 disponível • Win32/Win64" : "Runtime indisponível"],
                        ["Segurança", "NTSYNC e isolamento do Seven Kernel"],
                        ["Atualizações", "Canal Developer Preview"]
                    ]

                    Rectangle {
                        required property var modelData
                        width: parent.width
                        height: 66
                        radius: 11
                        color: "#0c172b"
                        border.width: 1
                        border.color: "#1f365d"

                        Column {
                            anchors.left: parent.left
                            anchors.leftMargin: 14
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4
                            Text { text: modelData[0]; color: "#ffffff"; font.pixelSize: 13; font.bold: true }
                            Text { text: modelData[1]; color: "#8ea4c6"; font.pixelSize: 11 }
                        }
                    }
                }

                Row {
                    spacing: 10

                    Button {
                        text: "Reiniciar"
                        onClicked: SevenSystem.reboot()
                    }

                    Button {
                        text: "Desligar"
                        onClicked: SevenSystem.powerOff()
                    }
                }
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: SevenSystem.refresh()
    }
}
