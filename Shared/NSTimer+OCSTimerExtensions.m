//
//  NSTimer+OCSTimerExtensions.m
//  Sticky Password
//
//  Created by OC on 13.7.15.
//  Copyright (c) 2015 Lamantine a.s. All rights reserved.
//

@implementation NSTimer (OCSTimerExtensions)
+(NSTimer*)ocs_scheduledTimerWithTimeInterval:(NSTimeInterval)ti block:(void(^)(void))block {
    return [NSTimer scheduledTimerWithTimeInterval:ti target:[NSBlockOperation blockOperationWithBlock:block] selector:@selector(main) userInfo:nil repeats:NO];
}
@end
