//
//  EOObject.h
//  EOModeller
//
//  Created by OC on 24.03.16.
//  Copyleft (c) 2016 OC. No rights reserved, what for, on earth?.
//

// base class for all EO objects, shared functionality

@interface EOObject:NSObject <NSPasteboardWriting, NSPasteboardReading>
@property NSMutableDictionary *userInfo; // dynamic, ie., reads from rawContents -- see below

@property NSMutableDictionary *rawContents; // "real" property; the raw dictionary contents, as read/written to/from file

+(NSDictionary*)keyForProperty; // all @dynamic properties are automatically read from/written to the rawContents dictionary. If a property should use a different dictionary key, return {property:key} (no need for super, this level returns @{}). Key can contain dots for nested dictionaries

+(NSString*)typeIdentifier; // essentially class name, but cleaned up from prefix and KVO artifacts
-(void)prepareCopyWithDictionary:(NSMutableDictionary*)data; // to be overridden, adds to dictionary whatever it considers reasonable. The dictionary already contains rawContents (with key @".")
-(void)finishPasteWithDictionary:(NSDictionary*)data; // self-describing (rawContents already set)

-(void)reportDidChangeKeyPath:(NSString*)keypath oldValue:oldValue; // essentially internal, used in subclasses too. Sends EOObjectDidChangeNotification, copies value if copiable

+(NSString*)validNameForName:(NSString*)name allowDots:(BOOL)allowDots; // cleans up a property/entity (!allowDots)/class (allow) name so that is valid; used with validations
+(NSString*)sqlifiedNameForName:(NSString*)name withPrefix:(NSString*)prefix; // generates an appropriate SQL name for a property/entity name

-(BOOL)validateName:(NSString**)name error:(NSError *__autoreleasing *)error; // since property "name" is shared betw. most EOObjects, its validation is implemented here. Also, reusable (same rules apply to external names). ALSO: if instance responds to selector setDefaultNames, it is scheduled with the new name for argument
-(BOOL)validateClassName:(NSString**)name error:(NSError *__autoreleasing *)error; // twice directly inherited, also reusable
@end

extern NSString * const EOObjectDidChangeNotification; // posted when changes to allow undo; object is model...

// this is actually an implementation detail, too -- used to create isXXX methods of entity/attribute/relationship, where IS if some parent's attribute contains “my” name. Should be in an internal header, if we had one :) Capitalized is the capitalized part of getter, eg., ClassProperty for isClassProperty; attr is the appropriate array attribute of the parent, eg., classProperties
#define setAttrValue(parent,attr,value) \
  if (value) { \
    NSMutableArray *ma=(id)self.parent.attr; \
    if (!ma) self.parent.attr=ma=[NSMutableArray array]; \
    else if ([ma containsObject:self.name]) return; \
    [ma addObject:self.name]; \
  } else [(id)self.parent.attr removeObject:self.name];
#define GenerateISAccessors(parent,capitalized,attr) \
  -(BOOL)is##capitalized { \
    return [self.parent.attr containsObject:self.name]; \
  } \
  -(void)setIs##capitalized:(BOOL)value { \
    BOOL orig=[self is##capitalized]; \
    setAttrValue(parent,attr,value); \
    [self reportDidChangeKeyPath:@"is" #capitalized oldValue:@(orig)]; \
  }
