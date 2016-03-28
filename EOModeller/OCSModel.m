//
//  OCSModel.m
//  EOModeller
//
//  Created by OC on 5/10/13.
//  Copyleft (c) 2013 OC. No rights reserved, what for, on earth?.
//

#import "OCSModel.h"
#import "OCSEntitiesAC.h"
#import "OCSAttributesAC.h"
#import "OCSRelationshipsAC.h"

#import "EOModel.h"
#import "EOEntity.h"

@implementation OCSModel
-(BOOL)smartSort {
    return [NSUserDefaults.standardUserDefaults boolForKey:@"SmartSort"];
}
-(IBAction)toggleSmartSortMode:sender {
    [NSUserDefaults.standardUserDefaults setBool:!self.smartSort forKey:@"SmartSort"];
    [self.entityAC rearrangeObjects];
    [self.attributesAC rearrangeObjects];
    [self.relationshipAC rearrangeObjects];
}

-(NSString *)windowNibName {
    return @"OCSModel";
}
-(void)awakeFromNib {
    [super awakeFromNib];
}
-(void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self]; // added in FileAccess when model created
}

-(void)eoObjectDidChange:(NSNotification*)nn {
    //NSLog(@"undo: registering '%@' for %@",nn.userInfo[@"keypath"],nn.userInfo[@"object"]);
    [self.undoManager registerUndoWithTarget:self selector:@selector(eoObjectUndo:) object:nn.userInfo];
}
-(void)eoObjectUndo:(NSDictionary*)undo {
    //NSLog(@"undo: undoing '%@' for %@ -> '%@'",undo[@"keypath"],undo[@"object"],undo[@"old"]);
    [undo[@"object"] setValue:undo[@"old"] forKeyPath:undo[@"keypath"]];
}

-(id)currentACController {
    id fr=[self.entityTable.window firstResponder];
    while (fr && ![fr isKindOfClass:NSTableView.class] && ![fr isKindOfClass:NSWindow.class]) fr=[fr superview];
    if ([fr isKindOfClass:[NSTableView class]]) {
        id controller=[fr infoForBinding:@"content"][@"NSObservedObject"];
        if ([controller isKindOfClass:OCS_AC.class]) return controller;
    }
    return nil;
}

-(void)delete:sender {
    id controller=self.currentACController;
    if (controller) {
        NSArray *robj=[controller selectedObjects];
        [controller remove:self];
        [self.undoManager registerUndoWithTarget:controller selector:@selector(addObjects:) object:robj];
    }
}

-(void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    NSArray *senames=[self.entityAC.selectedObjects valueForKey:@"name"];
    [coder encodeObject:senames forKey:@"cz.ocs.senames"];
    //[coder encodeDouble:NSHeight([self.inspectorSplitView.subviews[0] frame]) forKey:@"cz.ocs.inspectorheight"];
    //[coder encodeBool:[self.inspectorSplitView isSubviewCollapsed:self.inspectorSplitView.subviews[0]] forKey:@"cz.ocs.inspectorcollapsed"];
    [coder encodeDouble:self.inspectorDrawer.contentSize.width forKey:@"cz.ocs.drawerwidth"];
    [coder encodeBool:self.inspectorDrawer.state==NSDrawerOpeningState || self.inspectorDrawer.state==NSDrawerOpenState forKey:@"cz.ocs.draweropen"];
}
-(void)restoreStateWithCoder:(NSCoder *)coder {
    [super restoreStateWithCoder:coder];
    NSArray *senames=[coder decodeObjectForKey:@"cz.ocs.senames"];
    if (senames.count) {
        NSIndexSet *sendx=[self.entityAC.arrangedObjects indexesOfObjectsPassingTest:^BOOL(EOEntity *obj, NSUInteger idx, BOOL *stop) {
            return [senames containsObject:obj.name];
        }];
        self.entityAC.selectionIndexes=sendx;
    }
    CGFloat x;
//    if ((x=[coder decodeDoubleForKey:@"cz.ocs.inspectorheight"])>=100) {
//        NSRect ifr=[self.inspectorSplitView.subviews[0] frame];
//        ifr.size.height=x;
//        [self.inspectorSplitView.subviews[0] setFrame:ifr];
//    }
    //if ([coder ])
    if ((x=[coder decodeDoubleForKey:@"cz.ocs.drawerwidth"])>=100) {
        NSSize dsz=self.inspectorDrawer.contentSize;
        dsz.width=x;
        self.inspectorDrawer.contentSize=dsz;
    }
    if ([coder decodeBoolForKey:@"cz.ocs.draweropen"]) [self.inspectorDrawer open];
}

-(BOOL)validateToolbarItem:(NSToolbarItem*)tbi {
    if (tbi.action==@selector(toggleSmartSortMode:)) tbi.image=[NSImage imageNamed:self.smartSort?@"SmartSort":@"SmartSortOff"];
    return YES;
}
-(BOOL)validateMenuItem:(NSMenuItem *)mi {
    //NSLog(@"model %@ validates mi %@",self,NSStringFromSelector(mi.action));
    if (mi.action==@selector(toggleSmartSortMode:)) mi.state=self.smartSort?NSOnState:NSOffState;
    else if (mi.action==@selector(addNewEntity:)) return [self.entityAC canAdd];
    else if (mi.action==@selector(addNewAttribute:)) return [self.attributesAC canAdd];
    else if (mi.action==@selector(addNewRelationship:)) return [self.relationshipAC canAdd];
    return YES;
}

// these simply redirect for FR, don't add functionality here, if needed, add into ACs
-(IBAction)addNewEntity:sender { [self.entityAC add:sender]; }
-(IBAction)addNewAttribute:sender { [self.attributesAC add:sender]; }
-(IBAction)addNewRelationship:sender { [self.relationshipAC add:sender]; }

-(IBAction)toggleModelInspector:sender { [self.inspectorDrawer toggle:sender]; }
@end

