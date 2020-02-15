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
      .overlayTextLayout {
        tv-position: top;
      }
      .centeredText {
        text-align: center;
      }
      .customRowText {
      color: rgba(0, 0, 0, 0.6);
      text-align: center;
    }
    .templateBackground {
          background-color: #091a2a;
      }
    </style>
  </head>
  
  <descriptiveAlertTemplate class="templateBackground" theme="dark">
	<title>Editor's Choice</title>
    
    <shelf>
        <section>
        <lockup Id="Radiomyme">
    	<img src="${this.BASEURL}/resources/images/radio/Radiomyme.jpg" width="308" height="308" />
        <title class="showTextOnHighlight">Radiomyme</title>
        </lockup>
        <lockup Id="NRJ">
        <img src="${this.BASEURL}resources/images/channels/nrj.lsr" width="308" height="308" />
        <title class="showTextOnHighlight">NRJ</title>
        </lockup>
        <lockup Id="DanceWave">
        <img src="${this.BASEURL}resources/images/channels/dw.lsr" width="308" height="308" />
        <title class="showTextOnHighlight">Dance Wave</title>
        </lockup>
        <lockup Id="ClubOne">
        <img src="${this.BASEURL}/resources/images/radio/Club1.jpg" width="308" height="308" />
        <title class="showTextOnHighlight">Club One</title>
        </lockup>
        <lockup Id="Hotmix">
        <img src="${this.BASEURL}resources/images/channels/hotmix.lsr" width="308" height="308" />
        <title class="showTextOnHighlight">HotMix Radio Dance</title>
        </lockup>
        <lockup Id="MixFeever">
        <img src="${this.BASEURL}resources/images/channels/mixfeever.lsr" width="308" height="308" />
        <title class="showTextOnHighlight">MixFeever</title>
        </lockup>
        <lockup Id="Funradio">
        <img src="${this.BASEURL}resources/images/channels/funradio.lsr" width="308" height="308" />
        <title class="showTextOnHighlight">Funradio</title>
        </lockup>
        <lockup Id="EliumRadioClub">
        <img src="${this.BASEURL}resources/images/radio/eliumradio/1.lsr" width="450" height="450" />
        <title class="showTextOnHighlight">EliumRadio Club and Dance</title>
        </lockup>
        <lockup Id="Parazhit">
        <img src="${this.BASEURL}resources/images/channels/parazhit.lsr" width="308" height="308" />
    	<title class="showTextOnHighlight">Parazhit</title>
        </lockup>
        <lockup Id="EliumRadioRock">
        <img src="${this.BASEURL}resources/images/radio/eliumradio/2.lsr" width="450" height="450" />
        <title class="showTextOnHighlight">EliumRadio Rock and Pop</title>
        </lockup>
        </section>
      </shelf>
  </descriptiveAlertTemplate>
</document>`
}
