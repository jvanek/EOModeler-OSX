//
//  OCSNamedValueTransformer.m
//  EOModeller
//
//  Created by OC on 5/19/13.
//  Copyleft (c) 2013 OC. No rights reserved, what for, on earth?.
//

/*
 Allows to create BOOL-to-something transformers automatically upon using
 
 <transformerclass>_<yesvalue>[_<novalue>]
 
 At the moment, there are OCSBoolToIconTransformer for image names and OCSBoolToColorTransformer for colour names (to be suffixed 'Color' and sent to NSColor).

*/
 
#import <objc/runtime.h>

@protocol OCSNamedTransformerCreationProtocol
+(NSValueTransformer*)transformerForName:(NSString*)name; // name like "<yesvalue>[_<novalue>]"
@end

@interface OCSNamedValueTransformerSupport:NSValueTransformer @end
@implementation OCSNamedValueTransformerSupport
static NSValueTransformer*(*original)(id,SEL,NSString*);
+(NSValueTransformer*)valueTransformerForName:(NSString*)name {
    NSValueTransformer *tr=original(self,_cmd,name);
    if (!tr) {
        NSRange rr=[name rangeOfString:@"_"];
        if (rr.location!=NSNotFound) {
            Class trc=NSClassFromString([name substringToIndex:rr.location]);
            if ([trc respondsToSelector:@selector(transformerForName:)])
                [self setValueTransformer:tr=[trc transformerForName:[name substringFromIndex:NSMaxRange(rr)]] forName:name];
        }
    }
    return tr;
}
+(void)load {
    SEL sel=@selector(valueTransformerForName:);
    Method mm=class_getClassMethod(self.superclass,sel);
    original=(__typeof__(original))method_getImplementation(mm);
    method_setImplementation(mm,[self methodForSelector:sel]);
}
@end

@interface OCSNamedValueTransformerBase:NSValueTransformer
@property (copy) id yesValue,noValue;
@end
@implementation OCSNamedValueTransformerBase
+(Class)transformedValueClass { return [NSObject class]; }
+(BOOL)allowsReverseTransformation { return NO; }
-transformedValueForStoredValue:storedValue {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
-transformedValue:value {
    return [self transformedValueForStoredValue:[value boolValue]?self.yesValue:self.noValue];
}
+(NSValueTransformer*)transformerForName:(NSString*)name {
    NSArray *aa=[name componentsSeparatedByString:@"_"];
    NSString *y=aa[0]; if (!y.length) y=nil;
    NSString *n=aa.lastObject; if (!n.length || aa.count==1) n=nil;
    OCSNamedValueTransformerBase *tran=[[self alloc] init];
    tran.yesValue=y;
    tran.noValue=n;
    return tran;
}
@end

@interface OCSBoolToIconTransformer:OCSNamedValueTransformerBase @end
@implementation OCSBoolToIconTransformer
-transformedValueForStoredValue:storedValue {
    if ([storedValue isKindOfClass:[NSString class]]) storedValue=[NSImage imageNamed:storedValue];
    return storedValue;
}
@end

@interface OCSBoolToColorTransformer:OCSNamedValueTransformerBase @end
@implementation OCSBoolToColorTransformer
-transformedValueForStoredValue:storedValue {
    if ([storedValue isKindOfClass:[NSString class]]) {
        SEL sel=NSSelectorFromString([storedValue stringByAppendingString:@"Color"]);
        if ([NSColor respondsToSelector:sel]) storedValue=[NSColor performSelector:sel];
    }
    return storedValue?:[NSColor blackColor];
}
@end

@interface OCSYNToBoolValueTransformer:NSValueTransformer @end
@implementation OCSYNToBoolValueTransformer
+(Class)transformedValueClass { return [NSNumber class]; }
+(BOOL)allowsReverseTransformation { return NO; }
-transformedValue:value {
    return [NSNumber numberWithBool:[value boolValue]];
}
+(void)load {
    @autoreleasepool {
        [NSValueTransformer setValueTransformer:[[self alloc] init] forName:NSStringFromClass(self.class)];
    }
}
@end

@interface OCSSimpleStringArrayValueTransformer:NSValueTransformer @end
@implementation OCSSimpleStringArrayValueTransformer
+(Class)transformedValueClass { return NSArray.class; }
-transformedValue:value {
    return [value componentsJoinedByString:@", "];
}
-reverseTransformedValue:value {
    NSMutableArray *ma=[NSMutableArray array];
    for (NSString *s in [value componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ,;\t"]]) if (s.length) [ma addObject:s];
    return ma;
}
+(void)load {
    @autoreleasepool {
        [NSValueTransformer setValueTransformer:[[self alloc] init] forName:NSStringFromClass(self.class)];
    }
}
@end
