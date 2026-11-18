import QtQuick

Item {
    id: tg
    property string label
    property string hint
    property bool checked
    signal toggled
    width: parent?.width ?? 0
    height: 46
    Column {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2
        Txt { text: tg.label; font.pixelSize: 13 }
        Txt { text: tg.hint; color: Theme.fgDim; font.pixelSize: 11; visible: tg.hint.length > 0 }
    }
    Rectangle {
        id: sw
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 46; height: 26; radius: 13
        color: tg.checked ? Theme.accent : Theme.track
        Behavior on color { ColorAnimation { duration: 200 } }
        Rectangle {
            width: 20; height: 20; radius: 10
            anchors.verticalCenter: parent.verticalCenter
            x: tg.checked ? parent.width - width - 3 : 3
            color: tg.checked ? Theme.base : Theme.fg
            Behavior on x { NumberAnimation { duration: 260; easing.type: Easing.OutBack } }
        }
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: tg.toggled()
    }
}
