/*
Copyright (C) 2015 Hani Hamrouni. All Rights Reserved.

*/

var Presenter = {

    /**
     * @description This function demonstrate the default way of present a document. 
     * The document can be presented on screen by adding to to the documents array
     * of the navigationDocument. The navigationDocument allows you to manipulate
     * the documents array with the pushDocument, popDocument, replaceDocument, and
     * removeDocument functions. 
     *
     * You can replace an existing document in the navigationDocumetn array by calling 
     * the replaceDocument function of navigationDocument. replaceDocument requires two
     * arguments: the new document, the old document.
     * @param {Document} xml - The XML document to push on the stack
     */
    defaultPresenter: function(xml) {

        /*
        If a loading indicator is visible, we replace it with our document, otherwise 
        we push the document on the stack
        */
        if(this.loadingIndicatorVisible) {
            navigationDocument.replaceDocument(xml, this.loadingIndicator);
            this.loadingIndicatorVisible = false;
        } else {
            navigationDocument.pushDocument(xml);
        }
    },

    /**
     * @description This function demonstrates the presentation of documents as modals.
     * You can present and manage a document in a modal view by using the pushModal() and
     * removeModal() functions. Only a single document may be presented as a modal at
     * any given time. Documents presented in the modal view are presented in fullscreen
     * with a semi-transparent background that blurs the document below it.
     *
     * @param {Document} xml - The XML document to present as modal
     */
    modalDialogPresenter: function(xml) {
        navigationDocument.presentModal(xml);
    },

    /**
     * @description This function demonstrates how to present documents within a menu bar.
     * Each item in the menu bar can have a single document associated with it. To associate
     * document to you an item you use the MenuBarDocument feature.
     *
     * Menu bar elements have a MenuBarDocument feature that stores the document associated
     * with a menu bar element. In JavaScript you access the MenuBarDocument by invoking the 
     * getFeature function on the menuBar element. 
     *
     * A feature in TVMLKit is a construct for attaching extended capabilities to an
     * element. See the TVMLKit documentation for information on elements with available
     * features.
     *
     * @param {Document} xml - The XML document to associate with a menu bar element
     * @param {Element} ele - The currently selected item element
     */
    menuBarItemPresenter: function(xml, ele) {
        /*
        To get the menu bar's 'MenuBarDocument' feature, we move up the DOM Node tree using
        the parentNode property. This allows us to access the the menuBar element from the 
        current item element.
        */
        var feature = ele.parentNode.getFeature("MenuBarDocument");

        if (feature) {
            /*
            To retrieve the document associated with the menu bar element, if one has been 
            set, you call the getDocument function the MenuBarDocument feature. The function
            takes one argument, the item element.
            */
            var currentDoc = feature.getDocument(ele);
            /*
            To present a document within the menu bar, you need to associate it with the 
            menu bar item. This is accomplished by call the setDocument function on MenuBarDocument
            feature. The function takes two argument, the document to be presented and item it 
            should be associated with.

            In this implementation we are only associating a document once per menu bar item. You can 
            associate a document each time the item is selected, or you can associate documents with 
            all the menu bar items before the menu bar is presented. You will need to experimet here
            to balance document presentation times with updating the document items.
            */
            if (!currentDoc) {
                feature.setDocument(xml, ele);
            }
        }
    },

    /**
     * @description This function handles the select event and invokes the appropriate presentation method.
     * This is only one way to implent a system for presenting documents. You should determine
     * the best system for your application and data model.
     *
     * @param {Event} event - The select event
     */
    load: function(event) {
        console.log(event);

        var self = this,
            ele = event.target,
            templateURL = ele.getAttribute("template"),
            presentation = ele.getAttribute("presentation");
            videoURL = ele.getAttribute("videoURL");
            Id = ele.getAttribute("Id");
            imageURL = ele.getAttribute("imageURL");
            nomURL = ele.getAttribute("nomURL");
  if(Id) {
    flux = LiveFlux[Id];
    var player = new Player();
    player.playlist = new Playlist();
    flux.forEach(function(metadata) {
        var audio = new MediaItem("audio", metadata.url);
        audio.url = metadata.url;
        audio.title = metadata.title;
        audio.subtitle = metadata.subtitle;
        audio.description = metadata.description;
        audio.artworkImageURL = metadata.artworkImageURL;
        audio.contentRatingDomain = metadata.contentRatingDomain;
        audio.contentRatingRanking = metadata.contentRatingRanking;
        audio.resumeTime = metadata.resumeTime;
        
        player.playlist.push(audio);
    });
    setPlaybackEventListeners(player);
    player.present();
   	player.play();
  }
  if(videoURL) {
    var player = new Player();
    player.playlist = new Playlist();
    var mediaItem = new MediaItem("audio", videoURL);
    mediaItem.url = ele.getAttribute("videoURL");
    mediaItem.title = ele.getAttribute("nomURL");
    mediaItem.artworkImageURL = ele.getAttribute("imageURL");
    player.playlist.push(mediaItem);
    setPlaybackEventListeners(player);
    player.present();
    player.play();
  }

        /*
        Check if the selected element has a 'template' attribute. If it does then we begin
        the process to present the template to the user.
        */
        if (templateURL) {
            /*
            Whenever a user action is taken you need to visually indicate to the user that
            you are processing their action. When a users action indicates that a new document
            should be presented you should first present a loadingIndicator. This will provide
            the user feedback if the app is taking a long time loading the data or the next 
            document.
            */
            self.showLoadingIndicator(presentation);

            /* 
            Here we are retrieving the template listed in the templateURL property.
            */
            resourceLoader.loadResource(templateURL,
                function(resource) {
                    if (resource) {
                        /*
                        The XML template must be turned into a DOMDocument in order to be 
                        presented to the user. See the implementation of makeDocument below.
                        */
                        var doc = self.makeDocument(resource);
                        
                        /*
                        Event listeners are used to handle and process user actions or events. Listeners
                        can be added to the document or to each element. Events are bubbled up through the
                        DOM heirarchy and can be handled or cancelled at at any point.

                        Listeners can be added before or after the document has been presented.

                        For a complete list of available events, see the TVMLKit DOM Documentation.
                        */
                        doc.addEventListener("select", self.load.bind(self));
                        
                        /*
                        This is a convenience implementation for choosing the appropriate method to 
                        present the document. 
                        */
                        if (self[presentation] instanceof Function) {
                            self[presentation].call(self, doc, ele);
                        } else {
                            self.defaultPresenter.call(self, doc);
                        }
                    }
                }
            );
        }
    },

    /**
     * @description This function creates a XML document from the contents of a template file.
     * In this example we are utilizing the DOMParser to transform the Index template from a 
     * string representation into a DOMDocument.
     *
     * @param {String} resource - The contents of the template file
     * @return {Document} - XML Document
     */
    makeDocument: function(resource) {
        if (!Presenter.parser) {
            Presenter.parser = new DOMParser();
        }

        var doc = Presenter.parser.parseFromString(resource, "application/xml");
        return doc;
    },

    /**
     * @description This function handles the display of loading indicators.
     *
     * @param {String} presentation - The presentation function name
     */
    showLoadingIndicator: function(presentation) {
        /*
        You can reuse documents that have previously been created. In this implementation
        we check to see if a loadingIndicator document has already been created. If it 
        hasn't then we create one.
        */
        if (!this.loadingIndicator) {
            this.loadingIndicator = this.makeDocument(this.loadingTemplate);
        }
        
        /* 
        Only show the indicator if one isn't already visible and we aren't presenting a modal.
        */
        if (!this.loadingIndicatorVisible && presentation != "modalDialogPresenter" && presentation != "menuBarItemPresenter") {
            navigationDocument.pushDocument(this.loadingIndicator);
            this.loadingIndicatorVisible = true;
        }
    },

    /**
     * @description This function handles the removal of loading indicators.
     * If a loading indicator is visible, it removes it from the stack and sets the loadingIndicatorVisible attribute to false.
     */
    removeLoadingIndicator: function() {
        if (this.loadingIndicatorVisible) {
            navigationDocument.removeDocument(this.loadingIndicator);
            this.loadingIndicatorVisible = false;
        }
    },

    /**
     * @description Instead of a loading a template from the server, it can stored in a property 
     * or variable for convenience. This is generally employed for templates that can be reused and
     * aren't going to change often, like a loadingIndicator.
     */
    loadingTemplate: `<?xml version="1.0" encoding="UTF-8" ?>
        <document>
          <loadingTemplate>
            <activityIndicator>
              <text>Loading...</text>
            </activityIndicator>
          </loadingTemplate>
        </document>`
}

function setPlaybackEventListeners(currentPlayer) {

    /**
     * The requestSeekToTime event is called when the user attempts to seek to a specific point in the asset.
     * The listener is passed an object with the following attributes:
     * - type: this attribute represents the name of the event
     * - target: this attribute represents the event target which is the player object
     * - timeStamp: this attribute represents the timestamp of the event
     * - currentTime: this attribute represents the current playback time in seconds
     * - requestedTime: this attribute represents the time to seek to in seconds
     * The listener must return a value:
     * - true to allow the seek
     * - false or null to prevent it
     * - a number representing an alternative point in the asset to seek to, in seconds
     * @note Only a single requestSeekToTime listener can be active at any time. If multiple eventListeners are added for this event, only the last one will be called.
     */
    currentPlayer.addEventListener("requestSeekToTime", function(event) {
        console.log("Event: " + event.type + "\ntarget: " + event.target + "\ntimestamp: " + event.timeStamp + "\ncurrent time: " + event.currentTime + "\ntime to seek to: " + event.requestedTime) ;
        return true;
    });


    /**
     * The shouldHandleStateChange is called when the user requests a state change, but before the change occurs.
     * The listener is passed an object with the following attributes:
     * - type: this attribute represents the name of the event
     * - target: this attribute represents the event target which is the player object
     * - timeStamp: this attribute represents the name of the event
     * - state: this attribute represents the state that the player will switch to, possible values: playing, paused, scanning
     * - oldState: this attribute represents the previous state of the player, possible values: playing, paused, scanning
     * - elapsedTime: this attribute represents the elapsed time, in seconds
     * - duration: this attribute represents the duration of the asset, in seconds
     * The listener must return a value:
     * - true to allow the state change
     * - false to prevent the state change
     * This event should be handled as quickly as possible because the user has already performed the action and is waiting for the application to respond.
     * @note Only a single shouldHandleStateChange listener can be active at any time. If multiple eventListeners are added for this event, only the last one will be called.
     */
    currentPlayer.addEventListener("shouldHandleStateChange", function(event) {
        console.log("Event: " + event.type + "\ntarget: " + event.target + "\ntimestamp: " + event.timeStamp + "\nold state: " + event.oldState + "\nnew state: " + event.state + "\nelapsed time: " + event.elapsedTime + "\nduration: " + event.duration);
        return true;
    });

    /**
     * The stateDidChange event is called after the player switched states.
     * The listener is passed an object with the following attributes:
     * - type: this attribute represents the name of the event
     * - target: this attribute represents the event target which is the player object
     * - timeStamp: this attribute represents the timestamp of the event
     * - state: this attribute represents the state that the player switched to
     * - oldState: this attribute represents the state that the player switched from
     */
    currentPlayer.addEventListener("stateDidChange", function(event) {
        console.log("Event: " + event.type + "\ntarget: " + event.target + "\ntimestamp: " + event.timeStamp + "\noldState: " + event.oldState + "\nnew state: " + event.state);
    });

    /**
     * The stateWillChange event is called when the player is about to switch states.
     * The listener is passed an object with the following attributes:
     * - type: this attribute represents the name of the event
     * - target: this attribute represents the event target which is the player object
     * - timeStamp: this attribute represents the timestamp of the event
     * - state: this attribute represents the state that the player switched to
     * - oldState: this attribute represents the state that the player switched from
     */
    currentPlayer.addEventListener("stateWillChange", function(event) {
        console.log("Event: " + event.type + "\ntarget: " + event.target + "\ntimestamp: " + event.timeStamp + "\noldState: " + event.oldState + "\nnew state: " + event.state);
    });

    /**
     * The timeBoundaryDidCross event is called every time a particular time point is crossed during playback.
     * The listener is passed an object with the following attributes:
     * - type: this attribute represents the name of the event
     * - target: this attribute represents the event target which is the player object
     * - timeStamp: this attribute represents the timestamp of the event
     * - boundary: this attribute represents the boundary value that was crossed to trigger the event
     * When adding the listener, a third argument has to be provided as an array of numbers, each representing a time boundary as an offset from the beginning of the asset, in seconds.
     * @note This event can fire multiple times for the same time boundary as the user can scrub back and forth through the asset.
     */
    currentPlayer.addEventListener("timeBoundaryDidCross", function(event) {
        console.log("Event: " + event.type + "\ntarget: " + event.target + "\ntimestamp: " + event.timeStamp + "\nboundary: " + event.boundary);
    }, [30, 100, 150.5, 180.75]);

    /**
     * The timeDidChange event is called whenever a time interval has elapsed, this interval must be provided as the third argument when adding the listener.
     * The listener is passed an object with the following attributes:
     * - type: this attribute represents the name of the event
     * - target: this attribute represents the event target which is the player object
     * - timeStamp: this attribute represents the timestamp of the event
     * - time: this attribute represents the current playback time, in seconds.
     * - interval: this attribute represents the time interval
     * @note The interval argument should be an integer value as floating point values will be coerced to integers. If omitted, this value defaults to 1
     */
    currentPlayer.addEventListener("timeDidChange", function(event) {
        console.log("Event: " + event.type + "\ntarget: " + event.target + "\ntimestamp: " + event.timeStamp + "\ntime: " +  event.time + "\ninterval: " + event.interval);
    }, { interval: 10 });

    /**
     * The mediaItemDidChange event is called after the player switches media items.
     * The listener is passed an event object with the following attributes:
     * - type: this attribute represents the name of the event
     * - target: this attribute represents the event target which is the player object
     * - timeStamp: this attribute represents the timestamp of the event
     * - reason: this attribute represents the reason for the change; possible values are: 0 (Unknown), 1 (Played to end), 2 (Forwarded to end), 3 (Errored), 4 (Playlist changed), 5 (User initiated)
     */
    currentPlayer.addEventListener("mediaItemDidChange", function(event) {
        console.log("Event: " + event.type + "\ntarget: " + event.target + "\ntimestamp: " + event.timeStamp + "\nreason: " + event.reason);
    });

   /**
     * The mediaItemWillChange event is when the player is about to switch media items.
     * The listener is passed an event object with the following attributes:
     * - type: this attribute represents the name of the event
     * - target: this attribute represents the event target which is the player object
     * - timeStamp: this attribute represents the timestamp of the event
     * - reason: this attribute represents the reason for the change; possible values are: 0 (Unknown), 1 (Played to end), 2 (Forwarded to end), 3 (Errored), 4 (Playlist changed), 5 (User initiated)
     */
    currentPlayer.addEventListener("mediaItemWillChange", function(event) {
        console.log("Event: " + event.type + "\ntarget: " + event.target + "\ntimestamp: " + event.timeStamp + "\nreason: " + event.reason);
    });
}


var LiveFlux = {
    Radiomyme: [{
        title: "Radiomyme",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/Radiomyme.jpg",
        url: "http://listen.radionomy.com/radiomyme-tv"
    }],

    ClubOne: [{
        title: "Club One",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/Club1.jpg",
        url: "http://listen.radionomy.com/clubone"
    }],
    
    OldOne: [{
        title: "OldOne",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/OldOne.jpg",
        url: "http://listen.radionomy.com/oldone"
    }],
    
    Parazhit: [{
        title: "Parazhit",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/parazhit.png",
        url: "http://bit.ly/1OBiXFE"
    }],
    
    NRJ: [{
        title: "NRJ",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/NRJ.jpg",
        url: "http://cdn.nrjaudio.fm/audio1/fr/40101/aac_576.mp3"
    }],
    
    DanceWave: [{
        title: "Dance Wave",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/DanceWave.jpg",
        url: "http://dancewave.online/dance.mp3.pls"
    }],
    
    Hotmix: [{
        title: "HotMix Radio Dance",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/hotmix.jpg",
        url: "http://listen.radionomy.com/hotmixradio-dance-128.m3u"
    }],
    
    MixFeever: [{
        title: "MixFeever",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/mixfeever.jpg",
        url: "http://listen.radionomy.com/feevermix.m3u"
    }],
    
    Funradio: [{
        title: "Funradio",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/Funradio.jpg",
        url: "  http://streaming.radio.funradio.fr/fun-1-44-128.m3u"
    }],
    
    RTL: [{
        title: "RTL",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/RTL.jpg",
        url: "http://streaming.radio.rtl.fr/rtl-1-44-96"
    }],
    
    RTL2: [{
        title: "RTL 2",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/rtl/RTL2.jpg",
        url: "http://streaming.radio.rtl2.fr:80/rtl2-1-44-96"
    }],
    
    Europe1: [{
        title: "Europe 1",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/europe1.jpg",
        url: "http://mp3lg3.scdn.arkena.com/10489/europe1.mp3"
    }],
    
    Contact: [{
        title: "Contact FM",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/contact.jpg",
        url: "http://radio-contact.ice.infomaniak.ch/radio-contact-high.mp3"
    }],
    
    Nostalgie: [{
        title: "Nostalgie",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/nostalgie.jpg",
        url: "http://cdn.nrjaudio.fm/audio1/fr/30601/mp3_128.mp3"
    }],
    
    Skyrock: [{
        title: "Skyrock",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/skyrock.jpg",
        url: "http://icecast.skyrock.net/s/natio_mp3_128k"
    }],
    
    RFM: [{
        title: "RFM",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/rfm.jpg",
        url: "http://rfm-live-mp3-128.scdn.arkena.com/rfm.mp3"
    }],
    
   	VirginRadio: [{
        title: "Virgin Radio",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/virginradio.png",
        url: "http://vr-live-mp3-128.scdn.arkena.com/virginradio.mp3"
    }],
    
    RMC: [{
        title: "RMC",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/rmc.jpg",
        url: "http://rmc.scdn.arkena.com/rmc.mp3"
    }],
    
    CherieFM: [{
        title: "Cherie FM",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/cheriefm.jpg",
        url: " http://cdn.nrjaudio.fm/audio1/fr/30201/mp3_128.mp3"
    }],
    
    RireChanson: [{
        title: "Rire et Chanson",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/rireetchanson.jpg",
        url: " http://cdn.nrjaudio.fm/audio1/fr/30401/mp3_128.mp3"
    }],
    
    FranceINFO: [{
        title: "France Info",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/franceinfo.jpg",
        url: "http://direct.franceinfo.fr/live/franceinfo-midfi.mp3"
    }],
    
    FranceINTER: [{
        title: "France Inter",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/franceinter.jpg",
        url: "http://direct.franceinter.fr/live/franceinter-midfi.mp3"
    }],
    
    IbizaGlobal: [{
        title: "Ibiza Global Radio",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/ibizaglobalradio.jpg",
        url: "http://ibizaglobalradio.streaming-pro.com:8024/"
    }],
    
    SunshineLive: [{
        title: "Sunshine Live",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/sunshinelive.jpg",
        url: "http://stream.sunshine-live.de/live/mp3-192/Webradio-Player/"
    }],
    
   	Top40: [{
        title: "1 FM Top 40",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/1FMtop40.jpg",
        url: "http://strm112.1.fm/top40_mobile_mp3"
    }],
    
    ChartHitsFM: [{
        title: "Chart Hits FM",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/ChartHitsFM.jpg",
        url: "http://charthits-high.rautemusik.fm/listen.pls"
    }],
    
    IbizaSonica: [{
        title: "Ibiza Sonica",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/ibizasonica.jpg",
        url: "http://bit.ly/1TYRJHZ"
    }],
    
    Trance1FM: [{
        title: "1 FM Trance",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/1FMTrance.jpg",
        url: "http://strm112.1.fm/trance_mobile_mp3"
    }],
    
    Radio7: [{
        title: "Radio Seven",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/radio7.jpg",
        url: "http://play.radioseven.se/128.pls"
    }],
    
    Frisky: [{
        title: "Frisky",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/frisky.jpg",
        url: "http://yp.shoutcast.com/sbin/tunein-station.m3u?id=47007"
    }],
    
    RadioDance1: [{
        title: "1 Dance Radio",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/radiodance.jpg",
        url: "http://listen.radionomy.com/1-radio-dance"
    }],
    
   	BassDrive: [{
        title: "BassDrive",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/bassdrive.jpg",
        url: "http://bassdrive.com/bassdrive3.m3u"
    }],
    
    BigCityBeats: [{
        title: "Big City Beats",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/bigcitybeats.jpg",
        url: "http://yp.shoutcast.com/sbin/tunein-station.m3u?id=61568"
    }],
    
    BlueMarlinIbiza: [{
        title: "Blue Marlin Ibiza",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/BlueMarlinIbiza.jpg",
        url: "http://yp.shoutcast.com/sbin/tunein-station.m3u?id=302916"
    }],
    
    Quisqueya: [{
        title: "Quisqueya",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/Quisqueya.jpg",
        url: "http://yp.shoutcast.com/sbin/tunein-station.m3u?id=923464"
    }],
    
    RadioPiekary: [{
        title: "Radio Piekary",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/RadioPiekary.jpg",
        url: "http://yp.shoutcast.com/sbin/tunein-station.m3u?id=979102"
    }],
    
    RadioBeatsfm: [{
        title: "Radio Beats FM",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/beatsfm.jpg",
        url: "http://ibizaglobalradio.streaming-pro.com:8024/"
    }],
    
    RancheritadelAire: [{
        title: "La Rancherita del Aire",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/RancheritadelAire.jpg",
        url: "http://yp.shoutcast.com/sbin/tunein-station.m3u?id=769470"
    }],
    
   	RadioUnoPlus: [{
        title: "Radio Uno Plus",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/RadioUnoPlus.jpg",
        url: "http://listen.radionomy.com/radiounoplus"
    }],
    
    ColombiaCrossOver: [{
        title: "Colombia CrossOver",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/ColombiaCrossOver.jpg",
        url: "http://listen.radionomy.com/colombiacrossover"
    }],
    
    COLOMBIASALSAROSA: [{
        title: "Colombia Salsa Rosa",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/COLOMBIASALSAROSA.jpg",
        url: "http://listen.radionomy.com/colombiasalsarosa"
    }],
    
    CUMBIASINMORTALES: [{
        title: "Cumbias Inmortales",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/CUMBIASINMORTALES.jpg",
        url: "http://listen.radionomy.com/cumbias-inmortales"
    }],
    
    TropicalisimaBaladas: [{
        title: "Tropicalisima Baladas",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/TropicalisimaBaladas.jpg",
        url: "http://yp.shoutcast.com/sbin/tunein-station.m3u?id=402247"
    }],
    
    RadioKaribeaChala: [{
        title: "Radio Karibea Chala",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/RadioKaribeaChala.jpg",
        url: "http://yp.shoutcast.com/sbin/tunein-station.m3u?id=394674"
    }],
    
   	RitmoFM: [{
        title: "Ritmo 96 5 FM",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/RitmoFM.jpg",
        url: "http://yp.shoutcast.com/sbin/tunein-station.m3u?id=299319"
    }],
    
    LaRazaFM: [{
        title: "La Raza 106 1 FM",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/LaRazaFM.jpg",
        url: "http://yp.shoutcast.com/sbin/tunein-station.m3u?id=116014"
    }],
    
    SuperKFM: [{
        title: "Super K 100 7 FM",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/SuperKFM.jpg",
        url: "http://yp.shoutcast.com/sbin/tunein-station.m3u?id=126643"
    }],
    
    LaXEstereo: [{
        title: "La X Estereo",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/LaXEstereo.jpg",
        url: "http://yp.shoutcast.com/sbin/tunein-station.m3u?id=369433"
    }],

    ANTENA1: [{
        title: "Antena 1",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/ANTENA1.jpg",
        url: "http://yp.shoutcast.com/sbin/tunein-station.m3u?id=830692"
    }],
    
    RUSSIANHIT: [{
        title: "Russian Hit",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/RUSSIANHIT.jpg",
        url: "http://yp.shoutcast.com/sbin/tunein-station.m3u?id=160882"
    }],
    
    RADIOSCOOPHUNGARY: [{
        title: "Radioscoop Hungary",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/RADIOSCOOPHUNGARY.jpg",
        url: "http://yp.shoutcast.com/sbin/tunein-station.m3u?id=719284"
    }],
    
   	KissFMRomania: [{
        title: "KissFM Romania",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/KissFMRomania.jpg",
        url: "http://yp.shoutcast.com/sbin/tunein-station.m3u?id=528480"
    }],
    
    HitradioOE3: [{
        title: "Hitradio OE3",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/HitradioOE3.jpg",
        url: "http://yp.shoutcast.com/sbin/tunein-station.m3u?id=195363"
    }],
    
    RadioZULive: [{
        title: "Radio ZU Live",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/RadioZULive.jpg",
        url: "http://yp.shoutcast.com/sbin/tunein-station.m3u?id=496791"
    }],
    
    Evangelizar: [{
        title: "Evangelizar",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/Evangelizar.jpg",
        url: "http://yp.shoutcast.com/sbin/tunein-station.m3u?id=501985"
    }],
    
    LasMasBailadas: [{
        title: "Las Mas Bailadas",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/LasMasBailadas.jpg",
        url: "http://yp.shoutcast.com/sbin/tunein-station.m3u?id=219515"
    }],
    
    KralFM: [{
        title: "Kral FM",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/KralFM.jpg",
        url: "http://yp.shoutcast.com/sbin/tunein-station.m3u?id=201663"
    }],
    
   	Shanson: [{
        title: "Shanson 101 9 Kiev",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/Shansono.jpg",
        url: "http://yp.shoutcast.com/sbin/tunein-station.m3u?id=53530"
    }],
    
    KralPop: [{
        title: "Kral Pop",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/KralPop.jpg",
        url: "http://yp.shoutcast.com/sbin/tunein-station.pls?id=31023"
    }],
    
    WebRadioRiodoOestenaBalada: [{
        title: "Web Radio Rio do Oeste na Balada",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/PopRadio.jpg",
        url: "http://yp.shoutcast.com/sbin/tunein-station.m3u?id=126643"
    }],
    
    AntenneBayern: [{
        title: "Antenne Bayern",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/AntenneBayern.jpg",
        url: "http://yp.shoutcast.com/sbin/tunein-station.m3u?id=403432"
    }],

    MegaRadio: [{
        title: "Mega Radio",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/MegaRadio.jpg",
        url: "http://yp.shoutcast.com/sbin/tunein-station.pls?id=653998"
    }],
    
    RadioRomaniaInternational: [{
        title: "Radio Romania International",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/RadioRomaniaInternational.jpg",
        url: "http://yp.shoutcast.com/sbin/tunein-station.pls?id=99194139"
    }],
    
   	DJFMUkraine: [{
        title: "DJFM Ukraine",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/DJFMUkraine.jpg",
        url: "http://yp.shoutcast.com/sbin/tunein-station.pls?id=1629506"
    }],
    
    Narodniradio: [{
        title: "Narodni radio",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/Narodniradio.jpg",
        url: "http://yp.shoutcast.com/sbin/tunein-station.pls?id=1397078"
    }],
    
    ShowRadyo: [{
        title: "Show Radyo",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/ShowRadyo.jpg",
        url: "http://yp.shoutcast.com/sbin/tunein-station.pls?id=524473"
    }],
    
    ClubeFM: [{
        title: "Clube FM",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/ClubeFM.jpg",
        url: "http://yp.shoutcast.com/sbin/tunein-station.pls?id=869363"
    }],
    
    RadioMozart: [{
        title: "Radio Mozart",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/RadioMozart.jpg",
        url: "http://listen.radionomy.com/radio-mozart"
    }],
    
    SmoothRiviera: [{
        title: "Smooth Riviera",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/SmoothRiviera.jpg",
        url: "http://listen.radionomy.com/smooth-riviera"
    }],
    
    ABCPiano: [{
        title: "ABC Piano",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/ABCPiano.jpg",
        url: "http://listen.radionomy.com/abc-piano"
    }],
    
    ClassicalHits: [{
        title: "1000 Classical Hits",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/ClassicalHits.jpg",
        url: "http://listen.radionomy.com/1000classicalhits"
    }],
    
    ChristmasCarolsRadio: [{
        title: "Christmas Carols Radio",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/ChristmasCarolsRadio.jpg",
        url: "http://listen.radionomy.com/christmascarolsradio"
    }],
    
    CINEMIX: [{
        title: "CINEMIX",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/CINEMIX.jpg",
        url: "http://listen.shoutcast.com/CINEMIX-1"
    }],
    
    BarockMusic: [{
        title: "Barock Music",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/BarockMusic.jpg",
        url: "http://listen.radionomy.com/barock-music"
    }],
    
    AbacusFMMozartPiano: [{
        title: "Abacus FM Mozart Piano",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/AbacusFMMozartPiano.jpg",
        url: "http://listen.radionomy.com/abacusfm-mozart-piano"
    }],
    
    AbacusFMBach: [{
        title: "Abacus FM Bach",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/AbacusFMBach.jpg",
        url: "http://listen.radionomy.com/abacusfm-bach"
    }],
    
    Mozartiana: [{
        title: "Mozartiana",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/Mozartiana.jpg",
        url: "http://listen.radionomy.com/mozartiana"
    }],
    
    HitsClassicalMusic: [{
        title: "1000 Hits Classical Music",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/HitsClassicalMusic.jpg",
        url: "http://listen.radionomy.com/1000hitsclassicalmusic"
    }],
    
    InstrumentalHits: [{
        title: "Instrumental Hits",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/InstrumentalHits.jpg",
        url: "http://listen.radionomy.com/instrumental-hits"
    }],
    
    AmbianceClassique: [{
        title: "Ambiance Classique",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/AmbianceClassique.jpg",
        url: "http://listen.radionomy.com/ambiance-classique"
    }],
    
    RadioChopin: [{
        title: "Radio Chopin",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/RadioChopin.jpg",
        url: "http://listen.radionomy.com/radio-chopin"
    }],
    
    RadioBach: [{
        title: "Radio Bach",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/RadioBach.jpg",
        url: "http://listen.radionomy.com/radio-bach"
    }],
    
    BeethovenRadio: [{
        title: "Beethoven Radio",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/BeethovenRadio.jpg",
        url: "http://listen.radionomy.com/beethoven-radio"
    }],
    
    RadioNostalgia: [{
        title: "Radio Nostalgia",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/RadioNostalgia.jpg",
        url: "http://listen.radionomy.com/radio-nostalgia"
    }],
    
    BobMarleyRadio: [{
        title: "Bob Marley Radio",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/BobMarleyRadio.jpg",
        url: "http://listen.radionomy.com/bob-marley"
    }],
    
    
    LeJamRadio: [{
        title: "LEDJAM Radio",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/LeJamRadio.jpg",
        url: "http://listen.radionomy.com/ledjamradio.mp3"
    }],
    
    ABCLove: [{
        title: "ABC Love",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/ABCLove.jpg",
        url: "http://listen.radionomy.com/abc-love"
    }],
    
    RevolutionFM: [{
        title: "Revolution FM",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/RockRadio.jpg",
        url: "http://listen.radionomy.com/revolution-fm.m3u"
    }],
    
    RadioUnoPlus: [{
        title: "Radio Uno Plus",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/RockRadio.jpg",
        url: "http://listen.radionomy.com/radiounoplus.m3u"
    }],
    
    Corailradio: [{
        title: "Corail radio",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/Logo_Corail4_HD1200.png",
        url: "http://listen.radionomy.com/corail.m3u"
    }],
    
    Corail80: [{
        title: "Corail 80",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/Logo_Corail80_2HD1200.png",
        url: "http://listen.radionomy.com/corail-80-.m3u"
    }],
    
    Corailstation: [{
        title: "Corail station",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/Logo_Corailstation3_HD1200.png",
        url: "http://listen.radionomy.com/corail-station-.m3u"
    }],
    
    Corailvintage: [{
        title: "Corail vintage",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/Logo_Corailvintage_HD1200.png",
        url: "http://listen.radionomy.com/corailvintage60-70.m3u"
    }],
    
    RadioBelfortaine: [{
        title: "Radio Belfortaine",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/radiobelfortaine.jpg",
        url: "http://listen.radionomy.com/radiobelfortaine"
    }],
    
    SoundtracksForeverRadio: [{
        title: "Soundtracks Forever Radio",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/SF_Radio_600.jpg",
        url: "http://listen.radionomy.com/soundtracksforever"
    }],
    
    SubarashiiRadioManga: [{
        title: "Subarashii Radio Manga",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/SubarashiiRadioManga.png",
        url: "http://listen.radionomy.com/subarashii"
    }],
    
    RadioNapoli: [{
        title: "Radio Napoli",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/radionapoli.jpg",
        url: "http://listen.radionomy.com/radionapoli"
    }],
    
    EliumRadioClub: [{
        title: "EliumRadio Club and Dance",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/eliumradio/1.png",
        url: "http://listen.radionomy.com/elium-clubdance"
    }],
    
    EliumRadioRock: [{
        title: "EliumRadio Rock and Pop",
        artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/eliumradio/2.png",
        url: "http://listen.radionomy.com/elium-rock"
    }],
    
    MarcsRadio: [{
                 title: "Marcs Radio",
                 artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/marcsradio.png",
                 url: "http://listen.radionomy.com/marcsradio.m3u"
                 }],
    
    ChannelTrance: [{
                 title: "Channel Trance",
                 artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/channeltrance.png",
                 url: "http://serveur3.wanastream.com:17400/listen.pls"
                 }],
    
    ZenForYou: [{
                 title: "Zen For You",
                 artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/zenforyou.jpg",
                 url: "http://listen.radionomy.com/zen-for-you"
                 }],
    
    MaxximumOxyclub: [{
                 title: "Maxximum Oxyclub",
                 artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/maxximumoxyclub.jpg",
                 url: "http://listen.radionomy.com/maxximumoxyclub"
                 }],
    
    TaiwanLounge: [{
                 title: "Taiwan Lounge",
                 artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/TAIWANLOUNGERADIO.png",
                 url: "http://listen.radionomy.com/taiwan-lounge.m3u"
                 }],
    
    LaRadioduCinema: [{
                 title: "La Radio du Cinema",
                 artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/laradioducinema.png",
                 url: "http://listen.radionomy.com/pointures"
                 }],
    
    LivefromtheMia: [{
                 title: "Live from the Mia",
                 artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/LivefromtheMia.jpg",
                 url: "https://lc.cx/4Yg4"
                 }],
    
    Alfunkradio: [{
                 title: "Al funk webradio",
                 artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/AllFunkWeberadio.jpg",
                 url: "http://listen.radionomy.com/alfunkwebradio"
                 }],
    
    FM80: [{
                 title: "FM 80",
                 artworkImageURL: "http://www.radiomyme.fr/tv/resources/images/radio/FM80.png",
                 url: "http://listen.shoutcast.com/fm-80.m3u"
                 }],
};
