//
//  EOModel.h
//  EOModeller
//
//  Created by OC on 24.03.16.
//  Copyright (c) 2016 OC. All rights reserved.
//

// represents model itself

#import "EOObject.h"

@class EOEntity;

@interface EOModel:EOObject
// generic model items
@property NSString *modelVersion;
@property NSString *adaptorName;
@property NSArray *entityDicts; // these are sub-dicts, see below
@property NSArray *entitiesWithSharedObjects; // these are just names (later, will add BOOL accessor to entity)
@property NSArray *storedProcedures;
@property NSDictionary *connectionDictionary; // see below

// connection dictionary items
@property NSString *username;
@property NSString *password;
@property NSString *urls;
@property NSString *driver;
@property NSString *plugin;

// specific to model, not in rawContents
@property (readonly) NSArray *entities; // EOEntities based on entityDicts

-(EOEntity*)entityNamed:(NSString*)name;
@end

@interface EOModel (FileAccess)
+(instancetype)modelFromWrapper:(NSFileWrapper*)wrapper error:(NSError *__autoreleasing *)error; // with nil wrapper creates a memory-only empty model
-(NSFileWrapper*)fileWrapperError:(NSError *__autoreleasing *)error; // creates wrapper, or nil and error
@end