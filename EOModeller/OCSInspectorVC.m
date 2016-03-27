//
//  OCSInspectorVC.m
//  EOModeller
//
//  Created by OC on 5/25/13.
//  Copyright (c) 2013 OC. All rights reserved.
//

#import "OCSInspectorVC.h"
#import "OCSModel.h"
#import "OCS_AC.h"
#import "OCSEntitiesAC.h"
#import "OCSAttributesAC.h"
#import "OCSRelationshipsAC.h"

#import "EOObject.h"

@implementation OCSInspectorVC {
    EOObject *currentEOObject;
}
-(void)awakeFromNib {
    [super awakeFromNib];
    [self.entitiesAC addObserver:self forKeyPath:@"selection" options:0 context:(__bridge void*)OCSInspectorVC.class];
    [self.attributesAC addObserver:self forKeyPath:@"selection" options:0 context:(__bridge void*)OCSInspectorVC.class];
    [self.relationshipsAC addObserver:self forKeyPath:@"selection" options:0 context:(__bridge void*)OCSInspectorVC.class];
    [self.mainWindow addObserver:self forKeyPath:@"firstResponder" options:0 context:(__bridge void*)OCSInspectorVC.class];
}
-(void)dealloc {
    self.rawBrowser.delegate=nil; // quadruple weird, but it seems when closing window, the browser actually tries to send some delegate stuff from _shouldShowCellExpansionForRow:column:
    
    [self.entitiesAC removeObserver:self forKeyPath:@"selection" context:(__bridge void*)OCSInspectorVC.class];
    [self.attributesAC removeObserver:self forKeyPath:@"selection" context:(__bridge void*)OCSInspectorVC.class];
    [self.relationshipsAC removeObserver:self forKeyPath:@"selection" context:(__bridge void*)OCSInspectorVC.class];
    [self.mainWindow removeObserver:self forKeyPath:@"firstResponder" context:(__bridge void*)OCSInspectorVC.class];
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context!=(__bridge void*)OCSInspectorVC.class) return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    NSArray *selection;
    NSString *tvid=nil;
    if ([keyPath isEqualToString:@"selection"]) {
        tvid=[[object objectClass] typeIdentifier];
        selection=[object selectedObjects];
        if (!selection.count) tvid=[tvid isEqualToString:@"entity"]?@"model":@"";
    } else if ([keyPath isEqualToString:@"firstResponder"]) {
        id fr=[object firstResponder];
        while (fr && ![fr isKindOfClass:NSTableView.class] && ![fr isKindOfClass:NSWindow.class]) fr=[fr superview];
        if ([fr isKindOfClass:[NSTableView class]]) {
            id controller=[fr infoForBinding:@"content"][@"NSObservedObject"];
            if ([controller isKindOfClass:OCS_AC.class]) {
                tvid=[[controller objectClass] typeIdentifier];
                if ((selection=[controller selectedObjects]).count==0) tvid=[tvid isEqualToString:@"entity"]?@"model":@"";
            }
        }
    }
    
    if (tvid) {
        EOObject *eo=selection.lastObject?:[tvid isEqualToString:@"model"]?self.model.model:nil;
        if (eo!=currentEOObject) { // make sure we don't reload unless really needed
            currentEOObject=eo;
            [self.rawBrowser loadColumnZero];
            if (eo && !eo.userInfo) eo.userInfo=[NSMutableDictionary dictionary];
            self.userInfoDC.content=eo.userInfo;
        }
        if (tvid.length && ![tvid isEqualToString:self.mainTabView.selectedTabViewItem.identifier]) // superfluous pbbly, no harm
            [self.mainTabView selectTabViewItemWithIdentifier:tvid];
    }
}

// raw data editor (well viewer, at the moment)
static NSArray *orderedKeys(NSDictionary *dd) {
    return [dd.allKeys sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
}
-(NSString*)browser:(NSBrowser *)sender titleOfColumn:(NSInteger)column {
    return column?nil:@"Raw content";
}
-(NSInteger)browser:(NSBrowser*)browser numberOfRowsInColumn:(NSInteger)column {
    id object=currentEOObject.rawContents;
    for (int i=0;i<column;i++) {
        NSInteger row=[browser selectedRowInColumn:i];
        if ([object isKindOfClass:NSDictionary.class])
            object=object[orderedKeys(object)[row]];
        else if ([object isKindOfClass:NSArray.class])
            object=object[row];
        else object=nil;
    }
    if ([object isKindOfClass:NSDictionary.class]) return orderedKeys(object).count;
    if ([object isKindOfClass:NSArray.class]) return [object count];
    return object?1:0;
}
-(void)browser:(NSBrowser*)browser willDisplayCell:(NSBrowserCell*)cell atRow:(NSInteger)row column:(NSInteger)column {
    id object=currentEOObject.rawContents;
    BOOL leaf=NO;
    for (int i=0;i<column;i++) {
        NSInteger row=[browser selectedRowInColumn:i];
        if ([object isKindOfClass:NSDictionary.class])
            object=object[orderedKeys(object)[row]];
        else if ([object isKindOfClass:NSArray.class])
            object=object[row];
        else object=nil;
    }
    NSString *text;
    if ([object isKindOfClass:NSDictionary.class]) {
        text=orderedKeys(object)[row];
        id val=object[text];
        if (![val isKindOfClass:NSDictionary.class] && ![val isKindOfClass:NSArray.class]) {
            text=[text stringByAppendingFormat:@"=%@",val];
            leaf=YES;
        }
    } else if ([object isKindOfClass:NSArray.class]) {
        id nested=object[row];
        if ([nested isKindOfClass:NSDictionary.class])
            text=[NSString stringWithFormat:@"- dictionary (%ld) -",[nested count]];
        else if ([nested isKindOfClass:NSArray.class]) text=[NSString stringWithFormat:@"- array (%ld) -",[nested count]];
        else {
            text=[nested description];
            leaf=YES;
        }
    } else {
        text=[object description]?:@"--";
        leaf=YES;
    }
    [cell setStringValue:text?:@"???"];
    [cell setLeaf:leaf];
}


@end
