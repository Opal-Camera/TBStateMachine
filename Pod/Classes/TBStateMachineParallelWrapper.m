//
//  TBStateMachineParallelWrapper.m
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBStateMachineParallelWrapper.h"
#import "TBStateMachine.h"
#import "NSException+TBStateMachine.h"

@interface TBStateMachineParallelWrapper ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSMutableArray *priv_parallelStates;
@property (nonatomic, strong) NSOperationQueue *parallelQueue;

@end

@implementation TBStateMachineParallelWrapper

+ (TBStateMachineParallelWrapper *)parallelWrapperWithName:(NSString *)name;
{
	return [[TBStateMachineParallelWrapper alloc] initWithName:name];
}

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _name = name.copy;
        _priv_parallelStates = [NSMutableArray new];
    }
    return self;
}

- (void)setStates:(NSArray *)states
{
    [_priv_parallelStates removeAllObjects];
    
    for (id object in states) {
        if ([object conformsToProtocol:@protocol(TBStateMachineNode)])  {
            id<TBStateMachineNode> stateMachineNode = object;
            [_priv_parallelStates addObject:stateMachineNode];
        } else {
            @throw ([NSException tb_doesNotConformToNodeProtocolException:object]);
        }
    }
}

- (void)enter:(id<TBStateMachineNode>)previousState data:(NSDictionary *)data
{
	for (id<TBStateMachineNode> stateMachineNode in _priv_parallelStates) {
        [stateMachineNode enter:previousState data:data];
    }
}

- (void)exit:(id<TBStateMachineNode>)nextState data:(NSDictionary *)data
{
	for (id<TBStateMachineNode> stateMachineNode in _priv_parallelStates) {
        [stateMachineNode exit:nextState data:data];
    }
}

- (TBStateMachineTransition *)handleEvent:(TBStateMachineEvent *)event
{
    return [self handleEvent:event data:nil];
}

- (TBStateMachineTransition *)handleEvent:(TBStateMachineEvent *)event data:(NSDictionary *)data
{
    TBStateMachineTransition *nextParentTransition = nil;
    for (id<TBStateMachineNode> stateMachineNode in _priv_parallelStates) {
        
        // break at first returned follow-up state.
        TBStateMachineTransition *result = [stateMachineNode handleEvent:event data:data];
        if (result.destinationState) {
            nextParentTransition = result;
            break;
        }
    }
    // return follow-up state.
    return nextParentTransition;
}


@end
