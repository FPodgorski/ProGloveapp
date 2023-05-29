import QtQuick 2.0

Item {

  Component.onCompleted: {
    var temp = [];
    temp.push({"Label" : "Number", "Value" : "123"});
    temp.push({"Label" : "Text", "Value" : "asdfg"});
    temp.push({"Label" : "Date", "Value" : "12.03.2023."});
    temp.push({"Label" : "Moral", "Value" : "none"});
    temp.push({"Label" : "Added", "Value" : "Scrolling"});
    temp.push({"Label" : "Tho", "Value" : "Ree"});

    detBtn.setModel(temp)
  }

  CDDetailsButton {
    id: detBtn
    x: 15
    y: 15
    z:-1

    maxHeight:  350

    titleDetails.gridView.cellWidth:  titleDetails.width / 2
  }
}
