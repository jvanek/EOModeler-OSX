//
//  OCSModel.h
//  EOModeller
//
//  Created by OC on 5/10/13.
//  Copyleft (c) 2013 OC. No rights reserved, what for, on earth?.
//

@class EOModel,OCSEntitiesAC,OCSAttributesAC,OCSRelationshipsAC;
@class OCS_AC;

@interface OCSModel:NSDocument <NSSplitViewDelegate,NSTableViewDelegate>
@property (retain, nonatomic) NSFileWrapper *originalWrapper; // kept so that I can check for changes
@property (copy, nonatomic) NSDictionary *originalRawContents; // need both to check for contents too
@property (retain, nonatomic) NSTimer *originalCheckerTimer; // we'll check occasionally
@property (weak, nonatomic) NSAlert *fileDiffersAlert; // and show the alert if differs

@property (retain,nonatomic) EOModel *model;

@property (retain,nonatomic) IBOutlet NSWindow *sqlWindow; // so as it does not get released
@property (assign,nonatomic) IBOutlet NSTextView *sqlTextView; // in there

@property (assign,nonatomic) IBOutlet NSDrawer *inspectorDrawer; // just so as...
@property (assign,nonatomic) IBOutlet NSSplitView *inspectorSplitView; // ... they state can be stored (damned framework does not do that)

@property (assign,nonatomic) IBOutlet NSSplitView *mainSplit,*leftSplit,*rightSplit;
@property (assign,nonatomic) IBOutlet NSTableView *entityTable,*attributesTable,*relationshipTable;

@property (assign,nonatomic) IBOutlet OCSEntitiesAC *entityAC;
@property (assign,nonatomic) IBOutlet OCSAttributesAC *attributesAC;
@property (assign,nonatomic) IBOutlet OCSRelationshipsAC *relationshipAC;

@property (readonly) BOOL smartSort;

@property (readonly) OCS_AC *currentACController; // the currently selected one of entity/attribute/relationship controllers, if any

-(void)eoObjectDidChange:(NSNotification*)nn; // category access
// TEMPORARY
@property (assign,nonatomic) IBOutlet NSTextView *fsEditor;
@end

