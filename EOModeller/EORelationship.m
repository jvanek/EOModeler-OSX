//
//  EORelationship.m
//  EOModeller
//
//  Created by OC on 24.03.16.
//  Copyright (c) 2016 OC. All rights reserved.
//

#import "EOModel.h"
#import "EOEntity.h"
#import "EOAttribute.h"
#import "EORelationship.h"

@implementation EORelationship
@dynamic definition,deleteRule,destination,isMandatory,isToMany,joinSemantic,joins,name,numberOfToManyFaultsToBatchFetch,ownsDestination,propagatesPrimaryKey;

GenerateISAccessors(entity,ClassProperty,classProperties)

-(BOOL)isFlattened {
    return self.definition.length>0;
}
+(NSSet*)keyPathsForValuesAffectingIsFlattened {
    return [NSSet setWithObject:@"definition"];
}

-(EOModel __weak *)model {
    return self.entity.model;
}

-(NSArray*)availableTargetEntitiyNames {
    return [[self.model.entities valueForKey:@"name"] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

-(NSArray*)availableJoinSemantics {
    return @[@"EOInnerJoin", @"EOFullOuterJoin", @"EOLeftOuterJoin", @"EORightOuterJoin"];
}

//-(NSString*)displayRelationshipSourceAttribute {
//    return [[self.joins valueForKey:@"sourceAttribute"] componentsJoinedByString:@"~"];
//}
//+(NSSet*)keyPathsForValuesAffectingDisplayRelationshipSourceAttribute {
//    return [NSSet setWithObjects:@"joins",@"joins.sourceAttribute", nil];
//}
//-(NSString*)displayRelationshipDestinationAttribute {
//    return [[self.joins valueForKey:@"destinationAttribute"] componentsJoinedByString:@"~"];
//}
//+(NSSet*)keyPathsForValuesAffectingdisplayRelationshipDestinationAttribute {
//    return [NSSet setWithObjects:@"joins",@"joins.destinationAttribute", nil];
//}

-(NSString*)displayRelationshipJointDescription {
    NSString *flat=self.definition;
    if (flat) return [@"\u21b0 " stringByAppendingString:flat];
    return [self displayJoinsShowingTargetEntity:YES];
}
+(NSSet*)keyPathsForValuesAffectingDisplayRelationshipJointDescription {
    return [NSSet setWithObjects:@"definition",@"joins",@"destination",nil];
}

static NSArray *orderedJoins(NSArray *joins,BOOL inverted) {
    NSString *sa=@"sourceAttribute",*da=@"destinationAttribute";
    if (inverted) {
        NSString *temp=sa; sa=da; da=temp;
    }
    return [joins sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:sa ascending:YES],[NSSortDescriptor sortDescriptorWithKey:da ascending:YES]]];
}

-(NSString*)displayJoinsShowingTargetEntity:(BOOL)showTarget {
    if (!self.joins.count) return nil;
    NSMutableArray *ma=[NSMutableArray array];
    unichar rel=self.isToMany?0xbb:0x203a;
    for (NSDictionary *jd in orderedJoins(self.joins,NO))
        if (showTarget)
            [ma addObject:[NSString stringWithFormat:@"%@ %C %@.%@",jd[@"sourceAttribute"],rel,self.destination,jd[@"destinationAttribute"]]];
        else
            [ma addObject:[NSString stringWithFormat:@"%@ %C %@",jd[@"sourceAttribute"],rel,jd[@"destinationAttribute"]]];
    return [ma componentsJoinedByString:@", "];
}
-(NSString*)displayJoins {
    return [self displayJoinsShowingTargetEntity:NO];
}
+(NSSet*)keyPathsForValuesAffectingDisplayJoins {
    return [NSSet setWithObjects:@"joins",@"destination",nil];
}
-(void)removeAllJoins {
    [self ocs_changingValuesForKeys:@[@"joins"] do:^{
        [(id)self.joins removeAllObjects];
    }];
}
-(NSArray*)availableJoinSourceAttributes {
    NSArray *attrs=self.entity.attributes;
    if (self.isToMany) {
        NSMutableArray *ma=[NSMutableArray array];
        for (EOAttribute *attr in attrs)
            if (attr.isPrimaryKey) [ma addObject:attr];
        attrs=ma;
    }
    return [[attrs valueForKey:@"name"] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}
+(NSSet*)keyPathsForValuesAffectingAvailableJoinSourceAttributes {
    return [NSSet setWithObject:@"isToMany"];
}
-(NSArray*)availableJoinDestinationAttributes {
    if (!self.destination.length) return nil;
    EOEntity *de=[self.model entityNamed:self.destination];
    
    NSArray *attrs=de.attributes;
    if (!self.isToMany) {
        NSMutableArray *ma=[NSMutableArray array];
        for (EOAttribute *attr in attrs)
            if (attr.isPrimaryKey) [ma addObject:attr];
        attrs=ma;
    }
    return [[attrs valueForKey:@"name"] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}
+(NSSet*)keyPathsForValuesAffectingAvailableJoinDestinationAttributes {
    return [NSSet setWithObjects:@"isToMany",@"destination",nil];
}

-(BOOL)addJoinFromSourceAttribute:(NSString*)sattrname toDestinationAttribute:(NSString*)dattrname {
    if (!sattrname.length || !dattrname.length) return NO;
    for (NSDictionary *jd in self.joins)
        if (OCSEquals(jd[@"sourceAttribute"], sattrname) && OCSEquals(jd[@"destinationAttribute"], dattrname))
            return NO;
    if (!self.joins) self.joins=[NSMutableArray array];
    [self ocs_changingValuesForKeys:@[@"joins"] do:^{
        [(id)self.joins addObject:@{@"sourceAttribute":sattrname, @"destinationAttribute":dattrname}];
    }];
    return YES;
}

-(NSArray*)availableDeleteRules {
    return @[@"EODeleteRuleNullify", @"EODeleteRuleCascade", @"EODeleteRuleDeny",@"EODeleteRuleNoAction"];
}

static NSString *stringFromJoins(NSArray *joins,BOOL inverted) {
    NSMutableString *ms=[NSMutableString string];
    NSString *sa=@"sourceAttribute",*da=@"destinationAttribute";
    if (inverted) {
        NSString *temp=sa; sa=da; da=temp;
    }
    for (NSDictionary *jd in orderedJoins(joins,inverted))
        [ms appendFormat:@"/%@>%@",jd[sa],jd[da]];
    return ms;
}
-(NSString*)inverseRelationshipName {
    if (!self.destination.length) return @"Target entity not set";
    EOEntity *de=[self.model entityNamed:self.destination];
    if (!de) return @"Destination entity not found";
    if (!self.joins.count) return @"No joins are set";
    NSString *ikey=stringFromJoins(self.joins, YES);
    for (EORelationship *rel in de.relationships) {
        if (OCSEquals(rel.destination,self.entity.name) && OCSEquals(stringFromJoins(rel.joins,NO), ikey))
            return [NSString stringWithFormat:@"%@.%@: %@",self.destination,rel.name,rel.displayJoins];
    }
    return @"None";
}
+(NSSet*)keyPathsForValuesAffectingInverseRelationshipName {
    return [NSSet setWithObjects:@"destination",@"joins",nil];
}

-(BOOL)validateDestination:(NSString**)name error:(NSError *__autoreleasing *)error {
    return [self validateName:name error:error];
}
-(BOOL)validateDefinition:(NSString**)name error:(NSError *__autoreleasing *)error {
    return [self validateClassName:name error:error];
}

+(instancetype)relationshipFromDictionary:(NSMutableDictionary*)reld error:(NSError *__autoreleasing *)error {
    return [[self alloc] initWithDictionary:reld error:error];
}
-(instancetype)initWithDictionary:(NSMutableDictionary*)reld error:(NSError *__autoreleasing *)error {
    if (!(self=[super init])) return nil;
    self.rawContents=reld?:[NSMutableDictionary dictionary];
    // resolve deprecations
    if ([self.rawContents[@"dataPath"] length] && !self.definition.length) {
        self.definition=self.rawContents[@"dataPath"];
        [self.rawContents removeObjectForKey:@"dataPath"];
    }
    if ([self.rawContents[@"userDictionary"] count]) {
        if (!self.userInfo) self.userInfo=[NSMutableDictionary dictionary];
        [self.userInfo ocs_addNewEntriesWithKeys:nil fromDictionary:self.rawContents[@"userDictionary"]];
        [self.rawContents removeObjectForKey:@"userDictionary"];
    }

    return self;
}

@end
