import QtQuick 2.0
import QtQuick.Controls 2.15

Item {

  id: root
  anchors.fill: parent

  property var m_model: [{"Label": "TestLabel", "Value" : "TestValue"}]
  property int delegateHeight: 125
  property int headerFontSize: 14
  property int valueFontSize: 32
  property int headerHeight: 30
  property bool bBackground: false

  property alias rBackground: rBackground
  property alias gridView: gridView


  Rectangle {
    id: rBackground
    anchors.fill: parent
    color: "transparent"
  }

  property int minImgDim: 250

  GridView {
    id: gridView
    anchors.fill: parent
    boundsBehavior: Flickable.StopAtBounds
    interactive: true
    clip: true

    model: m_model

    cellHeight: root.height / 2
    cellWidth: root.width / 2

    delegate: Item {
      height: gridView.cellHeight
      width: gridView.cellWidth

      CDTextField {
        anchors.fill: parent
        txtHeader.text:  m_model[index]["Label"]
        txtValue.text: m_model[index]["Value"]
        rHeader.height: root.headerHeight
        rValue.color: "transparent"

        txtValue.fontSizeMode: Text.Fit

        txtHeader.font.pixelSize: root.headerFontSize
        txtValue.font.pixelSize: root.valueFontSize
      }
    }
  }
}
