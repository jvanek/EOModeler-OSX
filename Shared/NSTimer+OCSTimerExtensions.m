//
//  NSTimer+OCSTimerExtensions.m
//  EOModeller
//
//  Created by OC on 13.7.15.
//  Copyleft (c) 2016 OC. No rights reserved, what for, on earth?.
//

@implementation NSTimer (OCSTimerExtensions)
+(NSTimer*)ocs_scheduledTimerWithTimeInterval:(NSTimeInterval)ti block:(void(^)(void))block {
    return [NSTimer scheduledTimerWithTimeInterval:ti target:[NSBlockOperation blockOperationWithBlock:block] selector:@selector(main) userInfo:nil repeats:NO];
}
@end
