//
//  EOEntity.m
//  EOModeller
//
//  Created by OC on 24.03.16.
//  Copyleft (c) 2016 OC. No rights reserved, what for, on earth?.
//

#import "EOModel.h"
#import "EOEntity.h"
#import "EOAttribute.h"
#import "EORelationship.h"

@interface EOEntity ()
@property NSMutableArray *attributes,*relationships;
@property NSMutableDictionary *fetchSpecifications;
@end

@implementation EOEntity
@dynamic attributeDicts,relationshipDicts,attributesUsedForLocking,classProperties,primaryKeyAttributes,batchFaultingMaxSize,cachesObjects,className,entityIndexes,externalName,externalQuery,isAbstractEntity,isReadOnly,maxNumberOfInstancesToBatchFetch,name,parent,restrictingQualifier,sharedObjectFetchSpecificationNames;

-(BOOL)isGenericRecord {
    return self.className && [self.className hasSuffix:@"GenericRecord"];
}
-(void)setIsGenericRecord:(BOOL)igr {
    [self setValue:igr?@"EOGenericRecord":nil forKey:@"className"];
}
+(NSSet*)keyPathsForValuesAffectingIsGenericRecord {
    return [NSSet setWithObject:@"className"];
}

GenerateISAccessors(model,SharedEOEntity,entitiesWithSharedObjects)

-(void)insertObject:(EOAttribute*)attr inAttributesAtIndex:(NSUInteger)index {
    attr.entity=self;
    if (!self.attributeDicts) self.attributeDicts=[NSMutableArray array];
    [(id)self.attributeDicts addObject:attr.rawContents];
    [(id)self.attributes insertObject:attr atIndex:index];
}
-(void)removeObjectFromAttributesAtIndex:(NSUInteger)index {
    EOAttribute *attr=self.attributes[index];
    attr.entity=nil;
    [(id)self.attributeDicts removeObject:attr.rawContents];
    [(id)self.attributes removeObjectAtIndex:index];
}
-(void)insertObject:(EORelationship*)rel inRelationshipsAtIndex:(NSUInteger)index {
    rel.entity=self;
    if (!self.relationshipDicts) self.relationshipDicts=[NSMutableArray array];
    [(id)self.relationshipDicts addObject:rel.rawContents];
    [(id)self.relationships insertObject:rel atIndex:index];
}
-(void)removeObjectFromRelationshipsAtIndex:(NSUInteger)index {
    EORelationship *rel=self.relationships[index];
    rel.entity=nil;
    [(id)self.relationshipDicts removeObject:rel.rawContents];
    [(id)self.relationships removeObjectAtIndex:index];
}

+(NSDictionary*)keyForProperty {
    return @{
             @"attributeDicts":@"attributes",
             @"relationshipDicts":@"relationships",
             };
}

-(BOOL)canSetDefaultNames {
    return self.name.length && (!self.className.length || !self.externalName.length);
}
+(NSSet*)keyPathsForValuesAffectingCanSetDefaultNames {
    return [NSSet setWithObjects:@"name",@"className",@"externalName", nil];
}

-(void)setDefaultNames:(NSString*)name {
    if (!self.className.length)
        [self setValue:[self classNameSuggestionFor:name] forKey:@"className"];
    if (!self.externalName.length)
        [self setValue:[self externalNameSuggestionFor:name] forKey:@"externalName"];
}

-(BOOL)validateExternalName:(NSString**)name error:(NSError *__autoreleasing *)error {
    return [self validateName:name error:error];
}
-(BOOL)validateParent:(NSString**)name error:(NSError *__autoreleasing *)error {
    return [self validateName:name error:error];
}

-(NSString*)classNameSuggestionFor:(NSString*)name {
    return name;
}
-(NSString*)externalNameSuggestionFor:(NSString*)name {
    return [self.class sqlifiedNameForName:name withPrefix:@"T_"];
}
@end
