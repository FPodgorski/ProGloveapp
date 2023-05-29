import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "CDCommTest.js" as COMM

Dialog{
    id:addDialog
    property var utovarUID:""
    property var rampaID:""
    property var reqMsg:""
    property var newUid:""
    width: parent.width/2
    height: parent.height/1.2
    implicitHeight: 800
    implicitWidth: 600



    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    Rectangle{
        id:mainRect
        anchors.fill:parent
        color: "#111111"

        Text{
            id:bnpText
            text:"Broj naloga prijevoza:"
            color:"white"
            font.pointSize: 16
            anchors.top:parent.top
            anchors.left:parent.left
            anchors.topMargin: 25
            anchors.leftMargin: 25

        }

        TextField{
            id:bnpInput
            anchors.top:bnpText.bottom
            anchors.left:bnpText.left
            maximumLength: 60
            width:300
        }

        Text{
            id:nazivText
            text:"Naziv:"
            color:"white"
            font.pointSize: 16
            anchors.top:bnpInput.bottom
            anchors.left:parent.left
            anchors.leftMargin: 25
            anchors.topMargin: 15
        }

        TextField{
            id:nazivInput
            anchors.top:nazivText.bottom
            anchors.left:nazivText.left
            maximumLength: 128
            width:300
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
                objectName: "uidSearch"
                z:99

                tableName: "i_Tvrtke"
                sortColumnName: "Naziv"

                mainColor: highlightColor

                chooseAfilter: '[{"columnName":"Naziv", "label":"Prijevoznik"}]'
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
                objectName: "rampa321"
                z:99

                tableName: "OT_UTOVARNA_MJESTA"
                sortColumnName: "NAZIV"

                mainColor: highlightColor

                chooseAfilter: '[{"columnName":"NAZIV", "label":"Rampa"}]'
                labelFontSize: 32

                textEdit.font.pointSize: 32
                searchTable.headerHeight: 35

                onRowSelected: {
                    rampaID=selectedRow["ID"];
                }
            }
        }

        //         CDComboBox{
        //             id:utovarInput
        //             anchors.top:utovarText.bottom
        //             anchors.left:utovarText.left
        //             idleDelegateColor:"gray"
        //             z:100
        //             listModel:["1" , "2", "3"]

        //         }
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
        }
        CDDatePicker{
            id:date
            anchors.top:bnpInput.top
            anchors.right:parent.right
            anchors.rightMargin: 20
            txtHeader.color:"white"
            txtHeader.font.pixelSize: 16
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
                    const datum = date.getDate();
                    //const tekst ='{' +'"BR_NALOGA_PRIJEVOZA"' + ':"'+bnpInput.text + '",'+'"NAZIV"' +':"'+ nazivInput.text +'",'+ '"REG_OZN_VOZILA"' + ':"'+regInput.text +'",' + '"UID_PRIJEVOZNIKA"' + ':"'+uidInput.text + '",'+ '"ID_UTOVARNOG_MJESTA"' +':"'+ utovarInput.text + '",' +'"ODREDISTE"' +':"'+ odredisteInput.text +'",'+ '"DOC_DATE"' +':"'+ datum+'"' + '}';
                    var nes={}
                    nes["BR_NALOGA_PRIJEVOZA"]=bnpInput.text
                    nes["NAZIV"]=nazivInput.text
                    nes["REG_OZN_VOZILA"]=regInput.text
                    nes["UID_PRIJEVOZNIKA"]=utovarUID
                    nes["ID_UTOVARNOG_MJESTA"]=rampaID
                    nes["ODREDISTE"]=odredisteInput.text
                    nes["DOC_DATE"]=datum;
                    body=JSON.stringify(nes);
                    print("JSON"+body);
                    COMM.http_Request(null, "POST", "OT_NALOG_UTOVARA_M", "", body, resp_POST_OT_NALOG_UTOVARA_M);
                }
            }
            CDButton {
                height:75
                text: "Odustani"
                idleColConst:"red"
                onClick: {
                    addDialog.close();
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

    function clear(){
        bnpInput.text=""
        nazivInput.text=""
        regInput.text=""
        uidInput.resetData();
        utovarInput.resetData();
        utovarUID=""
        rampaID=""
        odredisteInput.text=""

    }

    //poziv dijagrama (40536) POST OT_NALOG_UTOVARA_M


    function resp_POST_OT_NALOG_UTOVARA_M(response)
    {
        var success = response["success"];
        var message = response["message"];
        var data = response["data"];

        if(success === true)
        {
            print("resp_POST_OT_NALOG_UTOVARA_M: " + JSON.stringify(data));
            addDialog.close();
            print(data["UID"]);
            newUid=data["UID"];

        }
        else
        {
            reqMsg=message;
            print("resp_POST_OT_NALOG_UTOVARA_M: " + message);
            msgDialog.open()
        }
    }
}
