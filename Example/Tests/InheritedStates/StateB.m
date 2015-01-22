//
//  StateB.m
//  TBStateMachine
//
//  Created by Julian Krumow on 22.01.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "StateB.h"
#import "TBSMStateMachine.h"

@implementation StateB

- (void)enter:(TBSMState *)sourceState destinationState:(TBSMState *)destinationState data:(NSDictionary *)data
{
    [self.executionSequence addObject:[NSString stringWithFormat:@"%@_enter", self.name]];
    
    [super enter:sourceState destinationState:destinationState data:data];
    
    TBSMStateMachine *parentStateMachine = self.parentNode;
    [parentStateMachine scheduleEvent:[TBSMEvent eventWithName:@"DummyEventB" data:nil]];
}

- (void)exit:(TBSMState *)sourceState destinationState:(TBSMState *)destinationState data:(NSDictionary *)data
{
    [super exit:sourceState destinationState:destinationState data:data];
    
    [self.executionSequence addObject:[NSString stringWithFormat:@"%@_exit", self.name]];
}

@end
