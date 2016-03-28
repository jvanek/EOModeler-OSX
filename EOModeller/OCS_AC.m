//
//  OCS_AC.m
//  EOModeller
//
//  Created by OC on 5/25/13.
//  Copyleft (c) 2013 OC. No rights reserved, what for, on earth?.
//

#import "OCS_AC.h"
#import "OCSModel.h"
#import "OCSEntitiesAC.h"
#import "OCSAttributesAC.h"
#import "OCSRelationshipsAC.h"

@implementation OCS_AC
+(int)smartOrderingPriorityFor:(EOObject*)item {
    return 0;
}
-(NSArray*)arrangeObjects:(NSArray*)objects {
    objects=[super arrangeObjects:objects];
    if (objects.count<=1 || !self.model.smartSort) return objects;
    NSMutableDictionary *pp=[NSMutableDictionary dictionary];
    for (EOObject *item in objects) {
        NSNumber *pn=[NSNumber numberWithInt:[self.class smartOrderingPriorityFor:item]];
        [pp[pn]?:(pp[pn]=[NSMutableArray array]) addObject:item];
    }
    NSMutableArray *ma=nil;
    for (NSNumber *pn in [pp.allKeys sortedArrayUsingSelector:@selector(compare:)]) {
        NSMutableArray *pma=pp[pn];
        if (ma) [ma addObjectsFromArray:pma];
        else ma=pma;
    }
    return ma;
}

-(id)newObject {
    NSAssert(NO,@"newObject not overridden for %@!",self.objectClass);
    return nil;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    self.sortDescriptors=@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
}
@end

