//
//  TBSMStateMachine+DebugSupport.m
//  TBStateMachine
//
//  Created by Julian Krumow on 19.02.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBSMStateMachine+DebugSupport.h"
#import "TBSMDebugStateMachine.h"
#import "TBSMDebugSwizzler.h"
#import "TBSMDebugLogger.h"

@implementation TBSMStateMachine (DebugSupport)
@dynamic millisecondsPerMachTime;
@dynamic eventDebugQueue;

- (NSNumber *)debugSupportEnabled
{
    return objc_getAssociatedObject(self, @selector(debugSupportEnabled));
}

- (void)setDebugSupportEnabled:(NSNumber *)debugSupportEnabled
{
    objc_setAssociatedObject(self, @selector(debugSupportEnabled), debugSupportEnabled, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)millisecondsPerMachTime
{
    return objc_getAssociatedObject(self, @selector(millisecondsPerMachTime));
}

- (void)setMillisecondsPerMachTime:(NSNumber *)millisecondsPerMachTime
{
    objc_setAssociatedObject(self, @selector(millisecondsPerMachTime), millisecondsPerMachTime, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)eventDebugQueue
{
    NSMutableArray *queue = objc_getAssociatedObject(self, @selector(eventDebugQueue));
    if (queue == nil) {
        queue = [NSMutableArray new];
        self.eventDebugQueue = queue;
    }
    return queue;
}

- (void)setEventDebugQueue:(NSMutableArray *)eventDebugQueue
{
    objc_setAssociatedObject(self, @selector(eventDebugQueue), eventDebugQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)activateDebugSupport
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [TBSMDebugSwizzler swizzleMethod:@selector(scheduleEvent:) withMethod:@selector(tbsm_scheduleEvent:) onClass:[TBSMDebugStateMachine class]];
        [TBSMDebugSwizzler swizzleMethod:@selector(handleEvent:) withMethod:@selector(tbsm_handleEvent:) onClass:[TBSMDebugStateMachine class]];
        [TBSMDebugSwizzler swizzleMethod:@selector(setUp:) withMethod:@selector(tbsm_setUp:) onClass:[TBSMStateMachine class]];
        [TBSMDebugSwizzler swizzleMethod:@selector(tearDown:) withMethod:@selector(tbsm_tearDown:) onClass:[TBSMStateMachine class]];
    });
}

- (void)tbsm_setUp:(id)data
{
    [[TBSMDebugLogger sharedInstance] log:@"[%@] setup data: %@", self.name, data];
    [self tbsm_setUp:data];
}

- (void)tbsm_tearDown:(id)data
{
    [[TBSMDebugLogger sharedInstance] log:@"[%@] teardown data: %@", self.name, data];
    [self tbsm_tearDown:data];
}

- (void)tbsm_scheduleEvent:(TBSMEvent *)event
{
    [self.eventDebugQueue addObject:event];
    [self tbsm_scheduleEvent:event];
}

- (void)scheduleEvent:(TBSMEvent *)event withCompletion:(TBSMDebugCompletionBlock)completion
{
    event.completionBlock = completion;
    [self scheduleEvent:event];
}

- (BOOL)tbsm_handleEvent:(TBSMEvent *)event
{
    [[TBSMDebugLogger sharedInstance] log:@"[%@]: attempt to handle event '%@' data: %@", self.name, event.name, event.data];
    
    uint64_t startTime = mach_absolute_time();
    BOOL hasHandledEvent = [self tbsm_handleEvent:event];
    
    uint64_t endTime = mach_absolute_time() - startTime;
    NSTimeInterval timeInterval = endTime * self.millisecondsPerMachTime.doubleValue;
    
    [self.eventDebugQueue removeObject:event];
    
    [[TBSMDebugLogger sharedInstance] log:@"[%@]: run-to-completion step took %f milliseconds", self.name, timeInterval];
    [[TBSMDebugLogger sharedInstance] log:@"[%@]: remaining events in queue: %i", self.name, self.eventDebugQueue.count];
    [[TBSMDebugLogger sharedInstance] log:@"[%@]: %@\n\n", self.name, [self.eventDebugQueue valueForKeyPath:@"name"]];
    
    TBSMDebugCompletionBlock completionBlock = event.completionBlock;
    if (completionBlock) {
        completionBlock();
    }
    return hasHandledEvent;
}

@end
