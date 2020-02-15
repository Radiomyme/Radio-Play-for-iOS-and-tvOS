/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
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
      <img src="http://data.radiomyme.com/TVOS/tv/resources/images/background/bg_product_uber2.jpg"/>
    </background>
    <banner>
      <stack>
        <title>Club One</title>
        <subtitle>Online Radio</subtitle>
        <row> 
          <text>House</text>
          <text>Chill</text>
          <text>Electro</text>
          <badge src="resource://hd" class="badge" />
        </row>

        <description allowsZooming="true">Club One is the easiest way to enjoy House Music everywhere. Our House Music is provided by young djs all over the world. Club One: Worldwide house music, always on !</description>
        <row>
          <buttonLockup Id="ClubOne">
            <badge src="resource://button-play" />
            <title>Play</title>
          </buttonLockup>
        </row>
      </stack>
    </banner>
  </productBundleTemplate>
</document>`
}
