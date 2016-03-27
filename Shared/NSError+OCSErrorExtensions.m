#include <netdb.h>

@implementation NSError (OCSErrorExtensions)
-(NSString*)ocs_localizedErrorDescription {
    NSString *s;
    
    // special case for DNS errors, copied down more or less verbatim from Apple's UDPEcho. Can't harm with generic errors, it seems!
    if ([self.domain isEqualToString:(NSString*)kCFErrorDomainCFNetwork] && self.code==kCFHostErrorUnknown) {
        NSNumber *failureNum=self.userInfo[(id)kCFGetAddrInfoFailureKey];
        if ([failureNum isKindOfClass:NSNumber.class]) {
            int failure=[failureNum intValue];
            if (failure) {
                const char *failureStr=gai_strerror(failure);
                if (failureStr) return [NSString stringWithUTF8String:failureStr];
            }
        }
    }
    
    if ([s=[self localizedFailureReason] length]) return s;
    if ([s=[self localizedDescription] length]) return s;
    if ([s=[self localizedRecoverySuggestion] length]) return s;
    return self.description;
}

+(NSError*)ocs_errorWithDomain:(NSString*)domain code:(int)code extraItems:(NSDictionary*)extra format:(NSString*)fmt,... {
    va_list al;
    va_start(al, fmt);
    NSString *s=[[NSString alloc] initWithFormat:fmt arguments:al];
    va_end(al);
    NSMutableDictionary *md=[extra mutableCopy]?:[NSMutableDictionary dictionary];
    md[NSLocalizedDescriptionKey]=md[NSLocalizedFailureReasonErrorKey]=s;
    return [NSError errorWithDomain:domain code:code userInfo:md];
}
+(NSString*)ocs_errorDomainForFile:(const char*)fname {
    const char *last=strrchr(fname,'/');
    return [NSString stringWithFormat:@"LM.%s",last?:fname];
}
@end

@implementation NSException (OCSErrorExtensions)
-(NSString*)ocs_localizedErrorDescription {
    return [NSString stringWithFormat:@"%@: %@",self.name,self.reason];
}
@end
@implementation NSObject (OCSErrorExtensions) // just in case the message gets sent to a generic object (should not happen, but let's stay safe, e.g., someone may throw non-exception)
-(NSString*)ocs_localizedErrorDescription {
    return [NSString stringWithFormat:@"ErrDesc(%@): %@",self.class,self.description];
}
@end