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
      .whiteText {
        color: rgb(255, 255, 255);
      }
      .templateBackground {
          background-color: #091a2a;
      }
      </style>
    </head>
    <catalogTemplate class="templateBackground" theme="dark">
      <banner>
        <title>Categories</title>
      </banner>
      <list>
        <section>
          <header>
            <title>Select a music style</title>
          </header>
          <listItemLockup>
            <title>Electro Music Radios</title>
            <decorationLabel>25</decorationLabel>
            <relatedContent>
              <grid>
                <section>
        <lockup Id="DanceWave">
          <img src="${this.BASEURL}/resources/images/radio/DanceWave.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Dance Wave</title>
        </lockup>
        <lockup Id="Radiomyme">
            <img src="${this.BASEURL}/resources/images/radio/Radiomyme.jpg" width="308" height="308" />
            <title class="showTextOnHighlight">Radiomyme</title>
        </lockup>
        <lockup Id="IbizaGlobal">
          <img src="${this.BASEURL}/resources/images/radio/ibizaglobalradio.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Ibiza Global Radio</title>
        </lockup>
         <lockup Id="SunshineLive">
          <img src="${this.BASEURL}/resources/images/radio/sunshinelive.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Sunshine Live</title>
        </lockup>
        <lockup Id="Top40">
          <img src="${this.BASEURL}/resources/images/radio/1FMtop40.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">1FM Top 40</title>
        </lockup>
        <lockup Id="ChartHitsFM">
          <img src="${this.BASEURL}/resources/images/radio/ChartHitsFM.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Chart Hits FM</title>
        </lockup>
        <lockup Id="IbizaSonica">
          <img src="${this.BASEURL}/resources/images/radio/ibizasonica.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Ibiza Sonica</title>
        </lockup>
        <lockup Id="Trance1FM">
          <img src="${this.BASEURL}/resources/images/radio/1FMTrance.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">1FM Trance</title>
        </lockup>
        <lockup Id="Radio7">
          <img src="${this.BASEURL}/resources/images/radio/radio7.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Radio Seven</title>
        </lockup>
         <lockup Id="Frisky">
          <img src="${this.BASEURL}/resources/images/radio/frisky.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Frisky</title>
        </lockup>
        <lockup Id="RadioDance1">
          <img src="${this.BASEURL}/resources/images/radio/radiodance.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">1 Radio Dance</title>
        </lockup>
        <lockup Id="BassDrive">
          <img src="${this.BASEURL}/resources/images/radio/bassdrive.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">BassDrive</title>
        </lockup>
        <lockup Id="BigCityBeats">
          <img src="${this.BASEURL}/resources/images/radio/bigcitybeats.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Big City Beats</title>
        </lockup>
        <lockup Id="BlueMarlinIbiza">
          <img src="${this.BASEURL}/resources/images/radio/BlueMarlinIbiza.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Blue Marlin Ibiza</title>
        </lockup>
                </section>
              </grid>
            </relatedContent>
          </listItemLockup>
          <listItemLockup>
            <title>Editor's choice</title>
            <decorationLabel>9</decorationLabel>
            <relatedContent>
              <grid>
                <section>
        <lockup Id="Radiomyme">
            <img src="${this.BASEURL}/resources/images/radio/Radiomyme.jpg" width="308" height="308" />
            <title class="showTextOnHighlight">Radiomyme</title>
        </lockup>
        <lockup Id="ClubOne">
            <img src="${this.BASEURL}/resources/images/radio/Club1.jpg" width="308" height="308" />
            <title class="showTextOnHighlight">Club One</title>
        </lockup>
        <lockup Id="OldOne">
            <img src="${this.BASEURL}/resources/images/radio/OldOne.jpg" width="308" height="308" />
            <title class="showTextOnHighlight">OldOne</title>
        </lockup>
        <lockup Id="NRJ">
            <img src="${this.BASEURL}/resources/images/radio/NRJ.jpg" width="308" height="308" />
            <title class="showTextOnHighlight">NRJ</title>
        </lockup>
        <lockup Id="DanceWave">
            <img src="${this.BASEURL}/resources/images/radio/DanceWave.jpg" width="308" height="308" />
            <title class="showTextOnHighlight">Dance Wave</title>
        </lockup>
        <lockup Id="EliumRadioClub">
            <img src="${this.BASEURL}/resources/images/radio/eliumradio/1.lsr" width="308" height="308" />
            <title class="showTextOnHighlight">EliumRadio Club and Dance</title>
        </lockup>
        <lockup Id="Hotmix">
            <img src="${this.BASEURL}/resources/images/radio/hotmix.jpg" width="308" height="308" />
            <title class="showTextOnHighlight">HotMix Radio Dance</title>
        </lockup>
        <lockup Id="MixFeever">
            <img src="${this.BASEURL}/resources/images/radio/mixfeever.jpg" width="308" height="308" />
            <title class="showTextOnHighlight">MixFeever</title>
        </lockup>
        <lockup Id="Funradio">
            <img src="${this.BASEURL}/resources/images/radio/Funradio.jpg" width="308" height="308" />
            <title class="showTextOnHighlight">Funradio</title>
        </lockup>
        <lockup Id="Parazhit">
            <img src="${this.BASEURL}/resources/images/channels/parazhit.lsr" width="308" height="308" />
            <title class="showTextOnHighlight">Parazhit</title>
        </lockup>
        <lockup Id="EliumRadioRock">
            <img src="${this.BASEURL}/resources/images/radio/eliumradio/2.lsr" width="308" height="308" />
            <title class="showTextOnHighlight">EliumRadio Rock and Pop</title>
        </lockup>
                </section>
              </grid>
            </relatedContent>
          </listItemLockup>
          <listItemLockup>
            <title>French Radios</title>
            <decorationLabel>16</decorationLabel>
            <relatedContent>
              <grid>
                <section>
        			        <lockup Id="RTL">
            <img src="${this.BASEURL}/resources/images/radio/RTL.jpg" width="308" height="308" />
            <title class="showTextOnHighlight">RTL</title>
        </lockup>
        <lockup Id="RTL2">
            <img src="${this.BASEURL}/resources/images/radio/rtl/RTL2.jpg" width="308" height="308" />
            <title class="showTextOnHighlight">RTL 2</title>
        </lockup>
        <lockup Id="Europe1">
            <img src="${this.BASEURL}/resources/images/radio/europe1.jpg" width="308" height="308" />
            <title class="showTextOnHighlight">Europe 1</title>
        </lockup>
        <lockup Id="Contact">
          <img src="${this.BASEURL}/resources/images/radio/contact.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Contact FM</title>
        </lockup>
        <lockup Id="Nostalgie">
            <img src="${this.BASEURL}/resources/images/radio/nostalgie.jpg" width="308" height="308" />
            <title class="showTextOnHighlight">Nostalgie</title>
        </lockup>
        <lockup Id="Skyrock">
            <img src="${this.BASEURL}/resources/images/radio/skyrock.jpg" width="308" height="308" />
            <title class="showTextOnHighlight">Skyrock</title>
        </lockup>
        <lockup Id="RFM">
            <img src="${this.BASEURL}/resources/images/radio/rfm.jpg" width="308" height="308" />
            <title class="showTextOnHighlight">RFM</title>
        </lockup>
        <lockup Id="VirginRadio">
            <img src="${this.BASEURL}/resources/images/radio/virginradio.png" width="308" height="308" />
            <title class="showTextOnHighlight">Virgin Radio</title>
        </lockup>
        <lockup Id="RMC">
            <img src="${this.BASEURL}/resources/images/radio/rmc.jpg" width="308" height="308" />
            <title class="showTextOnHighlight">RMC</title>
        </lockup>
        <lockup Id="CherieFM">
            <img src="${this.BASEURL}/resources/images/radio/cheriefm.jpg" width="308" height="308" />
            <title class="showTextOnHighlight">Cherie FM</title>
        </lockup>
        <lockup Id="NRJ">
            <img src="${this.BASEURL}/resources/images/radio/NRJ.jpg" width="308" height="308" />
            <title class="showTextOnHighlight">NRJ</title>
        </lockup>
        <lockup Id="RireChanson">
            <img src="${this.BASEURL}/resources/images/radio/rireetchanson.jpg" width="308" height="308" />
            <title class="showTextOnHighlight">Rire et Chanson</title>
        </lockup>
        <lockup Id="FranceINFO">
            <img src="${this.BASEURL}/resources/images/radio/franceinfo.jpg" width="308" height="308" />
            <title class="showTextOnHighlight">France Info</title>
        </lockup>
        <lockup Id="FranceINTER">
            <img src="${this.BASEURL}/resources/images/radio/franceinter.jpg" width="308" height="308" />
            <title class="showTextOnHighlight">France Inter</title>
        </lockup>
        <lockup Id="Funradio">
            <img src="${this.BASEURL}/resources/images/radio/Funradio.jpg" width="308" height="308" />
            <title class="showTextOnHighlight">Funradio</title>
        </lockup>
                </section>
              </grid>
            </relatedContent>
          </listItemLockup>
          <listItemLockup>
            <title>Latin Music Radios</title>
            <decorationLabel>15</decorationLabel>
            <relatedContent>
              <grid>
                <section>
          <lockup Id="Quisqueya">
          <img src="${this.BASEURL}/resources/images/radio/Quisqueya.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Quisqueya</title>
        </lockup>
        <lockup Id="RadioPiekary">
          <img src="${this.BASEURL}/resources/images/radio/RadioPiekary.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Radio Piekary</title>
        </lockup>
        <lockup Id="RadioBeatsfm">
          <img src="${this.BASEURL}/resources/images/radio/beatsfm.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Radio Beats FM</title>
        </lockup>
        <lockup Id="RancheritadelAire">
          <img src="${this.BASEURL}/resources/images/radio/RancheritadelAire.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Rancherita del Aire</title>
        </lockup>
        <lockup Id="RadioUnoPlus">
          <img src="${this.BASEURL}/resources/images/radio/RadioUnoPlus.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Radio Uno Plus</title>
        </lockup>
        <lockup Id="ColombiaCrossOver">
          <img src="${this.BASEURL}/resources/images/radio/ColombiaCrossOver.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Colombia CrossOver</title>
        </lockup>
        <lockup Id="COLOMBIASALSAROSA">
          <img src="${this.BASEURL}/resources/images/radio/COLOMBIASALSAROSA.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">COLOMBIASALSAROSA</title>
        </lockup>
        <lockup Id="CUMBIASINMORTALES">
          <img src="${this.BASEURL}/resources/images/radio/CUMBIASINMORTALES.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">CUMBIAS INMORTALES</title>
        </lockup>
        <lockup Id="TropicalisimaBaladas">
          <img src="${this.BASEURL}/resources/images/radio/TropicalisimaBaladas.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Tropicalisima Baladas</title>
        </lockup>
        <lockup Id="RadioKaribeaChala">
          <img src="${this.BASEURL}/resources/images/radio/RadioKaribeaChala.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Radio Karibea Chala</title>
        </lockup>
        <lockup Id="RitmoFM">
          <img src="${this.BASEURL}/resources/images/radio/RitmoFM.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Ritmo 96 5 FM</title>
        </lockup>
        <lockup Id="LaRazaFM">
          <img src="${this.BASEURL}/resources/images/radio/LaRazaFM.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">La Raza 106 1 FM</title>
        </lockup>
        <lockup Id="SuperKFM">
          <img src="${this.BASEURL}/resources/images/radio/SuperKFM.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Super K 100 7 FM</title>
        </lockup>
        <lockup Id="LaXEstereo">
          <img src="${this.BASEURL}/resources/images/radio/LaXEstereo.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">La X Estereo</title>
        </lockup>
        </section>
              </grid>
            </relatedContent>
          </listItemLockup>
          <listItemLockup>
            <title>Pop Music Radios</title>
            <decorationLabel>25</decorationLabel>
            <relatedContent>
              <grid>
                <section>
          <lockup Id="ANTENA1">
          <img src="${this.BASEURL}/resources/images/radio/ANTENA1.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Antena 1</title>
        </lockup>
        <lockup Id="RUSSIANHIT">
          <img src="${this.BASEURL}/resources/images/radio/RUSSIANHIT.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Russian Hit</title>
        </lockup>
        <lockup Id="RADIOSCOOPHUNGARY">
          <img src="${this.BASEURL}/resources/images/radio/RADIOSCOOPHUNGARY.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Radioscoop Hungary</title>
        </lockup>
        <lockup Id="KissFMRomania">
          <img src="${this.BASEURL}/resources/images/radio/KissFMRomania.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">KissFM Romania</title>
        </lockup>
        <lockup Id="HitradioOE3">
          <img src="${this.BASEURL}/resources/images/radio/HitradioOE3.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Hitradio OE3</title>
        </lockup>
        <lockup Id="RadioZULive">
          <img src="${this.BASEURL}/resources/images/radio/RadioZULive.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Radio ZU Live</title>
        </lockup>
        <lockup Id="Evangelizar">
          <img src="${this.BASEURL}/resources/images/radio/Evangelizar.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Evangelizar</title>
        </lockup>
        <lockup Id="LasMasBailadas">
          <img src="${this.BASEURL}/resources/images/radio/LasMasBailadas.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Las Mas Bailadas</title>
        </lockup>
        <lockup Id="KralFM">
          <img src="${this.BASEURL}/resources/images/radio/KralFM.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Kral FM</title>
        </lockup>
        <lockup Id="Shanson">
          <img src="${this.BASEURL}/resources/images/radio/Shansono.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Shanson 101 9 Kiev</title>
        </lockup>
        <lockup Id="KralPop">
          <img src="${this.BASEURL}/resources/images/radio/KralPop.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Kral Pop</title>
        </lockup>
        <lockup Id="AntenneBayern">
          <img src="${this.BASEURL}/resources/images/radio/AntenneBayern.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Antenne Bayern</title>
        </lockup>
        <lockup Id="MegaRadio">
          <img src="${this.BASEURL}/resources/images/radio/MegaRadio.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Mega Radio</title>
        </lockup>
        <lockup Id="RadioRomaniaInternational">
          <img src="${this.BASEURL}/resources/images/radio/RadioRomaniaInternational.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Radio Romania International</title>
        </lockup>
        <lockup Id="DJFMUkraine">
          <img src="${this.BASEURL}/resources/images/radio/DJFMUkraine.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">DJFM Ukraine</title>
        </lockup>
        <lockup Id="Narodniradio">
          <img src="${this.BASEURL}/resources/images/radio/Narodniradio.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Narodni radio</title>
        </lockup>
        <lockup Id="ShowRadyo">
          <img src="${this.BASEURL}/resources/images/radio/ShowRadyo.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Show Radyo</title>
        </lockup>
        <lockup Id="ClubeFM">
          <img src="${this.BASEURL}/resources/images/radio/ClubeFM.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Clube FM</title>
        </lockup>
                </section>
              </grid>
            </relatedContent>
          </listItemLockup>
          <listItemLockup>
            <title>Classic Music Radios</title>
            <decorationLabel>25</decorationLabel>
            <relatedContent>
              <grid>
              <section>
                <lockup Id="RadioMozart">
          <img src="${this.BASEURL}/resources/images/radio/RadioMozart.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Radio Mozart</title>
        </lockup>
        <lockup Id="ABCPiano">
          <img src="${this.BASEURL}/resources/images/radio/ABCPiano.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">ABC Piano</title>
        </lockup>
        <lockup Id="BarockMusic">
          <img src="${this.BASEURL}/resources/images/radio/BarockMusic.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Barock Music</title>
        </lockup>
        <lockup Id="AbacusFMMozartPiano">
          <img src="${this.BASEURL}/resources/images/radio/AbacusFMMozartPiano.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Abacus FM Mozart Piano</title>
        </lockup>
        <lockup Id="AbacusFMBach">
          <img src="${this.BASEURL}/resources/images/radio/AbacusFMBach.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Abacus FM Bach</title>
        </lockup>
        <lockup Id="Mozartiana">
          <img src="${this.BASEURL}/resources/images/radio/Mozartiana.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Mozartiana</title>
        </lockup>
        <lockup Id="HitsClassicalMusic">
          <img src="${this.BASEURL}/resources/images/radio/HitsClassicalMusic.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">1000 Hits Classical Music</title>
        </lockup>
        <lockup Id="InstrumentalHits">
          <img src="${this.BASEURL}/resources/images/radio/InstrumentalHits.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Instrumental Hits</title>
        </lockup>
        <lockup Id="AmbianceClassique">
          <img src="${this.BASEURL}/resources/images/radio/AmbianceClassique.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Ambiance Classique</title>
        </lockup>
        <lockup Id="RadioChopin">
          <img src="${this.BASEURL}/resources/images/radio/RadioChopin.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Radio Chopin</title>
        </lockup>
        <lockup Id="RadioBach">
          <img src="${this.BASEURL}/resources/images/radio/RadioBach.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Radio Bach</title>
        </lockup>
        <lockup Id="BeethovenRadio">
          <img src="${this.BASEURL}/resources/images/radio/BeethovenRadio.jpg" width="308" height="308" />
          <title class="showTextOnHighlight">Beethoven Radio</title>
        </lockup>
                </section>
              </grid>
            </relatedContent>
          </listItemLockup>
        </section>
      </list>
    </catalogTemplate>
  </document>`
}
