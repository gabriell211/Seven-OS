import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: page

    property string currentPath: SevenApp.homePath
    property var entries: SevenApp.listDirectory(currentPath)

    function reload() {
        entries = SevenApp.listDirectory(currentPath)
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Button {
                text: "⌂"
                ToolTip.text: "Pasta pessoal"
                ToolTip.visible: hovered
                onClicked: {
                    page.currentPath = SevenApp.homePath
                    page.reload()
                }
            }

            Button {
                text: "←"
                ToolTip.text: "Voltar uma pasta"
                ToolTip.visible: hovered
                onClicked: {
                    page.currentPath = SevenApp.parentDirectory(page.currentPath)
                    page.reload()
                }
            }

            TextField {
                id: pathField
                Layout.fillWidth: true
                text: page.currentPath
                selectByMouse: true
                onAccepted: {
                    page.currentPath = text
                    page.reload()
                }
            }

            Button {
                text: "Ir"
                onClicked: {
                    page.currentPath = pathField.text
                    page.reload()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#312640"
        }

        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 4
            model: page.entries

            ScrollBar.vertical: ScrollBar {}

            delegate: Rectangle {
                required property var modelData
                width: list.width
                height: 52
                radius: 10
                color: mouse.containsMouse ? "#2b2239" : "#17131f"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 12

                    Rectangle {
                        width: 34
                        height: 34
                        radius: 9
                        color: modelData.directory ? "#49336a" : "#28314a"

                        Text {
                            anchors.centerIn: parent
                            text: modelData.directory ? "▰" :
                                  modelData.suffix === "exe" || modelData.suffix === "msi" ? "⊞" : "▪"
                            color: modelData.directory ? "#d2b5ff" :
                                   modelData.suffix === "exe" || modelData.suffix === "msi" ? "#73baff" : "#c4bdd0"
                            font.pixelSize: 18
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Label {
                            Layout.fillWidth: true
                            text: modelData.name
                            color: "#f5f0fa"
                            elide: Text.ElideRight
                            font.pixelSize: 13
                        }

                        Label {
                            text: modelData.directory
                                ? "Pasta"
                                : modelData.suffix === "exe" ? "Aplicativo Windows"
                                : modelData.suffix === "msi" ? "Instalador Windows"
                                : Math.max(0, modelData.size) + " bytes"
                            color: "#91889d"
                            font.pixelSize: 10
                        }
                    }

                    Label {
                        visible: modelData.suffix === "exe" || modelData.suffix === "msi"
                        text: modelData.suffix === "msi" ? "Instalar" : "Executar"
                        color: "#77bcff"
                        font.pixelSize: 11
                    }
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton

                    onDoubleClicked: {
                        if (modelData.directory) {
                            page.currentPath = modelData.path
                            page.reload()
                            return
                        }

                        SevenApp.openEntry(modelData.path)
                    }
                }
            }

            Label {
                anchors.centerIn: parent
                visible: list.count === 0
                text: "Esta pasta está vazia."
                color: "#8e8599"
            }
        }

        Label {
            Layout.fillWidth: true
            text: "Dica: dê duplo clique em .exe para executar e em .msi para instalar pelo Seven Windows Runtime."
            color: "#82778f"
            font.pixelSize: 10
            wrapMode: Text.Wrap
        }
    }
}
