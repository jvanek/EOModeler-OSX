//
//  OCSModel+SplitViewDelegate.m
//  EOModeller
//
//  Created by OC on 5/24/13.
//  Copyright (c) 2013 OC. All rights reserved.
//

#import "OCSModel.h"

@interface OCSModel (SplitViewDelegate) @end
@implementation OCSModel (SplitViewDelegate)
- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    return ![subview isKindOfClass:NSScrollView.class]; // in main window subviews happen to be scrollviews and never are to be collapsed; in inspector plain customviews can
}
- (BOOL)splitView:(NSSplitView *)splitView shouldCollapseSubview:(NSView *)subview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex {
    return [subview.identifier isEqualToString:@"rawbrowser"]; // only one subview in whole model XIB collapsible this way
}

-(CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
//    if (splitView.subviews[0]==self.attributesTable.enclosingScrollView)
//        NSLog(@"%g caused by %@",[splitView.subviews[0] fittingSize].height,[splitView.subviews[0] constraints]);
//    NSSize vfs=[splitView.subviews[0] fittingSize];
//    CGFloat min=splitView.isVertical?vfs.height:vfs.width;
//    if (min<100) min=100;
//    NSLog(@"%@ MIN proposed %g autolayout %g -> %g of %@",splitView,proposedMinimumPosition,min,proposedMinimumPosition+min,splitView.subviews[0]);
    return proposedMinimumPosition+100;
}
-(CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
//    NSSize vfs=[splitView.subviews[1] fittingSize];
//    CGFloat size=splitView.isVertical?vfs.height:vfs.width;
//    if (size<100) size=100;
//    NSLog(@"%@ MAX proposed %g autolayout %g -> %g of %@",splitView,proposedMaximumPosition,size,proposedMaximumPosition-size,splitView.subviews[1]);
    return proposedMaximumPosition-100;
}
@end
