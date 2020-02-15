/*
Copyright (C) 2017 Radiomyme. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
A catalog template allows you to display groupings of related items, such as genres of movies or TV shows. View the list of groupings on the left and focus on one to see its items on the right.
*/
var Template = function() { return `<?xml version="1.0" encoding="UTF-8" ?>
<document>
  <head>
    <style>
    .showTextOnHighlight {
      tv-text-highlight-style: show-on-highlight;
    }
    .badge {
      tv-tint-color: rgb(0,0,0);
    }
    .5ColumnGrid {
      tv-interitem-spacing: 50;
    }
    </style>
  </head>
  <productBundleTemplate theme="light">
    <background>
      <img src="${this.BASEURL}/resources/images/background/bg_product_uber3.jpg"/>
    </background>
    <banner>
      <stack>
        <title>Club One</title>
        <subtitle>Online Radio</subtitle>
        <row> 
          <text>Vintage</text>
          <text>70 80 90</text>
          <text>Hits</text>
          <badge src="resource://hd" class="badge" />
        </row>

        <description allowsZooming="true">OldOne is a Vintage/Old song Station based in France. Broadcasting released from international artists form 1970 to 2000. Best hits only !</description>
        <row>
          <buttonLockup Id="OldOne">
            <badge src="resource://button-play" />
            <title>Play</title>
          </buttonLockup>
        </row>
      </stack>
    </banner>
  </productBundleTemplate>
</document>`
}
