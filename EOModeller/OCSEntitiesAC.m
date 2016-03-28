//
//  OCSEntitiesAC.m
//  EOModeller
//
//  Created by OC on 5/24/13.
//  Copyleft (c) 2013 OC. No rights reserved, what for, on earth?.
//

#import "OCSEntitiesAC.h"
#import "OCSModel.h"

#import "EOEntity.h"

@implementation OCSEntitiesAC
+(int)smartOrderingPriorityFor:(EOEntity*)item {
    if (item.isAbstractEntity) return 0;
    if (item.isGenericRecord) return 2;
    return 1;
}

-(id)newObject {
    [self.model.inspectorDrawer performSelector:@selector(open:) withObject:self afterDelay:0];
    return [EOEntity entityFromWrapper:nil fetchSpecifications:nil error:NULL];
}

@end
