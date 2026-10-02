import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: window

    width: SevenApp.mode === "files" ? 1120 : 920
    height: SevenApp.mode === "files" ? 760 : 640
    minimumWidth: 720
    minimumHeight: 480
    visible: true
    title: SevenApp.title
    color: "#100d18"

    palette.window: "#100d18"
    palette.windowText: "#f4effa"
    palette.base: "#17131f"
    palette.text: "#f4effa"
    palette.button: "#2a2139"
    palette.buttonText: "#f4effa"
    palette.highlight: "#6d42b8"
    palette.highlightedText: "#ffffff"

    header: Rectangle {
        height: 58
        color: "#1d1728"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            spacing: 12

            Rectangle {
                width: 34
                height: 34
                radius: 10
                color: "#6d42b8"

                Text {
                    anchors.centerIn: parent
                    text: "7"
                    color: "white"
                    font.pixelSize: 22
                    font.bold: true
                }
            }

            ColumnLayout {
                spacing: 0

                Label {
                    text: SevenApp.title
                    color: "#ffffff"
                    font.pixelSize: 18
                    font.bold: true
                }

                Label {
                    text: "Seven OS"
                    color: "#9e94ac"
                    font.pixelSize: 10
                }
            }

            Item { Layout.fillWidth: true }

            Button {
                text: "Atualizar"
                onClicked: SevenApp.refresh()
            }
        }
    }

    Loader {
        anchors.fill: parent
        anchors.margins: 16
        sourceComponent: {
            switch (SevenApp.mode) {
            case "settings": return settingsPage
            case "store": return storePage
            case "monitor": return monitorPage
            default: return filesPage
            }
        }
    }

    Component { id: filesPage; FilesPage {} }
    Component { id: settingsPage; SettingsPage {} }
    Component { id: storePage; StorePage {} }
    Component { id: monitorPage; MonitorPage {} }

    Connections {
        target: SevenApp

        function onErrorOccurred(message) {
            errorLabel.text = message
            errorPopup.open()
        }
    }

    Popup {
        id: errorPopup
        anchors.centerIn: parent
        width: Math.min(520, window.width - 48)
        modal: true
        focus: true
        padding: 20

        background: Rectangle {
            color: "#251d31"
            radius: 14
            border.color: "#694c8b"
        }

        contentItem: ColumnLayout {
            spacing: 16

            Label {
                text: "Seven OS"
                color: "#ffffff"
                font.bold: true
                font.pixelSize: 18
            }

            Label {
                id: errorLabel
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                color: "#dcd4e6"
            }

            Button {
                Layout.alignment: Qt.AlignRight
                text: "Fechar"
                onClicked: errorPopup.close()
            }
        }
    }
}
