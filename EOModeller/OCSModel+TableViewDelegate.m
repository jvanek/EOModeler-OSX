//
//  OCSModel+TableViewDelegate.m
//  EOModeller
//
//  Created by OC on 5/24/13.
//  Copyleft (c) 2013 OC. No rights reserved, what for, on earth?.
//

#import "OCSModel.h"
#import "OCSEntitiesAC.h"
#import "OCSAttributesAC.h"
#import "OCSRelationshipsAC.h"

#import "EOObject.h"
#import "EOEntity.h"

@interface OCSModel (TableViewDelegate) @end
@implementation OCSModel (TableViewDelegate)
-(BOOL)selectionShouldChangeInTableView:(NSTableView *)tv {
    NSInteger cc=tv.clickedColumn;
    return cc>=0 && cc<tv.tableColumns.count && ![[tv.tableColumns[cc] identifier] hasSuffix:@"_toggleYN"];
}
static EOEntity *editingFS; // QUICK AND DIRTY, see below
-(BOOL)tableView:(NSTableView*)tv shouldTrackCell:(NSCell*)cell forTableColumn:(NSTableColumn*)column row:(NSInteger)row {
    if (OCSEquals(column.identifier,@"numberOfFSs")) {
        // QUICK AND DIRTY, will change when there's time to do FS editor right. Therefore dupped code, too
        NSDictionary *bd=[column infoForBinding:@"value"];
        NSArrayController *ac=bd[@"NSObservedObject"];
        editingFS=ac.arrangedObjects[row];
        NSLog(@"WANNA edit %@ of %@",editingFS.fetchSpecifications,editingFS.name);
        // this is EXTREMELY q&d, WILL change... well, when I have some time :)
        self.fsEditor.string=[editingFS.fetchSpecifications ocs_openStepPropertyListError:NULL]?:@"";
        self.fsEditor.font=[NSFont userFixedPitchFontOfSize:0];
        [NSApp beginSheet:self.fsEditor.window modalForWindow:self.entityTable.window modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
        return NO;
    }
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
-(IBAction)fsEditorOK:(id)sender {
    NSError *error=nil; // used as flag. Ugly. Nevermind, temp code anyway!
    id fs=nil;
    if (self.fsEditor.string.length) {
        fs=[NSPropertyListSerialization propertyListWithData:[self.fsEditor.string dataUsingEncoding:NSUTF8StringEncoding] options:NSPropertyListMutableContainersAndLeaves format:NULL error:&error];
        if (!fs) [self.fsEditor.window presentError:error modalForWindow:self.fsEditor.window delegate:nil didPresentSelector:NULL contextInfo:NULL];
    }
    [editingFS setValue:fs forKey:@"fetchSpecifications"]; // should auto-update the column (which works) and the list of FS names in inspector, which does not, [FSNUPD] in EOEntity. At the moment am NOT solving, for the code is to be trashed as soon as I have time for a decent FS editor anyway (it is alas a bit non-trivial due to those EOKeyArchived qualifiers)
    if (!error) [self fsEditorCancel:self];
}
-(IBAction)fsEditorCancel:(id)sender {
    editingFS=nil;
    [NSApp endSheet:self.fsEditor.window];
    [self.fsEditor.window orderOut:self];
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

// this one will change when there's time to do FSpecs right
-(NSString*)tableView:(NSTableView*)tv toolTipForCell:(NSCell*)cell rect:(NSRectPointer)rect tableColumn:(NSTableColumn*)tc row:(NSInteger)row mouseLocation:(NSPoint)mouseLocation {
    if (!OCSEquals(tc.identifier,@"numberOfFSs")) return nil;
    
    EOEntity *ent=self.entityAC.arrangedObjects[row];
    NSArray *fsnames=[ent.fetchSpecifications.allKeys sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    if (!fsnames) return nil;
    return [fsnames componentsJoinedByString:@", "];
}


@end
