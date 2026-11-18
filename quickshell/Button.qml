import QtQuick

Rectangle {
    id: btn
    property string text
    property bool primary: false
    signal clicked
    implicitWidth: btnLabel.implicitWidth + 28
    height: 36
    radius: 18
    color: primary ? Theme.accent : (ba.containsMouse ? Theme.track : Theme.bgAlt)
    scale: ba.pressed ? 0.94 : 1
    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
    Txt {
        id: btnLabel
        anchors.centerIn: parent
        text: btn.text
        color: btn.primary ? Theme.base : Theme.fg
        font.bold: btn.primary
    }
    MouseArea {
        id: ba
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.clicked()
    }
}
