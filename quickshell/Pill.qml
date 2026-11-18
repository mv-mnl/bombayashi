import QtQuick

// Contenedor redondeado de la barra
Rectangle {
    default property alias content: row.data
    property alias spacing: row.spacing

    implicitWidth: row.implicitWidth + Theme.s(16)
    implicitHeight: Theme.barHeight
    radius: height / 2
    color: Theme.bg
    border.color: Theme.border
    border.width: 1

    Behavior on color { ColorAnimation { duration: 300 } }
    Behavior on implicitWidth { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 2
    }
}
