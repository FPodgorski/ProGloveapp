import QtQuick 2.0

// Fish kebobs

Item {
    id: root
    objectName: "root"
    width: 100
    height: 40
    focus: true

    signal click()
    property bool isClicked: false;
    property bool focusEnabled: true;

    onClick: {
      if(focusEnabled)
        root.forceActiveFocus()
    }

    states: [
      State {
        id: mobileState
        name: "mobileState"
        when: cb.platform == "mobile"
        PropertyChanges {
          target: root;
          fontSize: 30
        }
      },
      State {
        id: mobile90State
        name: "mobile90State"
        when: cb.platform == "mobile90"
        PropertyChanges {
          target: root;
          fontSize: 24
        }
      }
    ]

    property string text: "Button";

    property bool bGradient: true
    property int cornerRad: 5;
    property int borderWidth: 3
    property int fontSize: 14

    property color idleCol: idleColConst;
    property color clickedCol: "gray";
    property color fontColor: "white"
    property color borderColor: "#CCCCCC"
    property color idleColConst: "#222222"
    property color hoverColor: "#bbbbbb"

    property alias mouseArea: mouseArea
    property alias txtText: txtText
    property alias rBg: rBg
    property alias rGradient: rGradient

    Rectangle {
        id: rBg
        color: {
          if(root.isClicked)
            return clickedCol;
          else{
            if(root.enabled)
              return idleCol;
            else
              return "gray";
          }
        }

        border.color: root.borderColor
        border.width: root.borderWidth
        anchors.fill: parent
        radius: root.cornerRad
        clip: true

        Text {
          id: fakeText
          anchors.fill: parent
          color: "transparent"
          font.pixelSize: root.fontSize
          wrapMode: Text.WordWrap

          text: root.text

        }

        Text {
            id: txtText
            z: 1
            color: root.fontColor
            text: root.text
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.fill: parent
            anchors.margins: Math.min(parent.width, parent.height) * 0.15

            fontSizeMode: Text.Fit
            font.pixelSize: root.fontSize
            elide: Text.ElideRight

            MouseArea {
                id: mouseArea
                objectName: "mouseArea"
                anchors.fill: parent
                hoverEnabled: true

                onClicked: {click();}
                onPressed: {root.isClicked = !root.isClicked;}
                onReleased: {root.isClicked = !root.isClicked;}
                onEntered:  {
//                  root.idleCol = hoverColor;
                  rHoverMask.visible = true;
                }
                onExited: {
//                  root.idleCol = idleColConst;
                  rHoverMask.visible = false;
                }
            }
        }

        Rectangle {
            id: rGradient
            z: 0
            radius: root.cornerRad

            gradient: Gradient {

                GradientStop {
                    position: 0
                    color: bGradient ? "#44ffffff": "#00ffffff"
                }

                GradientStop {
                    position: 1
                    color: bGradient ? "#44000000" : "#00000000"
                }
            }
            anchors.fill: parent


            Rectangle{
              id: rHoverMask
              anchors.fill: parent
              radius: root.cornerRad
              visible: false

              color: "#44FFFFFF"
            }
        }
    }
}
