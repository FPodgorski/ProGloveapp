import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "CDCommTest.js" as COMM


ApplicationWindow{
    id:root

    visible:true

    property var operators:""
    property var operatorsCount:""

    property var deviceName:""
    property var devId:""


    property var className:"Nalog utovara"
    property var objectNameParam: "Otprema1"
    property var codeName : "%"
    property var rampText:""

    property var activeUid:""

    property var scanMsg:""
    property var scanData: ""

    property var ischecked:""

    property var nalogNaziv:""

    property var odrediste:""
    property var prijevoznik:""
    property var registarskaOznaka:""

    property var ref:""

    property var waitTxt:""

    property var timerTime:""

    property var detailsArray:[]

    property var palleteID:""

    property var opVrsta:""

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

    Item {
        id: iTabs
        height: 60
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        z:1

        CDDetailsButton {
            id: deviceNameDetailsButton
            anchors.left: parent.left
            anchors.top: parent.top
            minHeight: parent.height - 10
            maxHeight: 300
            enabled: false

            width: 120
            buttonText: ""

            Component.onCompleted: {
                var md = [];

                //            md.push({"Label":"Detail1", "Value":"something1"})
                //            md.push({"Label":"Detail2", "Value":"something2"})
                //            md.push({"Label":"Detail3", "Value":"something3"})
                //            md.push({"Label":"Detail4", "Value":"something4"})

                setModel(md);
            }
        }

        CDDetailsButton {
            id: nalogDetailsButton

            z:200

            visible: sl.currentIndex == 1
            width: 250

            anchors.leftMargin: 25
            anchors.left: deviceNameDetailsButton.right
            anchors.top: parent.top
            minHeight: parent.height - 10
            maxHeight: 300

            buttonText: nalogNaziv

            Component.onCompleted: {
                //          var md = [];

                //           md.push({"Label":"Reg. oznaka", "Value":"something1"})
                //            md.push({"Label":"Detail2", "Value":"something2"})
                //            md.push({"Label":"Detail3", "Value":"something3"})
                //            md.push({"Label":"Detail4", "Value":"something4"})

                //            setModel(md);
            }
        }

        Rectangle{
            id:deviceNameRec
            anchors.top:parent.top
            anchors.left:parent.left
            visible: false
            width:200
            height:50
            color:"#111111"
            border.width: 2
            border.color: "white"
            Text {
                text:rampText
                anchors.centerIn: parent
                color:"white"
                font.pixelSize: 20
            }
        }

        Rectangle{
            id:nalogName
            visible: false
            anchors.top:parent.top
            anchors.left:deviceNameRec.left
            anchors.leftMargin: 300
            width:200
            height:50
            color:"#111111"
            border.width: 2
            border.color: "white"
            Text{
                id:nalogNameTxt
                text:nalogNaziv
                anchors.centerIn: parent
                color:"white"
                font.pixelSize: 20
            }
        }

        Rectangle{
            id:operaterField
            anchors.top:parent.top
            anchors.right:parent.right
            height:50
            z:200
            width:if(root.width<1000){parent.width/2}else{parent.width/3}
            //color:"#111111"
            //radius:5
            //border.width:1
            //border.color:"white"
            border.color: "dodgerblue"
            border.width: 3
            radius: 5
            color: "#292929"

            Text{
                id:noOpTxt
                anchors.fill:parent
                color:"white"
                font.pixelSize: 24
                text:"NEMA PRIJAVLJENIH OPERATERA!!!"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                fontSizeMode: Text.Fit
                wrapMode: Text.WordWrap
            }

            ListView{
                id:operaterList
                anchors.fill:parent
                model:listModel
                orientation: ListView.Horizontal
                delegate:
                    Rectangle {
                    width:operaterField.width/listModel.count
                    //color:"#111111"
                    height: operaterField.height
                    z:300
                    property var spicy:this
                    //border.width: 2
                    //border.color: "white"
                    border.color: "dodgerblue"
                    border.width: 3
                    radius: 5
                    color: "#292929"


                    Text{
                        id:txt1
                        //anchors.top:parent.top
                        text:name
                        font.pixelSize:20
                        color:"white"
                        anchors.centerIn: parent
                        wrapMode: Text.WordWrap
                        width:parent.width
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    MouseArea{
                        anchors.fill:parent
                        onClicked:{
                            if(info.visible==false || ref!=spicy){
                                info.visible=true
                                ref=spicy
                                citacTxt.text="ID čitača: \n" + idCitac
                                paletaTxt.text="Vrsta palete: \n" + vrstaPalete
                            }else{
                                info.visible=false
                            }
                        }
                    }
                }
            }

            Rectangle{
                id:info
                visible:false
                anchors.top:operaterList.bottom
                anchors.left:operaterList.left
                height:120
                width:operaterList.width
                border.color: "dodgerblue"
                border.width: 3
                radius: 5
                color: "#292929"
                Rectangle{
                    anchors.top:parent.top
                    height:parent.height/2
                    width:parent.width
                    color:"transparent"
                    Text{
                        id:citacTxt
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
                        id:paletaTxt
                        anchors.centerIn: parent
                        color:"white"
                        text:"Vrsta palete: \n" + vrstaPalete
                        font.pixelSize: 18
                    }
                }
            }
        }
    }

    StackLayout{
        id:sl
        anchors.top:iTabs.bottom
        anchors.bottom:parent.bottom
        anchors.left:parent.left
        anchors.right:parent.right
        currentIndex: 0

        onCurrentIndexChanged: {
            altTable.refreshTable();
            dV.altTable.refreshTable();
            checkIfEmpty();
            iFocusFix.forceActiveFocus();
        }

        Item{
            id:md
            property alias nijeRoot:nijeRoot
            Item {
                id: nijeRoot
                objectName: "maybeNotRoot"
                anchors.fill: parent

                property var images: [];
                property var m_imageModel: [];

                property var idutovar:"1"



                Rectangle {
                    anchors.fill: parent
                    color: "#161616"
                    z: -1
                }

                Item {
                    id: iFilters
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 305

                    Column {
                        anchors.fill: parent
                        spacing: 15
                        anchors.topMargin: 25
                        anchors.leftMargin: 50
                        anchors.rightMargin: 25

                        CDTextInput {
                            id: tiBrNaloga
                            width: parent.width
                            height: 75
                            label: "SCI"
                            textInput.onDisplayTextChanged:  {
                                nijeRoot.applyFilters()
                            }
                        }

                        CDTextInput {
                            id: tiOdrediste
                            width: parent.width
                            height: 75
                            label: "Odredište"
                            textInput.onDisplayTextChanged:  {
                                nijeRoot.applyFilters()
                            }
                        }

                        CDTextInput {
                            id: tiNazivPrijevoznika
                            width: parent.width
                            height: 75
                            label: "Prijevoznik"
                            textInput.onDisplayTextChanged:  {
                                nijeRoot.applyFilters()
                            }
                        }

                        Button {
                            text: "Apply filters"
                            visible: false
                            height: 75
                            width: 250
                            onClicked: nijeRoot.applyFilters()
                        }
                    }
                }

                function applyFilters() {
                    var filters = [];
                    var filter;

                    if(tiBrNaloga.textInput.displayText != "") {
                        filter = {"Name" : "BR_NALOGA_PRIJEVOZA", "Value" : tiBrNaloga.textInput.displayText, "Cond" : "LIKE"}
                        filters.push(filter);
                    }

                    if(tiOdrediste.textInput.displayText != "") {
                        filter = {"Name" : "ODREDISTE", "Value" :  tiOdrediste.textInput.displayText, "Cond" : "LIKE"}
                        filters.push(filter);
                    }

                    if(tiNazivPrijevoznika.textInput.displayText != "") {
                        filter = {"Name" : "NazivPrijevoznika", "Value" : tiNazivPrijevoznika.textInput.displayText , "Cond" : "LIKE"}
                        filters.push(filter);
                    }

                    altTable.classicTable.activeFilters = filters;
                    altTable.refreshTable();
                }

                Item {
                    id: iTable
                    anchors.top: iFilters.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: iControls.top

                    anchors.leftMargin: 50
                    anchors.rightMargin: 50
                    anchors.bottomMargin: 25

                    CDAlternatingTable {
                        id: altTable
                        anchors.fill: parent
                        tableName: "v_Ot_Nalog_Utovara_M"

                        verticalHeaders:  ["BR_NALOGA_PRIJEVOZA", "ODREDISTE", "NazivPrijevoznika"]
                        verticalDetails: ["NAZIV", "REG_OZN_VOZILA", "VrstaPalete", "Operater"]
                        classicTable.constFilters: [{"Name" : "Status", "Value" : "2", "Cond" : "!="},{"Name" : "Status", "Value" : "5", "Cond" : "!="}]


                        classicTable.visible: false
                        verticalTable.visible: true
                        verticalTable.detailsHeight: verticalTable.detailGridHeight
                        verticalTable.maDetailsEnabled: true
                        verticalTable.headerColumnWidths: [width * 0.5, width*0.25, width*0.25]

                        onTableRefreshed: {
                            if(altTable.verticalTable.m_model.length==1){
                                altTable.verticalTable.selectRow(0);
                            }
                        }

                    }
                }

                Item {
                    id: iControls
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 25
                    height: 75

                    Button {
                        height: parent.height

                        width: parent.width * 0.5
                        anchors.centerIn: parent
                        text: "Odaberi utovarni nalog"

                        highlighted: true
                        //Material.accent: "dodgerblue"
                        //      font.capitalization: Font.Normal
                        font.pixelSize: 36

                        enabled: if(altTable.verticalTable.expandedRows.length > 0){true}else{false}
                        onClicked:{
                            if(operatorsCount>0){
                                COMM.http_Request(null, "GET", "SearchAktivanNalog","idutovar=" + devId, "", resp_GET_SearchAktivanNalog1);


                                activeUid=altTable.fieldByName(altTable.verticalTable.expandedRows[0], "UID")
                                dV.activeUid=activeUid
                                sl.currentIndex=1
                                print("aktivan UID "+activeUid);
                            }else{
                                scanMsg="Nije moguće odabrati nalog, jer nema prijavljenih operatera!!"
                                scanMsgDial.open()
                            }
                        }
                    }
                }

                Component.onCompleted: {
                    COMM.http_Request(null, "GET", "SearchAktivanNalog","idutovar=" + idutovar, "", resp_GET_SearchAktivanNalog);

                }

                //poziv dijagrama (40598) GET SearchAktivanNalog
                function resp_GET_SearchAktivanNalog(response)
                {
                    var success = response["success"];
                    var message = response["message"];
                    var data = response["data"];

                    if(success === true)
                    {
                        if(data!=""){
                            print("resp_GET_SearchAktivanNalog nije : " + JSON.stringify(data));
                            activeUid=data[0]["UID"]
                            ischecked=data[0]["IS_CHECKED"]
                            print("IS_CHECKED!!!"+ischecked)
                            nalogNaziv=data[0]["BR_NALOGA_PRIJEVOZA"]
                            registarskaOznaka=data[0]["REG_OZN_VOZILA"]
                            prijevoznik=data[0]["NazivPrijevoznika"]
                            odrediste=data[0]["ODREDISTE"]
                            detailsArray=[]
                            detailsArray.push({"Label":"Reg. oznaka", "Value":registarskaOznaka})
                            detailsArray.push({"Label":"Prijevoznik", "Value":prijevoznik})
                            detailsArray.push({"Label":"Odrediste", "Value":odrediste})
                            nalogDetailsButton.setModel(detailsArray)
                            dV.registarskaOznaka=registarskaOznaka
                            dV.activeUid=activeUid
                            dV.altTable.refreshTable();
                            sl.currentIndex=1;
                            checkListCheck();
                            checkIfEmpty();

                        }else{
                             sl.currentIndex=0;
                             dV.repDial.close()

                        }
                    }
                    else
                    {
                        print("resp_GET_SearchAktivanNalog: " + message);

                    }
                    COMM.http_Request(null, "GET", "DynamicSelect","TableName=V_OT_CONFIG" + "&FilterParams=" + '{"Name":"ID_UTOVARNOG_MJESTA", "Value" : '+devId+', "Cond" : "="}' + "&OrderBy=" , "", resp_GET_DynamicSelect3);

                }

            }

        }

        Item{
            id:dm
            DrugiView{
                id:dV
                objectName: "DrugiView"
                //activeUid:root.activeUid
                ischecked: root.ischecked
                anchors.fill:parent

                altTable.onTableRefreshed: {
                    checkIfEmpty();
                }

                onCloseNalog: {
                    sl.currentIndex=0;
                    activeUid=""
                    nalogNaziv=""
                    COMM.http_Request(null, "GET", "DynamicSelect","TableName=V_OT_CONFIG" + "&FilterParams=" + '{"Name":"ID_UTOVARNOG_MJESTA", "Value" : '+devId+', "Cond" : "="}' + "&OrderBy=" , "", resp_GET_DynamicSelect3);
                    operatorsCount=0;
                    noOpFunction();
                    print("Nalog uspješno zatvoren");
                    scanMsg="Nalog uspješno zatvoren";
                    closeMsgDial.open()
                    print("=="+scanMsg)

                }
                repDial.onAccepted: {
                    registarskaOznaka=dV.repDial.regOznText;
                    detailsArray=[]
                    detailsArray.push({"Label":"Reg. oznaka", "Value":registarskaOznaka})
                    detailsArray.push({"Label":"Prijevoznik", "Value":prijevoznik})
                    detailsArray.push({"Label":"Odrediste", "Value":odrediste})
                    nalogDetailsButton.setModel(detailsArray)
                }
            }
            Rectangle{
                id:emptyRec
                anchors.fill:parent
                color:"transparent"
                visible:false
                z:-10
                Text{
                    anchors.centerIn: parent
                    height:300
                    text:"Nema paleta pod nalogom"
                    color:"white"
                    font.pointSize: 36
                }
            }
        }
    }
    ListModel {
        id: listModel
    }
    Component.onCompleted: {

        print("FORCING FOCUS")
        iFocusFix.forceActiveFocus();

        deviceName=cdBridge.get_device_name()
        COMM.http_Request(null, "GET", "MjestoUtovaraByDeviceName","DeviceName=" + deviceName, "", resp_GET_MjestoUtovaraByDeviceName);

        print("resp_GET_DynamicSelect3 PARAMETRI"+ devId)
        COMM.http_Request(null, "GET", "GetSysParams","ClassName=" + className + "&ObjectName=" + objectNameParam + "&CodeName=" + codeName, "", resp_GET_GetSysParams);

        noOpFunction();

    }

    Item {
        id: iFocusFix
        focus: true

        onActiveFocusChanged: {
            print("iFocusFix activeFocus changed to " + activeFocus);
        }
    }

    function createListElement(number) {

        return {
            name:operators[number]["USER_NAME"],
            idCitac:operators[number]["ID_CITACA"],
            vrstaPalete:opVrsta
            //vrstaPalete:operators[number]["VrstaPalete"]
        };
    }

    MessageDialog{
        id:scanMsgDial
        z:99
        txtSize: 40
        modal:true

        onOpened: {
            //msgTimerInterval=5000
            msgTxt=scanMsg;
            print("msgtxt"+msgTxt)
            errorCut();
        }
        onClosed: {
            msgTxt=""
        }

    }
    MessageDialog{
        id:waitDial
        txtSize: 40
        modal:true

        z:99
        showBtn: false


        onOpened: {
            timerTxt.start()
            msgTxt=waitTxt+"\n"+countDown;
        }
        timerTxt.onTriggered: {
            if(countDown!=0){
            countDown=countDown-1
            msgTxt=waitTxt+"\n"+countDown;
            }else{
                timerTxt.running=false
            }
        }

        onClosed: {
            msgTxt=""
        }

    }
    MessageDialog{
        id:closeMsgDial
        z:99
        txtSize: 40
        modal:true

        onOpened: {
            msgTxt="Nalog uspješno zatvoren";
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
            if(operatorsCount!=0){
                cdBridge.setUsername(operators[0]["USERNAME"])
            }
            print("operatorsCount"+operatorsCount)
            listModel.clear()
            for (let i = 0; i < operatorsCount; i++) {
                if(operators[i]["VrstaPalete"]!=null){
                    opVrsta=operators[i]["VrstaPalete"]
                }else{
                    opVrsta=""
                }

                listModel.append(createListElement(i));
            }
            noOpFunction()

        }
        else
        {
            print("resp_GET_DynamicSelect3: " + message);
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
            // scanMsgDial.msgTimer.start();
        }else{
            if(args["scan_type"]=="UPARIVANJE_UTOVARNOG_MJESTA"){
                scanData=JSON.parse(args["DataSet"])
                scanMsg="Operater " + scanData[0]["NAME_OP"] + " ID: " + scanData[0]["ID_OP"] + " uparen sa mjestom: " + scanData[0]["NAME_UTM"];
                scanMsgDial.open();
                noOpFunction()
                COMM.http_Request(null, "GET", "DynamicSelect","TableName=V_OT_CONFIG" + "&FilterParams=" + '{"Name":"ID_UTOVARNOG_MJESTA", "Value" : '+devId+', "Cond" : "="}' + "&OrderBy=" , "", resp_GET_DynamicSelect3);

            }else if(args["scan_type"]=="OCITANJE_OTPREMNICE"){
                scanData=JSON.parse(args["DataSet"])
                scanMsg="Otpremnica: " + scanData[0]["ID_OTPREMNICE"] + " dodana pod nalog: " + scanData[0]["BR_NALOGA_PRIJEVOZA"]
                scanMsgDial.open();

            }else if(args["scan_type"]=="OCITANJE_PALETE"){
                scanData=args["DataSet"]
                print("PALETA SCAN!!!"+args)
                print("PALETA SCAN!!!"+JSON.stringify(args))
                print("PALETA SCAN!!!"+JSON.parse(args))
                scanMsg="Paleta: " + scanData[0]["SSCC_PALETE"] + " ocitana na rampi: " + scanData[0]["BR_NALOGA_PRIJEVOZA"] + "pod nalogom: " + scanData[0]["ID_NALOGA_UTOVARA"]
                scanMsgDial.open();
                dV.altTable.refreshTable();
                dV.altTable.refreshTable();
            }
            //scanMsgDial.msgTimer.start();
        }
    }
    function resp_GET_SearchAktivanNalog1(response)
    {
        var success = response["success"];
        var message = response["message"];
        var data = response["data"];

        if(success === true)
        {
            if(data!=""){
                print("resp_GET_SearchAktivanNalog1: " + JSON.stringify(data));
                print("Nalog postoji lol");
                activeUid=data[0]["UID"]
                root.ischecked=data[0]["IS_CHECKED"]
                scanMsg="Nalog: " + data[0]["NAZIV"] + " je već aktivan"
                scanMsgDial.open();
                nalogNaziv=data[0]["BR_NALOGA_PRIJEVOZA"];
                registarskaOznaka=data[0]["REG_OZN_VOZILA"]
                prijevoznik=data[0]["NazivPrijevoznika"]
                odrediste=data[0]["ODREDISTE"]
                dV.registarskaOznaka=registarskaOznaka
                detailsArray=[]
                detailsArray.push({"Label":"Reg. oznaka", "Value":registarskaOznaka})
                detailsArray.push({"Label":"Prijevoznik", "Value":prijevoznik})
                detailsArray.push({"Label":"Odrediste", "Value":odrediste})
                nalogDetailsButton.setModel(detailsArray)
                dV.activeUid=activeUid
                dV.altTable.refreshTable();
                sl.currentIndex=1
                checkListCheck();
                print("aktivan UID "+activeUid);
                checkIfEmpty();
            }else{
                activeUid=altTable.fieldByName(altTable.verticalTable.expandedRows[0], "UID")
                nalogNaziv=altTable.fieldByName(altTable.verticalTable.expandedRows[0], "BR_NALOGA_PRIJEVOZA")
                registarskaOznaka=altTable.fieldByName(altTable.verticalTable.expandedRows[0], "REG_OZN_VOZILA")
                prijevoznik=altTable.fieldByName(altTable.verticalTable.expandedRows[0], "NazivPrijevoznika")
                odrediste=altTable.fieldByName(altTable.verticalTable.expandedRows[0], "ODREDISTE")
                root.ischecked=altTable.fieldByName(altTable.verticalTable.expandedRows[0], "IS_CHECKED")
                detailsArray=[]
                detailsArray.push({"Label":"Reg. oznaka", "Value":registarskaOznaka})
                detailsArray.push({"Label":"Prijevoznik", "Value":prijevoznik})
                detailsArray.push({"Label":"Odrediste", "Value":odrediste})
                nalogDetailsButton.setModel(detailsArray)
                var nes={}
                nes["UID"]=activeUid;
                nes["STATUS"]=2;
                nes["ID_UTOVARNOG_MJESTA"]=devId
                var body=JSON.stringify(nes)
                COMM.http_Request(null, "PUT", "OT_NALOG_UTOVARA_M","", body, resp_PUT_OT_NALOG_UTOVARA_M);
                dV.activeUid=activeUid
                dV.altTable.refreshTable();
                dV.registarskaOznaka=registarskaOznaka
                sl.currentIndex=1
                checkListCheck();
                print("aktivan UID "+activeUid);
                print("nema aktivnog naloga")
                checkIfEmpty();
            }

            //activeUid=data["UID"]
            //sl.currentIndex=1;
        }
        else
        {
            print("resp_GET_SearchAktivanNalog1: " + message);
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
            scanMsgDial.error=true;
            scanMsgDial.errorCut();
            scanMsg=message;
            scanMsgDial.open();
            // scanMsgDial.msgTimer.start();
        }
    }
    function checkListCheck(){
        if(ischecked!=true){
            dV.repDial.uid=activeUid;
            dV.repDial.open();
        }
    }

    function checkIfEmpty(){
        print("checkIfEmpty"+dV.altTable.verticalTable.m_model.length)
        if(sl.currentIndex==1 && dV.altTable.verticalTable.m_model.length==0){
            emptyRec.z=100
            emptyRec.visible=true

        }else{
            emptyRec.visible=false
            emptyRec.z=-99
        }
    }

    function register() {
        COMM.registerToBroker("OCITANJE_PALETE/"+devId, ocPalete);
    }
    function register2() {
        COMM.registerToBroker("UPARIVANJE_UTOVARNOG_MJESTA", upUtovar);
    }
    function register3() {
        COMM.registerToBroker("OCITANJE_OTPREMNICE/"+devId, ocOtpr);
    }
    function registerOcitanjeStart() {
        COMM.registerToBroker("OCITANJE_PALETE_POKRENUTO/"+devId, ocitanjeStart);
    }
    function registerVrPalete() {
        COMM.registerToBroker("VRSTA_PALETE", vrPalete);
    }
    function uparivanjeOp() {
        COMM.registerToBroker("UPARIVANJE_OPERATERA", opUparivanje);
    }

    function registerRefresh(){
        print("NALOG_UTOVARA_M REGISTRIRAN")
        let topic="NALOG_UTOVARA_M_REFRESH/"+devId
        print("TOPIC"+topic)
        COMM.registerToBroker(topic, refresh);

    }


    function refresh(args){
        print("callback refresh")
        COMM.http_Request(null, "GET", "SearchAktivanNalog","idutovar=" + devId, "", md.nijeRoot.resp_GET_SearchAktivanNalog);

    }


    function opUparivanje(args){
        COMM.http_Request(null, "GET", "DynamicSelect","TableName=V_OT_CONFIG" + "&FilterParams=" + '{"Name":"ID_UTOVARNOG_MJESTA", "Value" : '+devId+', "Cond" : "="}' + "&OrderBy=UPDATED_AT desc" , "", resp_GET_DynamicSelect3);

    }

    function ocPalete(args) {
        waitDial.close()
            if(JSON.parse(args)["success"]=="0"){
                scanMsgDial.error=true;
                scanMsgDial.errorCut();
                scanMsg=JSON.parse(args)["message"];
                scanMsgDial.open();

            }else{
                print("receiveParseTopic called with args = " + JSON.stringify(args));
                print()
                scanData=JSON.parse(args)["data"]
                scanData=JSON.parse(scanData)
                print("PUTEVI"+scanData[0]["PATHS"])
                let scanPath=scanData[0]["PATHS"]
                let scanPaths=[]
                scanPath=JSON.parse(scanPath)
                print("PUT"+scanPath[0]["Path"])
                scanPaths.push(scanPath[0]["Path"]);
                scanPaths.push(scanPath[1]["Path"]);
                scanMsgDial.error=false;
                scanMsg="Paleta: " + scanData[0]["SSCC_PALETE"] + " ocitana na rampi: " + scanData[0]["ID_UTOVARNOG_MJESTA"] + " pod nalogom: " + scanData[0]["ID_NALOGA_UTOVARA"]
                //scanMsgDial.open();

                palleteID=scanData[0]["SSCC_PALETE"];
                print("1. " + palleteID)

                // dV.requestLoadImages()
                dV.altTable.refreshTable();
                dV.scanPictures(scanPaths,palleteID);
                checkIfEmpty();
            }

    }
    function upUtovar(args) {
        if(JSON.parse(args)["success"]=="0"){
            scanMsgDial.error=true;
            scanMsgDial.errorCut();
            scanMsg=JSON.parse(args)["message"];
            scanMsgDial.open();

        }else{
            print("upUtovar = " + args);
            print("upUtovar = " + JSON.parse(args)["data"]);
            scanData=JSON.parse(args)["data"]
            print("JSON PARSE ARGS"+scanData)
            scanData=JSON.parse(scanData)
            print("JSON 2nd PARSE ARGS"+scanData)
            noOpFunction()
            cdBridge.setUsername(scanData[0]["USERNAME"])
            print("USERNAME"+scanData[0]["USERNAME"])
            if(scanData[0]["ID_UTOVARNOG_MJESTA"]==devId){
                scanMsgDial.error=false;
                scanMsg="Operater " + scanData[0]["NAME_OP"] + " ID: " + scanData[0]["ID_OP"] + " uparen sa mjestom: " + scanData[0]["NAME_UTM"];
                scanMsgDial.open();
            }

            iFocusFix.forceActiveFocus();
            COMM.http_Request(null, "GET", "DynamicSelect","TableName=V_OT_CONFIG" + "&FilterParams=" + '{"Name":"ID_UTOVARNOG_MJESTA", "Value" : '+devId+', "Cond" : "="}' + "&OrderBy=UPDATED_AT desc" , "", resp_GET_DynamicSelect3);
        }
    }
    function ocOtpr(args) {
        print("receiveParseTopic called with args = " + JSON.stringify(args));
        if(JSON.parse(args)["success"]=="0"){
            scanMsgDial.error=true;
            scanMsgDial.errorCut();
            scanMsg=JSON.parse(args)["message"];
            scanMsgDial.open();

        }else{

            //print("receiveParseTopic called with args PARSE= " + JSON.parse(args));
            print("PARSE"+JSON.parse(args)["data"])
            scanData=JSON.parse(args)["data"]
            print("JSON PARSE ARGS"+scanData)
            scanData=JSON.parse(scanData)
            print("JSON 2nd PARSE ARGS"+scanData)
            scanMsgDial.error=false;
            scanMsg="Otpremnica: " + scanData[0]["ID_OTPREMNICE"] + " dodana pod nalog: " + scanData[0]["BR_NALOGA_PRIJEVOZA"]
            scanMsgDial.open();
            dV.naloziTableDial.rfrsh();
        }

    }
    function vrPalete(args) {
        print("receiveParseTopic called with args = " + JSON.stringify(args));
        if(JSON.parse(args)["success"]=="0"){
            scanMsgDial.error=true;
            scanMsgDial.errorCut();
            scanMsg=JSON.parse(args)["message"];
            scanMsgDial.open();

        }else{

            print("PARSE"+JSON.parse(args)["data"])
            noOpFunction()
            COMM.http_Request(null, "GET", "DynamicSelect","TableName=V_OT_CONFIG" + "&FilterParams=" + '{"Name":"ID_UTOVARNOG_MJESTA", "Value" : '+devId+', "Cond" : "="}' + "&OrderBy=" , "", resp_GET_DynamicSelect3);
        }
    }

    function upOprtr(args) {
        print("receiveParseTopic called with args = " + JSON.stringify(args));
        if(JSON.parse(args)["success"]=="0"){
            scanMsgDial.error=true;
            scanMsgDial.errorCut();
            scanMsg=JSON.parse(args)["message"];
            scanMsgDial.open();

        }else{

            print("PARSE"+JSON.parse(args)["data"])
            scanData=JSON.parse(args)["data"]
            print("JSON PARSE ARGS"+scanData)
            scanData=JSON.parse(scanData)
            print("JSON 2nd PARSE ARGS"+scanData)
            scanMsgDial.error=false;
            scanMsg="Otpremnica: " + scanData[0]["ID_OTPREMNICE"] + " dodana pod nalog: " + scanData[0]["BR_NALOGA_PRIJEVOZA"]
            scanMsgDial.open();
            dV.naloziTableDial.rfrsh();
        }
    }

    function ocitanjeStart(args){
        print("PARSE"+JSON.parse(args)["data"])
        scanData=JSON.parse(args)["data"]
        print("JSON PARSE ARGS"+scanData)
        scanData=JSON.parse(scanData)
        //timerTime=scanData[0]["SleepMS"]
        print("JSON 2nd PARSE ARGS"+scanData)
        timerTime=scanData["SleepMS"]/1000
        print("timerTime"+scanData["SleepMS"])
        print("WTF"+JSON.parse(args)["message"])
        waitTxt=JSON.parse(args)["message"]
        dV.scanPicDial.close();
        waitDial.countDown=timerTime
        waitDial.open();
    }

    function noOpFunction(){
        if(operatorsCount==0){
            noOpTxt.visible=true;
        }else{
            noOpTxt.visible=false;
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
            devId=data[0]["ID"]
            print(devId)
            deviceNameDetailsButton.buttonText=data[0]["NAZIV"]
            COMM.http_Request(null, "GET", "DynamicSelect","TableName=V_OT_CONFIG" + "&FilterParams=" + '{"Name":"ID_UTOVARNOG_MJESTA", "Value" : '+devId+', "Cond" : "="}' + "&OrderBy=" , "", resp_GET_DynamicSelect3);
            register()
            register2()
            register3()
            registerVrPalete()
            registerOcitanjeStart()
            registerRefresh();
            uparivanjeOp();
        }
        else
        {
            print("resp_GET_MjestoUtovaraByDeviceName: " + message);
        }
    }
}

