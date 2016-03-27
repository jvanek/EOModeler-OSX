//
//  OCSAttributesAC.m
//  EOModeller
//
//  Created by OC on 5/24/13.
//  Copyright (c) 2013 OC. All rights reserved.
//

#import "OCSAttributesAC.h"
#import "OCSModel.h"

#import "EOAttribute.h"

@implementation OCSAttributesAC
+(int)smartOrderingPriorityFor:(EOAttribute*)item {
    return item.isClassProperty?0:1;
}

-(id)newObject {
    [self.model.inspectorDrawer performSelector:@selector(open:) withObject:self afterDelay:0];
    return [EOAttribute attributeFromDictionary:nil error:NULL];
}

@end
