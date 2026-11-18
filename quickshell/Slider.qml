import QtQuick

Item {
    id: sl
    property string label
    property real from: 0
    property real to: 100
    property real value: 0
    property string suffix: ""
    property int decimals: 0
    signal moved(real v)
    width: parent?.width ?? 0
    height: 48
    Txt { anchors.left: parent.left; y: 2; text: sl.label; font.pixelSize: 13 }
    Txt {
        anchors.right: parent.right; y: 2
        text: sl.value.toFixed(sl.decimals) + sl.suffix
        color: Theme.accent
        font.bold: true
    }
    LevelBar {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 6
        height: 8
        interactive: true
        value: (sl.value - sl.from) / (sl.to - sl.from)
        onMoved: v => {
            const raw = sl.from + v * (sl.to - sl.from);
            const k = Math.pow(10, sl.decimals);
            sl.moved(Math.round(raw * k) / k);
        }
    }
}
