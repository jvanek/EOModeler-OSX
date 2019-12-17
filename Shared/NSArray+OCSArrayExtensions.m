@implementation NSArray (OCSArrayExtensions)
-(NSString*)ocs_openStepPropertyListError:(NSError**)error {
    if (!self.count) return @"()";
    NSMutableString *ms=[NSMutableString stringWithString:@"("];
    BOOL comma=NO;
    for (id o in self) {
        NSString *s=[o ocs_openStepPropertyListError:error];
        if (!s) return nil;
        if (comma) [ms appendString:@","];
        comma=YES;
        [ms appendFormat:@"\n  %@", [[s componentsSeparatedByString:@"\n"] componentsJoinedByString:@"\n  "]];
    }
    [ms appendString:@"\n)"];
    return ms;
}
@end
