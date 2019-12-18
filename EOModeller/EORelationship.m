//
//  EORelationship.m
//  EOModeller
//
//  Created by OC on 24.03.16.
//  Copyleft (c) 2016 OC. No rights reserved, what for, on earth?.
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
    if (self.definition.length) {
#warning Should improve so that it works properly for any number of intermediate steps; this is hard-coded for standard M:N
        NSArray<NSString*> *path=[self.definition componentsSeparatedByString:@"."];
        EORelationship *mn,*bkmn,*fwmn,*bk,*nm;
        for (EORelationship *r in self.entity.relationships) if (OCSEquals(r.name, path[0])) { mn=r; break; }
        if (!mn) return @"Flattened-by relationship unknown";
        if (!mn.destination.length) return @"Flattened-by entity not set";
        EOEntity *de=[self.model entityNamed:mn.destination];
        if (!de) return [NSString stringWithFormat:@"Flattened-by entity '%@' not found",mn.destination];
        if (!mn.joins.count) return [NSString stringWithFormat:@"No flattened-by joins to '%@' are set",mn.destination];
        NSString *ikey=stringFromJoins(mn.joins, YES);
        for (EORelationship *r in de.relationships)
            if (OCSEquals(r.destination,self.entity.name) && OCSEquals(stringFromJoins(r.joins,NO), ikey)) bkmn=r;
            else if (OCSEquals(r.name, path.lastObject)) fwmn=r;
        if (!bkmn) return [NSString stringWithFormat:@"None from entity '%@'",mn.destination];
        if (path.count<2) // normally should not happen
            return [NSString stringWithFormat:@"\u21b0 %@.%@: %@",mn.destination,bkmn.name,bkmn.displayJoins];
        if (path.count>2) // normally should not happen
            return [NSString stringWithFormat:@"\u21b0 %@.%@: %@ + path(unparsed!)",mn.destination,bkmn.name,bkmn.displayJoins];
        // for 2-item path we show the rest
        if (!fwmn) return [NSString stringWithFormat:@"\u21b0 %@.%@: %@ + relshp '%@' not found!",mn.destination,bkmn.name,bkmn.displayJoins,path.lastObject];
        EOEntity *fe=[self.model entityNamed:fwmn.destination];
        if (!fe) return [NSString stringWithFormat:@"\u21b0 %@.%@: %@ + entity '%@' not found!",mn.destination,bkmn.name,bkmn.displayJoins,fwmn.destination];
        if (!fwmn.joins) return [NSString stringWithFormat:@"«» %@ no-joins in $fwmn.name! ⤳ %@.%@: %@",fe.name,mn.destination,bkmn.name,bkmn.displayJoins];
        ikey=stringFromJoins(fwmn.joins, YES);
        for (EORelationship *r in fe.relationships)
            if (OCSEquals(r.destination,mn.destination) && OCSEquals(stringFromJoins(r.joins,NO), ikey)) bk=r;
            else if (r.definition.length) {
                NSArray *rp=[r.definition componentsSeparatedByString:@"."];
                if (rp.count==2 && OCSEquals(rp[0], bk.name) && OCSEquals(rp[1], bkmn.name)) nm=r;
            }
        if (!bk) return [NSString stringWithFormat:@"«» %@ none for $fwmn.name! ⤳ %@.%@: %@",fe.name,mn.destination,bkmn.name,bkmn.displayJoins];
        if (bk.isClassProperty) return [NSString stringWithFormat:@"«» %@.%@ %@ ⤳ %@.%@: %@ ", fe.name, bk.name, bk.displayJoins, bk.destination, bkmn.name, bkmn.displayJoins];
        if (!nm) return [NSString stringWithFormat:@"«» no flattened-by found at destination: %@.%@ %@ ⤳ %@.%@: %@ ", fe.name, bk.name, bk.displayJoins, bk.destination, bkmn.name, bkmn.displayJoins];
        return [NSString stringWithFormat:@"«» %@.%@ ⤳ .%@ %@ ⤳ %@.%@: %@ ", fe.name, nm.name, bk.name, bk.displayJoins, bk.destination, bkmn.name, bkmn.displayJoins];
    }
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
