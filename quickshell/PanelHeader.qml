import QtQuick

// Encabezado de panel: ícono grande + título + subtítulo + controles a la derecha
Item {
    id: head
    property string icon
    property string title
    property string subtitle
    property bool active: true
    default property alias trailing: trail.data

    width: parent?.width ?? 0
    height: 52

    Rectangle {
        id: badge
        width: 44; height: 44; radius: 15
        anchors.verticalCenter: parent.verticalCenter
        color: head.active ? Theme.accent : Theme.track
        Behavior on color { ColorAnimation { duration: 250 } }
        Txt {
            anchors.centerIn: parent
            text: head.icon
            font.pixelSize: 21
            color: head.active ? Theme.base : Theme.fgDim
        }
    }
    Column {
        anchors.left: badge.right
        anchors.leftMargin: 14
        anchors.right: trail.left
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2
        Txt { width: parent.width; text: head.title; font.pixelSize: 16; font.bold: true }
        Txt { width: parent.width; text: head.subtitle; color: Theme.fgDim; font.pixelSize: 11; visible: text.length > 0 }
    }
    Row {
        id: trail
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8
    }
}
