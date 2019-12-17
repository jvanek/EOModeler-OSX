@implementation NSDictionary (OCSDictionaryExtensions)
-(NSString*)ocs_openStepPropertyListError:(NSError**)error {
    if (!self.count) return @"{}";
    NSMutableString *ms=[NSMutableString stringWithString:@"{"];
    BOOL sc=NO;
    for (id k in [self.allKeys sortedArrayUsingSelector:@selector(compare:)]) {
        NSString *ks=[k ocs_openStepPropertyListError:error];
        if (!ks) return nil;
        NSString *vs=[self[k] ocs_openStepPropertyListError:error];
        if (!vs) return nil;
        if (sc) [ms appendString:@";"];
        sc=YES;
        [ms appendFormat:@"\n  %@ = %@", ks, [[vs componentsSeparatedByString:@"\n"] componentsJoinedByString:@"\n  "]];
    }
    [ms appendString:@";\n}"];
    return ms;
}
@end
