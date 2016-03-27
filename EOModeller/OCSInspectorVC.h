//
//  OCSInspectorVC.h
//  EOModeller
//
//  Created by OC on 5/25/13.
//  Copyright (c) 2013 OC. All rights reserved.
//

@class OCSModel,OCSEntitiesAC,OCSAttributesAC,OCSRelationshipsAC;

@interface OCSInspectorVC:NSViewController <NSBrowserDelegate>
@property (weak,nonatomic) IBOutlet OCSModel *model;

@property (weak,nonatomic) IBOutlet NSWindow *mainWindow; // should be available programmatically?!? :-O
@property (weak,nonatomic) IBOutlet NSTabView *mainTabView;

@property (weak,nonatomic) IBOutlet OCSEntitiesAC *entitiesAC;
@property (weak,nonatomic) IBOutlet OCSAttributesAC *attributesAC;
@property (weak,nonatomic) IBOutlet OCSRelationshipsAC *relationshipsAC;
@property (weak,nonatomic) IBOutlet NSDictionaryController *userInfoDC;

@property (weak,nonatomic) IBOutlet NSBrowser *rawBrowser;

@end
