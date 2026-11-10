import QtQuick

Text {
    required property var theme

    color: theme.onSurface
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 13
}
