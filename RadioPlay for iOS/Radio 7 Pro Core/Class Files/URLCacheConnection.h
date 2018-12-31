#import <UIKit/UIKit.h>

@protocol URLCacheConnectionDelegate;

@interface URLCacheConnection : NSObject 
{
	id <URLCacheConnectionDelegate> delegate;
	
	NSMutableData *receivedData;
	NSDate        *lastModified;
}

@property (nonatomic, assign) id delegate;

@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSDate		*lastModified;

- (id) initWithURL:(NSURL *)theURL delegate:(id<URLCacheConnectionDelegate>)theDelegate;

@end

@protocol URLCacheConnectionDelegate<NSObject>

- (void) connectionDidFail:(URLCacheConnection *)theConnection;
- (void) connectionDidFinish:(URLCacheConnection *)theConnection;

@end
