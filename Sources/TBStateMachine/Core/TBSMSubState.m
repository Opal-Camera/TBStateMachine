//
//  TBSMSubState.m
//  TBStateMachine
//
//  Created by Julian Krumow on 19.09.14.
//  Copyright (c) 2014-2017 Julian Krumow. All rights reserved.
//

#import "TBSMSubState.h"
#import "TBSMStateMachine.h"
#import "NSException+TBStateMachine.h"


@implementation TBSMSubState

+ (instancetype)subStateWithName:(NSString *)name
{
    return [[[self class] alloc] initWithName:name];
}

- (void)setStateMachine:(TBSMStateMachine *)stateMachine
{
    if (![stateMachine isKindOfClass:[TBSMStateMachine class]]) {
        @throw ([NSException tbsm_notAStateMachineException:stateMachine]);
    }
    _stateMachine = stateMachine;
    [_stateMachine setParentVertex:self];
}

- (void)setStates:(NSArray<__kindof TBSMState *> *)states
{
    NSString *name = [self.name stringByAppendingString:@"SubMachine"];
    TBSMStateMachine *stateMachine = [TBSMStateMachine stateMachineWithName:name];
    stateMachine.states = states;
    [self setStateMachine:stateMachine];
}

- (void)removeTransitionVertexes
{
    [super removeTransitionVertexes];
    [self.stateMachine removeTransitionVertexes];
}

- (void)enter:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(id)data
{
    if (self.stateMachine == nil) {
        @throw [NSException tbsm_missingStateMachineException:self.name];
    }
    [super enter:sourceState targetState:targetState data:data];
    [_stateMachine enter:sourceState targetState:targetState data:data];
}

- (void)enter:(TBSMState *)sourceState targetStates:(NSArray *)targetStates region:(TBSMParallelState *)region data:(id)data
{
    if (self.stateMachine == nil) {
        @throw [NSException tbsm_missingStateMachineException:self.name];
    }
    [super enter:sourceState targetState:region data:data];
    [_stateMachine enter:sourceState targetStates:targetStates region:region data:data];
}

- (void)exit:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(id)data
{
    if (self.stateMachine == nil) {
        @throw [NSException tbsm_missingStateMachineException:self.name];
    }
    [_stateMachine tearDown:data];
    [super exit:sourceState targetState:targetState data:data];
}

- (BOOL)handleEvent:(TBSMEvent *)event
{
    return [_stateMachine handleEvent:event];
}

@end
