//
//  EOEntity+FileAccess.m
//  EOModeller
//
//  Created by OC on 26.03.16.
//  Copyleft (c) 2016 OC. No rights reserved, what for, on earth?.
//

#import "EOEntity.h"
#import "EOAttribute.h"
#import "EORelationship.h"

@interface EOEntity ()
@property NSMutableArray *attributes,*relationships;
@property NSMutableDictionary *fetchSpecifications;
@end

@implementation EOEntity (FileAccess)
+(instancetype)entityFromWrapper:(NSFileWrapper*)wrapper fetchSpecifications:(NSFileWrapper*)fswrapper error:(NSError *__autoreleasing *)error {
    return [[self alloc] initWithWrapper:wrapper fetchSpecifications:fswrapper error:error];
}
-(instancetype)initWithWrapper:(NSFileWrapper*)wrapper fetchSpecifications:(NSFileWrapper*)fswrapper error:(NSError *__autoreleasing *)error {
    if (!(self=[super init])) return nil;
    self.attributes=[NSMutableArray array];
    self.relationships=[NSMutableArray array];
    if (wrapper && ![self readFromWrapper:wrapper fetchSpecifications:fswrapper error:error]) return nil;
    if (!self.rawContents) self.rawContents=[NSMutableDictionary dictionary];
    return self;
}

-(BOOL)readFromWrapper:(NSFileWrapper*)wrapper fetchSpecifications:(NSFileWrapper*)fswrapper error:(NSError *__autoreleasing *)error {
    if (!wrapper.isRegularFile) {
        if (error) *error=OCSERROR(@"Wrong entity plist '%@' in model",wrapper.filename);
        return NO;
    }
    if (!(self.rawContents=[NSPropertyListSerialization propertyListWithData:wrapper.regularFileContents options:NSPropertyListMutableContainersAndLeaves format:NULL error:error])) return NO;
    // resolve deprecations
    if ([self.rawContents[@"mappingQualifier"] length] && !self.restrictingQualifier.length) {
        self.restrictingQualifier=self.rawContents[@"mappingQualifier"];
        [self.rawContents removeObjectForKey:@"mappingQualifier"];
    }
    if ([self.rawContents[@"isFetchable"] length] && ![self.rawContents[@"isAbstractEntity"] length]) {
        self.isAbstractEntity=![self.rawContents[@"isFetchable"] boolValue];
        [self.rawContents removeObjectForKey:@"isFetchable"];
    }
    if ([self.rawContents[@"userDictionary"] count]) {
        if (!self.userInfo) self.userInfo=[NSMutableDictionary dictionary];
        [self.userInfo ocs_addNewEntriesWithKeys:nil fromDictionary:self.rawContents[@"userDictionary"]];
        [self.rawContents removeObjectForKey:@"userDictionary"];
    }

    for (NSMutableDictionary *amd in self.attributeDicts) {
        EOAttribute *attr=[EOAttribute attributeFromDictionary:amd error:error];
        if (!attr) return NO;
        [(id)self.attributes addObject:attr];
        attr.entity=self;
    }
    for (NSMutableDictionary *rmd in self.relationshipDicts) {
        EORelationship *rel=[EORelationship relationshipFromDictionary:rmd error:error];
        if (!rel) return NO;
        [(id)self.relationships addObject:rel];
        rel.entity=self;
    }
    
    if (fswrapper) {
        if (!fswrapper.isRegularFile) {
            if (error) *error=OCSERROR(@"Wrong fetch specifications plist '%@' in model",fswrapper.filename);
            return NO;
        }
        if (!(self.fetchSpecifications=[NSPropertyListSerialization propertyListWithData:fswrapper.regularFileContents options:NSPropertyListMutableContainersAndLeaves format:NULL error:error])) return NO;
    }
    
    return YES;
}
-(NSArray*)fileWrappersError:(NSError *__autoreleasing *)error {
    // note that attribute/relationshipDicts are kept up to date all the time
    if (!self.rawContents) {
        if (error) *error=OCSERROR(@"The entity '%@' is invalid, there is no data",self.name);
        return nil;
    }
    NSData *dd=[self.rawContents ocs_openStepPropertyListDataError:error];
    if (!dd) return nil;
    NSMutableArray *result=[NSMutableArray array];
    [result addObject:[[NSFileWrapper alloc] initRegularFileWithContents:dd]];
    if (self.fetchSpecifications.count) {
        if (!(dd=[self.fetchSpecifications ocs_openStepPropertyListDataError:error])) return nil;
        [result addObject:[[NSFileWrapper alloc] initRegularFileWithContents:dd]];
    }
    return result;
}

@end
