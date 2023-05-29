import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0 // 5.15
//import Qt5Compat.GraphicalEffects // 6.3

Item {
  width: 100
  height: 50
  id: root

  property int animLength: 170
  property var easing: Easing.InQuad
  property int glowRadiusHighlight: 30
  property int glowRadiusUnhighlight: 10

  property color highlightColor: "dodgerblue"
  property color fillColor: "#222222"
  property int radius: 15
  property bool highlighted: false
  property bool autoHighlight: true

  signal click();

  property alias glowingRec: glowingRec;
  property alias iContainer: iContainer


  function toggleHighlight()
  {
    if(!highlighted)
      animGlowHighlight.start();
    else
      animGlowUnHighlight.start();

    highlighted = !highlighted;
  }

  Rectangle {
    id: glowingRec
    anchors.fill: parent
    radius: root.radius
    color: root.fillColor
    border.width: 4
    border.color: highlightColor

    Item {
      id: iContainer
      anchors.fill: parent
      anchors.margins: glowingRec.border.width

      layer.enabled: true
      layer.effect: OpacityMask {
        maskSource: rContainerMask
      }

      MouseArea{
        anchors.fill: parent
        onClicked: {
          root.click();

          if(root.autoHighlight)
            toggleHighlight();
        }
      }
    }
  }

  Glow {
    id: effect
    anchors.fill: glowingRec
    radius: root.glowRadiusUnhighlight
//    samples: 32
    spread: 0.25
    color: highlightColor
    source: glowingRec

    NumberAnimation on radius { id: animGlowHighlight; from: effect.radius; to: root.glowRadiusHighlight; duration: root.animLength; running: false;}
    NumberAnimation on radius { id: animGlowUnHighlight; from: effect.radius; to: root.glowRadiusUnhighlight; duration: root.animLength; running: false;}
  }

  Rectangle {
    id: rContainerMask
    width: iContainer.width
    height: iContainer.height
    radius: glowingRec.radius - glowingRec.border.width
    visible: false
  }
}
