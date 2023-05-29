import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "CDCommTest.js" as COMM


Item{
    id:root

    property var activeUid:""
    property var scanMsg:""

    property var registarskaOznaka:""

    property var selectedPath:""
    property var picturesPath:""
    property var m_imageModel: []
    property var palleteData:""
    property var palleteTypeCount:""
    property var picturesArray:[]
    property int galleryCounter:0
    property var ischecked:""
    property alias altTable:altTable
    property alias repDial:repDial
    property alias naloziTableDial:naloziTableDial
    property alias scanPicDial:scanPicDial


    property var hexImg:""
    property var imageID:""


    property var palleteType:""

    signal closeNalog()

    //    onActiveUidChanged: {
    //        print("classicTable.constFilters" + JSON.stringify(altTable.classicTable.constFilters))
    //        print("View uid"+activeUid);
    //        altTable.refreshTable();
    //        print("View uid"+activeUid);
    //        print("classicTable.constFilters" + JSON.stringify(altTable.classicTable.constFilters))

    //    }



    Rectangle{
        id:midWrap
        color:"transparent"
        anchors.top:parent.top
        anchors.left:parent.left
        anchors.right:parent.right
        anchors.bottom:bottomWrap.top


        CDAlternatingTable {
            id: altTable
            anchors.fill: parent
            tableName: "V_OT_NALOG_UTOVARA_D2"
            //"E4BCE658-5B9A-4313-AE2D-7084C75FE3EF"

            verticalHeaders:  ["SSCC", "VrstaPalete", "Operater"]
            classicTable.constFilters: [{"Name" : "UID_NALOGA_UTOVARA_M", "Value" : activeUid, "Cond" : "="}]
            verticalDetails: ["CREATED_AT", "UPDATED_AT"]
            classicTable.sortColumn: "UPDATED_AT"
            classicTable.sortOrder: "desc"

            classicTable.visible: false
            verticalTable.visible: true
            verticalTable.detailsHeight: verticalTable.detailGridHeight + 75
            verticalTable.maDetailsEnabled: true
            verticalTable.headerColumnWidths: [width * 0.25, width*0.25, width*0.5]

            verticalTable.onRowPressAndHold: {
                menuDial.open()
            }
            onTableRefreshed: {
               // requestLoadImages();
            }




            //              verticalTable.onRowExpanded:{
            ////                  selectedPath=altTable.fieldByName(selectedRow,"Images");
            ////                  selectedPath=JSON.parse(selectedPath)
            ////                  print("KEKW"+selectedPath)
            ////                  for(let i=0;i<selectedPath.length;i++){
            ////                      picturesPath=selectedPath[i]["Value"]
            ////                      picturesPath=JSON.stringify(picturesPath)
            ////                      picturesPath=picturesPath.lace('"','')
            ////                      picturesPath=picturesPath.replace('"','')
            ////                      picturesArray.push(picturesPath);
            ////                      print("picturesPath: "+JSON.stringify(picturesPath))
            ////                      print("picturesArray: "+picturesArray[0])
            ////                  }
            ////                  galleryCounter=0;
            //              }
        }


    }
    Rectangle{
        id:bottomWrap
        height:if(root.width>1000){70}else{350}
        anchors.left:parent.left
        anchors.right:parent.right
        anchors.bottom:parent.bottom
        color: "#111111"
        Column{
            visible:if(root.width>1000){false}else{true}
            spacing:15
            Row{
                CDButton{
                    text:"Checklista"
                    height:100
                    width:root.width/2
                    //visible: cb.check_privilege("CheckLista", "View", 0)
                    onClick: {
                        repDial.regOzn=registarskaOznaka;
                        repDial.uid=activeUid;
                        repDial.open();
                    }
                }
                CDButton{
                    text:"Vrsta paleta"
                    enabled:altTable.hasSelection
                    height:100
                    width:root.width/2
                    onClick: {
                        changePalletDial.open()
                    }
                }
            }
            Row{
                CDButton{
                    text:"Kraj utovara"
                    height:100
                    width:root.width/2
                    onClick:{
                        closingDial.open();
                    }
                }
                CDButton{
                    text:"Otpremnice"
                    height:100
                    width:root.width/2
                    onClick: {
                        naloziTableDial.open();
                    }
                }
            }
            Row{
                CDButton{
                    text:"Slike"
                    enabled:altTable.hasSelection
                    height:100
                    width:root.width
                    onClick: {
                        selectedPath=altTable.fieldByName(altTable.verticalTable.expandedRows[0],"Images");
                        selectedPath=JSON.parse(selectedPath)
                        print("selectedpath"+selectedPath)
                        for(let i=0;i<selectedPath.length;i++){
                            picturesPath=selectedPath[i]["Value"]
                            picturesPath=JSON.stringify(picturesPath)
                            picturesPath=picturesPath.replace('"','')
                            picturesPath=picturesPath.replace('"','')
                            picturesArray.push(picturesPath);
                            print("picturesPath: "+JSON.stringify(picturesPath))
                            print("picturesArray: "+picturesArray[0])
                        }
                        galleryCounter=0;
                        m_imageModel = [];
                        for(var i = 0; i < picturesArray.length; i++) {
                        COMM.http_Request(null, "GET", "LoadImageFromPath","ImgPath=" + picturesArray[i].replace('file:///','') + "&ImageID=Image" + i + "&SessionID=" , "", resp_GET_LoadImageFromPath );
                        }
                        picturesArray=picturesArray;
                        picDial.open();
                    }
                }
            }
        }
        Row {
            visible:if(root.width>1000){true}else{false}
            anchors.fill: parent
            anchors.topMargin: 5
            anchors.leftMargin: 100
            spacing: 25


            CDButton{
                text:"Checklista"
                height:60
                width:if(root.width>1000){200}else{100}
                //visible: cb.check_privilege("CheckLista", "View", 0)
                onClick: {
                    print("registarska oznaka"+registarskaOznaka)
                    repDial.regOzn=registarskaOznaka;
                    repDial.uid=activeUid;
                    repDial.open();
                }
            }
            CDButton{
                text:"Vrsta paleta"
                enabled:altTable.hasSelection
                height:60
                width:if(root.width>1000){200}else{100}
                onClick: {
                    changePalletDial.open();
                }
            }
            CDButton{
                text:"Zatvori nalog"
                height:60
                width:if(root.width>1000){200}else{100}
                onClick:{
                    closingDial.open();
                }
            }
            CDButton{
                text:"Otpremnice"
                height:60
                width:if(root.width>1000){200}else{100}
                onClick: {
                    naloziTableDial.open();
                }
            }

            CDButton{
                text:"Slike"
                enabled:altTable.hasSelection
                height:60
                width:if(root.width>1000){200}else{100}
                onClick: {
                    selectedPath=altTable.fieldByName(altTable.verticalTable.expandedRows[0],"Images");
                    selectedPath=JSON.parse(selectedPath)
                    print("selectedpah"+selectedPath)
                    for(let i=0;i<selectedPath.length;i++){
                        picturesPath=selectedPath[i]["Value"]
                        picturesPath=JSON.stringify(picturesPath)
                        picturesPath=picturesPath.replace('"','')
                        picturesPath=picturesPath.replace('"','')
                        picturesArray.push(picturesPath);
                        print("picturesPath: "+JSON.stringify(picturesPath))
                        print("picturesArray: "+picturesArray[0])
                    }
                    galleryCounter=0;
                    m_imageModel = [];
                    for(var i = 0; i < picturesArray.length; i++) {
                    COMM.http_Request(null, "GET", "LoadImageFromPath","ImgPath=" + picturesArray[i].replace('file:///','') + "&ImageID=Image" + i + "&SessionID=" , "", resp_GET_LoadImageFromPath );
                    }
                    picDial.open();
                }
            }
        }
    }



    RepVerticalDialog{
        id:repDial
        width: parent.width
        height:parent.height
        onRegister: {
            repDial.regOznText=registarskaOznaka;
        }
    }
    Dialog{
        id:closingDial
        width:600
        height:500
        modal:true
        closePolicy: Popup.NoAutoClose
        x: (parent.width - width) / 2
        y: (parent.height - height) /12
        Rectangle{
            anchors.fill:parent
            color: "#111111"
            Text{
                id:cdTxt
                anchors.top:parent.top
                anchors.topMargin: 50
                anchors.left:parent.left
                anchors.leftMargin: parent.width/6
                anchors.right:parent.right
                height:parent.height/4
                font.pointSize: 30
                wrapMode: Text.WordWrap
                text:"Želite li zatvoriti nalog?"
                color:"white"
            }
            Text{
                id:plombaTxt
                anchors.top:cdTxt.bottom
                anchors.left:parent.left
                anchors.leftMargin: 50
                anchors.topMargin: 15
                text: "Plomba:"
                color:"white"
                font.pointSize: 30
            }
            TextField{
                id:plombaInput
                anchors.top:plombaTxt.top
                anchors.left:plombaTxt.right
                font.pointSize: 30
                width:250
            }

            Row{
                id:closingRow
                anchors.bottom:parent.bottom
                anchors.left:parent.left
                anchors.bottomMargin: 15
                anchors.leftMargin: (parent.width/2)-100
                spacing:10
                CDButton {
                    text: "Potvrdi"
                    idleColConst: "green"
                    height:70
                    fontSize: 22
                    onClick: {
                        if(altTable.verticalTable.m_model.length==0){
                            var nes={}
                            nes["UID"]=activeUid;
                            nes["STATUS"]=5;
                            nes["PLOMBA"]=plombaInput.text
                            var bodyd=JSON.stringify(nes)
                            COMM.http_Request(null, "PUT", "OT_ZatvaranjeNalogaUtovara","", bodyd, resp_PUT_OT_ZatvaranjeNalogaUtovara );
                            plombaInput.text=""



                            closingDial.close();
                        }else{
                            for(var i=0;i<altTable.verticalTable.m_model.length;i++){

                                if(i==(altTable.verticalTable.m_model.length-1) && altTable.verticalTable.m_model[i]["VrstaPalete"]!=null){
                                    var nes={}
                                    nes["UID"]=activeUid;
                                    print("active UID!!"+activeUid)
                                    nes["STATUS"]=5;
                                    nes["PLOMBA"]=plombaInput.text
                                    var bodyd=JSON.stringify(nes)
                                    COMM.http_Request(null, "PUT", "OT_ZatvaranjeNalogaUtovara","", bodyd, resp_PUT_OT_ZatvaranjeNalogaUtovara);
                                    plombaInput.text=""


                                    closingDial.close();
                                }else if(altTable.verticalTable.m_model[i]["VrstaPalete"]==null){
                                    var nes={}
                                    nes["UID"]=activeUid;
                                    print("active UID!!"+activeUid)
                                    nes["STATUS"]=5;
                                    nes["PLOMBA"]=plombaInput.text
                                    var bodyd=JSON.stringify(nes)
                                    COMM.http_Request(null, "PUT", "OT_ZatvaranjeNalogaUtovara","", bodyd, resp_PUT_OT_ZatvaranjeNalogaUtovara);
                                    closingDial.close();
                                   // scanMsg="Nekim paletama nije dodijeljena vrsta!!!";
                                    //scanMsgDial.open()
                                    altTable.verticalTable.selectRow(i);
                                    break;
                                }
                            }
                        }
                    }
                }
                CDButton {
                    text: "Odustani"
                    idleColConst:"red"
                    height:70
                    fontSize: 22
                    onClick: {
                        closingDial.close();
                    }
                }
            }
        }
        onOpened:{
            plombaInput.text=""
        }
    }



    MessageDialog{
        id:scanMsgDial
        txtSize: 40
        modal:true

        onOpened: {
            msgTimerInterval=5000
            msgTxt=scanMsg;
            errorCut();
        }
    }
    Dialog{
        id:picDial
        width: root.width
        height: root.height
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        modal:true
        Rectangle{
            anchors.top:parent.top
            anchors.left:parent.left
            anchors.right:parent.right
            anchors.bottom: picRow.top

            Rectangle {
                //        anchors.topMargin: -50
                //        width: parent.width - 150
                //        height: parent.height - 150

                anchors.topMargin: -50
                width: parent.width
                height: parent.height
                anchors.centerIn: parent
                color: "transparent"
                clip: true
                z: 1
                CDZoomImage{
                    id:bigPic
                    imageWidth: 1024
                    imageHeight: 768

                    //          imageWidth: parent.width
                    //          imageHeight: parent.height
                    anchors.fill: parent
                    source: "KODEL SLIKE/4.jpg"
                    visible: true
                    onSourceChanged: {
                        bigPic.resetScale()
                        //                        if(source != "KODEL SLIKE/4.jpg") {
                        //                            visible = true
                        //                        }
                    }
                }
                Text{
                    id:picNmb
                    text:galleryCounter+1 +"/"+selectedPath.length
                    z:100
                    color:"red"
                    font.pointSize: 28
                    anchors.top:parent.top
                    anchors.left:parent.left
                }
            }

            //                CDZoomImage{
            //                    id:bigPic2
            //                    anchors.right:parent.right
            //                    anchors.top:parent.top
            //                    anchors.bottom:parent.bottonm
            //                    imageWidth:parent.width/2
            //                    source:""
            //                }
            CDButton {
                anchors.top:parent.top
                anchors.right:parent.right
                text: "X"
                fontSize:20
                idleColConst:"red"
                width:60
                height: 60
                z:100
                onClick: {
                    picDial.close();
                }
            }

        }
        Row{
            id:picRow
            anchors.left:parent.left
            anchors.right:parent.right
            anchors.bottom: parent.bottom
            CDButton{
                id:leftBtnDial
                text:"Prethodna"
                width:parent.width/2
                height:60
                onClick: {
                    if(galleryCounter==0){
                        galleryCounter=picturesArray.length-1
                    }else{
                        galleryCounter--
                    }
                    bigPic.source="image://multiImageProvider/"+m_imageModel[galleryCounter]
                }
            }
            CDButton{
                id:rightBtnDial
                text:"Sljedeća"
                width:parent.width/2
                height:60
                onClick: {
                    if(galleryCounter>=(picturesArray.length-1)){
                        galleryCounter=0
                    }else{
                        galleryCounter++
                    }
                    bigPic.source="image://multiImageProvider/"+m_imageModel[galleryCounter]
                }
            }
        }

        onOpened: {
            bigPic.source="";
            bigPic.source="image://multiImageProvider/"+m_imageModel[0]
            //  bigPic.source="image://multiImageProvider/"+m_imageModel[galleryCounter];
            // bigPic.source=picturesArray[galleryCounter]
        }
        onClosed:{
            picturesArray=[]
        }

    }
    Dialog{
        id:naloziTableDial
        width: parent.width
        height: parent.height
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        closePolicy: Popup.NoAutoClose

                function rfrsh(){
                    nalogTable.refreshTable();
                }

        Rectangle{
            anchors.fill:parent
            color: "#111111"

            Rectangle{
                id:header
                anchors.top:parent.top
                anchors.left:parent.left
                anchors.right:parent.right
                height:60
                color: "#111111"
                z:100
                Text {
                    id: hdrTxt
                    anchors.centerIn: parent
                    font.pixelSize: 22
                    text: "Otpremnice"
                    color:"white"
                }
                CDButton {
                    anchors.top:parent.top
                    anchors.right:parent.right
                    text: "X"
                    fontSize:20
                    idleColConst:"red"
                    width:60
                    height: 60
                    onClick: {
                        naloziTableDial.close();
                    }
                }
            }
            Rectangle{
                anchors.top:header.bottom
                anchors.left:parent.left
                anchors.right:parent.right
                anchors.bottom:parent.bottom


                CDAlternatingTable{
                    id:nalogTable
                    anchors.fill:parent
                    verticalHeaders:  ["ID_OTPREMNICE", "UtovarnoMjesto","UPDATED_AT", "Operater"]
                    tableName: "V_OT_NALOG_UTOVARA_D1"
                    verticalDetails: ["CREATED_AT"]


                    autoInitRefresh: false
                    classicTable.visible: false
                    verticalTable.visible: true
                    verticalTable.detailsHeight: verticalTable.detailGridHeight
                    verticalTable.maDetailsEnabled: true
                    verticalTable.headerColumnWidths: [width * 0.25, width*0.2, width*0.2,width*0.3]
                }
            }

        }
        onOpened:{
            nalogTable.constFilters=[{"Name" : "UID_NALOGA_UTOVARA_M", "Value" : activeUid, "Cond" : "="}]
            nalogTable.refreshTable();
        }
    }

    Dialog{
        id:menuDial
        width:200
        height:200
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        Column{
            anchors.fill:parent
            Button{
                id:reportBtn
                width:parent.width
                height:100
                text:"Izvjestaj"
                onClicked: {
                    cdBridge.openURL(cb.appParams["sReportingServer"]+"/result?report=NaloziZaUtovar%5Ctemplate1.fr3" + "&UID="+ activeUid + "&FORMAT=PDF");
                }
            }
        }
    }

    Dialog{
        id:changePalletDial
        width: 650
        height: 500
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        closePolicy: Popup.NoAutoClose
        modal: true

        Rectangle{
            anchors.fill:parent
            color: "#111111"
            Item{
                id:wrap
                anchors.top:parent.top
                anchors.left:parent.left
                anchors.right:parent.right
                height:300

                //        CDSearchTable_new{
                //          id:palletTable
                //          anchors.centerIn:parent
                //          height:150
                //          width:350
                //          objectName: "palletTable"
                //          z:99
                //          newVersion:true

                //          tableName: "OT_VRSTE_PALETA"
                //          sortColumnName: "NAZIV"

                //          mainColor: "dodgerblue"

                //          chooseAfilter: '[{"columnName":"NAZIV", "label":"Vrsta paleta"}]'
                //          labelFontSize: 32

                //          textEdit.font.pixelSize: 32
                //          searchTable.headerHeight: 35

                //          onRowSelected: {
                //            palleteType=selectedRow["ID"];
                //          }
                //        }
                ComboBox{
                    id:cbox
                    anchors.centerIn:parent
                    z:100
                    height:150
                    width:300
                    textRole:"naziv"
                    valueRole: "id"
                    model:palleteModel
                    font.pointSize: 30
                    delegate: ItemDelegate{
                        width:cbox.width
                        height:90
                        font.pointSize: 30
                        text:cbox.textRole ? (Array.isArray(cbox.model) ? modelData[cbox.textRole] : model[cbox.textRole]) : modelData
                    }

                }
            }

            Item {
                anchors.top:wrap.bottom
                anchors.bottom:parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right

                CDButton {
                    text: "Potvrdi"
                    idleColConst: "green"
                    height:100
                    width:150
                    anchors.bottom:parent.bottom
                    anchors.left: parent.left

                    enabled: palletTable.bReady
                    fontSize: 26
                    onClick: {
                        print("RIP"+cbox.currentIndex)
                        palleteType=cbox.currentIndex+1
                        var body=""
                        var nes={}
                        nes["ID_VRSTA_PALETE"]=cbox.currentValue;
                        nes["UID"]=altTable.selected("UID");
                        nes=JSON.stringify(nes)
                        print("COOL"+nes)
                        COMM.http_Request(null, "PUT", "OT_NALOG_UTOVARA_D2","", nes, resp_PUT_OT_NALOG_UTOVARA_D2);
                        changePalletDial.close();
                    }
                }

                CDButton {
                    text: "Odustani"
                    idleColConst:"red"
                    anchors.bottom:parent.bottom
                    anchors.right: parent.right
                    width:150
                    height: 100
                    fontSize: 26
                    onClick: {
                        changePalletDial.close();
                    }
                }

            }
        }
        onOpened:{


            if(palleteModel.count==0){
                cboxTime.start()
                COMM.http_Request(null, "GET", "DynamicSelect","TableName=OT_VRSTE_PALETA"  + "&FilterParams=" +  "&OrderBy=" + "&NoOfRecords="  + "&ConnDef=", "", resp_GET_DynamicSelect);

            }else{
                if(altTable.selected("VrstaPalete")!=""){
                    print("YYY"+cbox.find(altTable.selected("VrstaPalete")))
                    cbox.currentIndex = cbox.find(altTable.selected("VrstaPalete"));
                    //cbox.currentValue=altTable.selected("VrstaPalete");

                }else{
                    cbox.currentIndex = -1
                }
            }
        }

        onClosed: {
            altTable.refreshTable();
            //COMM.http_Request(null, "GET", "DynamicSelect","TableName=" + table2.tableName + "&FilterParams=[]" + "&OrderBy=", "", resp_GET_DynamicSelectPalette);
        }
    }

        Timer {
            id:cboxTime
            interval: 70;
            onTriggered: {
                if(altTable.selected("VrstaPalete")!=""){
                    print("YYY"+cbox.find(altTable.selected("VrstaPalete")))
                    cbox.currentIndex = cbox.find(altTable.selected("VrstaPalete"));
                    //cbox.currentValue=altTable.selected("VrstaPalete");

                }else{
                    cbox.currentIndex = -1
                }
            }
        }

    ListModel{
        id:palleteModel
    }

    Dialog{
        id:scanPicDial
       x: (parent.width - width) / 2
       y: (parent.height - height) /2
        closePolicy: Popup.NoAutoClose
        width:parent.width
        height:parent.height
        modal:true
        Rectangle{
            id:hdr
            Text{
                id:ssccTxt
                text:""
                anchors.centerIn: parent
                color:"white"
                font.pointSize: 30

            }
            height:100
            color:"black"
            width:parent.width-100
            CDButton{
                id:closeScan
                text:"X"
                idleColConst:"red"
                height:100
                width:100
                anchors.right:parent.right
                onClick: {
                    scanPicDial.close();
                }
            }
        }

        Rectangle {
            color: "transparent"
            anchors.top:hdr.bottom
            anchors.left:parent.left
            anchors.right:parent.right
            anchors.bottom: parent.bottom

            GridView {
              id: grid
              anchors.fill: parent



              verticalLayoutDirection: GridView.TopToBottom

              cellWidth: parent.width
              cellHeight: parent.height/2

              delegate: Rectangle {

                clip: true
                color: "transparent"
                width: grid.cellWidth
                height: grid.cellHeight

                CDZoomImage {
                  anchors.fill: parent
                  imageWidth: parent.width
                  imageHeight: parent.height
                  source: "image://multiImageProvider/" + m_imageModel[index]
                }
              }
            }
        }
        onOpened:{
            //requestLoadImages();
        }

    }



    function resp_PUT_OT_ZatvaranjeNalogaUtovara(response)
    {
        var success = response["success"];
        var message = response["message"];
        var data = response["data"];

        if(success === true)
        {
            print("resp_PUT_OT_ZatvaranjeNalogaUtovara: " + JSON.stringify(data));
            closeNalog();
        }
        else
        {
            print("resp_PUT_OT_ZatvaranjeNalogaUtovara: " + message);
            scanMsgDial.error=true
            scanMsg=message;
            scanMsgDial.errorCut();
            scanMsgDial.open();
            //scanMsgDial.msgTimer.start();
        }
    }
 /*   function requestLoadImages() {


        // Reset modela i providera (releasa slike iz memorije 4ever)
        m_imageModel = [];
        multiImageProvider.discardCurrentImages();

        // Stari dijagram za load slike koji na slot vrati poslani ImageID i SessionID
        for(var i = 0; i < picturesArray.length; i++) {
            var temp = {};

            temp["GroupID"] = "40591"; // ID Dijagrama
            temp["GroupUID"] = "{17DA57E9-CA0C-4468-BC10-2A9C5F679B46}"; // UID Dijagrama
            temp["FormName"] = cdBridge.mainFormName(); // Ime forme na kojoj se objekt nalazi
            temp["ObjectName"] = root.objectName // Ime samog objekta kojega želimo osvježiti
            temp["QMLFunctionName"] = "receiveImage"; // Ime funkcije koju želimo pozvati

            // Globalne varijable dijagrama
            temp["ImgPath"] = picturesArray[i].replace('file:///','');
            temp["ImageID"] = "Image" + i;
            temp["SessionID"] = "";

            print("PICTUREARRAY"+picturesArray[i])
            cdBridge.call_diagram(temp);
        }
    }
    */
    //poziv dijagrama (40649) GET LoadImageFromPath

    function resp_GET_LoadImageFromPath(response)
    {
        print("resp_GET_LoadImageFromPath: ");

            var success = response["success"];
            var message = response["message"];
            var data = response["data"];

            if(success === true)
            {
                print("resp_GET_LoadImageFromPath: " + JSON.stringify(data));
                hexImg = data[0]["DataSet"];
                imageID = data[0]["ImageID"];
                print("OVO"+data[0]["ImageID"])
                print("RADIM receiveImage")
        //        var hexImg = args["DataSet"];
        //        var imageID = args["ImageID"];

                multiImageProvider.addSourceFromHexString(hexImg, imageID);

                print("RADIM receiveImage MID")

                m_imageModel.push(imageID);
                grid.model = m_imageModel;
                print("ImageProviderSlika"+imageID)
                //img.source="";
                // img.source="image://multiImageProvider/"+m_imageModel[galleryCounter];
                //bigPic.source="image://multiImageProvider/"+m_imageModel[galleryCounter];
                // print("KEKW1"+bigPic.source)
                bigPic.source="image://multiImageProvider/Image0";
            }
            else
            {
                print("resp_GET_LoadImageFromPath: " + message);
            }
    }


    function receiveImage() {



    }

    //    function resp_GET_DynamicSelectPalette(response)
    //    {
    //        var success = response["success"];
    //        var message = response["message"];
    //        var data = response["data"];

    //        if(success === true)
    //        {

    //            print("success")
    //            print("resp_GET_DynamicSelect: " + JSON.stringify(data));
    //            var rows = data;

    //            if(rows.length > 0) {
    //                var row = rows[0];
    //                var columns = Object.keys(row);
    //                table2.setBasicModel(columns, rows);
    //            }
    //            else {
    //                table2.setBasicModel([], {});
    //            }

    //            print("success done")
    //        }
    //        else
    //        {
    //            print("resp_GET_DynamicSelect: " + message);
    //        }
    //    }
    function resp_PUT_OT_NALOG_UTOVARA_D2(response)
    {
        var success = response["success"];
        var message = response["message"];
        var data = response["data"];

        print("resp_PUT_OT_NALOG_UTOVARA_D2 success: " + success);

        if(success === true)
        {
            print("resp_PUT_OT_NALOG_UTOVARA_D2: " + JSON.stringify(data));
        }
        else
        {
            print("resp_PUT_OT_NALOG_UTOVARA_D2: " + message);
        }
    }
    //poziv dijagrama (40529) GET DynamicSelect
    function createListElement(number) {

        return {
            id:palleteData[number]["ID"],
            naziv:palleteData[number]["NAZIV"]
        };
    }

    function resp_GET_DynamicSelect(response)
    {
        var success = response["success"];
        var message = response["message"];
        var data = response["data"];

        if(success === true)
        {
            print("resp_GET_DynamicSelect VRSTA PALETA: " + JSON.stringify(data));
            palleteData=data;
            palleteTypeCount=Object.keys(data).length
            for (let i = 0; i < palleteTypeCount; i++) {
                palleteModel.append(createListElement(i));
            }
        }
        else
        {
            print("resp_GET_DynamicSelect: " + message);
        }
    }
    function scanPictures(scanPaths,palleteID){
        print("scan pictures")

//        for(let i=0;i<altTable.verticalTable.m_model.length;i++){
//            if(palleteID==altTable.fieldByName(i,"SSCC")){
//                selectedPath=altTable.fieldByName(i,"Images");

//                selectedPath=JSON.parse(selectedPath)
//                print("selectedpah"+selectedPath)
//                for(let j=0;j<selectedPath.length;j++){
//                    picturesPath=selectedPath[j]["Value"]
//                    picturesPath=JSON.stringify(picturesPath)
//                    picturesPath=picturesPath.replace('"','')
//                    picturesPath=picturesPath.replace('"','')
//                    picturesArray.push(picturesPath);
//                    print("picturesPath: "+JSON.stringify(picturesPath))
//                    print("picturesArray: "+picturesArray[0])
//                }

                galleryCounter=0;
                m_imageModel = [];
                for(var l = 0; l < scanPaths.length; l++) {
                    print("SCANPATHS"+ scanPaths[l])
                COMM.http_Request(null, "GET", "LoadImageFromPath","ImgPath=" + scanPaths[l].replace('file:///','') + "&ImageID=Image" + l + "&SessionID=" , "", resp_GET_LoadImageFromPath);
                }
                //picturesArray=picturesArray;
                ssccTxt.text=palleteID

                scanPicDial.open();
//            }

        //}

    }


}
