//
//  OCSEntitiesAC.m
//  EOModeller
//
//  Created by OC on 5/24/13.
//  Copyright (c) 2013 OC. All rights reserved.
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

//+(void)updateDictionary:(NSMutableDictionary*)object afterChangedKeyPath:(NSString*)kp {
//    //NSLog(@"updating %@ (%@)",object[@"ocs_type"],kp);
//    NSString *name=object[@"name"];
//    if (!name.length) return;
//    NSString *ename=[self.class validNameForName:name];
//    if (![ename isEqualToString:name]) [self performSelector:@selector(__ocs_replaceNameInBy:) withObject:[NSArray arrayWithObjects:object,ename,nil] afterDelay:0];
//    //NSLog(@"-> (%@) (%@)",ename,object[@"externalName"]);
//}
//+(void)__ocs_replaceNameInBy:(NSArray*)objectAndValue {
//    id value=nil;
//    if (objectAndValue.count==2) value=objectAndValue.lastObject;
//    [objectAndValue[0] setValue:value forKey:@"name"];
//}
@end
