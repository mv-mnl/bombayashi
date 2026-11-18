import QtQuick

// Fila de lista con hover, estado activo y entrada escalonada (por índice)
Rectangle {
    id: row
    property string icon
    property string title
    property string subtitle
    property string trailing
    property bool active: false
    property bool busy: false
    property int index: 0
    property bool animate: true
    default property alias extra: extraCol.data
    signal clicked
    signal secondary

    width: parent?.width ?? 0
    height: 50 + extraCol.implicitHeight
    radius: 15
    color: active ? Theme.alpha(Theme.accent, 0.14) : ma.containsMouse ? Theme.bgAlt : "transparent"
    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

    // Entrada escalonada
    opacity: 0
    transform: Translate { id: slide; x: 18 }
    Component.onCompleted: if (animate) appear.start(); else { opacity = 1; slide.x = 0 }
    SequentialAnimation {
        id: appear
        PauseAnimation { duration: Math.min(row.index, 12) * 28 }
        ParallelAnimation {
            NumberAnimation { target: row; property: "opacity"; to: 1; duration: 260 }
            NumberAnimation { target: slide; property: "x"; to: 0; duration: 380; easing.type: Easing.OutBack }
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: e => e.button === Qt.RightButton ? row.secondary() : row.clicked()
    }

    Item {
        id: line
        width: parent.width
        height: 50

        Txt {
            id: ic
            x: 14
            anchors.verticalCenter: parent.verticalCenter
            width: 22
            text: row.icon
            font.pixelSize: 17
            color: row.active ? Theme.accent : Theme.fg
            horizontalAlignment: Text.AlignHCenter
            RotationAnimation on rotation {
                running: row.busy
                from: 0; to: 360; duration: 1000
                loops: Animation.Infinite
                onRunningChanged: if (!running) ic.rotation = 0
            }
        }
        Column {
            anchors.left: ic.right
            anchors.leftMargin: 12
            anchors.right: trail.left
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1
            Txt { width: parent.width; text: row.title; font.bold: row.active }
            Txt { width: parent.width; text: row.subtitle; color: Theme.fgDim; font.pixelSize: 10; visible: text.length > 0 }
        }
        Txt {
            id: trail
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            text: row.trailing
            color: row.active ? Theme.accent : Theme.fgDim
            font.pixelSize: 11
        }
    }

    Column {
        id: extraCol
        y: 50
        x: 14
        width: parent.width - 28
    }
}
