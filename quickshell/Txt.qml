import QtQuick

// Texto con la fuente y colores del tema
Text {
    color: Theme.fg
    font.family: Theme.font
    font.pixelSize: Theme.fontSize
    elide: Text.ElideRight
    verticalAlignment: Text.AlignVCenter
}
