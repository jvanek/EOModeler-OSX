//
//  EOObject.m
//  EOModeller
//
//  Created by OC on 24.03.16.
//  Copyleft (c) 2016 OC. No rights reserved, what for, on earth?.
//

#import <objc/runtime.h>
#import "EOObject.h"
#import "EOModel.h"

@implementation EOObject
@dynamic userInfo;

-init { // see below also initWithPasteboardPropertyList:ofType:
    if (!(self=[super init])) return nil;
    _rawContents=[NSMutableDictionary dictionary];
    return self;
}

+(NSString*)typeIdentifier {
    NSString *ti=[clname(self) lowercaseString];
    if (![ti hasPrefix:@"eo"]) return ti;
    return [ti substringFromIndex:2];
}

+(NSDictionary*)keyForProperty { return @{}; }

-(EOModel __weak *)model { return (EOModel*)self; } // overridden by attribs/entities
-(void)reportDidChangeKeyPath:(NSString*)keypath oldValue:oldValue {
    NSMutableDictionary *undo=[NSMutableDictionary dictionary];
    undo[@"object"]=self;
    undo[@"keypath"]=keypath;
    if (oldValue) {
        if (![oldValue conformsToProtocol:@protocol(NSCopying)]) undo[@"old"]=oldValue;
        else undo[@"old"]=[oldValue copy];
    }
    [NSNotificationCenter.defaultCenter postNotificationName:EOObjectDidChangeNotification object:self.model userInfo:undo];
}

+(NSString*)validNameForName:(NSString*)name allowDots:(BOOL)allowDots {
    if (!name.length) return name;
    static NSCharacterSet *invalid,*invaliddot;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        id ms=[NSMutableCharacterSet characterSetWithRange:NSMakeRange('a', 'z'-'a'+1)];
        [ms addCharactersInRange:NSMakeRange('A', 'Z'-'A'+1)];
        [ms addCharactersInRange:NSMakeRange('0', '9'-'0'+1)];
        [ms addCharactersInString:@"_$"];
        invalid=[ms invertedSet];
        [ms addCharactersInString:@"."];
        invaliddot=[ms invertedSet];
    });
    name=[[NSString alloc] initWithData:[name dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES] encoding:NSASCIIStringEncoding];
    while ([name rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location==0)
        name=[name substringFromIndex:1];
    return [[name componentsSeparatedByCharactersInSet:allowDots?invaliddot:invalid] componentsJoinedByString:@""];
}
+(NSString*)sqlifiedNameForName:(NSString*)name withPrefix:(NSString*)prefix {
    if (!name.length) return name;
    int n=1;
    if (isupper([name characterAtIndex:0]))
        while (n<name.length-1 && isupper([name characterAtIndex:n+1])) n++; // skip prefix up to last uppercase
    //NSLog(@"... UPC prefix in (%@) is %d",name,n);
    if (n>1) name=[name substringFromIndex:n];
    while (name.length) {
        for (n=1;n<name.length && islower([name characterAtIndex:n]);n++);
        //NSLog(@"... camelpart of (%@) is %d",name,n);
        prefix=[prefix stringByAppendingString:[[name substringToIndex:n] uppercaseString]];
        if (![name=[name substringFromIndex:n] length]) break;
        if (n>1) prefix=[prefix stringByAppendingString:@"_"];
    }
    return prefix;
}

-(BOOL)validateName:(NSString**)name error:(NSError *__autoreleasing *)error {
    if (!(*name).length) return YES; // empty name is considered valid GUI-level, invalid when saving
    NSString *valid=[self.class validNameForName:*name allowDots:NO];
    if (!OCSEquals(valid, *name)) *name=valid;
    if ((*name).length && [self respondsToSelector:@selector(setDefaultNames:)])
        [self performSelector:@selector(setDefaultNames:) withObject:*name afterDelay:0];
    return YES;
}
-(BOOL)validateClassName:(NSString**)name error:(NSError *__autoreleasing *)error {
    if (!(*name).length) return YES; // empty name is considered valid GUI-level, invalid when saving
    NSString *valid=[self.class validNameForName:*name allowDots:YES];
    if (!OCSEquals(valid, *name)) *name=valid;
    return YES;
}

+(NSString*)uti {
    return [[[NSBundle.mainBundle bundleIdentifier] stringByAppendingString:@"."] stringByAppendingString:self.typeIdentifier];
}

-(NSArray*)writableTypesForPasteboard:(NSPasteboard*)pasteboard {
    return @[self.class.uti];
}
-(NSPasteboardWritingOptions)writingOptionsForType:(NSString*)type pasteboard:(NSPasteboard*)pasteboard {
    return NSPasteboardWritingPromised;
}
-(void)prepareCopyWithDictionary:(NSMutableDictionary*)data { /* empty, to be overridden */ }
-(id)pasteboardPropertyListForType:(NSString*)type {
    NSMutableDictionary *md=[NSMutableDictionary dictionaryWithObject:_rawContents forKey:@"."];
    [self prepareCopyWithDictionary:md];
    return [NSKeyedArchiver archivedDataWithRootObject:md];
}

+(NSArray*)readableTypesForPasteboard:(NSPasteboard*)pasteboard {
    return @[self.uti];
}
-(void)finishPasteWithDictionary:(NSDictionary*)data { /* empty, to be overridden */ }
-(instancetype)initWithPasteboardPropertyList:(id)propertyList ofType:(NSString*)type {
    NSDictionary *dd=[NSKeyedUnarchiver unarchiveObjectWithData:propertyList];
    if (!dd[@"."]) return nil;
    if (!(self=[super init])) return nil;
    _rawContents=dd[@"."]; // unarchived, no need to copy
    [self finishPasteWithDictionary:dd];
    return self;
}


// all the code below just makes sure appropriate rawContents-based getters and setters are installed for all dynamic properties
inline static NSString *set2key(NSString *set) {
    return [[[set substringWithRange:NSMakeRange(3, 1)] lowercaseString] stringByAppendingString:[set substringWithRange:NSMakeRange(4, set.length-5)]];
}
inline static NSArray *keya4key(EOObject *self,NSString *key) {
    NSDictionary *k4p=[self.class keyForProperty];
    if (k4p[key]) key=k4p[key];
    return [key componentsSeparatedByString:@"."];
}
inline static id gettercmd(EOObject *self,SEL cmd) {
    NSArray *ka=keya4key(self,NSStringFromSelector(cmd));
    //NSLog(@"%@ called getter with %@",self.class,ka);
    id md=self.rawContents;
    for (NSString *key in ka) md=md[key];
    return md;
}
static id getterIMP(EOObject *self,SEL cmd) {
    return gettercmd(self,cmd);
}
static BOOL getterIMPb(EOObject *self,SEL cmd) {
    return [gettercmd(self,cmd) boolValue]; // works well for Y/N
}
inline static void settercmd(EOObject *self,SEL cmd,id value) {
    NSString *key=set2key(NSStringFromSelector(cmd));
    NSArray *ka=keya4key(self,key);
    //NSLog(@"called setter with %@ -> '%@' <- %@",NSStringFromSelector(cmd),ka,value);
    NSMutableDictionary *md=self.rawContents;
    NSString *lk=ka.lastObject;
    for (NSString *key in [ka subarrayWithRange:NSMakeRange(0, ka.count-1)]) {
        NSMutableDictionary *nmd=md[key];
        if (!nmd) md[key]=nmd=[NSMutableDictionary new];
        md=nmd;
    }

    id oldValue=[self valueForKeyPath:key]; // md[lk]; much faster, but did not work well for BOOLs, of course
    if (value) md[lk]=value;
    else [md removeObjectForKey:lk];
    
    if (!OCSEquals(key, @"userInfo") || !OCSEquals(md[lk], @{})) // do not report adding empty userInfo
        [self reportDidChangeKeyPath:key oldValue:oldValue];
}
static void setterIMP(EOObject *self,SEL cmd,id value) {
    settercmd(self,cmd,value);
}
static void setterIMPb(EOObject *self,SEL cmd,BOOL value) {
    settercmd(self,cmd,value?@"Y":@"N");
}

static inline NSString *clname(Class class) {
    NSString *name=NSStringFromClass(class);
    if (![name hasPrefix:@"NSKVONotifying_"]) return name;
    return [name substringFromIndex:15];
}
static inline NSString *setter(NSString *getter) {
    return [[[@"set" stringByAppendingString:[getter substringToIndex:1].uppercaseString] stringByAppendingString:[getter substringFromIndex:1]] stringByAppendingString:@":"];
}
+(void)initialize {
    unsigned nprop=0;
    objc_property_t *prop=class_copyPropertyList(self, &nprop);
    //NSLog(@"=== in %@ there is %u props...",self,nprop);
    for (unsigned n=0;n<nprop;n++) {
        char *dyn=property_copyAttributeValue(prop[n],"D");
        if (dyn) {
            free(dyn);
            NSString *key=[NSString stringWithUTF8String:property_getName(prop[n])];
#if 0 // these bloody keys do not seem to be documented anywhere?!?
            unsigned an=0;
            objc_property_attribute_t *all=property_copyAttributeList(prop[n],&an);
            NSLog(@"prop '%@' has %u attributes:",key,an);
            for (;an--;all++)
                NSLog(@"  '%s': '%s'",all->name,all->value);
#endif
            BOOL boolean=NO;
            char *type=property_copyAttributeValue(prop[n],"T");
            if (type) {
                boolean=!strcmp(type,"c");
                free(type);
            }
            if (boolean) {
                class_addMethod(self, NSSelectorFromString(key), (IMP)getterIMPb, "c@:");
                class_addMethod(self, NSSelectorFromString(setter(key)), (IMP)setterIMPb, "v@:c");
            } else {
                class_addMethod(self, NSSelectorFromString(key), (IMP)getterIMP, "@@:");
                class_addMethod(self, NSSelectorFromString(setter(key)), (IMP)setterIMP, "v@:@");
            }
        }
    }
    if (prop) free(prop);
}
@end

NSString * const EOObjectDidChangeNotification=@"EOObjectDidChangeNotification";
