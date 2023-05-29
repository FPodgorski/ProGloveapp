import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
  id: root
  width: 350
  height: 50

  // --------------------------------
  property alias textInput: textInput
  property alias textLabel: textLabel
  // --------------------------------
  property color highlightColor: "dodgerblue"
  property color baseColor: "white"
  property bool hasText: textInput.text != ""
  property string text: textInput.text  
  property string label: "Label"


  Text {
    id: textLabel
    width: 300
    color: baseColor
    text: root.label
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.bottom: parent.bottom
    verticalAlignment: TextInput.AlignVCenter
    horizontalAlignment: TextInput.AlignHCenter
    font.pixelSize: 36
  }

  TextField {
    id: textInput
    anchors.top: parent.top
    anchors.right: parent.right
    anchors.left: textLabel.right
    anchors.bottom: parent.bottom
    anchors.leftMargin: 25
    anchors.rightMargin: 25
    verticalAlignment: TextInput.AlignVCenter
    horizontalAlignment: TextInput.AlignHCenter

    font.pixelSize: 36
    color: baseColor

    background: Rectangle {
      anchors.fill: parent
      color: "transparent"
      border.color:"transparent"
    }

    Rectangle {
      anchors.top: parent.bottom
      anchors.topMargin: -15
      anchors.horizontalCenter: parent.horizontalCenter
      color: textInput.activeFocus ? highlightColor: Qt.darker(highlightColor, 1.5)
      radius: 5
      height: 5
      width: textInput.width-15
    }

    focus: true
    onAccepted: root.accept()
  }
}

