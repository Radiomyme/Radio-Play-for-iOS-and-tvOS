//# sourceURL=application.js

/*
Copyright (C) 2015 Hani Hamrouni. All Rights Reserved.

*/

var resourceLoader;

/**
 * @description The onLaunch callback is invoked after the application JavaScript 
 * has been parsed into a JavaScript context. The handler is passed an object 
 * that contains options passed in for launch. These options are defined in the
 * swift or objective-c client code. Options can be used to communicate to
 * your JavaScript code that data and as well as state information, like if the 
 * the app is being launched in the background.
 *
 * The location attribute is automatically added to the object and represents 
 * the URL that was used to retrieve the application JavaScript.
 */
App.onLaunch = function(options) {



    var javascriptFiles = [
        `${options.BASEURL}js/ResourceLoader.js`,
        `${options.BASEURL}js/Presenter.js`
    ];

    /**
     * evaluateScripts is responsible for loading the JavaScript files neccessary
     * for you app to run. It can be used at any time in your apps lifecycle.
     * 
     * @param - Array of JavaScript URLs  
     * @param - Function called when the scripts have been evaluated. A boolean is
     * passed that indicates if the scripts were evaluated successfully.
     */
    evaluateScripts(javascriptFiles, function(success) {
        if (success) {
            resourceLoader = new ResourceLoader(options.BASEURL);

            var index = resourceLoader.loadResource(`${options.BASEURL}templates/Index.xml.js`, 
                function(resource) {
                    var doc = Presenter.makeDocument(resource);
                    doc.addEventListener("select", Presenter.load.bind(Presenter));
                    navigationDocument.pushDocument(doc);
                });
        } else {
            /*
            Be sure to handle error cases in your code. You should present a readable, and friendly
            error message to the user in an alert dialog.

            See alertDialog.xml.js template for details.
            */
            var alert = createAlert("Evaluate Scripts Error", "There was an error attempting to evaluate the external JavaScript files.\n\n Please check your network connection and try again later.");
            navigationDocument.presentModal(alert);

            throw ("Playback Example: unable to evaluate scripts.");
        }
    });
}


/**
 * This convenience funnction returns an alert template, which can be user to present errors to the user.
 */
var createAlert = function(title, description) {  

    var alertString = `<?xml version="1.0" encoding="UTF-8" ?>
        <document>
          <alertTemplate>
            <title>${title}</title>
            <description>${description}</description>
          </alertTemplate>
        </document>`

    var parser = new DOMParser();

    var alertDoc = parser.parseFromString(alertString, "application/xml");

    return alertDoc
}