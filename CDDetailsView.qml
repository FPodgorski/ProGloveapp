import QtQuick 2.0
import QtQuick.Controls 2.15

Item {

  id: root
  anchors.fill: parent

  property int delegateHeight: 125
  property var m_model: [{"Label" : "Test label", "Value" :  "TestValue"}, {"Label" : "Test label", "Value" :  "TestValue"},{"Label" : "Test label", "Value" :  "TestValue"},]


  property int headerFontSize: 14
  property int valueFontSize: 32

  property int headerHeight: 30
  property bool bBackground: false

  property alias rBackground: rBackground


  Rectangle{
    id: rBackground
    anchors.fill: parent
    color: "transparent"
  }


  Flickable {
    anchors.fill: parent
    contentHeight: root.m_model.length * root.delegateHeight

    Repeater {
      model: root.m_model


      delegate: Item {

        height: root.delegateHeight
        width: root.width
        y: index * root.delegateHeight


        CDTextField {
          anchors.fill: parent
          txtHeader.text:  m_model[index]["Label"]
          txtValue.text: m_model[index]["Value"]

          rHeader.height: root.headerHeight

          rValue.color: "transparent"


          txtHeader.font.pixelSize: root.headerFontSize
          txtValue.font.pixelSize: root.valueFontSize
        }
      }
    }
  }
}
