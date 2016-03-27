//
//  OCSModelGroup.m
//  EOModeller
//
//  Created by OC on 5/24/13.
//  Copyright (c) 2013 OC. All rights reserved.
//

#import "OCSModelGroup.h"
#import "OCSModel.h"

@implementation OCSModelGroup

+ (BOOL)autosavesInPlace {
    return YES;
}

- (BOOL)readFromFileWrapper:(NSFileWrapper *)wrapper ofType:(NSString *)type error:(NSError **)error {
    if (!wrapper.isDirectory) {
        if (error) *error=OCSERROR(@"Model Group must be a folder");
        return NO;
    }
    
    NSLog(@"WRP %@",wrapper.filename);
    
//    NSDictionary *nw=wrapper.fileWrappers;
//    NSFileWrapper *fw=nw[@"index.eomodeld"];
//    if (!fw || !fw.isRegularFile) {
//        if (error) *error=ERROR(@"No index in model");
//        return NO;
//    }
//    if (!(index=[NSPropertyListSerialization propertyListWithData:fw.regularFileContents options:NSPropertyListMutableContainersAndLeaves format:NULL error:error]))
//        return NO;
//    for (NSDictionary *ed in index[@"entities"]) {
//        NSString *name=[ed[@"name"] stringByAppendingPathExtension:@"plist"];
//        if (!(fw=nw[name]) || !fw.isRegularFile) {
//            if (error) *error=ERROR(@"No '%@' in model",name);
//            return NO;
//        }
//        if (!entities) entities=[NSMutableArray array];
//        NSDictionary *dd=[NSPropertyListSerialization propertyListWithData:fw.regularFileContents options:NSPropertyListMutableContainersAndLeaves format:NULL error:error];
//        if (!dd) return NO;
//        [entities addObject:dd];
//    }
    return NO;
}

@end
