import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Dialog {
    id:messageDialog
    property var msgTxt:""
    property alias msgTimer:msgTimer
    property alias timerTxt:timerTxt
    property int msgTimerInterval:5000
    property bool error:false
    property var showBtn:true
    property var txtSize:22
    property int countDown:0
    width:600
    height:500
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    z:99

    closePolicy: Popup.NoAutoClose
    contentItem:
    Rectangle{
        anchors.fill:parent
        color:"#111111"
        radius:15
        border.width:4
        border.color:error ? "red" : "dodgerblue"

        Image{
            z:200
            width:100
            height:100
            id:errPic
            source:"warning-svgrepo-com.svg"
            sourceSize.width: 100
            sourceSize.height: 100
            anchors.top:parent.top
            visible:error

        }
            Text {
                id:mesTex
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right:parent.right
                anchors.bottom:btn.top
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                anchors.leftMargin: 15
                anchors.rightMargin:15
                anchors.topMargin: 45
                width:parent.width
                color:if(error==false){"white"}else{"yellow"}
                wrapMode: Text.WordWrap
                font.pointSize:txtSize
                text: msgTxt

            }

        CDButton{
            id:btn
            visible: showBtn
            anchors.bottom: parent.bottom
            anchors.left:parent.left
            anchors.leftMargin: (parent.width/2)-50
            anchors.bottomMargin: 15
            fontSize:20
            text:"U redu"
            idleColConst:"green"
            width:100
            height: 50
            onClick: {
                messageDialog.close()
            }
        }
    }
    Timer{
        id:msgTimer
        interval:msgTimerInterval
        running: false;
        onTriggered: {
            messageDialog.close();
        }

    }
    Timer{
        id:timerTxt
        interval:1000
        running: true;
        repeat:true


    }
    function errorCut(){
        if(msgTxt.includes("[FireDAC][Phys][ODBC][Microsoft][SQL Server Native Client 11.0][SQL Server]")){
            msgTxt=msgTxt.replace("[FireDAC][Phys][ODBC][Microsoft][SQL Server Native Client 11.0][SQL Server]","")
        }
    }
}
