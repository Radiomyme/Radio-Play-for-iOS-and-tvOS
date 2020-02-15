//
//  Settings.m
//  Radio Play by Radiomyme
//

#import "Settings.h"

NSString *ViewDidAppear = NO;   // Just to Now if the View Appeared or Not - Do NOT Change it
BOOL USE_PLAYER_V2 = NO;        // Do NOT change
BOOL USE_m3u8 = NO;             // Do NOT change
BOOL M3u8_Play= NO;             // Do NOT change

//--------------------------------------
//--------Starting the Settings.m-------
//--------------------------------------

// Automatically switches between local database or remote database
// If you use remote (LOCAL_ENABLED = NO), you can add the URL in Radio Play Core -> Database Files -> PlayerDB.plist
// Categories are not supported in remote mode

NSString *const LOCAL_ENABLED = YES; // Mark NO to use remote access

//-----------------------------------------
//--------          Ads             -------
//-----------------------------------------

// AdMob (Google) - https://apps.admob.com/

BOOL *const GOOGLE_ACTIVATION = YES; //To enable Ads, mark YES to activate. If Facebook and Google are activated, only Google AdMob will be displayed. To desactivate you replace YES by NO
BOOL *const GOOGLE_BANNER = YES; //Add a banner in the PlayerView at the bottom
BOOL *const GOOGLE_BANNER_HOME= NO; //Add a banner in the HomeView at the bottom
NSString *const Google_ad_interstitial_ID = @"ca-app-pub-4466685095115509/6569030274"; // Player Interstitial
NSString *const Google_ad_banner_ID = @"ca-app-pub-4466685095115509/1323089876"; // Player Banner
NSString *const Google_ad_banner_Home_ID = @"ca-app-pub-4466685095115509/6160328830"; // Home Banner
NSString *const GOOGLE_ID = @"ca-app-pub-4466685095115509~5892890271";//Create your ID for your App -- It's not your Banner or Interstitial ID -> This ID is displayed in the top of your AdMob Home Page

// Ad Remover (In-App Purchase)

// Change #define kRemoveAdsProductIdentifier @"com.endato.radiomyme.adsremover" in Settings.h & create your ID on itunesconnect.apple.com
BOOL InAppPurchase = YES; //To disable mark NO

//-----------------------------------------
//--------          Home            -------
//-----------------------------------------

NSString *const Home_Title = @"Radio Play";                 //Name displayed on page "Radio"
NSString *Facebook_URL = @"408517575833673";                //Your Facebook ID displayed in the Player Page
NSString *const open_music_URL = @"https://www.radiomyme.fr/";    //Your Website URL displayed in the Player Page

// Use Instagram or Twitter ?

NSString *Account_ID = @"radiomyme";    //Your account displayed in the Player Page
BOOL *const Use_Twitter = YES;          //Use twitter (YES), (NO) for Instagram

// Search

BOOL *const Allow_Search = YES;         //Allow the Search Bar to Appear in the Home Page

//-----------------------------------------
//--------  QuickActions (3DTouch)  -------
//-----------------------------------------

//Don't forget to change the name and the logo of the quickaction in the Other Resources -> Info.plist -> UIApplicationShortcutItems -> Items

//To change the logo, replace the QuickAction_Station1, QuickAction_Station2, QuickAction_Station3 and QuickAction_Station4 png files
//To change the name replace Radio 1, Radio 2, Radio 3, Radio 4 by the name of your station

NSString *const Station_Name1 = @"RTL";
NSString *const Station_Sub1 = @"RTL bouge";
NSString *const Station_Logo1 = @"http://data.radiomyme.com/tv/resources/images/radio/RTL.jpg";
NSString *const Station_Stream1 = @"http://streaming.radio.rtl.fr/rtl-1-44-96";
NSString *const Station_Facebook1 = @"282315205283";
NSString *const Station_Twitter1 = @"RTLFrance";

NSString *const Station_Name2 = @"Europe1";
NSString *const Station_Sub2 = @"Europe 1, Mieux capter son époque";
NSString *const Station_Logo2 = @"http://data.radiomyme.com/tv/resources/images/radio/europe1.jpg";
NSString *const Station_Stream2 = @"http://mp3lg3.scdn.arkena.com/10489/europe1.mp3";
NSString *const Station_Facebook2 = @"223401325619";
NSString *const Station_Twitter2 = @"Europe1";

NSString *const Station_Name3 = @"NRJ";
NSString *const Station_Sub3 = @"Hit Music Only";
NSString *const Station_Logo3 = @"http://data.radiomyme.com/tv/resources/images/radio/NRJ.jpg";
NSString *const Station_Stream3 = @"http://cdn.nrjaudio.fm/audio1/fr/30001/mp3_128.mp3";
NSString *const Station_Facebook3 = @"39824562567";
NSString *const Station_Twitter3 = @"NRJhitmusiconly";

NSString *const Station_Name4 = @"France INFO";
NSString *const Station_Sub4 = @"Actualités en temps réel et info en direct";
NSString *const Station_Logo4 = @"http://data.radiomyme.com/tv/resources/images/radio/franceinfo.jpg";
NSString *const Station_Stream4 = @"http://direct.franceinfo.fr/live/franceinfo-midfi.mp3";
NSString *const Station_Facebook4 = @"266677330042439";
NSString *const Station_Twitter4 = @"franceinfo";

//Tips : If you want to add only 1,2 or 3 stations make sure that you delete the items 1,2 or 3 in the info.plist -> UIApplicationShortcutItems -> Items. You will also be able to edit and change the logo and the name displayed for the 3DTouch

//-----------------------------------------
//--------      Player Settings     -------
//-----------------------------------------

// Default Artist and Song if nothing is available

NSString *Station_Title = @"Radio Play";    //Default artist name displayed if there is no information available
NSString *Station_Subtitle = @"Broadcasting Live";  //Default title displayed if there is no information available

// Do you want to use Last_Fm to find the albums ?

BOOL Use_Last_Fm = YES; //Use Last_Fm Album or not

// Share Button Settings

BOOL *const Open_Music = YES;   //Will open the Music app to add the song to your costumer library (Apple Music)
NSString *const Default_URL = @"https://www.radiomyme.fr"; //Default URL of share button in Player View

BOOL *const Share_whith_station_logo = NO; //If the user push Share in the Player section, the image will be the logo of the station. If NO is selected, it will be the current Album Image of LastFM.

// Album Art

BOOL Activate_Blur_Effect = YES; // Activate the Blur Effect of the Album Art
BOOL Activate_Reflection_Effect = NO; // Activate the Reflection Effect of the Album Art

// Volume Slider

NSString *const Activate_Volume_Slider = YES; // Activate the Volume slider when ads are removed (In App Purchase) or Ads disabled

NSString *Album_size = @"1000";

//-----------------------------------------
//------------    Categories   ------------
//-----------------------------------------

// Look for "Help123" (CTRL + F) in the Level1Controller.m to set up your categories
// Don't forget to change the stations for each categories in the DataBase Files -> audioplaylistpro_category1.plist (first category or row), audioplaylistpro_category2.plist, audioplaylistpro_category3.plist

BOOL *const Enable_Categories = YES;

//-----------------------------------------
//--------    Push Notifications    -------
//-----------------------------------------

// OneSignal

NSString *const OneSignal_ID=@"8d4e7c2f-6526-4af3-9635-52456e55bedb";// To create your ID go at https://documentation.onesignal.com/docs/generate-an-ios-push-certificate
