//
//  EOModel.m
//  EOModeller
//
//  Created by OC on 24.03.16.
//  Copyleft (c) 2016 OC. No rights reserved, what for, on earth?.
//

#import "EOModel.h"
#import "EOEntity.h"

@interface EOModel ()
@property NSMutableArray *entities; // so that it generates setter, too
@end

@implementation EOModel
@dynamic modelVersion,adaptorName,entityDicts,entitiesWithSharedObjects,storedProcedures,connectionDictionary;
@dynamic username,password,urls,driver,plugin;

-(void)insertObject:(EOEntity*)entity inEntitiesAtIndex:(NSUInteger)index {
    entity.model=self;
    // does NOT add to entityDicts: does not make really sense!
    [(id)self.entities insertObject:entity atIndex:index];
}
-(void)removeObjectFromEntitiesAtIndex:(NSUInteger)index {
    EOEntity *entity=self.entities[index];
    entity.model=nil;
    [(id)self.entities removeObjectAtIndex:index];
}

+(NSDictionary*)keyForProperty {
    return @{
             @"modelVersion":@"EOModelVersion",
             @"entityDicts":@"entities",
             @"entityDictsWithSharedObjects":@"entitiesWithSharedObjects",
             @"username":@"connectionDictionary.username",
             @"password":@"connectionDictionary.password",
             @"urls":@"connectionDictionary.URL",
             @"driver":@"connectionDictionary.driver",
             @"plugin":@"connectionDictionary.plugin"
             };
}

-(EOEntity*)entityNamed:(NSString *)name {
    for (EOEntity *ent in self.entities)
        if (OCSEquals(ent.name,name)) return ent;
    return nil;
}
@end
