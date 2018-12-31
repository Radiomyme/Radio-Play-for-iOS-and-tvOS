//
//  Settings.h
//  Radio Play by Radiomyme
//

#pragma mark - App Settings

// Automatically switches between local database or remote database
extern NSString *const LOCAL_ENABLED;

// Automatically enables or disables Admob
extern BOOL *const GOOGLE_ACTIVATION;
extern BOOL *const GOOGLE_BANNER;
extern NSString *const GOOGLE_adUnitID;
extern NSString *const Google_ad_banner_ID;
extern NSString *const GOOGLE_ID;
extern BOOL *const FACEBOOK_ACTIVATION;
extern NSString *const FACEBOOK_ID_Interstitial;
extern BOOL InAppPurchase;
extern NSString *const InAppPurchase_Id;
extern BOOL USE_PLAYER_V2;
extern BOOL USE_m3u8;
extern BOOL M3u8_Play;
extern NSString *const Activate_Volume_Slider;
extern BOOL Activate_Blur_Effect;
extern BOOL Use_Last_Fm;
extern BOOL *const Share_whith_station_logo;
extern BOOL *const Allow_Search;
extern BOOL *const Open_Music;
extern NSArray *Categories;
extern BOOL *const Enable_Categories;

//
// Add your iTunes Connect Id for In-App Purchase
//

#define kRemoveAdsProductIdentifier @"com.endato.radiomyme.adremover"

// end

extern NSString *const Home_Title;
extern NSString *Facebook_URL;
extern NSString *Twitter_URL;
extern NSString *Instagram_URL;
extern NSString *const Chat_URL;
extern NSString *const Station_Name1;
extern NSString *const Station_Name2;
extern NSString *const Station_Name3;
extern NSString *const Station_Name4;
extern NSString *const Station_Sub1;
extern NSString *const Station_Sub2;
extern NSString *const Station_Sub3;
extern NSString *const Station_Sub4;
extern NSString *const Station_Stream1;
extern NSString *const Station_Stream2;
extern NSString *const Station_Stream3;
extern NSString *const Station_Stream4;
NSString *const Station_Facebook1;
NSString *const Station_Facebook2;
NSString *const Station_Facebook3;
NSString *const Station_Facebook4;
NSString *const Station_Twitter1;
NSString *const Station_Twitter2;
NSString *const Station_Twitter3;
NSString *const Station_Twitter4;
NSString *const Station_Logo1;
NSString *const Station_Logo2;
NSString *const Station_Logo3;
NSString *const Station_Logo4;
extern NSString *const Player_Title;
extern NSString *const Default_StreamAlbum_Station1;
extern NSString *const Default_StreamAlbum_Station1_URL;
extern NSString *const Default_StreamAlbum_Station2;
extern NSString *const Default_StreamAlbum_Station2_URL;
extern NSString *const Default_URL;
extern NSString *const OneSignal_ID;
extern NSString *ViewDidAppear;

extern NSString *Station_Title;
extern NSString *Station_Subtitle;

// Last.FM API Key
#define LAST_FM_API_KEY @"819ed12177d0e70f6fec5c6da87cc7a5"

#ifndef LAST_FM_API_KEY
#error "Must define Last.FM API key. Please visit http://www.last.fm/api to signup"
#endif
