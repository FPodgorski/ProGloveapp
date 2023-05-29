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
    property var regOzn:""

    property var regOznText: ""

    signal accepted()
    signal register()

    width: parent.width-300
    height:parent.height-200


    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    closePolicy: Popup.NoAutoClose

    Rectangle{
        id:mainRec
        anchors.fill:parent
        color: "#111111"

        /* Row{
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
        }*/

        Row{
            id:regRow
            anchors.top:mainRec.top
            anchors.left:mainRec.left
            anchors.right:mainRec.right
            height:100
            Rectangle{
                id:recc
                width:parent.width/2
                height:100
                color:"black"
                Text{
                    anchors.centerIn: parent
                    font.pointSize: 24
                    color:"white"
                    text:"Registarska oznaka vozila:"
                }
            }

            Rectangle{
                //width:350
                width:mainRec.width/2
                height:100
                color:"white"
                border.color:"black"
                border.width:2
                TextArea{
                    id:reOznTxt
                    text:regOznText
                    height:100
                    anchors.fill:parent
                    font.pointSize:26
                    wrapMode: Text.Wrap
                    color: "black"
                    verticalAlignment: TextEdit.AlignVCenter
                    horizontalAlignment: TextEdit.AlignHCenter
                    onTextChanged: {
                        regOznText=text
                        checkiran();
                    }
                }
            }
        }

        ScrollView{
            id:scroll
            anchors.top:regRow.bottom
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
                        Column{
                        property var uskladeno:if(rad1.checked==true){"true"}else{"false"}
                        property var coolchecked: if(rad1.checked==true || rad2.checked==true){"true"}else{"false"}
                        property var napomenaText:""
                        property var regOznText:""
                        property var itemUID:jsonValue[index]["UID"]
                        Row{
                            height:150
                            Rectangle{
                                //width:100
                                width:mainRec.width*0.1
                                height:150
                                color:"#111111"
                                border.color:"white"
                                border.width:2
                                Text{
                                    anchors.centerIn: parent
                                    font.pointSize: 24
                                    color:"white"
                                    text:jsonValue[index]["REDNI_BROJ"]
                                }
                            }
                            Rectangle{
                                //width:500
                                width:mainRec.width*0.9
                                height:150
                                color:"#111111"
                                border.color:"white"
                                border.width:2
                                Text{
                                    leftPadding: 15
                                    rightPadding: 15
                                    anchors.centerIn: parent
                                    font.pointSize: 24
                                    width:mainRec.width*0.9
                                    //fontSizeMode: Text.Fit
                                    wrapMode: Text.WordWrap
                                    color:"white"
                                    text:jsonValue[index]["OPIS"]
                                }
                            }
                        }
                        Row{
                            Rectangle{
                                //width:200
                                width:mainRec.width
                                height:150
                                color:"#111111"
                                border.color:"white"
                                border.width:2
                                Row{
                                    anchors.centerIn:parent
                                    RadioButton {
                                        id:rad1
                                        text:"Ok"
                                        checked: if(jsonValue[index]["SUKLADNO"]==1){true}else{false}
                                        contentItem: Text {
                                            text: parent.text
                                            color: "white"
                                            font.pointSize:24
                                            verticalAlignment: Text.AlignVCenter
                                            leftPadding: parent.indicator.width + parent.spacing


                                        }
                                        onClicked: {
                                            checkiran();
                                        }
                                    }
                                    RadioButton {
                                        id:rad2
                                        text:"Nesukladno"
                                        checked: if(jsonValue[index]["SUKLADNO"]==0){true}else{false}
                                        contentItem: Text {
                                            text: parent.text
                                            color: "white"
                                            font.pointSize:24
                                            verticalAlignment: Text.AlignVCenter
                                            leftPadding: parent.indicator.width + parent.spacing
                                        }
                                        onClicked: {
                                            checkiran();
                                        }
                                    }
                                }
                            }
                        }

                        Row{
                            Rectangle{
                                //width:350
                                width:mainRec.width
                                height:150
                                color:"white"
                                border.color:"black"
                                border.width:2
                                TextArea{
                                    id:napomena
                                    text:jsonValue[index]["NAPOMENA"]
                                    anchors.fill:parent
                                    font.pointSize:28
                                    wrapMode: Text.Wrap
                                    color: "black"
                                    onTextChanged:{
                                        napomenaText=text;
                                    }
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
                    checkiran();
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
                id:acceptBtn
                anchors.centerIn: parent
                fontSize:20
                text:"Potvrdi"
                idleColConst:"green"
                width:150
                height: 75
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
                    var chckBody={}
                    chckBody["UID"]=uid;
                    chckBody["IS_CHECKED"]="True";
                    print("KEKW1"+regOznText)
                    chckBody["REG_OZN_VOZILA"]=regOznText
                    chckBody=JSON.stringify(chckBody)
                    COMM.http_Request(null, "PUT", "OT_NALOG_UTOVARA_M","", chckBody, resp_PUT_OT_NALOG_UTOVARA_M);
                    accepted();
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
            checkiran();
        }
        else
        {
            print("resp_GET_DynamicSelectfilterJSON: " + message);
        }
    }
    onOpened: {
        register()
        COMM.http_Request(null, "GET", "DynamicSelectfilterJSON","tableName=" + "OT_PREDLOZAK_UTOVARA" + '&filterParams=[{"Name":"UID_NALOG_UTOVARA_M","Value":'+'"'+uid+'"'+',"Cond":"="}]'   + "&orderBy=" + "REDNI_BROJ", "", resp_GET_DynamicSelectfilterJSON);
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

    function checkiran(){
        for(let i=0;i<jsonLength;i++){
            if(repeat.itemAt(i).coolchecked=="true" && reOznTxt.text!=""){
                acceptBtn.enabled=true;

            }else {
                acceptBtn.enabled=false;
                break;
            }
        }
    }

    function resp_PUT_OT_NALOG_UTOVARA_M(response)
    {
        var success = response["success"];
        var message = response["message"];
        var data = response["data"];

        if(success === true)
        {
            print("resp_PUT_OT_NALOG_UTOVARA_M: " + JSON.stringify(data));

        }
        else
        {
            print("resp_PUT_OT_NALOG_UTOVARA_M: " + message);
        }
    }

}

