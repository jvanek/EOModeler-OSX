
@implementation NSObject (OCSObjectExtensions)
-(void)ocs_changingValuesForKeys:(NSArray*)keys do:(void(^)(void))block {
    @try {
        for (NSString *key in keys) [self willChangeValueForKey:key];
        if (block) block();
    } @finally {
        for (NSString *key in keys.reverseObjectEnumerator) [self didChangeValueForKey:key];
    }
}

-(NSString*)ocs_openStepPropertyListError:(NSError**)error {
    [NSException raise:NSInternalInconsistencyException format:@"In '%@' the ocs_openStepPropertyListError: method is not overridden!",self.className];
    return nil;
}
-(NSData*)ocs_openStepPropertyListDataError:(NSError**)error {
    NSString *s=[self ocs_openStepPropertyListError:error];
    if (!s) return nil;
    NSData *d=[s dataUsingEncoding:NSUTF8StringEncoding];
    id check=[NSPropertyListSerialization propertyListWithData:d options:NSPropertyListImmutable format:NULL error:error];
    if (!check)
        return nil;
    if (![self isEqual:check]) {
        if (error) *error=OCSERROR(@"The data could not be serialized to OpenStep property format and read reliably back");
        return nil;
    }
    return d;
}

@end
