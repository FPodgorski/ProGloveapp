import QtQuick 2.15

Item {
  id: root;
  implicitWidth: 1024
  implicitHeight: 50
  anchors.horizontalCenter: parent.horizontalCenter
  anchors.top: parent.top
  anchors.bottom: parent.bottom

  width: (nrButtons * defModWidth > parent.width) ? parent.width : nrButtons * defModWidth

  // --------------------- Colors

  property bool bCustomColors: false
  property var selectedColors: ({})

  property color buttonColor: "#222222"
  property color selectedColor: "#AAAAAA"
  property color borderHighlight: "dodgerblue"
  property color borderUnhighlight: "white"


  // --------------------- Logic

  property int nrButtons: 2
  property int selected: 0
  property var tabLayout
  property var comboSwitch
  property int defModWidth: 200
  property var btnTexts
  btnTexts: []
  property alias rep: btnRepeater

  property var staticTexts: []
  property bool showFirstModule: false

  Component.onCompleted: {
    //    if(!showFirstModule)
    //      tabLayout.currentIndex = -1;
    //    else
    //      tabLayout.currentIndex = 0;
  }

  function disableButton(index)
  {
    btnRepeater.update();
    btnRepeater.itemAt(index).enabled = false;
  }

  function switchTab(arg)
  {
    for(var i = 0; i < btnTexts.length; i++)
    {
      if(btnTexts[i] === arg)
      {
        selected = i;
      }
    }

    print("switchTab called with arg = " + arg);
    print("switchTab staticTexts = " + JSON.stringify(staticTexts));

    for(i = 0; i < staticTexts.length; i++)
    {
      if(staticTexts[i] === arg)
      {
        print("switchTab found it at index = " + i);
        tabLayout.currentIndex = i;
      }
    }
  }



  Row {
    anchors.fill: parent
    spacing: 0

    Repeater{
      id: btnRepeater
      model: nrButtons

      CDButton {
        id: rRepDelegate
        width: (defModWidth * nrButtons > root.width) ? parent.width / nrButtons : root.defModWidth
        height: parent.height
        idleCol: {
          if(!bCustomColors)
            return root.selected === model.index ? root.selectedColor : root.buttonColor;
          else
          {
            if(root.selected === model.index)
              return selectedColors[root.btnTexts[index]];
            else
              return root.buttonColor;
          }

        }
        txtText.color: root.selected === model.index ? "white" : "white"
        txtText.text: root.btnTexts[index]

        mouseArea.onClicked:{
          comboSwitch.currentIndex = comboSwitch.indexOfValue(txtText.text);
        }

        enabled: true
        cornerRad: 6
        txtText.font.pixelSize: 12
        rBg.border.width: 3
        rBg.border.color: {
          if(!bCustomColors)
            return root.selected === model.index ? root.borderHighlight : root.borderUnhighlight;
          else
          {
            if(root.selected === model.index)
              return Qt.darker(root.selectedColors[root.btnTexts[index]], 1.5);
            else
              return root.borderUnhighlight;
          }
        }

        property int dex: index


        CDButton {
          anchors.top: parent.top
          anchors.right: parent.right
          width: 15
          height: 15
          anchors.margins: 5

          //          Rectangle {
          //            anchors.fill: parent
          //            color: "red"
          //          }


          z: 1

          txtText.anchors.margins: 0
          txtText.text: "X"
          txtText.font.pixelSize: 25
          txtText.fontSizeMode: Text.Fit
          txtText.color: "red"
          rBg.color: "#00FFFFFF"
          rBg.border.width: 0
          rGradient.visible: false


          mouseArea.onClicked: {

            if(btnTexts.length === 1) // Jesam li sve zazvorio
            {
              btnTexts = [];
              tabLayout.currentIndex = -1;
              comboSwitch.currentIndex = -1;
              nrButtons = 0;
            }
            else
            {
              var switchDex = parent.dex - 1;
              if(switchDex < 0) switchDex = 0;

              console.log("btnTexts before splicing = " + btnTexts);

              btnTexts.splice(parent.dex, 1);


              console.log("btnTexts after splicing = " + btnTexts);

              if(parent.dex == selected)
              {
                console.log("Tab that's supposed to close was selected");

                comboSwitch.currentIndex = comboSwitch.indexOfValue(btnTexts[switchDex]);
              }
              else if(parent.dex < selected)
              {
                selected--;
              }


              widthChanger.target = parent;
              widthChanger.from = parent.width;
              widthChanger.start();

              //              nrButtons--;
            }
          }
        }
      }
    }
  }

  PropertyAnimation{
    id: widthChanger
    target: root
    property: "width"
    from: 0
    to: 0
    duration: 75
    onStopped: {
      nrButtons--;
    }
  }
}
