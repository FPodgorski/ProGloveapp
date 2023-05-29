import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0
//import Qt5Compat.GraphicalEffects // 6.3

Item {
  id: root
  objectName: "root"
  height: 50
  width: 100

  //  Logic

  property int currentIndex: -1
  property string currentText: currentIndex >= 0 ? listModel[currentIndex] : ""
  property var listModel: []


  signal selectedChanged()
  signal selectedChangedByUser()
  signal modelChanged()

  property alias txtCurrentItem: txtCurrentItem
  property alias listView: listView

  // Public

  property int delegateHeight: 50
  property int radius: 5

  // UI

  property color dropDownMenuColor: "transparent"
  property color hoverColor: "gray"
  property color pressedColor: "lightgray"
  property color idleDelegateColor: "#444444"
  property color highlightColor: "dodgerblue"

  property color actHighlightColor: root.enabled ? highlightColor : "gray"

  property int animLength: 100
  property var easing: Easing.InQuad
  property int glowRadius: 2
  property int glowRadiusHighlight: 5
  property int selectionFontSize: 24
  property int listFontSize: 20


  property int minimumHeight: 200
  property int dropDownHeight: Math.min(listView.contentHeight, minimumHeight)


  function openDropDownMenu()
  {
    iListBox.height = listView.contentHeight;
  }

  function toggleDropDownMenu()
  {
    if(iListBox.height > 0)
    {
      jumpUpAnimation.start();
      animGlowUnHighlight.start();

    }

    else
    {
      dropDownAnimation.start();
      animGlowHighlight.start();

    }
  }

  // Outward methods

  function indexOfValue(val)
  {

    console.log("ComboBox indexOfValue called with vale = " + val);

    for(var i = 0; i < listModel.length; i++)
    {
      if(listModel[i] == val)
      {
        console.log("ComboBox indexOfValue found index = " + i);
        return i;
      }
    }
    console.log("ComboBox indexOfValue found nothing, returns -1");
    return -1
  }

  Item{
    id: iListBox
    anchors.top: rSelected.bottom
    anchors.topMargin: 1
    anchors.left: rSelected.left
    width: rSelected.width

    height: 0
    z: -2

    NumberAnimation on height { id: dropDownAnimation; to: root.dropDownHeight; duration: root.animLength; easing: Easing.InCurve; running: false}
    NumberAnimation on height { id: jumpUpAnimation; to: 0; duration: root.animLength / 2; easing: Easing.InCurve; running: false}

    clip: true

    Rectangle {
      id: rListBox
      anchors.fill: parent
      color: root.dropDownMenuColor


      Flickable {
        anchors.fill: parent
        boundsBehavior: Flickable.StopAtBounds



        ListView {
          id: listView
          model: root.listModel
          anchors.fill: parent
          boundsBehavior: Flickable.StopAtBounds

          ScrollBar.vertical: ScrollBar {
            active: true
          }

          spacing: 1

          delegate: Rectangle{
            id: rDelegate
            height: root.delegateHeight
            width: rListBox.width
            color: root.idleDelegateColor
            radius: 2
            property bool isPressed: false

            Text{
              id: listText
              text: root.listModel[index]
              anchors.fill: parent
              font.pixelSize: root.listFontSize

              color: "white"
              verticalAlignment: Text.AlignVCenter
              horizontalAlignment: Text.AlignLeft
              anchors.leftMargin: 15


              MouseArea{
                id: maDelegate
                hoverEnabled: true
                anchors.fill: parent

                onEntered: {
                  rDelegate.color = root.hoverColor
                }
                onExited: {
                  rDelegate.color = root.idleDelegateColor
                }

                onPressed: {
                  rDelegate.color = root.pressedColor
                }
                onReleased: {
                  root.currentIndex = index;
                  selectedChangedByUser(index);
                  root.toggleDropDownMenu();
                  rDelegate.color = root.idleDelegateColor;
                }
              }
            }
          }
        }
      }
    }
  }

  RectangularGlow {
    id: effect
    parent: rSelectedGlow
    anchors.fill: parent
    glowRadius: root.glowRadius
    spread: 0.5
    color: root.actHighlightColor
    cornerRadius: 5 + glowRadius
    visible: true
    z:2

    NumberAnimation on glowRadius { id: animGlowHighlight; from: effect.glowRadius; to: root.glowRadiusHighlight; duration: root.animLength; running: false;}
    NumberAnimation on glowRadius { id: animGlowUnHighlight; from: effect.glowRadius; to: root.glowRadius; duration: root.animLength; running: false;}
  }

  Rectangle {
    anchors.fill: parent
    color: "transparent"
    id: rSelectedGlow
    z: -1
  }

  Rectangle {

    id: rSelected
    anchors.fill: parent
    radius: root.radius
    color: "#222222"
    anchors.margins: 2

    gradient: Gradient {
      orientation: Gradient.Vertical
      GradientStop {
        position: 0
        color: "#333333"
      }

      GradientStop {
        position: 1
        color: "#222222"
      }
    }

    MouseArea {
      anchors.fill: parent
      onClicked: {
        root.toggleDropDownMenu()
      }
    }


    Text {
      id: txtCurrentItem
      text: root.currentText
      anchors.left: parent.left
      anchors.right: imDownArrow.left
      anchors.top: parent.top
      anchors.bottom: parent.bottom

      font.pixelSize: root.selectionFontSize
      color: "white"
      verticalAlignment: Text.AlignVCenter
      anchors.rightMargin: 0
      anchors.leftMargin: 15
      horizontalAlignment: Text.AlignLeft

      fontSizeMode: Text.Fit
      clip: true
    }

    Image {
      id: imDownArrow
      width: 12
      height: 12
      anchors.verticalCenter: parent.verticalCenter
      anchors.right: parent.right
      source: "../whiteTriangle.png"
      anchors.rightMargin: parent.height * 0.18
      fillMode: Image.PreserveAspectFit
      rotation: 180
    }
  }
}
