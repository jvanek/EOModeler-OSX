//
//  OCSModel+SQLGeneration.m
//  EOModeller
//
//  Created by OC on 5/24/13.
//  Copyright (c) 2013 OC. All rights reserved.
//

#import "OCSModel.h"

@interface OCSModel (SQLGeneration) @end
@implementation OCSModel (SQLGeneration)

-(IBAction)generateSQL:sender {
//    NSMutableString *sql=self.sqlTextView.textStorage.mutableString;
//    [sql setString:@"SET TRANSACTION ISOLATION LEVEL SERIALIZABLE, LOCKING PESSIMISTIC;\n"];
//    for (NSDictionary *entity in entities) {
//        NSString *table=entity[@"externalName"];
//        [sql appendFormat:@"\nCREATE TABLE \"%@\" (\n",table];
//        NSMutableArray *uidcols=[NSMutableArray array];
//        for (NSDictionary *ad in entity[@"attributes"]) {
//            NSString *column=ad[@"columnName"];
//            [sql appendFormat:@"\t\"%@\" %@",column,ad[@"externalType"]];
//            if (ad[@"width"]) [sql appendFormat:@"(%@)",ad[@"width"]];
//            else if (ad[@"precision"]) [sql appendFormat:@"(%@,%@)",ad[@"precision"],ad[@"scale"]?:@"0"];
//            if ([ad[@"ocs_primaryKey"] boolValue]) [uidcols addObject:column];
//            if ([ad[@"ocs_primaryKey"] boolValue] || ![ad[@"allowsNull"] boolValue]) [sql appendString:@" NOT NULL"];
//            [sql appendString:@",\n"];
//        }
//        [sql deleteCharactersInRange:NSMakeRange(sql.length-2, 2)]; // last ',\n'
//        [sql appendString:@"\n);\n"];
//        if (uidcols.count) {
//            [sql appendFormat:@"SET UNIQUE = 1000000 FOR \"%@\";\n",table];
//            [sql appendFormat:@"ALTER TABLE \"%@\" ADD PRIMARY KEY (\"%@\") NOT DEFERRABLE INITIALLY IMMEDIATE;\n",table,[uidcols componentsJoinedByString:@"\", \""]];
//        }
//    }
//    [self.sqlWindow makeKeyAndOrderFront:self];
}

@end
