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
-(void)ocs_revertToCurrentDiskVersionLogType:(const char*)logtype {
    NSLog(@"... about to %s revert to the disk version (%s)",logtype,self.documentEdited?"EDITED":"unchanged");
    NSError *error;
    if ([self revertToContentsOfURL:self.fileURL ofType:@"revert" error:&error]) NSLog(@"... OK");
    else NSLog(@"... FAILED: %@", error.ocs_localizedErrorDescription);
}
-(void)awakeFromNib {
    [super awakeFromNib];
    NSUserDefaults *def=NSUserDefaults.standardUserDefaults;
    NSTimeInterval checkTI=[def floatForKey:@"cz.ocs.CheckFilesInterval"];
    if (checkTI<=0) return;
    
    self.originalCheckerTimer=[NSTimer scheduledTimerWithTimeInterval:checkTI repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (self.originalWrapper && self.fileURL && ![self.originalWrapper matchesContentsOfURL:self.fileURL]) {
            NSLog(@"WARNING: original wrapper does not match anymore %@!",self.fileURL);
            NSError *error;
            NSFileWrapper *nwr=[[NSFileWrapper alloc] initWithURL:self.fileURL options:NSFileWrapperReadingImmediate error:&error];
            if (nwr) {
                EOModel *nwm=[EOModel modelFromWrapper:nwr error:&error];
                if ([nwm.rawContents isEqualToDictionary:self.originalRawContents]) {
                    NSLog(@"OK: contents is unchanged");
                    self.originalWrapper=nwr; // changed unimportant details, like whspcs or file change times
                    [self.fileDiffersAlert.buttons.lastObject/*keep different*/ performClick:self];
                    return; // conditions below need to be reported
                } else NSLog(@"OOPS, contents really differs or wrong model!");
            } else NSLog(@"WARNING: original path is not readable at %@ since %@!",self.fileURL,error.ocs_localizedErrorDescription);
            if ([def boolForKey:@"cz.ocs.AutoRevertToDiskVersion"] && !self.documentEdited) [self ocs_revertToCurrentDiskVersionLogType:"auto"];
            else if (!self.fileDiffersAlert) { // unless already shown...
                NSLog(@"... showing the alert");
                NSAlert *alert=[[NSAlert alloc] init];
                alert.messageText=@"Contents changed!";
                alert.informativeText=@"The contents of the original model on the disk did change; most probably since a new branch was just checked out. Do you want to read in the new data?";
                if (self.documentEdited) {
                    alert.informativeText=[NSString stringWithFormat:@"%@\n\nBEWARE, the document contains unsaved changes! Should you choose to „Read in“, they are going to be lost irretrievably!", alert.informativeText];
                    [alert addButtonWithTitle:@"Stash as ~ and then read in"];
                }
                [alert addButtonWithTitle:@"Read in"];
                [alert addButtonWithTitle:@"Keep different"];
                NSWindow *over=self.windowControllers[0].window;
                while (over.attachedSheet) over=over.attachedSheet;
                [alert beginSheetModalForWindow:over completionHandler:^(NSModalResponse returnCode) {
                    NSError *error;
                    if (returnCode==NSAlertFirstButtonReturn) {
                        if (alert.buttons.count==2) [self ocs_revertToCurrentDiskVersionLogType:"user-decision"];
                        else/*3 btns -> stash and then revert*/ {
                            NSFileWrapper *currw=[self.model fileWrapperError:&error];
                            if (!currw) NSLog(@"ERROR: could not create current data wrapper: %@",error.ocs_localizedErrorDescription);
                            else {
                                static NSDateFormatter *df;
                                static dispatch_once_t onceToken;
                                dispatch_once(&onceToken, ^{
                                    df=[[NSDateFormatter alloc] init];
                                    df.locale=[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
                                    df.dateFormat=@"yyyy-MM-dd-HHmmss";
                                });
                                NSString *nn=[NSString stringWithFormat:@"%@~%@.%@", self.fileURL.lastPathComponent.stringByDeletingPathExtension, [df stringFromDate:NSDate.date], self.fileURL.pathExtension];
                                NSURL *stash;
                                while ([stash=[self.fileURL.URLByDeletingLastPathComponent URLByAppendingPathComponent:nn] checkResourceIsReachableAndReturnError:NULL]) nn=[nn stringByAppendingString:@"~"];
                                NSLog(@"... saving to %@",stash);
                                if (![currw writeToURL:stash options:0 originalContentsURL:self.fileURL error:&error]) NSLog(@"ERROR: could not write current data to %@",stash);
                                else [self ocs_revertToCurrentDiskVersionLogType:"having-stashed"];
                            }
                        }
                    } else {
                        NSLog(@"... keeping different (in future may overwrite disk)");
#warning Should show the case in validators or something like that, and probably also should warn when saving
                        // must re-read from disk, this happens later, may differ from nwr meantime
                        NSFileWrapper *nwr=[[NSFileWrapper alloc] initWithURL:self.fileURL options:NSFileWrapperReadingImmediate error:&error];
                        if (!nwr) NSLog(@"ERROR: original path is not readable at %@ since %@!",self.fileURL,error.ocs_localizedErrorDescription);
                        else self.originalWrapper=nwr;
                    }
                }];
                self.fileDiffersAlert=alert;
            } else NSLog(@"... keeping the alert shown");
        }
    }];
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

-(OCS_AC*)currentACController {
    id fr=[self.entityTable.window firstResponder];
    while (fr && ![fr isKindOfClass:NSTableView.class] && ![fr isKindOfClass:NSWindow.class]) fr=[fr superview];
    if ([fr isKindOfClass:[NSTableView class]]) {
        id controller=[fr infoForBinding:@"content"][@"NSObservedObject"];
        if ([controller isKindOfClass:OCS_AC.class]) return controller;
    }
    return nil;
}

-(BOOL)doCopy {
    NSArray *selection=self.currentACController.selectedObjects;
    if (!selection.count) {
        NSBeep();
        return NO;
    }
    NSPasteboard *pb=NSPasteboard.generalPasteboard;
    [pb clearContents];
    [pb writeObjects:selection];
    return YES;
}
-(IBAction)cut:sender {
    if ([self doCopy]) [self delete:sender];
}
-(IBAction)copy:sender {
    [self doCopy];
}
-(IBAction)paste:sender {
    OCS_AC *controller=self.currentACController;
    if (!controller.canAdd) return NSBeep();
    NSPasteboard *pb=NSPasteboard.generalPasteboard;
#warning Should be smarter to e.g., allow pasting attributes into an entity; also to fix things like classProperty when pasted... later!
    NSArray *objs=[pb readObjectsForClasses:@[controller.objectClass] options:nil];
    if (!objs) NSBeep();
    else {
        [controller addObjects:objs];
        // whenInserted... but how, on bloody earth?!?
        [self.undoManager registerUndoWithTarget:controller selector:@selector(removeObjects:) object:objs];
    }
}

-(void)delete:sender {
    OCS_AC *controller=self.currentACController;
    if (controller) {
        NSArray *robj=controller.selectedObjects;
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

+(void)initialize {
    [NSUserDefaults.standardUserDefaults registerDefaults:@{
        @"cz.ocs.CheckFilesInterval":@5
    }];
}
@end

