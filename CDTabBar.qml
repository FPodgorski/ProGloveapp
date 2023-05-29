import QtQuick 2.12
//import QtQuick.Controls 1.4
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
//import QtCharts 2.15

Item {
  id: root;
  objectName: "root"
  implicitWidth: 1024
  implicitHeight: 768
//  anchors.fill: parent;

  property int nrButtons: btnTexts.length
  property int selected: 0
  property var tabLayout
  property var comboSwitch

  property var btnTexts
  btnTexts: ["asdf", "asdasdf"]
  property alias rep: btnRepeater


  property var selectedColors: []
  property bool singleColor: true;

  property var staticTexts: []


  property color selectedColor: "white"
  property color unselectedColor: "gray"
  property color disabledColor: "#222222"
  property color borderColor: "white"


  property color fontColorSelected: "white"
  property color fontColorUnselected: "black"
  property color fontColorDisabled: "white"

  property int fontSize: 18


  property int borderWidth: 3



  function disableButton(index)
  {
    btnRepeater.update();
    btnRepeater.itemAt(index).enabled = false;
  }

  function switchTabByIndex(index)
  {
    selected = index;
    tabLayout.currentIndex = index;
  }

  function switchTab(arg)
  {
    for(var i = 0; i < btnTexts.length; i++)
    {
      if(btnTexts[i] == arg)
        {
          selected = i;
        }
    }

    for(var i = 0; i < btnTexts.length; i++)
    {
      if(btnTexts[i] == arg)
        {
          tabLayout.currentIndex = i;
        }
    }

  }

  Row {
    height: parent.height
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    spacing: -2

    Repeater{
      id: btnRepeater
      model: nrButtons

      CDButton {
        width: (parent.width + (nrButtons - 1) * 2) / nrButtons
        height: parent.height
//        objectName: "button" + index
        idleCol: root.selected === model.index ? (root.singleColor ? selectedColor : selectedColors[index]) : (enabled ? unselectedColor : disabledColor)
        txtText.color: root.selected === model.index ? root.fontColorSelected : fontColorUnselected

        txtText.text: root.btnTexts[index]
//        txtText.text: cb.translationMap[root.btnTexts[index]]


        mouseArea.onClicked:{
          selected = index;
          tabLayout.currentIndex = index;
//          comboSwitch.currentIndex = index;
        }

        enabled: true
        cornerRad: 4
        rBg.border.width: root.borderWidth
        rBg.border.color: root.borderColor


        txtText.font.pixelSize: root.fontSize

//        rGradient.visible: false

      }
    }
  }
}
