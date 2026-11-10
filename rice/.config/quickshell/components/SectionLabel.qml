import QtQuick

Text {
    id: root

    required property var theme
    property string text: ""

    color: theme.onSurfaceVariant
    font.family: theme.fontFamily
    font.pixelSize: theme.smallSize
    font.letterSpacing: 1.1
    font.capitalization: Font.AllUppercase
}
