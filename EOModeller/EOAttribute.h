//
//  EOAttribute.h
//  EOModeller
//
//  Created by OC on 24.03.16.
//  Copyleft (c) 2016 OC. No rights reserved, what for, on earth?.
//

// represents an attribute in an entity

#import "EOObject.h"

@class EOEntity,EOModel;

@interface EOAttribute:EOObject
@property NSString *adaptorValueConversionClassName;
@property NSString *adaptorValueConversionMethodName;
@property BOOL allowsNull;
@property NSString *className;
@property NSString *columnName;
@property NSString *definition;
@property NSString *externalType;
@property NSString *factoryMethodArgumentType;
@property BOOL isReadOnly;
@property NSString *name;
@property NSNumber *precision;
@property NSString *prototypeName;
@property NSString *readFormat;
@property NSNumber *scale;
@property NSString *serverTimeZone;
@property NSString *valueFactoryClassName;
@property NSString *valueFactoryMethodName;
@property NSString *valueType;
@property NSNumber *width;
@property NSString *writeFormat;

// specific to attribute, not in rawContents
@property BOOL isUsedForLocking,isClassProperty,isPrimaryKey; // simple convenience with entity
@property (readonly) NSArray *factoryMethodArgumentAvailableTypes; // predef ones plus the real one if differs

@property (weak) EOEntity *entity; // convenience back-link to the owner
@property (weak,readonly) EOModel *model; // entity.model

-(NSString*)columnNameSuggestionFor:(NSString*)name; // suggested -- controller will use it when empty

// tasks
+(instancetype)attributeFromDictionary:(NSMutableDictionary*)attrd error:(NSError *__autoreleasing *)error; // with nil attrd creates a memory-only empty attribute


@end

