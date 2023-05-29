import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "CDCommTest.js" as COMM

Dialog{
    id:eDial
    property var name:""
    property var reg:""
    property var prijevoz:""
    property var utovar:""
    property var odr:""
    property var datum:""

    property alias uidInput:uidInput
    property alias utovarInput:utovarInput

    property var utovarUID:""
    property var rampaID:""
    property var rowUID:""
    property var editedStatus: ""

    property var reqMsg:""

    property var statMap:""


    property alias statField:statField
    property var stat: ""
    property var statName: ""
    property var colorMap:[]

    width: parent.width/2
    height: parent.height/1.2
//    implicitHeight: 800
//    implicitWidth: 600

    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    Rectangle{
        id:mainRect
        anchors.fill:parent
        color: "#111111"

        Text{
            id:nazivText
            text:"Naziv:"
            color:"white"
            font.pointSize: 16
            anchors.top:parent.top
            anchors.left:parent.left
            anchors.topMargin: 25
            anchors.leftMargin: 25
        }

        TextField{
            id:nazivInput
            anchors.top:nazivText.bottom
            anchors.left:nazivText.left
            maximumLength: 128
            width:300
            text:name
        }
        Text{
            id:regText
            text:"Registarska oznaka vozila:"
            color:"white"
            font.pointSize: 16
            anchors.top:nazivInput.bottom
            anchors.left:parent.left
            anchors.leftMargin: 25
            anchors.topMargin: 15
        }

        TextField{
            id:regInput
            anchors.top:regText.bottom
            anchors.left:regText.left
            maximumLength: 50
            width:300
            text:reg
        }

        Text{
            id:uidText
            text:"Prijevoznik:"
            color:"white"
            font.pointSize: 16
            anchors.top:regInput.bottom
            anchors.left:parent.left
            anchors.leftMargin: 25
            anchors.topMargin: 15
        }

        Item{
            id:uidWrap
            height:50
            width:200
            anchors.top:uidText.bottom
            anchors.left:uidText.left
            CDSearchTable_new{
                id:uidInput
                anchors.fill:parent
                objectName: "uidSearch123123"
                z:99

                tableName: "i_Tvrtke"
                //sortColumnName: "Naziv"

                mainColor: highlightColor

                chooseAfilter: '[{"columnName":"Naziv", "label":"Kupac"}]'
                filterParams: '{"Name" : "Sp", "Value" : "1", "Cond" : "="}'
                labelFontSize: 32

                textEdit.font.pointSize: 32
                searchTable.headerHeight:35

                onRowSelected: {
                    utovarUID=selectedRow["UID"];
                }
            }
        }

        Text{
            id:utovarText
            text:"Utovarno mjesto:"
            color:"white"
            font.pointSize: 16
            anchors.top:uidWrap.bottom
            anchors.left:parent.left
            anchors.leftMargin: 25
            anchors.topMargin: 15
        }

        Item{
            id:utovarWrap
            height:50
            width:200
            anchors.top:utovarText.bottom
            anchors.left:utovarText.left

            CDSearchTable_new{
                id:utovarInput
                anchors.fill:parent
                objectName: "rampa123"
                z:99

                tableName: "OT_UTOVARNA_MJESTA"
               //sortColumnName: "NAZIV"

                mainColor: highlightColor

               chooseAfilter: '[{"columnName":"NAZIV", "label":"Rampa"}]'
                labelFontSize: 32

                textEdit.font.pixelSize: 32
                searchTable.headerHeight: 35

                onRowSelected: {
                    rampaID=selectedRow["ID"];
                }
            }
        }
        Text{
            id:odredisteText
            text:"Odredište:"
            color:"white"
            font.pointSize: 16
            anchors.top:utovarWrap.bottom
            anchors.topMargin: 15
            anchors.left:parent.left
            anchors.leftMargin: 25
        }

        TextField{
            id:odredisteInput
            anchors.top:odredisteText.bottom
            anchors.left:odredisteText.left
            maximumLength: 50
            text:odr
        }
        Text{
            id:tekstStatus
            text:"Status:"
            color:"white"
            font.pointSize: 16
            anchors.top:odredisteInput.bottom
            anchors.topMargin: 15
            anchors.left:parent.left
            anchors.leftMargin: 25
        }

        TextField{
            id:statField
            anchors.top:tekstStatus.bottom
            anchors.left:tekstStatus.left
            readOnly: true
            onPressed:{
                tblDial.open()
            }
        }

        CDDatePicker{
            id:date
            anchors.top:nazivInput.top
            anchors.right:parent.right
            anchors.rightMargin: 20
            txtHeader.color:"white"
            txtHeader.font.pixelSize: 16
            // bDatePicker.txtText.text:calDate.selectedDate.toLocaleDateString(datum, "yyyy-MM-dd");

        }
        Row {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            leftPadding: parent.width/3
            height:mainRect.height*0.15
            spacing: 25
            CDButton {
                height:75
                text: "Potvrdi"
                idleColConst: "green"
                onClick: {
                    let datum1 = date.getDate();
                    var nes={}
                    nes["NAZIV"]=nazivInput.text
                    nes["REG_OZN_VOZILA"]=regInput.text
                    nes["UID_PRIJEVOZNIKA"]=utovarUID
                    nes["ID_UTOVARNOG_MJESTA"]=rampaID
                    nes["ODREDISTE"]=odredisteInput.text
                    nes["DOC_DATE"]=datum1;
                    nes["UID"]=rowUID;
                    nes["STATUS"]=stat;
                    body=JSON.stringify(nes)
                    print("edit je" + body);
                    COMM.http_Request(null, "PUT", "OT_NALOG_UTOVARA_M","", body, resp_PUT_OT_NALOG_UTOVARA_M);

                }
            }
            CDButton {
                text: "Odustani"
                height:75
                idleColConst:"red"
                onClick: {
                    eDial.close();
                }
            }
        }

        MessageDialog{
            id:msgDialog
            onOpened: {
                msgTxt=reqMsg;
                error();
            }
        }
    }

    Dialog{
        id:tblDial
        implicitHeight: 400
        implicitWidth: 400

        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        Rectangle{
            anchors.fill:parent
            color:"#111111"
            CDBTable{
                id: tableStat
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right:parent.right
                anchors.bottom:btn.top
                tableName: "SS_Status"
                constFilters:  [{"Name" : "GroupID", "Value" : "10", "Cond" : "="}]
                mColumnDefs:{
                    "StatusCode":{
                        "Width":50
                    },
                    "StatusMnemo":{
                        "DelegateChoice":"krug_mali"
                    },
                    "StatusName":{
                        "Width":100
                    },
                    "StatusDesc":{
                        "Width":150
                    },
                    "MsgText":{
                        "Visible":0
                    },
                    "LogTxt":{
                        "Visible":0
                    },
                    "LongText":{
                        "Visible":0
                    },
                    "ShortText":{
                        "Visible":0
                    },
                    "FontSettings":{
                        "Visible":0
                    },
                    "FontColor":{
                        "Visible":0
                    },
                    "BackColor":{
                        "Visible":0
                    },
                    "Icon":{
                        "Visible":0
                    },
                    "Image":{
                        "Visible":0
                    },
                    "Memo":{
                        "Visible":0
                    },
                    "GroupID":{
                        "Visible":0
                    },
                    "Status":{
                        "Visible":0
                    },
                    "DateTime":{
                        "Visible":0
                    },
                    "ID_OP":{
                        "Visible":0
                    },
                    "ID_Author":{
                        "Visible":0
                    },
                    "AuthorName":{
                        "Visible":0
                    },
                    "UID":{
                        "Visible":0
                    },
                    "ParentID":{
                        "Visible":0
                    },
                    "status_ext":{
                        "Visible":0
                    }
                }
                function krug_mali_colorProvider(row, column) {
                    var statTemp=tableStat.fieldByName(row,"StatusCode")
                    for(let i=0;i<colorMap.length;i++){
                        if(statTemp==colorMap[i]["STATUS"]){
                            return colorMap[i]["BackColor"];
                        }
                    }
                }
                onRowSelected: {
                    statName=fieldByName(selectedRow,"StatusName");
                    stat=fieldByName(selectedRow,"StatusCode");

                }
            }
            CDButton{
                id:btn
                anchors.bottom: parent.bottom
                anchors.left:parent.left
                anchors.leftMargin: (parent.width/2)-50
                anchors.bottomMargin: 15
                fontSize:20
                text:"Uredu"
                idleColConst:"green"
                width:100
                height: 50
                onClick: {
                    tblDial.close()
                    statField.text=statName
                }
            }
        }
    }

    Component.onCompleted:{


    }

    //poziv dijagrama (40537) PUT OT_NALOG_UTOVARA_M


    function resp_PUT_OT_NALOG_UTOVARA_M(response)
    {
        var success = response["success"];
        var message = response["message"];
        var data = response["data"];

        if(success === true)
        {
            print("resp_PUT_OT_NALOG_UTOVARA_M: succ" + JSON.stringify(data));
            eDial.close();
        }
        else
        {

            reqMsg=message;
            print("resp_PUT_OT_NALOG_UTOVARA_M: " + message);
            msgDialog.open();
            msgDialog.msgTimer.start();
        }
    }
}
