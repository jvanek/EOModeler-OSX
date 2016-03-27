//
//  OCSRelationshipsAC.h
//  EOModeller
//
//  Created by OC on 5/24/13.
//  Copyright (c) 2013 OC. All rights reserved.
//

#import "OCS_AC.h"

@interface OCSRelationshipsAC:OCS_AC
// support for adding a join can't be easily modelled
@property (weak,nonatomic) IBOutlet NSComboBox *sourceJoinAttribute,*destinationJoinAttribute;
-(IBAction)addJoin:sender;

@end
