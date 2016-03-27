//
//  OCSModel+TableViewDelegate.m
//  EOModeller
//
//  Created by OC on 5/24/13.
//  Copyright (c) 2013 OC. All rights reserved.
//

#import "OCSModel.h"
#import "OCSEntitiesAC.h"
#import "OCSAttributesAC.h"
#import "OCSRelationshipsAC.h"

#import "EOObject.h"

@interface OCSModel (TableViewDelegate) @end
@implementation OCSModel (TableViewDelegate)
-(BOOL)selectionShouldChangeInTableView:(NSTableView *)tv {
    NSInteger cc=tv.clickedColumn;
    return cc>=0 && cc<tv.tableColumns.count && ![[tv.tableColumns[cc] identifier] hasSuffix:@"_toggleYN"];
}
-(BOOL)tableView:(NSTableView*)tv shouldTrackCell:(NSCell*)cell forTableColumn:(NSTableColumn*)column row:(NSInteger)row {
    if (![column.identifier hasSuffix:@"_toggleYN"]) return YES;
    NSDictionary *bd=[column infoForBinding:@"value"];
    NSArrayController *ac=bd[@"NSObservedObject"];
    NSString *key=[bd[@"NSObservedKeyPath"] componentsSeparatedByString:@"."].lastObject;
    EOObject *tgt=ac.arrangedObjects[row];
    [tgt setValue:@(![[tgt valueForKey:key] boolValue]) forKey:key];
    if (self.smartSort && [key isEqualToString:@"isClassProperty"]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:ac selector:@selector(rearrangeObjects) object:OCSModel.class];
        [ac performSelector:@selector(rearrangeObjects) withObject:OCSModel.class afterDelay:3];
    }
    return NO;
}

-(IBAction)toggleSmartJointAttributes:sender {
    NSLog(@"UNIMPLEMENTED %@",NSStringFromSelector(_cmd));
}
-(IBAction)sizeAttributeColumnsToFit:sender {
    NSLog(@"UNIMPLEMENTED %@",NSStringFromSelector(_cmd));
}
-(IBAction)toggleSmartJointRelationships:sender {
    NSLog(@"UNIMPLEMENTED %@",NSStringFromSelector(_cmd));
}
-(IBAction)sizeRelationshipsToFit:sender {
    NSLog(@"UNIMPLEMENTED %@",NSStringFromSelector(_cmd));
}

//-(void)
@end
