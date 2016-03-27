//
//  OCSAppDelegate.m
//  EOModeller
//
//  Created by OC on 5/16/13.
//  Copyright (c) 2013 OC. All rights reserved.
//

#import "OCSAppDelegate.h"
#import "EOModel.h"

@interface OCSAppDelegate ()
@end

@implementation OCSAppDelegate
//-(void)applicationDidFinishLaunching:(NSNotification *)notification {
//    NSLog(@"HELLO");
//    EOModel *o=[EOModel
//    NSLog(@"got %@",o);
//    o.username=@"hi";
//    NSLog(@"set");
//    NSLog(@"-> %@ OF %@",o.username,o.rawContents);
//    o.username=nil;
//    NSLog(@"set");
//    NSLog(@"-> %@ OF %@",o.username,o.rawContents);
//    NSLog(@"dying");
//    [NSApp terminate:self];
//}

-(BOOL)applicationShouldOpenUntitledFile:(NSApplication*)sender { // does not do that automagically, allows New still
    return NO;
}

-(IBAction)showModelReferencePDF:sender {
    [[NSWorkspace sharedWorkspace] openFile:[NSBundle.mainBundle pathForResource:@"WO_BundleReference" ofType:@"pdf"]];
}
@end
