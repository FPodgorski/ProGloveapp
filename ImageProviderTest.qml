import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
  id: root
  objectName: "root"
  anchors.fill: parent


  // Lista pathova do slika za request prema serveru
  property var images: [];
  // Model za grid
  property var m_imageModel: [];


  Row {
    height: 50
    spacing: 15
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.top: parent.top

    Button {
      text: "Load images"
      onClicked: {
        // Prva lista slika za load
        images = ["Q:\\zagreb.jpg",
                  "Q:\\pexels.jpg",
                  "C:\\Users\\grigorr.INFINITY-MS\\Pictures\\Sup\\DeletePO.jpg",
                  "C:\\Users\\grigorr.INFINITY-MS\\Pictures\\Sup\\OddOneOut2.jpg",
                  "C:\\Users\\grigorr.INFINITY-MS\\Pictures\\Sup\\EditPOSave.jpg",
                  "C:\\Users\\grigorr.INFINITY-MS\\Pictures\\Sup\\OddOneOut3.jpg",
                  "C:\\Users\\grigorr.INFINITY-MS\\Pictures\\Sup\\001Bulbasaur.webp",
          ]

        requestLoadImages();
      }
    }

    Button {
      text: "Load other images"


      onClicked: {
        // Druga lista slika za load
        images = ["C:\\Users\\grigorr.INFINITY-MS\\Pictures\\OEExample2.png",
                  "C:\\Users\\grigorr.INFINITY-MS\\Pictures\\OEExample.png",
        ]
        requestLoadImages();
      }
    }
  }



  Rectangle {
    anchors.fill: parent
    anchors.margins: 50
    color: "maroon"

    GridView {
      id: grid
      anchors.fill: parent

      model: m_imageModel

      cellWidth:  430
      cellHeight: 250

      delegate:  Image {
        id: imageDelegate
        width: grid.cellWidth
        height: grid.cellHeight
        source: "image://multiImageProvider/" + m_imageModel[index]

        MouseArea {
          anchors.fill: parent
          onClicked: {
            print("source = " + imageDelegate.source);
          }
        }
      }
    }
  }


  // Primitivni način da odjebeš random slike koje ne spadaju u session
  property int currentSession: 0

  function requestLoadImages() {

    currentSession++;

    // Reset modela i providera (releasa slike iz memorije 4ever)
    m_imageModel = [];
    multiImageProvider.discardCurrentImages();

    // Stari dijagram za load slike koji na slot vrati poslani ImageID i SessionID
    for(var i = 0; i < images.length; i++) {
      var temp = {};

      temp["GroupID"] = "40591"; // ID Dijagrama
      temp["GroupUID"] = "{17DA57E9-CA0C-4468-BC10-2A9C5F679B46}"; // UID Dijagrama
      temp["FormName"] = cdBridge.mainFormName(); // Ime forme na kojoj se objekt nalazi
      temp["ObjectName"] = root.objectName; // Ime samog objekta kojega želimo osvježiti
      temp["QMLFunctionName"] = "receiveImage"; // Ime funkcije koju želimo pozvati

      // Globalne varijable dijagrama
      temp["ImgPath"] = images[i];
      temp["ImageID"] = "Image" + i;
      temp["SessionID"] = currentSession;

      cdBridge.call_diagram(temp);
    }
  }

  // Slot za učitat sliku
  function receiveImage(args) {

    if(args["SessionID"] != currentSession)
      return;

    var hexImg = args["DataSet"];
    var imageID = args["ImageID"];

    multiImageProvider.addSourceFromHexString(hexImg, imageID);

    m_imageModel.push(imageID);
    grid.model = m_imageModel;
  }
}
