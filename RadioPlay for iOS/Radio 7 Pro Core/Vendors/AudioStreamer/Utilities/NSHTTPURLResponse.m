//
//  NSHTTPURLResponse.m
//  Radio Play by Radiomyme
//

#import "NSHTTPURLResponse.h"

static Boolean CaseInsensitiveEqual(const void *a, const void *b) {
    return ([(id)a compare:(id)b options:NSCaseInsensitiveSearch | NSLiteralSearch] == NSOrderedSame);
}

static CFHashCode CaseInsensitiveHash(const void *value) {
    return [[(id)value lowercaseString] hash];
}

@implementation NSHTTPURLResponse (NSHTTPURLResponse)

- (NSDictionary *)caseInsensitiveHTTPHeaders {
    NSDictionary *src = [self allHeaderFields];
    
    CFDictionaryKeyCallBacks keyCallbacks = kCFTypeDictionaryKeyCallBacks;
    keyCallbacks.equal = CaseInsensitiveEqual;
    keyCallbacks.hash = CaseInsensitiveHash;
    
    CFMutableDictionaryRef dest = CFDictionaryCreateMutable(kCFAllocatorDefault, 
                                                            [src count], 
                                                            &keyCallbacks, 
                                                            &kCFTypeDictionaryValueCallBacks);

    NSEnumerator *enumerator = [src keyEnumerator];
    id key = nil;
    while((key = [enumerator nextObject])) {
        id value = [src objectForKey:key];
        [(NSMutableDictionary *)dest setObject:value forKey:key];
    }
     
    return [(NSDictionary *)dest autorelease];
}

@end
