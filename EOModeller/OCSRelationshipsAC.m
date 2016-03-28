//
//  OCSRelationshipsAC.m
//  EOModeller
//
//  Created by OC on 5/24/13.
//  Copyleft (c) 2013 OC. No rights reserved, what for, on earth?.
//

#import "OCSRelationshipsAC.h"
#import "OCSModel.h"

#import "EORelationship.h"

@implementation OCSRelationshipsAC
+(int)smartOrderingPriorityFor:(EORelationship*)item {
    return item.isClassProperty?0:1;
}

-(id)newObject {
    [self.model.inspectorDrawer performSelector:@selector(open:) withObject:self afterDelay:0];
    return [EORelationship relationshipFromDictionary:nil error:NULL];
}

-(IBAction)addJoin:sender {
    for (EORelationship *rel in self.selectedObjects)
        if (![rel addJoinFromSourceAttribute:self.sourceJoinAttribute.stringValue toDestinationAttribute:self.destinationJoinAttribute.stringValue]) NSBeep(); // if more is selected, would play a fugue; but if more is selected, should not be called anyway
}
@end
