@implementation NSString (OCSStringExtensions)
-(NSString*)substringUpToIndex:(NSUInteger)to {
    if (to<=0 && (to=[NSUserDefaults.standardUserDefaults integerForKey:@"cz.ocs.SubstringUpToIndexDefaultLenght"])<=0) to=1000;
    if (self.length<=to) return self;
    return [[self substringToIndex:to] stringByAppendingString:@"…"];
}
@end
