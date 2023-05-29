import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "CDCommTest.js" as COMM




Item {
    id: root
    objectName:"rootMain"
    anchors.fill: parent

    property color highlightColor: "dodgerblue"
    property var body:"";
    property var selectedName:""
    property var selectedReg:""
    property string selectedPrijevoz:""
    property string selectedUtovar:""
    property var selectedOdr:""
    property var selectedDatum:""
    property var selectedUID:""
    property var selectedNumber:""
    property var selectedStatus: ""
    property var palleteType:""

    property var statusMap: []
    property var statusMapColors: []

    property var selectedPath:""
    property var picturesPath:""
    property var picturesArray:[]

    property var m_imageModel: [];

    property int galleryCounter:0

    property var deviceName:""
    property var devId: ""

    property var scanMsg:""
    property var scanData: ""

    property var platform:""
    property var operators:""
    property var operatorsCount:""

    property var infoX:""
    property var infoY:""

    property var rampText:""
    property var className:"Nalog utovara"
    property var objectNameParam: "Otprema1"
    property var codeName : "%"



    //poziv dijagrama (40590) GET GetSysParams

    function resp_GET_GetSysParams(response)
    {
            var success = response["success"];
            var message = response["message"];
            var data = response["data"];

            if(success === true)
            {
                print("resp_GET_GetSysParams: " + JSON.stringify(data));
                 var tempParams = cb.appParams;

                 for(var i = 0; i < data.length; i++) {
                   var val = data[i]["Value"];
                   var name = data[i]["CodeName"];
                   tempParams[name] = val;
                 }

                 cb.appParams = tempParams;
                 print(JSON.stringify(cb.appParams));
            }
            else
            {
                print("resp_GET_GetSysParams: " + message);
            }
    }



    Rectangle {
        id: rBg
        z: -1
        color: "#222222"
        anchors.fill: parent
    }

    Item {
        id: iContent
        anchors.fill: parent
        anchors.margins: 25
        Item {
            id: iTabs
            height: 40
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: 320

            /*   CDTabBar {
                id: tbMasterDetail
                anchors.fill: parent
                anchors.horizontalCenter: parent.horizontalCenter
                tabLayout: tabLayout

                fontColorUnselected: "white"
                btnTexts: ["Master", "Detail"]
                nrButtons: btnTexts.length
                singleColor: true
                selectedColor:  root.highlightColor
                unselectedColor: "#222222"

                Component.onCompleted: {
                    //        if(bAutoBindTab)
                    //          rep.itemAt(1).enabled = Qt.binding( function() {return masterTable.hasSelection;} );
                }
            }*/
            Row{
                anchors.fill: parent
                anchors.horizontalCenter: parent.horizontalCenter
                CDButton{
                    width: (parent.width + (nrButtons - 1) * 2) / nrButtons
                    height: parent.height
                    cornerRad: 4
                    text: "Nalozi utovara"
                    txtText.font.pointSize: 18
                    rBg.border.width: 3
                    rBg.border.color: "white"
                    idleCol:if(tabLayout.currentIndex!=1){"dodgerblue"}else{"#222222"}
                    onClick: {
                        tabLayout.currentIndex=0
                    }
                }
                CDButton{
                    width: (parent.width + (nrButtons - 1) * 2) / nrButtons
                    height: parent.height
                    cornerRad: 4
                    text: "Stavke"
                    txtText.font.pointSize: 18
                    rBg.border.width: 3
                    rBg.border.color: "white"
                    idleCol:if(tabLayout.currentIndex==1){"dodgerblue"}else if(table1.selectedRow!=-1){"#222222"}else{"gray"}
                    enabled: if(table1.selectedRow==-1){false}else{true}
                    onClick: {
                        print("SELECTED UID:"+selectedUID);
                        tabLayout.currentIndex=1
                        COMM.http_Request(null, "GET", "DynamicSelect","TableName=" + table2.tableName + '&FilterParams=[{"Name":"UID_NALOGA_UTOVARA_M","Value":'+'"'+selectedUID+'"'+',"Cond":"="}]' + "&OrderBy=UPDATED_AT" , "", resp_GET_DynamicSelect2);

                    }
                }
            }
        }
        CDDetailsButton {
            id: detBtn
            x: 10
            y: 10
            z:99

            visible:if(tabLayout.currentIndex==1){true}else{false}

            maxHeight:  350

            titleDetails.gridView.cellWidth:  titleDetails.width / 2
        }
        Rectangle{
            id:deviceNameRec
            anchors.top:parent.top
            anchors.left:parent.left
            width:200
            height:50
            color:"#111111"
            border.width: 2
            border.color: "white"
            visible:false
            Text{
                text:rampText
                anchors.centerIn: parent
                color:"white"
                font.pixelSize: 20
            }

        }

        Item {
            anchors.top: iTabs.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: iControls.top
            anchors.topMargin: 25
            anchors.bottomMargin: 25

            StackLayout {
                id: tabLayout
                anchors.fill: parent
                currentIndex: -1

                Item {
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"

                        CDBTable {
                            id: table1
                            anchors.fill: parent
                            //autoScrollToSelected:false
                            tableName: "V_OT_NALOG_UTOVARA_M"
                            mColumnDefs:
                                [{"Width":75,"Visible":true,"ColumnName":"STATUS","DelegateChoice":"krug_mali"},{"Width":132,"Visible":true,"ColumnName":"NAZIV","DelegateChoice":""},{"Width":167,"Visible":true,"ColumnName":"REG_OZN_VOZILA","DelegateChoice":""},{"Width":75,"Visible":false,"ColumnName":"UID_PRIJEVOZNIKA","DelegateChoice":""},{"Width":138,"Visible":true,"ColumnName":"NazivPrijevoznika","DelegateChoice":""},{"Width":174,"Visible":true,"ColumnName":"ID_UTOVARNOG_MJESTA","DelegateChoice":""},{"Width":190,"Visible":true,"ColumnName":"PLOMBA","DelegateChoice":""},{"Width":75,"Visible":true,"ColumnName":"ODREDISTE","DelegateChoice":""},{"Width":75,"Visible":true,"ColumnName":"DOC_DATE","DelegateChoice":""},{"Width":75,"Visible":false,"ColumnName":"ID_OP","DelegateChoice":""},{"Width":75,"Visible":false,"ColumnName":"ID_OP_AUTHOR","DelegateChoice":""},{"Width":121,"Visible":true,"ColumnName":"CREATED_AT","DelegateChoice":""},{"Width":136,"Visible":true,"ColumnName":"UPDATED_AT","DelegateChoice":""},{"Width":157,"Visible":true,"ColumnName":"BR_NALOGA_PRIJEVOZA","DelegateChoice":""},{"Width":75,"Visible":false,"ColumnName":"UID","DelegateChoice":""},{"Width":75,"Visible":false,"ColumnName":"ID_OP_CHECK","DelegateChoice":""},{"Width":130,"Visible":true,"ColumnName":"Provjerio","DelegateChoice":""},{"Width":143,"Visible":true,"ColumnName":"CHECK_DATE","DelegateChoice":""},{"Width":96,"Visible":true,"ColumnName":"IS_CHECKED","DelegateChoice":""}]
                                /*{
                                "STATUS":{
                                    "DelegateChoice":"krug_mali"
                                },
                                "BR_NALOGA_PRIJEVOZA": {
                                    "Width":100
                                },
                                "NAZIV": {
                                    "Width":100
                                },
                                "REG_OZN_VOZILA": {
                                    "Width":100
                                },
                                "UID_PRIJEVOZNIKA": {
                                    "Visible":0
                                },
                                "NazivPrijevoznika": {
                                    "Width":100
                                },
                                "ID_UTOVARNOG_MJESTA": {
                                    "Width":100
                                },
                                "PLOMBA": {
                                    "Width":100
                                },
                                "ODREDISTE": {
                                    "Width":100
                                },
                                "DOC_DATE": {
                                    "Width":100
                                },
                                "ID_OP": {
                                     "Visible":0
                                },
                                "ID_OP_AUTHOR": {
                                      "Visible":0
                                },
                                "CREATED_AT": {
                                     "Width":100
                                },
                                "UPDATED_AT": {
                                     "Width":100
                                },
                                "UID": {
                                      "Visible":0
                                },
                                "ID_OP_CHECK": {
                                      "Visible":0
                                },
                                "Provjerio": {
                                     "Width":100
                                },
                                "CHECK_DATE": {
                                     "Width":100
                                },
                                "IS_CHECKED": {
                                     "Width":100
                                },
                            }*/
                            function krug_mali_colorProvider(row, column) {
                                var statTemp=table1.fieldByName(row,"STATUS")
                                for(let i=0;i<statusMapColors.length;i++){
                                    if(statTemp==statusMapColors[i]["STATUS"]){
                                        return statusMapColors[i]["BackColor"];
                                    }
                                }
                            }

                            // constFilters:  [{"Name" : "ID_OP", "Value" : "20", "Cond" : "!="}]
                            onRowSelected: {


                                picturesArray=[];
                                img.source="";
                                selectedNumber=fieldByName(selectedRow,"BR_NALOGA_PRIJEVOZA");
                                selectedName=fieldByName(selectedRow,"NAZIV");
                                selectedReg=fieldByName(selectedRow,"REG_OZN_VOZILA");
                                selectedPrijevoz=fieldByName(selectedRow,"NazivPrijevoznika");
                                selectedUtovar=fieldByName(selectedRow,"ID_UTOVARNOG_MJESTA");
                                selectedOdr=fieldByName(selectedRow,"ODREDISTE");
                                selectedDatum=fieldByName(selectedRow,"DOC_DATE");
                                selectedUID=fieldByName(selectedRow,"UID");
                                selectedStatus=fieldByName(selectedRow,"STATUS");
                                print("utovar je:"+selectedUtovar);

                                //Details
                                var dets=[];
                                dets.push({"Label":"Broj naloga", "Value":selectedNumber});
                                dets.push({"Label":"Registarska oznaka", "Value":selectedReg});
                                dets.push({"Label":"Utovarno mjesto", "Value":selectedUtovar});
                                detBtn.setModel(dets)
                                print("dets "+dets)

                            }
                            Component.onCompleted:{
                                contextMenu.insertItem(3,naloziTable);
                                contextMenu.insertItem(4 ,exceExport);
                                for(var i=0; i<6;i++){
                                    if(cell==statusMap[i]["StatusCode"]){
                                        statusName = statusMap[i]["StatusName"];
                                        statusDesc = statusMap[i]["StatusDesc"];

                                    }
                                }


                                //print("OdabraniROW "+s)
                            }
                        }
                    }
                }

                Item {
                    Rectangle {
                        id:tbl2Rec
                        anchors.fill: parent
                        color: "transparent"

                        CDBTable {
                            id: table2
                            anchors.top:parent.top
                            // anchors.right:slikaWrap.left
                            anchors.right:parent.right
                            anchors.bottom:parent.bottom
                            anchors.left:parent.left
                            tableName: "V_OT_NALOG_UTOVARA_D2"
                            //activeFilters:  [{"Name" : "STATUS_SYS", "Value" : "-2", "Cond" : "<>"}]
                            Component.onCompleted:{
                                contextMenu.insertItem(2,type);
                            }
                            onRowSelected: {
                                picturesArray=[];
                                img.source="";
                                selectedUID=fieldByName(selectedRow,"UID");
                                selectedPath=fieldByName(selectedRow,"Images");
                                selectedPath=JSON.parse(selectedPath)
                                print("selectedpath: "+selectedPath)
                                print("selectedpath length: "+selectedPath.length)
                                //selectedPath=JSON.stringify(selectedPath)
                                for(let i=0;i<selectedPath.length;i++){
                                    picturesPath=selectedPath[i]["Value"]
                                    picturesPath=JSON.stringify(picturesPath)
                                    picturesPath=picturesPath.replace('"','')
                                    picturesPath=picturesPath.replace('"','')
                                    picturesArray.push(picturesPath);
                                    print("picturesPath: "+JSON.stringify(picturesPath))
                                    print("picturesArray: "+picturesArray[0])
                                }
                                galleryCounter=0
                                //img.source=picturesArray[galleryCounter]

                            }
                        }
                        Rectangle{
                            id:slikaWrap
                            anchors.top:parent.top
                            anchors.right:parent.right
                            anchors.bottom:parent.bottom
                            width:600
                            visible:false
                            color:"gray"

                            CDButton{
                                id:bigPicBtn
                                anchors.top:parent.top
                                anchors.right:parent.right
                                text: "Uvećaj"
                                onClick:{
                                    picDial.open()
                                }
                            }

                            Image{
                                id:img
                                anchors.top:parent.top
                                anchors.right:parent.right
                                anchors.left:parent.left
                                anchors.bottom:galleryControls.top
                                source:""
                                fillMode: Image.PreserveAspectFit
                            }
                            Row{
                                id:galleryControls
                                anchors.right:parent.right
                                anchors.bottom:parent.bottom
                                CDButton{
                                    id:leftBtn
                                    text:"Prethodna"
                                    onClick: {
                                        if(galleryCounter==0){
                                            galleryCounter=picturesArray.length-1
                                        }else{
                                            galleryCounter--
                                        }
                                        img.source="image://multiImageProvider/"+m_imageModel[galleryCounter]
                                    }
                                }
                                CDButton{
                                    id:rightBtn
                                    text:"Sljedeća"
                                    onClick: {
                                        if(galleryCounter>=(picturesArray.length-1)){
                                            galleryCounter=0
                                        }else{
                                            galleryCounter++
                                        }
                                        img.source="image://multiImageProvider/"+m_imageModel[galleryCounter]
                                    }
                                }
                            }
                        }
                    }
                }


            }
        }


        //        ListModel{
        //            id:picList
        //            ListElement{
        //                path:"file:///Q:/zagreb.jpg"
        //            }
        //            ListElement{
        //                path:"file:///Q:/rijeka.jpg"
        //            }
        //        }

        Item {
            id: iControls
            height: 60
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            Row {
                anchors.fill: parent
                anchors.topMargin: 20
                spacing: 25
                visible:tabLayout.currentIndex==0;
                CDButton {
                    text: "Dodaj"
                    idleColConst: "green"
                    onClick: addDialog.open()
                    //enabled: cb.check_privilege("Dodaj", "Add", 0)
                }
                CDButton {
                    text: "Uredi"
                    idleColConst: "green"
                    enabled: if(table1.selectedRow==-1 || selectedStatus=="5"){false}else{true}
                    onClick: edDialog.open()
                }
                CDButton {
                    id:deleteBtn
                    text: "Izbriši"
                    idleColConst: "red"
                    enabled: if(table1.selectedRow==-1){false}else{true}
                   // visible: cb.check_privilege("Izbrisi", "View", 0)
                    onClick: {
                        ynd.yndText="Želite li izbrisati nalog?"
                        ynd.state="delete"
                        ynd.open();
                    }
                }
                CDButton{
                    text:"Pregled"
                    enabled: if(table1.selectedRow==-1 || selectedStatus=="5" ){false}else{true}
                    //visible: cb.check_privilege("CheckLista", "View", 0)
                    onClick: {
                        repDial.uid=selectedUID;
                        repDial.open();
                    }
                }
                CDButton{
                    text:"Izvjestaj"
                    enabled: if(table1.selectedRow==-1 ){false}else{true}
                   // visible: cb.check_privilege("Report", "View", 0)
                    onClick: {
                        cdBridge.openURL(cb.appParams["sReportingServer"]+"/result?report=NaloziZaUtovar%5Ctemplate1.fr3" + "&UID="+ selectedUID + "&FORMAT=PDF");
                    }
                }
                CDButton{
                    text:"Aktiviraj nalog"
                    enabled: if(table1.selectedRow==-1){false}else{true}
                  //  visible: cb.check_privilege("Aktivacija", "View", 0)
                    onClick:{

                        activateDial.open();
                    }
                }
                CDButton{
                    text:"Zatvori nalog"
                    enabled: if(table1.selectedRow==-1){false}else{true}
                   // visible: cb.check_privilege("Zatvaranje", "View", 0)
                    onClick:{
                        closingDial.open()

                    }
                }
            }

            CDButton{
                text:"Slike"
                anchors.left: parent.left
                anchors.top:parent.top
                visible: if(tabLayout.currentIndex==1){true}else{false}
                enabled: if(tabLayout.currentIndex!=1 || table2.selectedRow==-1){false}else{true}
                onClick: {
                    if(platform=="desktop"){
                    if(slikaWrap.visible==false){
                        slikaWrap.visible=true
                        table2.anchors.right=slikaWrap.left

                        requestLoadImages();
//                         img.source="";
//                       img.source="image://multiImageProvider/Image0";
                    }else{
                        slikaWrap.visible=false
                        table2.anchors.right=tbl2Rec.right
                    }
                    }else{
                        requestLoadImages();
                        picDial.open();
                    }
                }
            }
        }

        CDButton{
            id:workersBtn
            anchors.top:parent.top
            anchors.right:parent.right
            anchors.topMargin: 10
            anchors.rightMargin: 15
            text: "Operateri"
            onClick: {
                workersDial.open()
            }
        }

        Rectangle{
            id:operaterField
            visible:false
            anchors.top:parent.top
            anchors.right:parent.right
            height:50
            width:parent.width/3
            color:"#111111"
            radius:5
            border.width:1
            border.color:"white"

            ListView{
                id:operaterList
                anchors.fill:parent
                model:listModel
                orientation: ListView.Horizontal
                delegate:
                    Rectangle{
                    width:operaterField.width/listModel.count
                    color:"#111111"
                    height: operaterField.height
                    border.width: 2
                    border.color: "white"
                    Text{
                        id:txt1
                        //anchors.top:parent.top
                        text:name
                        font.pixelSize:20
                        color:"white"
                        anchors.centerIn: parent
                        wrapMode: Text.WordWrap
                        width:parent.width
                    }
                    MouseArea{
                        anchors.fill:parent
                        onClicked:{
                            if(info.visible==false){
                                info.visible=true
                            }else{
                                info.visible=false
                            }
                        }
                    }

                    Rectangle{
                        id:info
                        visible:false
                        anchors.top:parent.bottom
                        anchors.left:parent.left
                        height:120
                        width:parent.width
                        color:"#111111"
                        border.width: 2
                        border.color: "white"
                        Rectangle{
                            anchors.top:parent.top
                            height:parent.height/2
                            width:parent.width
                            color:"transparent"
                            Text{
                                text:"ID čitača: \n" + idCitac
                                color:"white"
                                anchors.centerIn: parent
                                font.pixelSize: 18
                            }
                        }
                        Rectangle{
                            anchors.bottom:parent.bottom
                            height:parent.height/2
                            width:parent.width
                            color:"transparent"
                            Text{
                                anchors.centerIn: parent
                                color:"white"
                                text:"Vrsta palete: \n" + vrstaPalete
                                font.pixelSize: 18
                            }
                        }
                    }
                }
            }
        }

        ListModel {
            id: listModel
        }

        Dialog{
            id:workersDial
            width: 600
            height: 800
            implicitHeight: 800
            implicitWidth: 600

            x: (parent.width - width) / 2
            y: (parent.height - height) / 2

            Rectangle{
                anchors.fill:parent
                color: "#111111"
                CDBTable{
                    id: workersTable
                    anchors.top:parent.top
                    anchors.left:parent.left
                    anchors.right:parent.right
                    anchors.bottom:wdBtn.top
                    anchors.bottomMargin: 10
                    tableName: "V_OT_CONFIG"
                    //constFilters:[{"Name" : "ID_OP", "Value" : "", "Cond" : "<>"}]

                    Component.onCompleted:{
                        contextMenu.insertItem(3,delOperator);
                    }
                }
                CDButton{
                    id:wdBtn
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10
                    anchors.left:parent.left
                    anchors.leftMargin: (parent.width/2)-50
                    fontSize:20
                    text:"Zatvori"
                    idleColConst:"red"
                    width:100
                    height: 50
                    onClick: {
                        workersDial.close()
                    }
                }
            }
        }
        MenuItem{
            id:delOperator
            text:"Odjavi operatera"
            onTriggered: {
                var idCitac = "";
                var idOperater = "";
                if(root.copyColumn >= 0 && root.copyRow >= 0) {
                  idCitac = fieldByName(copyRow, columnName("ID_CITACA"));
                  idOperater = fieldByName(copyRow, columnName("ID_OP"));
                }
                COMM.http_Request(null, "PUT", "UPARIVANJE_OPERATERA","ID_CITACA=" + idCitac + "&ID_OP=" + idOperater + "&COMMAND=" + "LOGOUT", "", resp_PUT_UPARIVANJE_OPERATERA);

            }
        }
    }

    Dialog{
        id:closingDial
        width: 400
        height: 250
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        Rectangle{
            anchors.fill:parent
            color: "#111111"
            Text{
                id:cdTxt
                anchors.top:parent.top
                anchors.topMargin: parent.height/5
                anchors.left:parent.left
                anchors.leftMargin: parent.width/6
                anchors.right:parent.right
                height:parent.height/4
                font.pointSize: 20
                wrapMode: Text.WordWrap
                text:"Želite li zatvoriti nalog?"
                color:"white"
            }
            Text{
                id:plombaTxt
                anchors.top:cdTxt.bottom
                text: "Plomba:"
                color:"white"
                font.pointSize: 20
            }
            TextField{
                id:plombaInput
                anchors.top:plombaTxt.top
                anchors.left:plombaTxt.right
            }

            Row{
                id:closingRow
                anchors.bottom:parent.bottom
                anchors.left:parent.left
                anchors.bottomMargin: parent.height/7
                anchors.leftMargin: (parent.width/2)-100
                CDButton {
                    text: "Potvrdi"
                    idleColConst: "green"
                    onClick: {
                        var nes={}
                        nes["UID"]=selectedUID;
                        nes["STATUS"]=5;
                        nes["PLOMBA"]=plombaInput.text
                        body=JSON.stringify(nes)
                        COMM.http_Request(null, "PUT", "OT_ZatvaranjeNalogaUtovara","", body, resp_PUT_OT_ZatvaranjeNalogaUtovara);
                        table1.refreshTable();
                        closingDial.close();
                    }
                }
                CDButton {
                    text: "Odustani"
                    idleColConst:"red"
                    onClick: {
                        closingDial.close();
                    }
                }
            }
        }
    }

    //    CDGenericDialog {
    //        id: stDialog
    //        width: 400
    //        height: 220
    //        highlightColor: root.highlightColor

    //        CDSearchTable_new {
    //            parent: stDialog.iContent
    //            id: stContainer3
    //            objectName: "stContainerUnq3"
    //            anchors.centerIn: parent
    //            width: 320
    //            height: 80

    //            tableName: "v_Containers"
    //            filterParams: '{}'
    //            sortColumnName: "ContCode"

    //            mainColor: root.highlightColor

    //            chooseAfilter: '[{"columnName":"ContCode", "label":"Kod"}]'
    //            labelFontSize: 32

    //            textEdit.font.pixelSize: 32
    //            searchTable.headerHeight:35
    //            searchTable.defaultColWidth: searchTable.width / 2
    //        }

    //        onAccepted: {
    //            showMessage(stContainer3.selectedRow["ContName"]);
    //        }
    //    }

    CDShowMessageDialog {
        id: showMessageDialog
        highlightColor: root.highlightColor
    }

    Dialog {
        id: ynd
        property var yndText:""
        property var state:""
        width: 400
        height: 250
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        Rectangle{
            anchors.fill:parent
            color: "#111111"
            Text{
                id:yndTxt
                anchors.top:parent.top
                anchors.topMargin: parent.height/5
                anchors.left:parent.left
                anchors.leftMargin: parent.width/6
                anchors.right:parent.right
                anchors.bottom:delRow.top
                font.pointSize: 20
                wrapMode: Text.WordWrap
                text:yndText
                color:"white"
            }

            Row{
                id:delRow
                anchors.centerIn:parent
                CDButton {
                    text: "Potvrdi"
                    idleColConst: "green"
                    onClick: {
                        switch(ynd.state){
                        case "delete":
                            ynd.del();
                            break;

                        case "activate":
                            ynd.activate();
                            break;
                        }
                    }
                }
                CDButton {
                    text: "Odustani"
                    idleColConst:"red"
                    onClick: {
                        ynd.close();
                    }
                }
            }
        }
        onOpened:{
            yndTxt.text=yndText;
        }

        onClosed: {
            table1.refreshTable();
        }
        function del(){
            var nes={}
            nes["UID"]=selectedUID;
            nes["STATUS_SYS"]="-2";
            nes["ID_OP"]="5";
            body=JSON.stringify(nes)
            print("DELETE BODY"+body)
            COMM.http_Request(null, "PUT", "DELETE_NALOG_UTOVARA_M","", body, resp_DELETE_OT_NALOG_UTOVARA_M);
            ynd.close();
        }
        function activate(){
            var nes={}
            nes["UID"]=selectedUID;
            nes["STATUS"]=2;
            body=JSON.stringify(nes)
            COMM.http_Request(null, "PUT", "OT_NALOG_UTOVARA_M","", body, resp_PUT_OT_NALOG_UTOVARA_M);

            ynd.close();
        }
    }
    Dialog {
        id: activateDial
        width: 400
        height: 250
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        Rectangle{
            anchors.fill:parent
            color: "#111111"
            Rectangle{
                id:topWrap
                anchors.top:parent.top
                anchors.left:parent.left
                anchors.right:parent.right
                height:parent.height/3
                color:"transparent"
                Text{
                    anchors.topMargin: parent.height/5
                    anchors.leftMargin: parent.width/6
                    anchors.fill:parent
                    font.pointSize: 20
                    wrapMode: Text.WordWrap
                    text:"Želite li aktivirati nalog? \n Pretraži nalog:"
                    color:"white"
                }
            }
            Rectangle{
                id:midWrap
                anchors.top:topWrap.bottom
                anchors.left:parent.left
                anchors.right:parent.right
                height:parent.height/3
                color:"transparent"
                TextField{
                    anchors.centerIn: parent
                    id:activateInput
                }
            }
            Rectangle{
                anchors.top:midWrap.bottom
                anchors.left:parent.left
                anchors.right:parent.right
                anchors.bottom:parent.bottom
                color:"transparent"
                Row{
                    id:accRow
                    anchors.centerIn: parent
                    CDButton {
                        text: "Potvrdi"
                        idleColConst: "green"
                        onClick: {
                            var brnaloga=activateInput.text
                            if(activateInput.text!=""){
                                COMM.http_Request(null, "GET", "PretragaNaloga","brnaloga=" + brnaloga + "&idutovar=" + devId, "", resp_GET_PretragaNaloga);

                            }else{

                                var nes={}
                                nes["UID"]=selectedUID;
                                nes["STATUS"]=2;
                                body=JSON.stringify(nes)
                                COMM.http_Request(null, "PUT", "OT_NALOG_UTOVARA_M","", body, resp_PUT_OT_NALOG_UTOVARA_M);
                            }
                            activateDial.close();
                        }
                    }
                    CDButton {
                        text: "Odustani"
                        idleColConst:"red"
                        onClick: {
                            activateDial.close();
                        }
                    }
                }
            }
        }
        onOpened:{
            activateInput.text=""
        }

        onClosed: {
            table1.refreshTable();
        }

    }
    AddDialog{
        id:addDialog
        onClosed: {
            clear();
            table1.refreshTable();
            //COMM.http_Request(null, "GET", "DynamicSelect","TableName=" + table1.tableName + "&FilterParams=[]" + "&OrderBy=", "", resp_GET_DynamicSelect);
        }
    }
    EditDialog{
        id:edDialog
        onOpened: {
            name=selectedName;
            reg=selectedReg;
            prijevoz=selectedPrijevoz;
            uidInput.autoFind("Naziv",selectedPrijevoz,"Naziv");
            utovarInput.autoFind("ID",selectedUtovar,"NAZIV");
            odr=selectedOdr;
            datum=selectedDatum;
            stat=selectedStatus;
            rowUID=selectedUID;
            colorMap=statusMapColors

            statMap=statusMap;
            for(let i=0;i<statMap.length;i++){
                if(stat==statMap[i]["StatusCode"]){
                    statField.text=statMap[i]["StatusName"]
                }
            }
        }
        onClosed: {
            table1.refreshTable();
        }

    }

    RepVerticalDialog{
        id:repDial
        onClosed: {
            table1.refreshTable();
        }
    }

    MenuItem{
        id:type
        text:"Promjeni vrstu palete"
        onTriggered: {
            changePalletDial.open();
        }
    }
    Dialog{
        id:changePalletDial
        width: 400
        height: 500
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        Rectangle{
            anchors.fill:parent
            color: "#111111"
            Item{
                id:wrap
                anchors.top:parent.top
                anchors.left:parent.left
                anchors.right:parent.right
                height:300

                CDSearchTable_new{
                    id:palletTable
                    anchors.centerIn:parent
                    height:150
                    width:200
                    objectName: "palletTable"
                    z:99
                    labelFontSize:22

                    tableName: "OT_VRSTE_PALETA"
                    sortColumnName: "NAZIV"

                    mainColor: highlightColor

                    chooseAfilter: '[{"columnName":"NAZIV", "label":"Vrsta paleta"}]'

                    textEdit.font.pointSize: 30
                    searchTable.headerHeight:24

                    onRowSelected: {
                        palleteType=selectedRow["ID"];
                    }
                }
            }

            Row{
                anchors.top:wrap.bottom
                anchors.bottom:parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: parent.width/4
                CDButton {
                    text: "Potvrdi"
                    idleColConst: "green"
                    onClick: {
                        body=""
                        var nes={}
                        nes["ID_VRSTA_PALETE"]=palleteType;
                        nes["UID"]=selectedUID;
                        body=JSON.stringify(nes)
                        COMM.http_Request(null, "PUT", "OT_NALOG_UTOVARA_D2","", body, resp_PUT_OT_NALOG_UTOVARA_D2);
                        changePalletDial.close();
                    }
                }

                CDButton {
                    text: "Odustani"
                    idleColConst:"red"
                    onClick: {
                        changePalletDial.close();
                    }
                }
            }
        }
        onClosed: {
            COMM.http_Request(null, "GET", "DynamicSelect","TableName=" + table2.tableName + "&FilterParams=[]" + "&OrderBy=", "", resp_GET_DynamicSelect2);
        }
    }
    MenuItem{
        id:naloziTable
        text:"Otpremnice"
        onTriggered: {
            naloziTableDial.open();
        }
    }
    MenuItem{
        id:exceExport
        text:"Ažuriraj Excel"
        enabled:if(selectedStatus!="5" && table1.selectedRow!=-1){true}else{false}
        onTriggered: {
            var nes={}
            nes["UID"]=selectedUID
            body=JSON.stringify(nes);
            COMM.http_Request(null, "POST", "NalogUtovaraExport","", body, resp_POST_NalogUtovaraExport);
        }
    }
    Dialog{
        id:naloziTableDial
        width: parent.width/1.5
        height: parent.height/2
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        Rectangle{
            anchors.fill:parent
            color: "#111111"

            CDBTable{
                id:nalogTable
                anchors.top:parent.top
                anchors.left:parent.left
                anchors.right:parent.right
                anchors.bottom:parent.bottom
                tableName: "OT_NALOG_UTOVARA_D1"
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
        onOpened:{
            nalogTable.constFilters=[{"Name" : "UID_NALOGA_UTOVARA_M", "Value" : selectedUID, "Cond" : "="}]
            nalogTable.refreshTable();
        }
    }

    Dialog{
        id:picDial
        width: root.width
        height: root.height
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        Rectangle{
            anchors.top:parent.top
            anchors.left:parent.left
            anchors.right:parent.right
            anchors.bottom: picRow.top
            Image{
                id:bigPic
                anchors.fill:parent
                source:""
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
            bigPic.source="image://multiImageProvider/"+m_imageModel[galleryCounter];
           // bigPic.source=picturesArray[galleryCounter]
        }
        onClosed:{
            img.source="";
            img.source="image://multiImageProvider/"+m_imageModel[galleryCounter];
        }
    }
    MessageDialog{
        id:scanMsgDial
        onOpened: {
            msgTimerInterval=5000
            msgTxt=scanMsg;
            error();
        }
    }



    function createListElement(number) {

        return {
            name:operators[number]["USER_NAME"],
            idCitac:operators[number]["ID_CITACA"],
            vrstaPalete:operators[number]["VrstaPalete"]
        };
    }

    function showMessage(message) {
        showMessageDialog.txtMsg.text = message;
        showMessageDialog.open();
    }

    function deleteAction() {
        showMessage("Deleting some stuff")
    }


    Component.onCompleted: {
        //COMM.http_Request(null, "GET", "DynamicSelect","TableName=" + table1.tableName + "&FilterParams=[]" + "&OrderBy=", "", resp_GET_DynamicSelect);
        //COMM.http_Request(null, "GET", "DynamicSelect","TableName=" + table2.tableName + "&FilterParams=[]" + "&OrderBy=" , "", resp_GET_DynamicSelect2);
        platform=cdBridge.getPlatform()
        deviceName=cdBridge.get_device_name()
        COMM.http_Request(null, "GET", "StatusiDokumenata","groupID=" + "10", "", resp_GET_StatusiDokumenata);
        print("Deviceparams "+ JSON.stringify(cdBridge.getDeviceParams()))
        print("Appparams "+ JSON.stringify(cdBridge.getAppParams()))
        print(platform)
        print("DeviceName "+ JSON.stringify(cdBridge.get_device_name()))
        print("ID_OP "+cdBridge.get_ID_OP())
        // filt=JSON.parse('{"Name":"''", "Value":"%", "Cond": "Like"}'))
        COMM.http_Request(null, "GET", "MjestoUtovaraByDeviceName","DeviceName=" + deviceName, "", resp_GET_MjestoUtovaraByDeviceName);

        switch(deviceName){
        case "OT_TBL1":
            devId="1";
            rampText="Rampa 1";
            break;
        case "OT_TBL2":
            devId="2";
            rampText="Rampa 2";
            break;
        case "OT_TBL3":
            devId="3";
            rampText="Rampa 3";
            break;
        }
        COMM.http_Request(null, "GET", "DynamicSelect","TableName=V_OT_CONFIG" + "&FilterParams=" + '{"Name":"ID_UTOVARNOG_MJESTA", "Value" : '+devId+', "Cond" : "="}' + "&OrderBy=" , "", resp_GET_DynamicSelect3);
        COMM.http_Request(null, "GET", "GetSysParams","ClassName=" + className + "&ObjectName=" + objectNameParam + "&CodeName=" + codeName, "", resp_GET_GetSysParams);
    }

    function resp_GET_DynamicSelect(response)
    {
        var success = response["success"];
        var message = response["message"];
        var data = response["data"];

        if(success === true)
        {

            print("success")
            print("resp_GET_DynamicSelect: " + JSON.stringify(data));
            var rows = data;

            if(rows.length > 0) {
                var row = rows[0];
                var columns = Object.keys(row);
                table1.setBasicModel(columns, rows);
            }
            else {
                table1.setBasicModel([], {});
            }

            print("success done")
        }
        else
        {
            print("resp_GET_DynamicSelect: " + message);
        }
    }
    function resp_GET_DynamicSelect2(response)
    {
        var success = response["success"];
        var message = response["message"];
        var data = response["data"];

        if(success === true)
        {

            print("success")
            print("resp_GET_DynamicSelect: " + JSON.stringify(data));
            var rows = data;

            if(rows.length > 0) {
                var row = rows[0];
                var columns = Object.keys(row);
                table2.setBasicModel(columns, rows);
            }
            else {
                table2.setBasicModel([], {});
            }

            print("success done")
        }
        else
        {
            print("resp_GET_DynamicSelect: " + message);
        }
    }

    //poziv dijagrama (40537) PUT OT_NALOG_UTOVARA_M


    function resp_PUT_OT_NALOG_UTOVARA_M(response)
    {
        var success = response["success"];
        var message = response["message"];
        var data = response["data"];

        if(success === true)
        {
            print("resp_PUT_OT_NALOG_UTOVARA_M: " + JSON.stringify(data));
                tabLayout.currentIndex=1
             COMM.http_Request(null, "GET", "DynamicSelect","TableName=" + table2.tableName + '&FilterParams=[{"Name":"UID_NALOGA_UTOVARA_M","Value":'+'"'+selectedUID+'"'+',"Cond":"="}]' + "&OrderBy=UPDATED_AT" , "", resp_GET_DynamicSelect2);

        }
        else
        {
            print("resp_PUT_OT_NALOG_UTOVARA_M: " + message);
            scanMsg=message;
            scanMsgDial.open();
            scanMsgDial.msgTimer.start();
        }
    }


    function resp_PUT_OT_NALOG_UTOVARA_D2(response)
    {
        var success = response["success"];
        var message = response["message"];
        var data = response["data"];

        if(success === true)
        {
            print("resp_PUT_OT_NALOG_UTOVARA_D2: " + JSON.stringify(data));
        }
        else
        {
            print("resp_PUT_OT_NALOG_UTOVARA_D2: " + message);
        }
    }

    //poziv dijagrama (40512) GET QualityControlStatuses
    //COMM.http_Request(null, "GET", "QualityControlStatuses","groupID=" + groupID, "", resp_GET_QualityControlStatuses);

    function resp_GET_StatusiDokumenata(response)
    {
        var success = response["success"];
        var message = response["message"];
        var data = response["data"];


        if(success === true)
        {
            statusMap =data

            for(let i=0;i<data.length;i++){
                var sColors={}
                sColors["STATUS"]=data[i]["StatusCode"]
                sColors["BackColor"]=data[i]["BackColor"]
                statusMapColors.push(sColors);
                print("Status map colors:"+JSON.stringify(statusMapColors))
            }
            //statusMapColors=JSON.stringify(statusMapColors)
            print("Status map colors!!!:"+statusMapColors)
            print("Boja je"+statusMapColors[2]["BackColor"])
            print("resp_GET_QualityControlStatuses: " + JSON.stringify(data));
            print("status mapa"+statusMap[1]["StatusName"]);
        }
        else
        {
            print("resp_GET_QualityControlStatuses: " + message);
        }
    }


    //poziv dijagrama (40541) DELETE OT_NALOG_UTOVARA_M

    function resp_DELETE_OT_NALOG_UTOVARA_M(response)
    {
        var success = response["success"];
        var message = response["message"];
        var data = response["data"];
        print("resp_DELETE_OT_NALOG_UTOVARA_M !!!!!!!!!!!!: " + JSON.stringify(data));
        if(success === true)
        {
            print("resp_DELETE_OT_NALOG_UTOVARA_M: " + JSON.stringify(data));
        }
        else
        {
            print("resp_DELETE_OT_NALOG_UTOVARA_M: " + message);
        }
    }

    function receiveData (args){
        print("scan_type"+args["scan_type"]);
        print("scan_data"+args["DataSet"]);
        print("scan_message"+args["Message"]);
        print("scan_success"+args["Success"]);
        scanMsg=args["Message"];
        print("scanMsg"+scanMsg)

        if(args["Success"].toUpperCase()=="FALSE" || args["Success"]=="0"){
            scanMsgDial.open();
            scanMsgDial.msgTimer.start();
        }else{
            if(args["scan_type"]=="UPARIVANJE_UTOVARNOG_MJESTA"){
                scanData=JSON.parse(args["DataSet"])
                scanMsg="Operater " + scanData[0]["NAME_OP"] + " ID: " + scanData[0]["ID_OP"] + " uparen sa mjestom: " + scanData[0]["NAME_UTM"];
                scanMsgDial.open();
                listModel.clear()
                COMM.http_Request(null, "GET", "DynamicSelect","TableName=V_OT_CONFIG" + "&FilterParams=" + '{"Name":"ID_UTOVARNOG_MJESTA", "Value" : '+devId+', "Cond" : "="}' + "&OrderBy=" , "", resp_GET_DynamicSelect3);

            }else if(args["scan_type"]=="OCITANJE_OTPREMNICE"){
                scanData=JSON.parse(args["DataSet"])
                scanMsg="Otpremnica: " + scanData[0]["ID_OTPREMNICE"] + " dodana pod nalog: " + scanData[0]["BR_NALOGA_PRIJEVOZA"]
                scanMsgDial.open();

                if(scanData[0]["UID_NALOGA_UTOVARA_M"]!=selectedUID){
                    table1.selectByValue("UID",scanData[0]["UID_NALOGA_UTOVARA_M"])
                }
            }else if(args["scan_type"]=="OCITANJE_PALETE"){
                scanData=JSON.parse(args["DataSet"])
                scanMsg="Paleta: " + scanData[0]["SSCC_PALETE"] + " ocitana na rampi: " + scanData[0]["BR_NALOGA_PRIJEVOZA"] + "pod nalogom: " + scanData[0]["ID_NALOGA_UTOVARA"]
            }
            scanMsgDial.msgTimer.start();
        }
    }

    //poziv dijagrama (40570) GET MjestoUtovaraByDeviceName


    function resp_GET_MjestoUtovaraByDeviceName(response)
    {
        var success = response["success"];
        var message = response["message"];
        var data = response["data"];

        if(success === true)
        {
            print("resp_GET_MjestoUtovaraByDeviceName: " + JSON.stringify(data));
        }
        else
        {
            print("resp_GET_MjestoUtovaraByDeviceName: " + message);
        }
    }
    function resp_GET_DynamicSelect3(response)
    {
        var success = response["success"];
        var message = response["message"];
        var data = response["data"];
        print("resp_GET_DynamicSelect3")

        if(success === true)
        {

            print("success")
            print("resp_GET_DynamicSelect3: " + JSON.stringify(data));
            operators=data;
            operatorsCount=Object.keys(data).length
            print("operatorsCount"+operatorsCount)
            for (let i = 0; i < operatorsCount; i++) {
                listModel.append(createListElement(i));
            }


        }
        else
        {
            print("resp_GET_DynamicSelect: " + message);
        }
    }

    //poziv dijagrama (40572) PUT OT_ZatvaranjeNalogaUtovara


    function resp_PUT_OT_ZatvaranjeNalogaUtovara(response)
    {
        var success = response["success"];
        var message = response["message"];
        var data = response["data"];

        if(success === true)
        {
            print("resp_PUT_OT_ZatvaranjeNalogaUtovara: " + JSON.stringify(data));
        }
        else
        {
            print("resp_PUT_OT_ZatvaranjeNalogaUtovara: " + message);
            scanMsg=message;
            scanMsgDial.open();
            scanMsgDial.msgTimer.start();
        }
    }

    //poziv dijagrama (40582) GET PretragaNaloga


    function resp_GET_PretragaNaloga(response)
    {
        var success = response["success"];
        var message = response["message"];
        var data = response["data"];

        if(success === true)
        {
            print("resp_GET_PretragaNaloga: " + JSON.stringify(data));
            table1.selectByValue("UID",data[0]["UID"])
            var nes={}
            nes["UID"]=selectedUID;
            nes["STATUS"]=2;
            body=JSON.stringify(nes)
            COMM.http_Request(null, "PUT", "OT_NALOG_UTOVARA_M","", body, resp_PUT_OT_NALOG_UTOVARA_M);

        }
        else
        {
            print("resp_GET_PretragaNaloga: " + message);
            scanMsg=message;
            scanMsgDial.open();
            scanMsgDial.msgTimer.start();

        }
    }

    //poziv dijagrama (40547) PUT UPARIVANJE_OPERATERA

    function resp_PUT_UPARIVANJE_OPERATERA(response)
    {
            var success = response["success"];
            var message = response["message"];
            var data = response["data"];

            if(success === true)
            {
                print("resp_PUT_UPARIVANJE_OPERATERA: " + JSON.stringify(data));
                workersTable.refreshTable();
            }
            else
            {
                print("resp_PUT_UPARIVANJE_OPERATERA: " + message);
            }
    }

    //poziv dijagrama (40569) POST NalogUtovaraExport

    function resp_POST_NalogUtovaraExport(response)
    {
            var success = response["success"];
            var message = response["message"];
            var data = response["data"];

            if(success === true)
            {
                print("resp_POST_NalogUtovaraExport: " + JSON.stringify(data));
            }
            else
            {
                print("resp_POST_NalogUtovaraExport: " + message);
            }
    }

    function requestLoadImages() {


        // Reset modela i providera (releasa slike iz memorije 4ever)
        m_imageModel = [];
        multiImageProvider.discardCurrentImages();

        // Stari dijagram za load slike koji na slot vrati poslani ImageID i SessionID
        for(var i = 0; i < picturesArray.length; i++) {
          var temp = {};

          temp["GroupID"] = "40591"; // ID Dijagrama
          temp["GroupUID"] = "{17DA57E9-CA0C-4468-BC10-2A9C5F679B46}"; // UID Dijagrama
          temp["FormName"] = cdBridge.mainFormName(); // Ime forme na kojoj se objekt nalazi
          temp["ObjectName"] = root.objectName; // Ime samog objekta kojega želimo osvježiti
          temp["QMLFunctionName"] = "receiveImage"; // Ime funkcije koju želimo pozvati

          // Globalne varijable dijagrama
          temp["ImgPath"] = picturesArray[i].replace('file:///','');
          temp["ImageID"] = "Image" + i;
          temp["SessionID"] = "";

          print("PICTUREARRAY"+picturesArray[i])
          cdBridge.call_diagram(temp);
        }
      }

    function receiveImage(args) {


      var hexImg = args["DataSet"];
      var imageID = args["ImageID"];

      multiImageProvider.addSourceFromHexString(hexImg, imageID);



      m_imageModel.push(imageID);
        img.source="";
        img.source="image://multiImageProvider/"+m_imageModel[galleryCounter];
        bigPic.source="image://multiImageProvider/"+m_imageModel[galleryCounter];
        //img.source="image://multiImageProvider/Image0";

    }


    states:[
        State{
            name: "mobile"
            when: platform == "mobile"

            PropertyChanges {
                target: table1; constFilters:  [{"Name" : "ID_UTOVARNOG_MJESTA", "Value" : devId , "Cond" : "="}]
            }
            PropertyChanges {
                target:workersBtn; visible: false
            }
            PropertyChanges {
                target:operaterField; visible: true
            }
            PropertyChanges {
                target:deleteBtn; visible: false
            }
            PropertyChanges {
                target:deviceNameRec; visible: if(tabLayout.currentIndex==0){true}else{false}
            }
            PropertyChanges {
                target:repDial; width: parent.width; height:parent.height
            }

        },
        State{
            name: "desktop"
            when: platform == "desktop"

            PropertyChanges {
                target:addDialog; width: 600; height:700
            }
            PropertyChanges {
                target:edDialog; width: 600; height:700
            }
        }
    ]
}
