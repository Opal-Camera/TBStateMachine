//
//  TBStateMachineTransition.m
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBStateMachineTransition.h"
#import "TBStateMachineNode.h"

@implementation TBStateMachineTransition

+ (TBStateMachineTransition *)transitionWithSourceState:(id<TBStateMachineNode>)sourceState destinationState:(id<TBStateMachineNode>)destinationState
{
    TBStateMachineTransition *transition = [TBStateMachineTransition new];
    transition.sourceState = sourceState;
    transition.destinationState = destinationState;
    return transition;
}

- (NSString *)name
{
    return [NSString stringWithFormat:@"%@-->%@", _sourceState.name, _destinationState.name];
}

@end
