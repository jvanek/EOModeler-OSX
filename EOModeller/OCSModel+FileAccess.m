//
//  OCSModel+FileAccess.m
//  EOModeller
//
//  Created by OC on 5/24/13.
//  Copyleft (c) 2013 OC. No rights reserved, what for, on earth?.
//

#import "OCSModel.h"
#import "OCS_AC.h"

#import "EOModel.h"

@implementation OCSModel (FileAccess)
//+(BOOL)autosavesInPlace {
//    return YES;
//}

-(NSFileWrapper*)fileWrapperOfType:(NSString *)type error:(NSError **)error {
    return [self.model fileWrapperError:error];
}

-(BOOL)readFromFileWrapper:(NSFileWrapper *)wrapper ofType:(NSString *)type error:(NSError **)error {
    if (self.model) [NSNotificationCenter.defaultCenter removeObserver:self name:EOObjectDidChangeNotification object:self.model];
    [self.undoManager disableUndoRegistration];
    @try {
        if (!(self.model=[EOModel modelFromWrapper:wrapper error:error])) return NO;
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(eoObjectDidChange:) name:EOObjectDidChangeNotification object:self.model]; // handler defined in OCSModel.h
        self.originalWrapper=wrapper;
        self.originalRawContents=self.model.rawContents;
    } @catch (id o) {
        NSLog(@"Exception: %@",o);
        if (error) *error=OCSERROR(@"Exception '%@'",o);
        return NO;
    } @catch (...) {
        NSLog(@"Exception: C++");
        if (error) *error=OCSERROR(@"Exception C++");
        return NO;
    } @finally {
        [self.undoManager enableUndoRegistration];
    }
    return YES;
}
@end
