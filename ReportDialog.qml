import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "CDCommTest.js" as COMM

Dialog{
    id:reportDialog
    property var uid:""
    property var jsonLength:""
    property var jsonValue:""
    property var reqMsg:""

    width: parent.width-300
    height:parent.height-200
    //    implicitHeight: 800
    //    implicitWidth: 1200

    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    Rectangle{
        id:mainRec
        anchors.fill:parent
        color: "#111111"

        Row{
            id:headerRow
            anchors.top:parent.top
            anchors.left:parent.left
            anchors.right:parent.right
            height:100
            Rectangle{
                //width:100
                width:parent.width*0.1
                height:100
                color:"#111111"
                Text{
                    anchors.centerIn: parent
                    font.pointSize: 20
                    color:"white"
                    text:"Br."
                }
            }
            Rectangle{
                //width:500
                width:parent.width*0.3
                height:100
                color:"#111111"
                Text{
                    anchors.centerIn: parent
                    font.pointSize: 20
                    color:"white"
                    text:"Opis"
                }
            }
            Rectangle{
                //width:200
                width:parent.width*0.2
                height:100
                color:"#111111"
                Text{
                    anchors.centerIn: parent
                    font.pointSize: 20
                    color:"white"
                    text:"OK - Nesukl."
                }
            }
            Rectangle{
                //width:350
                width:parent.width*0.4
                height:100
                color:"#111111"
                Text{
                    anchors.centerIn: parent
                    font.pointSize: 20
                    color:"white"
                    text:"Napomena"
                }
            }
        }

        ScrollView{
            id:scroll
            anchors.top:headerRow.bottom
            anchors.left:parent.left
            anchors.right:parent.right
            anchors.bottom:footer.top
            clip: true
            Column{

                Repeater{
                    id:repeat
                    anchors.fill:parent
                    model:jsonLength
                    delegate:
                        Row{
                        height:150
                        property var napomenaText:""
                        property var itemUID:jsonValue[index]["UID"]
                        property var uskladeno:if(rad1.checked==true){"true"}else{"false"}
                        Rectangle{
                            //width:100
                            width:mainRec.width*0.1
                            height:150
                            color:"#111111"
                            border.color:"white"
                            border.width:2
                            Text{
                                anchors.centerIn: parent
                                font.pointSize: 20
                                color:"white"
                                text:jsonValue[index]["REDNI_BROJ"]
                            }
                        }
                        Rectangle{
                            //width:500
                            width:mainRec.width*0.3
                            height:150
                            color:"#111111"
                            border.color:"white"
                            border.width:2
                            Text{
                                leftPadding: 15
                                rightPadding: 15
                                anchors.centerIn: parent
                                font.pointSize: 14
                                width:mainRec.width*0.3
                                fontSizeMode: Text.Fit
                                wrapMode: Text.WordWrap
                                color:"white"
                                text:jsonValue[index]["OPIS"]
                            }
                        }
                        Rectangle{
                            //width:200
                            width:mainRec.width*0.2
                            height:150
                            color:"#111111"
                            border.color:"white"
                            border.width:2
                            Row{
                                anchors.centerIn:parent
                                RadioButton {
                                    id:rad1
                                    text:"Ok"
                                    checked: if(jsonValue[index]["SUKLADNO"]==true){true}
                                    contentItem: Text {
                                        text: parent.text
                                        color: "white"
                                        font.pointSize:14
                                        verticalAlignment: Text.AlignVCenter
                                        leftPadding: parent.indicator.width + parent.spacing


                                    }
                                }
                                RadioButton {
                                    id:rad2
                                    text:"Nesukl."
                                    checked: if(jsonValue[index]["SUKLADNO"]==false){true}
                                    contentItem: Text {
                                        text: parent.text
                                        color: "white"
                                        font.pointSize:14
                                        verticalAlignment: Text.AlignVCenter
                                        leftPadding: parent.indicator.width + parent.spacing
                                    }
                                }
                            }
                        }
                        Rectangle{
                            //width:350
                            width:mainRec.width*0.4
                            height:150
                            color:"white"
                            border.color:"black"
                            border.width:2
                            TextArea{
                                id:napomena
                                text:jsonValue[index]["NAPOMENA"]
                                anchors.fill:parent
                                font.pointSize:14
                                wrapMode: Text.Wrap
                                onTextChanged:{
                                    napomenaText=text;
                                }
                            }
                        }
                    }
                }
            }
        }
        Row{
            anchors.right:parent.right
            anchors.top:parent.top
            CDButton {
                text: "X"
                fontSize:20
                idleColConst:"red"
                width:75
                height: 75
                onClick: {
                    reportDialog.close();
                }
            }
        }
        Rectangle{
            id:footer
            height: 75
            anchors.bottom:parent.bottom
            anchors.left:parent.left
            anchors.right:parent.right
            color:"#111111"
            CDButton{
                anchors.centerIn: parent
                fontSize:20
                text:"Potvrdi"
                idleColConst:"green"
                width:150
                height: 75
                enabled:checkiran()
                onClick: {
                    var nes={}
                    var item=""
                    var body=[]
                    for(let i=0;i<jsonLength;i++){
                        nes["NAPOMENA"]=repeat.itemAt(i).napomenaText;
                        nes["UID"]=repeat.itemAt(i).itemUID;
                        if(repeat.itemAt(i).uskladeno=="true"){
                            nes["SUKLADNO"]=1
                        }else {
                            nes["SUKLADNO"]=0
                        }

                        // nes["SUKLADNO"]=repeat.itemAt(i).uskladeno
                        item=JSON.stringify(nes)
                        print("report je" + item);
                        body.push(item);

                    }
                    // body=JSON.stringify(nes)
                    print("report je" + body);
                    COMM.http_Request(null, "PUT", "OT_PREDLOZAK_UTOVARA","","[" + body + "]", resp_PUT_OT_PREDLOZAK_UTOVARA);

                }
            }

        }
        MessageDialog{
            id:msgDialog
            onOpened: {
                msgTxt=reqMsg;
            }
        }

    }
    //poziv dijagrama (40508) GET DynamicSelectfilterJSON


    function resp_GET_DynamicSelectfilterJSON(response)
    {
        var success = response["success"];
        var message = response["message"];
        var data = response["data"];

        if(success === true)
        {
            jsonValue=data
            jsonLength= Object.keys(data).length
            print("Report resp_GET_DynamicSelectfilterJSON: " + JSON.stringify(data) + jsonLength);

        }
        else
        {
            print("resp_GET_DynamicSelectfilterJSON: " + message);
        }
    }
    onOpened: {
        COMM.http_Request(null, "GET", "DynamicSelectfilterJSON","tableName=" + "OT_PREDLOZAK_UTOVARA" + '&filterParams=[{"Name":"UID_NALOG_UTOVARA_M","Value":'+'"'+uid+'"'+',"Cond":"="}]'   + "&orderBy=" + "REDNI_BROJ", "", resp_GET_DynamicSelectfilterJSON);
        scroll.flickableItem.contentY=0;
    }
    //poziv dijagrama (40561) PUT OT_PREDLOZAK_UTOVARA


    function resp_PUT_OT_PREDLOZAK_UTOVARA(response)
    {
        var success = response["success"];
        var message = response["message"];
        var data = response["data"];

        if(success === true)
        {
            print("resp_PUT_OT_PREDLOZAK_UTOVARA: " + JSON.stringify(data));
            reportDialog.close();
        }
        else
        {
            print("resp_PUT_OT_PREDLOZAK_UTOVARA: " + message);
            reqMsg=message;
            msgDialog.open();
        }
    }


}

