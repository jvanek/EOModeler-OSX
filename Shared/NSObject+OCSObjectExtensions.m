
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
    // this is UGLY and UNRELIABLE implementation, but, hell with...
    if (![self isKindOfClass:NSDictionary.class]) {
        if (error) *error=OCSERROR(@"Only NSDictionaries can be serialized to OpneStep property lists, not %@",self.class);
        return nil;
    }
    NSString *ds=[(NSDictionary*)self descriptionInStringsFileFormat];
    if (!ds) {
        if (error) *error=OCSERROR(@"The data could not be serialized to OpenStep property format");
        return nil;
    }
    NSMutableString *ms=[NSMutableString string];
    [ms appendString:@"{\n"];
    [ms appendString:ds];
    [ms appendString:@"\n}"];
    
    id check=[NSPropertyListSerialization propertyListWithData:[ms dataUsingEncoding:NSUTF8StringEncoding] options:NSPropertyListImmutable format:NULL error:error];
    if (!check) return nil;
    if (![self isEqual:check]) {
        if (error) *error=OCSERROR(@"The data could not be serialized to OpenStep property format and read reliably back");
        return nil;
    }
    return ms;
}
-(NSData*)ocs_openStepPropertyListDataError:(NSError**)error {
    NSString *s=[self ocs_openStepPropertyListError:error];
    if (!s) return nil;
    return [s dataUsingEncoding:NSUTF8StringEncoding];
}

@end
