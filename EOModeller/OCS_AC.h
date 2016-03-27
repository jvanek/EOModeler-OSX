//
//  OCS_AC.h
//  EOModeller
//
//  Created by OC on 5/25/13.
//  Copyright (c) 2013 OC. All rights reserved.
//

@class OCSModel,EOObject;

// shared behaviour of all the three array controllers

@interface OCS_AC:NSArrayController
@property (weak,nonatomic) IBOutlet OCSModel *model;

+(int)smartOrderingPriorityFor:(EOObject*)item; // grouped by priorities in smart mode
@end
