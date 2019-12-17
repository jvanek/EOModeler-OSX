//
//  OCSAppDelegate.m
//  EOModeller
//
//  Created by OC on 5/16/13.
//  Copyleft (c) 2013 OC. No rights reserved, what for, on earth?.
//

#import "OCSAppDelegate.h"
#import "EOModel.h"

@interface OCSAppDelegate ()
@end

@implementation OCSAppDelegate
-(BOOL)applicationShouldOpenUntitledFile:(NSApplication*)sender { // does not do that automagically, allows New still
    return NO;
}

-(IBAction)showModelReferencePDF:sender {
    [[NSWorkspace sharedWorkspace] openFile:[NSBundle.mainBundle pathForResource:@"WO_BundleReference" ofType:@"pdf"]];
}

+(void)initialize {
    [NSUserDefaults.standardUserDefaults registerDefaults:@{
        @"DefaultAttributeSQLTypes":@[@"BOOLEAN", @"INTEGER", @"LOGINT", @"DECIMAL", @"CHAR VARYING", @"TIMESTAMP", @"BLOB"],
        @"DefaultAttributeClassNames":@[@"NSString", @"NSNumber", @"NSDecimalNumber", @"NSCalendarDate", @"NSData"],
        @"ValueTypesByClassName":@{
                @"NSString":@[
                        @"Auto string/stream", @"Stream (C)", @"Trim (c)", @"Encoded (E)", @"String (S)",
                        ],
                @"NSNumber":@[
                        @"BigDecimal (B)", @"Byte (b)", @"Boolean (c)", @"Double (d)", @"Float (f)", @"Integer (i)", @"Long (l)", @"Short (s)",
                        ],
                @"NSDecimalNumber":@[
                        @"BigDecimal (B)"
                        ],
                @"NSCalendarDate":@[
                        @"Automatic", @"Date (D)", @"M$-SQL Date (M)", @"Time (t)", @"Timestamp (T)",
                        ],
                },
        }];
}
@end
