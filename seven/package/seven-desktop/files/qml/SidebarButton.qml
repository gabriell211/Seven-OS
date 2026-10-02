import QtQuick
import QtQuick.Controls

Button {
    id: control

    property string glyph: ""
    property bool selected: false

    implicitHeight: 44
    implicitWidth: 146

    background: Rectangle {
        radius: 9
        color: control.selected
            ? "#155ee9"
            : control.hovered
                ? "#152447"
                : "transparent"
        border.width: control.selected ? 1 : 0
        border.color: "#2993ff"
    }

    contentItem: Row {
        spacing: 12

        Text {
            width: 24
            text: control.glyph
            color: control.selected ? "#dff0ff" : "#8ebaff"
            font.pixelSize: 18
            horizontalAlignment: Text.AlignHCenter
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: control.text
            color: "#f3f7ff"
            font.pixelSize: 14
            elide: Text.ElideRight
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
