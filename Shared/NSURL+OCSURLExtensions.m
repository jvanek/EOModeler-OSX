
@implementation NSURL (OCSURLExtensions)
-(BOOL)ocs_fileExists {
    return [self checkResourceIsReachableAndReturnError:NULL];
}
-(BOOL)ocs_regularFileExists {
    NSString *kind;
    if (![self getResourceValue:&kind forKey:NSURLFileResourceTypeKey error:NULL]) return NO;
    return [kind isEqualToString:NSURLFileResourceTypeRegular];
}
-(BOOL)ocs_directoryExists {
    NSString *kind;
    if (![self getResourceValue:&kind forKey:NSURLFileResourceTypeKey error:NULL]) return NO;
    return [kind isEqualToString:NSURLFileResourceTypeDirectory];
}

-(BOOL)ocs_ensurePathSansLastComponentExists:(NSError**)error {
    return [NSFileManager.defaultManager createDirectoryAtURL:[self URLByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:error];
}

+(NSURL*)ocs_temporaryFileAtPath:(NSURL*)path {
    if (!path) path=[NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    if ([path ocs_directoryExists]) {
        NSString *uuid=[[NSUUID UUID] UUIDString];
        if (!uuid) // this happens on 10.7, for NSUUUID is a 10.8 API
            uuid=NSProcessInfo.processInfo.globallyUniqueString;
        path=[path URLByAppendingPathComponent:uuid];
    }
    return path;
}
+(NSURL*)ocs_temporaryFile {
    return [self ocs_temporaryFileAtPath:nil];
}
@end
