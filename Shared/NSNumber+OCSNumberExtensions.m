@implementation NSNumber (OCSNumberExtensions)
-(NSString*)ocs_openStepPropertyListError:(NSError**)error {
    if (!strcmp(self.objCType, "c")) return self.boolValue?@"Y":@"N"; // the only special case we need is BOOL
    return self.description;
}
@end
