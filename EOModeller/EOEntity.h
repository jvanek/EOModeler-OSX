//
//  EOEntity.h
//  EOModeller
//
//  Created by OC on 24.03.16.
//  Copyleft (c) 2016 OC. No rights reserved, what for, on earth?.
//

// represents an entity in a model

#import "EOObject.h"

@class EOModel;

@interface EOEntity:EOObject
@property NSArray *attributeDicts,*relationshipDicts; // these are sub-dicts, see below
@property NSArray *attributesUsedForLocking,*classProperties,*primaryKeyAttributes; // access through EOAttribute, not directly!
@property NSNumber *batchFaultingMaxSize;
@property BOOL cachesObjects;
@property NSString *className;
@property NSArray *entityIndexes;
@property NSString *externalName;
@property NSString *externalQuery;
@property BOOL isAbstractEntity;
@property BOOL isReadOnly;
@property NSNumber *maxNumberOfInstancesToBatchFetch;
@property NSString *name;
@property NSString *parent;
@property NSString *restrictingQualifier;
@property NSArray *sharedObjectFetchSpecificationNames;

// specific to entity, not in rawContents
@property (readonly) NSArray *attributes,*relationships; // EOAttributes/EORelationships based on ...Dicts...
@property BOOL isGenericRecord; // simple convenience with className
@property BOOL isSharedEOEntity;

@property (readonly) NSDictionary *fetchSpecifications; // by name; read from separate file in (this) extra "real" property, not in rawContents

@property (weak) EOModel *model; // convenience back-link to the owner

-(NSString*)classNameSuggestionFor:(NSString*)name; // suggested -- controller will use it when empty
-(NSString*)externalNameSuggestionFor:(NSString*)name;
@end

@interface EOEntity (FileAccess)
+(instancetype)entityFromWrapper:(NSFileWrapper*)wrapper fetchSpecifications:(NSFileWrapper*)fswrapper error:(NSError *__autoreleasing *)error; // with nil wrapper creates a memory-only empty entity; nil fswrapper simply means there is no fetch specs
-(NSArray*)fileWrappersError:(NSError *__autoreleasing *)error; // creates ONE OR TWO wrappers (depending on whether there are fetchSpectifications), or nil and error
@end