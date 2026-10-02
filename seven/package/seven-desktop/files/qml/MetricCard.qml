import QtQuick

GlassPanel {
    id: root

    property string title: ""
    property real value: 0
    property string suffix: "%"
    property color accent: "#25a7ff"

    implicitWidth: 82
    implicitHeight: 92
    radius: 12

    Column {
        anchors.centerIn: parent
        spacing: 6

        Rectangle {
            width: 50
            height: 6
            radius: 3
            color: "#17233f"

            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, root.value / 100))
                height: parent.height
                radius: 3
                color: root.accent
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Math.round(root.value) + root.suffix
            color: "#ffffff"
            font.pixelSize: 18
            font.bold: true
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.title
            color: "#aebbd4"
            font.pixelSize: 11
        }
    }
}
