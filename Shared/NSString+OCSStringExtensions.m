@implementation NSString (OCSStringExtensions)
-(NSString*)substringUpToIndex:(NSUInteger)to {
    if (to<=0 && (to=[NSUserDefaults.standardUserDefaults integerForKey:@"cz.ocs.SubstringUpToIndexDefaultLenght"])<=0) to=1000;
    if (self.length<=to) return self;
    return [[self substringToIndex:to] stringByAppendingString:@"…"];
}

-(BOOL)ocs_matchesRegularExpression:(NSRegularExpression*)regexp {
    return [regexp firstMatchInString:self options:0 range:NSMakeRange(0, self.length)]!=nil;
}
-(NSString*)ocs_openStepPropertyListError:(NSError**)error {
    static NSRegularExpression *rg;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rg=[NSRegularExpression regularExpressionWithPattern:@"^[A-Za-z][A-Za-z0-9]*$" options:0 error:NULL];
    });
    if ([self ocs_matchesRegularExpression:rg]) return self;
    NSString *s=self;
    for (NSArray *sw in @[@[@"\"",@"\\\""], @[@"'",@"\\'"], @[@"\n",@"\\n"]]) s=[s stringByReplacingOccurrencesOfString:sw[0] withString:sw[1]];
    return [NSString stringWithFormat:@"\"%@\"", s];
}
@end
