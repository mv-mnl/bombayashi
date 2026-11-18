import QtQuick

// Texto clicable con animación al pasar el mouse
Item {
    id: chip

    property alias text: label.text
    property color color: Theme.fg
    property int size: Theme.barFont
    signal clicked
    signal rightClicked
    signal scrolled(int delta)

    implicitWidth: label.implicitWidth + Theme.s(12)
    implicitHeight: Theme.barHeight - 10

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Theme.accent
        opacity: area.containsMouse ? 0.1 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    Text {
        id: label
        anchors.centerIn: parent
        color: chip.color
        font.family: Theme.font
        font.pixelSize: chip.size
        scale: area.pressed ? 0.88 : area.containsMouse ? 1.06 : 1
        Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutBack } }
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: e => e.button === Qt.RightButton ? chip.rightClicked() : chip.clicked()
        onWheel: w => chip.scrolled(w.angleDelta.y)
    }
}
