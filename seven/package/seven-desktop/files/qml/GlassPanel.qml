import QtQuick

Rectangle {
    id: panel

    property color borderGlow: "#2877ff"
    property real glowOpacity: 0.45

    color: "#cc071125"
    radius: 16
    border.width: 1
    border.color: Qt.rgba(0.20, 0.48, 1.0, glowOpacity)
}
