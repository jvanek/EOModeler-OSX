//
//  EOModel+FileAccess.m
//  EOModeller
//
//  Created by OC on 26.03.16.
//  Copyleft (c) 2016 OC. No rights reserved, what for, on earth?.
//

#import "EOModel.h"
#import "EOEntity.h"

@interface EOModel ()
@property NSMutableArray *entities; // just so that assignment below works
@end

@implementation EOModel (FileAccess)
+(instancetype)modelFromWrapper:(NSFileWrapper*)wrapper error:(NSError *__autoreleasing *)error {
    return [[self alloc] initWithWrapper:wrapper error:error];
}
-(instancetype)initWithWrapper:(NSFileWrapper*)wrapper error:(NSError *__autoreleasing *)error {
    if (!(self=[super init])) return nil;
    self.entities=[NSMutableArray array];
    if (wrapper && ![self readFromWrapper:wrapper error:error]) return nil;
    if (!self.rawContents) self.rawContents=[NSMutableDictionary dictionary];
    return self;
}

-(BOOL)readFromWrapper:(NSFileWrapper*)wrapper error:(NSError *__autoreleasing *)error {
    if (!wrapper.isDirectory) {
        if (error) *error=OCSERROR(@"Model must be a folder");
        return NO;
    }
    NSDictionary *nw=wrapper.fileWrappers;
    NSFileWrapper *fw=nw[@"index.eomodeld"];
    if (!fw.isRegularFile) {
        if (error) *error=OCSERROR(@"No index in model");
        return NO;
    }
    if (!(self.rawContents=[NSPropertyListSerialization propertyListWithData:fw.regularFileContents options:NSPropertyListMutableContainersAndLeaves format:NULL error:error])) return NO;
    // resolve deprecations
    if ([self.rawContents[@"userDictionary"] count]) {
        if (!self.userInfo) self.userInfo=[NSMutableDictionary dictionary];
        [self.userInfo ocs_addNewEntriesWithKeys:nil fromDictionary:self.rawContents[@"userDictionary"]];
        [self.rawContents removeObjectForKey:@"userDictionary"];
    }
    
    for (NSDictionary *ed in self.entityDicts) {
        NSString *name=[ed[@"name"] stringByAppendingPathExtension:@"plist"];
        if (!(fw=nw[name])) {
            if (error) *error=OCSERROR(@"No '%@' in model",name);
            return NO;
        }
        EOEntity *ent=[EOEntity entityFromWrapper:fw fetchSpecifications:nw[[ed[@"name"] stringByAppendingPathExtension:@"fspec"]] error:error];
        if (!ent) return NO;
        ent.model=self;
        [(id)self.entities addObject:ent];
    }
    return YES;
}
-(BOOL)synchronizeEntityDictsError:(NSError *__autoreleasing *)error {
    [(id)self.entityDicts removeAllObjects];
    NSMutableSet *check=[NSMutableSet set];
    for (EOEntity *entity in self.entities) {
        if (!entity.name.length) {
            if (error) *error=OCSERROR(@"There is an entity without a name");
            return NO;
        }
        if ([check containsObject:entity.name]) {
            if (error) *error=OCSERROR(@"An entity name '%@' is duplicated",entity.name);
            return NO;
        }
        if (!entity.className.length) {
            if (error) *error=OCSERROR(@"The entity '%@' does not have a class name",entity.name);
            return NO;
        }
        [(id)self.entityDicts addObject:@{@"name":entity.name, @"className":entity.className}];
    }
    return YES;
}
-(NSFileWrapper*)fileWrapperError:(NSError *__autoreleasing *)error {
    if (![self synchronizeEntityDictsError:error]) return nil;
    NSMutableDictionary *files=[NSMutableDictionary dictionary];
    if (!self.rawContents) {
        if (error) *error=OCSERROR(@"The model is invalid, there is no data");
        return nil;
    }
    NSData *indexd=[self.rawContents ocs_openStepPropertyListDataError:error];
    if (!indexd) return nil;
    files[@"index.eomodeld"]=[[NSFileWrapper alloc] initRegularFileWithContents:indexd];
    for (EOEntity *entity in self.entities) { // they do have unique names, we checked in synchronize
        NSArray *wraps=[entity fileWrappersError:error];
        if (!wraps) return NO;
        files[[entity.name stringByAppendingPathExtension:@"plist"]]=wraps[0];
        if (wraps.count>1)
            files[[entity.name stringByAppendingPathExtension:@"fspec"]]=wraps[1];
    }
    return [[NSFileWrapper alloc] initDirectoryWithFileWrappers:files];
}
@end
