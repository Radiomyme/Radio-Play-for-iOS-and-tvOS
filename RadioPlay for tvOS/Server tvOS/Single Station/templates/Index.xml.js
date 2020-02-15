/*
Copyright (C) 2017 Radiomyme. All Rights Reserved.

*/
var Template = function() { return `<?xml version="1.0" encoding="UTF-8" ?>
<document>
  <head>
    <style>
    .showTextOnHighlight {
      tv-text-highlight-style: show-on-highlight;
    }
    .roundedImageCorners {
      itml-img-treatment: corner-small;
    }
    .customBadgeLayout {
      tv-tint-color: rgb(0, 0, 0);
      margin: 0 0 5 0;
    }
    .slide {
    margin-top: 300px;
     }
     .templateBackground {
          background-color: #091a2a;
      }
    </style>
  </head>
  <menuBarTemplate>
    <menuBar>
      <menuItem template="${this.BASEURL}templates/radio.xml.js" presentation="menuBarItemPresenter">
        <title>Home</title>
      </menuItem>
    </menuBar>
  </menuBarTemplate>
</document>`
}
