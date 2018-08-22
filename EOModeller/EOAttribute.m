//
//  EOAttribute.m
//  EOModeller
//
//  Created by OC on 24.03.16.
//  Copyleft (c) 2016 OC. No rights reserved, what for, on earth?.
//

#import "EOAttribute.h"
#import "EOEntity.h"

@implementation EOAttribute
@dynamic adaptorValueConversionClassName,adaptorValueConversionMethodName,allowsNull,className,columnName,definition,externalType,factoryMethodArgumentType,isReadOnly,name,precision,prototypeName,readFormat,scale,serverTimeZone,valueFactoryClassName,valueFactoryMethodName,valueType,width,writeFormat;

-(NSString*)displayAttributeType {
    if (self.definition) return [@"\u21b0 " stringByAppendingString:self.definition];
    NSString *vcl=self.className?:@"???",*vt=self.valueType,*dbt=self.externalType?:@"???";
    NSNumber *wd=self.width,*scl=self.scale,*prc=self.precision;
    if (vt.length) vcl=[vcl stringByAppendingFormat:@":%@",vt];
    if (wd) vcl=[vcl stringByAppendingFormat:@"(%@)",wd];
    if (scl || prc) vcl=[vcl stringByAppendingFormat:@"(%@,%@)",prc,scl];
    vcl=[vcl stringByAppendingFormat:@"/%@",dbt];
    return vcl;
}
+(NSSet*)keyPathsForValuesAffectingDisplayAttributeType {
    return [NSSet setWithObjects:@"definition",@"className",@"valueType",@"width",@"scale",@"precision",@"externalType", nil];
}

GenerateISAccessors(entity,UsedForLocking,attributesUsedForLocking)
GenerateISAccessors(entity,ClassProperty,classProperties)
GenerateISAccessors(entity,PrimaryKey,primaryKeyAttributes)

-(NSArray*)availableSQLTypes {
    return [NSUserDefaults.standardUserDefaults arrayForKey:@"DefaultAttributeSQLTypes"];
}
-(NSArray*)availableClassNames {
    return [NSUserDefaults.standardUserDefaults arrayForKey:@"DefaultAttributeClassNames"];
}
-(NSArray*)factoryMethodArgumentAvailableTypes {
    return @[@"EOFactoryMethodArgumentIsBytes", @"EOFactoryMethodArgumentIsData", @"EOFactoryMethodArgumentIsString"];
}
-(NSArray*)availableValueTypeDisplayItems {
    return [NSUserDefaults.standardUserDefaults dictionaryForKey:@"ValueTypesByClassName"][self.className];
}
+(NSSet*)keyPathsForValuesAffectingAvailableValueTypeDisplayItems {
    return [NSSet setWithObject:@"className"];
}
-(NSString*)valueTypeDisplayItem {
    NSString *found,*vt=self.valueType,*vtsuffix;
    NSArray *avail=self.availableValueTypeDisplayItems;
    if (!vt && !avail.count)
        return [NSString stringWithFormat:@"No value types in %@",self.className]; // check [*]
    if (vt.length) vtsuffix=[NSString stringWithFormat:@" (%@)",vt];
    for (NSString *item in avail)
        if (!vt.length && ![item hasSuffix:@")"] ||
            vt.length && [item hasSuffix:vtsuffix]) {
            found=item;
            break;
        }
    if (found) return found;
    return [NSString stringWithFormat:@"No '%@' in %@",self.valueType?:@"--",self.className]; // check [*]
}
-(void)setValueTypeDisplayItem:(NSString*)displayItem {
    if ([displayItem hasPrefix:@"No "]) return;  // [*] based on text, this is info-string, does not edit
    if (![displayItem hasSuffix:@")"]) [self setValue:nil forKey:@"valueType"];
    [self setValue:[displayItem substringWithRange:NSMakeRange(displayItem.length-2, 1)] forKey:@"valueType"];
}
+(NSSet*)keyPathsForValuesAffectingValueTypeDisplayItem {
    return [NSSet setWithObjects:@"valueType",@"className",nil];
}
-(BOOL)isDerived {
    return self.definition.length>0;
}
+(NSSet*)keyPathsForValuesAffectingIsDerived {
    return [NSSet setWithObject:@"definition"];
}

-(EOModel __weak *)model {
    return self.entity.model;
}


-(void)forceDefaultNames:(NSString*)name {
    [self setValue:[self columnNameSuggestionFor:name] forKey:@"columnName"];
}
-(void)setDefaultNames:(NSString*)name {
    if (!self.columnName.length)
        [self setValue:[self columnNameSuggestionFor:name] forKey:@"columnName"];
}

-(BOOL)validateAdaptorValueConversionClassName:(NSString**)name error:(NSError *__autoreleasing *)error {
    return [self validateClassName:name error:error];
}
-(BOOL)validateAdaptorValueConversionMethodName:(NSString**)name error:(NSError *__autoreleasing *)error {
    return [self validateName:name error:error];
}
-(BOOL)validateColumnName:(NSString**)name error:(NSError *__autoreleasing *)error {
    return [self validateName:name error:error];
}
-(BOOL)validatePrototypeName:(NSString**)name error:(NSError *__autoreleasing *)error {
    return [self validateName:name error:error];
}
-(BOOL)validateValueFactoryClassName:(NSString**)name error:(NSError *__autoreleasing *)error {
    return [self validateClassName:name error:error];
}
-(BOOL)validateValueFactoryMethodName:(NSString**)name error:(NSError *__autoreleasing *)error {
    return [self validateName:name error:error];
}

-(NSString*)columnNameSuggestionFor:(NSString*)name {
    return [self.class sqlifiedNameForName:name withPrefix:@"C_"];
}

+(instancetype)attributeFromDictionary:(NSMutableDictionary*)attrd error:(NSError *__autoreleasing *)error {
    return [[self alloc] initWithDictionary:attrd error:error];
}
-(instancetype)initWithDictionary:(NSMutableDictionary*)attrd error:(NSError *__autoreleasing *)error {
    if (!(self=[super init])) return nil;
    self.rawContents=attrd?:[NSMutableDictionary dictionary];
    // resolve deprecations
    if ([self.rawContents[@"valueClassName"] length] && !self.className.length) {
        self.className=self.rawContents[@"valueClassName"];
        [self.rawContents removeObjectForKey:@"valueClassName"];
    }
    if ([self.rawContents[@"updateFormat"] length] && !self.writeFormat.length) {
        self.writeFormat=self.rawContents[@"updateFormat"];
        [self.rawContents removeObjectForKey:@"updateFormat"];
    }
    if ([self.rawContents[@"insertFormat"] length] && !self.writeFormat.length) {
        self.writeFormat=self.rawContents[@"insertFormat"];
        [self.rawContents removeObjectForKey:@"insertFormat"];
    }
    if ([self.rawContents[@"selectFormat"] length] && !self.readFormat.length) {
        self.readFormat=self.rawContents[@"selectFormat"];
        [self.rawContents removeObjectForKey:@"selectFormat"];
    }
    if ([self.rawContents[@"externalName"] length] && !self.columnName.length) {
        self.columnName=self.rawContents[@"externalName"];
        [self.rawContents removeObjectForKey:@"externalName"];
    }
    if ([self.rawContents[@"userDictionary"] count]) {
        if (!self.userInfo) self.userInfo=[NSMutableDictionary dictionary];
        [self.userInfo ocs_addNewEntriesWithKeys:nil fromDictionary:self.rawContents[@"userDictionary"]];
        [self.rawContents removeObjectForKey:@"userDictionary"];
    }
    if (self.rawContents[@"maximumLength"] && !self.width) {
        self.width=self.rawContents[@"maximumLength"];
        [self.rawContents removeObjectForKey:@"maximumLength"];
    }
    
    return self;
}

@end
