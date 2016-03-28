//
//  EORelationship.h
//  EOModeller
//
//  Created by OC on 24.03.16.
//  Copyleft (c) 2016 OC. No rights reserved, what for, on earth?.
//

// represents an attribute in an entity

#import "EOObject.h"

@class EOEntity,EOModel;

@interface EORelationship:EOObject
@property NSString *definition;
@property NSString *deleteRule;
@property NSString *destination;
@property BOOL isMandatory;
@property BOOL isToMany;
@property NSString *joinSemantic;
@property NSArray *joins;
@property NSString *name;
@property NSNumber *numberOfToManyFaultsToBatchFetch;
@property BOOL ownsDestination;
@property BOOL propagatesPrimaryKey;

// specific to attribute, not in rawContents
@property BOOL isClassProperty; // dupped with Attribute, not worth sharing

@property (weak) EOEntity *entity; // convenience back-link to the owner
@property (weak,readonly) EOModel *model; // entity.model

// tasks
+(instancetype)relationshipFromDictionary:(NSMutableDictionary*)reld error:(NSError *__autoreleasing *)error; // with nil reld creates a memory-only empty relationship

-(BOOL)addJoinFromSourceAttribute:(NSString*)sattrname toDestinationAttribute:(NSString*)dattrname;

@end

