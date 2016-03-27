//
//  OCSShared.h
//  EOModeller
//
//  Created by OC on 24.03.16.
//  Copyright (c) 2016 OC. All rights reserved.
//

// Generic methods used throughout the complete project

@interface NSError (OCSErrorExtensions)
-(NSString*)ocs_localizedErrorDescription; // tries to find best possible description from the error
// the rest are error-creation convenience, see defines below
+(NSError*)ocs_errorWithDomain:(NSString*)domain code:(int)code extraItems:(NSDictionary*)extra format:(NSString*)fmt,... NS_FORMAT_FUNCTION(4,5);
+(NSString*)ocs_errorDomainForFile:(const char*)fname;
@end
@interface NSException (OCSErrorExtensions)
-(NSString*)ocs_localizedErrorDescription; // tries to find best possible description from the exception, consistent with errors
@end
#define OCSERROR(...) [NSError ocs_errorWithDomain:[NSError ocs_errorDomainForFile:__FILE__] code:__LINE__ extraItems:nil format:__VA_ARGS__]
#define OCSERRORCODE(cc,...) [NSError ocs_errorWithDomain:[NSError ocs_errorDomainForFile:__FILE__] code:(cc) extraItems:nil format:__VA_ARGS__]
#define OCSERRORDICT(dddd, ...) [NSError ocs_errorWithDomain:[NSError ocs_errorDomainForFile:__FILE__] code:__LINE__ extraItems:(dddd) format:__VA_ARGS__]

@interface NSMutableDictionary (OCSMutableDictionaryExtensions)
-(void)ocs_addExistingEntriesWithKeys:keys fromDictionary:(NSDictionary*)dict; // keys any for/in-supporting object, nil adds all; does nothing for nil entries.
-(void)ocs_addNewEntriesWithKeys:keys fromDictionary:(NSDictionary*)dict; // adds only keys which do not exist in receiver yet
@end

@interface NSObject (OCSObjectExtensions)
-(void)ocs_changingValuesForKeys:(NSArray*)keys do:(void(^)(void))block; // simple convenience -- first sends self willChangeValueForKey: for all keys, then performs block, and then sends didChange... in a reverse order

-(NSString*)ocs_openStepPropertyListError:(NSError**)error; // formats itself as a property list in the OpenStep format, alas not supported anymore by Apple
-(NSData*)ocs_openStepPropertyListDataError:(NSError**)error; // simple convenience which turns the result to data in UTF8 encoding
@end

@interface NSString (OCSStringExtensions)
-(NSString*)substringUpToIndex:(NSUInteger)to; // mainly for logs: returns shorter string as is; longer one is cut and ellipsis is added. If the index is zero, cuts to NSUserDefaults(cz.ocs.SubstringUpToIndexDefaultLenght) or 1000
@end

@interface NSTimer (OCSTimerExtensions)
+(NSTimer*)ocs_scheduledTimerWithTimeInterval:(NSTimeInterval)ti block:(void(^)(void))block; // performs block once when fired
@end

@interface NSURL (OCSURLExtensions)
-(BOOL)ocs_fileExists; // any kind
-(BOOL)ocs_regularFileExists; // exists and is regular
-(BOOL)ocs_directoryExists; // exists and is directory

-(BOOL)ocs_ensurePathSansLastComponentExists:(NSError**)error; // YES: exists-or-successfully-created

+(NSURL*)ocs_temporaryFileAtPath:(NSURL*)tempPath; // generates a new temporary file(name) at tempPath; if it does not exist, it is used for return; if tempPath is nil, uses NSTemporaryDirectory() for tempPath
+(NSURL*)ocs_temporaryFile; // convenience with tempPath=nil
@end

static inline BOOL OCSEquals(id a,id b) { // processes nils and NSNulls properly on both sides
    if (a==NSNull.null) a=nil;
    if (b==NSNull.null) b=nil;
    if (!a && !b) return YES;
    if (!a || !b) return NO;
    return [a isEqual:b];
}
static inline BOOL OCSEqualsEmptyStringIsNull(id a,id b) { // assumes ""==nil, often makes sense
    if ([a isEqual:@""]) a=nil;
    if ([b isEqual:@""]) b=nil;
    return OCSEquals(a, b);
}
