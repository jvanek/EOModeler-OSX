//
//  OCSModel+SQLGeneration.m
//  EOModeller
//
//  Created by OC on 5/24/13.
//  Copyleft (c) 2013 OC. No rights reserved, what for, on earth?.
//

#import "OCSModel.h"
#import "OCSAttributesAC.h"
#import "OCSEntitiesAC.h"

#import "EOModel.h"
#import "EOEntity.h"
#import "EOAttribute.h"

@interface OCSModel (SQLGeneration) @end
@implementation OCSModel (SQLGeneration)

// this is not really useable implementation, but well, as a first step, slightly better'n'nothing at all
// - for model or selected entities, we generate table creation
// - for selected attributes, we generate add-column
// - we ignore relationships for the moment, constraints are nice but non-essential :), in future...

-(IBAction)generateSQL:sender {
    NSMutableString *sql=self.sqlTextView.textStorage.mutableString;
    [sql setString:@"SET TRANSACTION ISOLATION LEVEL SERIALIZABLE, LOCKING PESSIMISTIC;\n"];
    
    NSArray *items=self.attributesAC.selectedObjects;
    if (items.count) {
        for (EOAttribute *attr in items) {
            [sql appendFormat:@"\nALTER TABLE \"%@\" ADD COLUMN \"%@\" %@",attr.entity.externalName,attr.columnName,attr.externalType];
            // code ugly and dupped. Don't care, got to be trashed soon anyway
            if (attr.width) [sql appendFormat:@"(%@)",attr.width];
            else if (attr.precision||attr.scale) [sql appendFormat:@"(%@,%@)",attr.precision?:@0,attr.scale?:@0];
            if (!attr.allowsNull) [sql appendString:@" NOT NULL"];
            [sql appendString:@";"];
        }
    } else {
        if (!(items=self.entityAC.selectedObjects).count) items=self.model.entities;
        for (EOEntity *entity in items) {
            [sql appendFormat:@"\nCREATE TABLE \"%@\" (\n",entity.externalName];
            NSMutableArray *uidcols=[NSMutableArray array];
            for (EOAttribute *attr in entity.attributes) {
                [sql appendFormat:@"  \"%@\" %@",attr.columnName,attr.externalType];
                if (attr.width) [sql appendFormat:@"(%@)",attr.width];
                else if (attr.precision||attr.scale) [sql appendFormat:@"(%@,%@)",attr.precision?:@0,attr.scale?:@0];
                if (attr.isPrimaryKey) [uidcols addObject:attr.columnName];
                if (!attr.allowsNull) [sql appendString:@" NOT NULL"];
                [sql appendString:@",\n"];
            }
            [sql deleteCharactersInRange:NSMakeRange(sql.length-2, 2)]; // last ',\n'
            [sql appendString:@"\n);\n"];
            if (uidcols.count) {
                [sql appendFormat:@"SET UNIQUE = 1000000 FOR \"%@\";\n",entity.externalName];
                [sql appendFormat:@"ALTER TABLE \"%@\" ADD PRIMARY KEY (\"%@\") NOT DEFERRABLE INITIALLY IMMEDIATE;\n",entity.externalName,[uidcols componentsJoinedByString:@"\", \""]];
            }
        }
    }
    
    [self.sqlWindow makeKeyAndOrderFront:self];
}

@end
