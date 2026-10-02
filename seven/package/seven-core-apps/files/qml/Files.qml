import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: root
    width: 820
    height: 570
    visible: true
    title: "Arquivos"
    color: "#071021"

    Rectangle {
        anchors.fill: parent
        color: "#071021"
        border.width: 1
        border.color: "#285b9b"
        radius: 10
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Button { text: "⌂"; onClicked: SevenFiles.home() }
            Button { text: "↑"; onClicked: SevenFiles.up() }
            Button { text: "↻"; onClicked: SevenFiles.refresh() }

            Rectangle {
                Layout.fillWidth: true
                height: 38
                radius: 9
                color: "#111d35"
                border.width: 1
                border.color: "#263e68"

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    verticalAlignment: Text.AlignVCenter
                    text: SevenFiles.currentPath
                    color: "#d7e4fa"
                    elide: Text.ElideMiddle
                }
            }
        }

        GridView {
            id: grid
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: SevenFiles
            cellWidth: 145
            cellHeight: 105
            clip: true

            delegate: Rectangle {
                required property int index
                required property string name
                required property bool isDirectory
                required property string extension

                width: 132
                height: 94
                radius: 12
                color: mouse.containsMouse ? "#172849" : "#0d182d"
                border.width: 1
                border.color: mouse.containsMouse ? "#287dff" : "#1e3154"

                Column {
                    anchors.centerIn: parent
                    spacing: 7

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: isDirectory ? "▰" : extension === "exe" || extension === "msi" ? "▣" : "◆"
                        color: isDirectory ? "#9b62ff" : extension === "exe" || extension === "msi" ? "#45a8ff" : "#b8c6de"
                        font.pixelSize: 28
                    }

                    Text {
                        width: 110
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: name
                        color: "#f2f6ff"
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideMiddle
                    }
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onDoubleClicked: SevenFiles.activate(index)
                }
            }
        }
    }

    Connections {
        target: SevenFiles
        function onError(message) {
            errorText.text = message
            errorToast.visible = true
            hideError.restart()
        }
    }

    Rectangle {
        id: errorToast
        visible: false
        width: Math.min(parent.width - 40, 460)
        height: 46
        radius: 10
        color: "#d3182540"
        border.width: 1
        border.color: "#4b78b8"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18

        Text {
            id: errorText
            anchors.centerIn: parent
            width: parent.width - 24
            color: "#e2ecff"
            font.pixelSize: 11
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        Timer {
            id: hideError
            interval: 2600
            onTriggered: errorToast.visible = false
        }
    }
}
