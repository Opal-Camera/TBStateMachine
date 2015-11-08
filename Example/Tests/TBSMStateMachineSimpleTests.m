//
//  TBSMStateMachineSimpleTests.m
//  TBStateMachineTests
//
//  Created by Julian Krumow on 14.09.2014.
//  Copyright (c) 2014-2015 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>
#import <TBStateMachine/TBSMStateMachine+DebugSupport.h>

SpecBegin(TBSMStateMachineSimple)

NSString * const EVENT_A = @"DummyEventA";
NSString * const EVENT_B = @"DummyEventA";
NSString * const EVENT_DATA_VALUE = @"DummyDataValue";

__block TBSMStateMachine *stateMachine;
__block TBSMState *a;
__block TBSMState *b;
__block TBSMState *c;

describe(@"TBSMStateMachine", ^{
    
    beforeEach(^{
        stateMachine = [TBSMStateMachine stateMachineWithName:@"StateMachine"];
        
        [stateMachine activateDebugSupport];
        
        a = [TBSMState stateWithName:@"a"];
        b = [TBSMState stateWithName:@"b"];
        c = [TBSMState stateWithName:@"c"];
    });
    
    afterEach(^{
        [stateMachine tearDown:nil];
        stateMachine = nil;
        a = nil;
        b = nil;
        c = nil;
    });
    
    describe(@"Exception handling on setup.", ^{
        
        it (@"throws a TBSMException when name is an empty string.", ^{
            expect(^{
                stateMachine = [TBSMStateMachine stateMachineWithName:@""];
            }).to.raise(TBSMException);
        });
        
        it(@"throws a TBSMException when state object is not of type TBSMState.", ^{
            id object = [NSObject new];
            expect(^{
                stateMachine.states = @[a, b, object];
            }).to.raise(TBSMException);
        });
        
        it(@"throws a TBSMException when initial state does not exist in set of defined states.", ^{
            stateMachine.states = @[a, b];
            expect(^{
                stateMachine.initialState = c;
            }).to.raise(TBSMException);
            
        });
        
        it(@"throws a TBSMException when initial state has not been set on setup.", ^{
            expect(^{
                [stateMachine setUp:nil];
            }).to.raise(TBSMException);
        });
        
        it(@"throws a TBSMException when the scheduledEventsQueue is not a serial queue.", ^{
            NSOperationQueue *queue = [NSOperationQueue new];
            queue.maxConcurrentOperationCount = 2;
            
            expect(^{
                stateMachine.scheduledEventsQueue = queue;
            }).to.raise(TBSMException);
        });
    });
    
    describe(@"Setup and configuration.", ^{
        
        it(@"accepts a serial NSOperationQueue as scheduledEventsQueue.", ^{
            NSOperationQueue *queue = [NSOperationQueue new];
            queue.maxConcurrentOperationCount = 1;
            stateMachine.scheduledEventsQueue = queue;
            
            expect(stateMachine.scheduledEventsQueue).to.equal(queue);
        });
    });
    
    describe(@"Location inside hierarchy.", ^{
        
        it(@"returns its path inside the state machine hierarchy containing all parent state machines in descending order.", ^{
            
            TBSMStateMachine *subStateMachineA = [TBSMStateMachine stateMachineWithName:@"SubA"];
            TBSMStateMachine *subStateMachineB = [TBSMStateMachine stateMachineWithName:@"SubB"];
            TBSMParallelState *parallelStates = [TBSMParallelState parallelStateWithName:@"ParallelWrapper"];
            subStateMachineB.states = @[b];
            TBSMSubState *subStateB = [TBSMSubState subStateWithName:@"subStateB"];
            subStateB.stateMachine = subStateMachineB;
            subStateMachineA.states = @[subStateB];
            
            parallelStates.stateMachines = @[subStateMachineA];
            stateMachine.states = @[parallelStates];
            
            NSArray *path = [subStateMachineB path];
            
            expect(path.count).to.equal(3);
            expect(path[0]).to.equal(stateMachine);
            expect(path[1]).to.equal(subStateMachineA);
            expect(path[2]).to.equal(subStateMachineB);
        });
        
    });
    
    describe(@"getters", ^{
        
        it(@"returns its name.", ^{
            TBSMStateMachine *stateMachineXYZ = [TBSMStateMachine stateMachineWithName:@"StateMachineXYZ"];
            expect(stateMachineXYZ.name).to.equal(@"StateMachineXYZ");
        });
        
        it(@"return the stored states.", ^{
            stateMachine.states = @[a, b];
            expect(stateMachine.states).haveCountOf(2);
            expect(stateMachine.states).contain(a);
            expect(stateMachine.states).contain(b);
        });
    });
    
    describe(@"setUp:", ^{
        
        it(@"enters initial state on set up when it has been set explicitly.", ^{
            
            stateMachine.states = @[a, b];
            stateMachine.initialState = a;
            
            [stateMachine setUp:nil];
            
            expect(stateMachine.currentState).to.equal(stateMachine.initialState);
            expect(stateMachine.currentState).to.equal(a);
        });
        
        it(@"enters initial state on set up when it has been set implicitly.", ^{
            
            stateMachine.states = @[a, b];
            
            [stateMachine setUp:nil];
            
            expect(stateMachine.currentState).to.equal(stateMachine.initialState);
            expect(stateMachine.currentState).to.equal(a);
        });
    });
    
    describe(@"tearDown:", ^{
        
        it(@"exits current state on tear down.", ^{
            
            stateMachine.states = @[a, b];
            [stateMachine setUp:nil];
            
            expect(stateMachine.currentState).to.equal(a);
            
            [stateMachine tearDown:nil];
            
            expect(stateMachine.currentState).to.beNil;
        });
    });
    
    describe(@"scheduleEventNamed:data:", ^{
    
        it(@"creates an event object through convenienceMethod.", ^{
            
            [a addHandlerForEvent:EVENT_A target:b];
            [b addHandlerForEvent:EVENT_B target:c];
            
            stateMachine.states = @[a, b, c];
            [stateMachine setUp:nil];
            
            waitUntil(^(DoneCallback done) {
                [stateMachine scheduleEventNamed:EVENT_A data:EVENT_DATA_VALUE];
                [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_B data:nil] withCompletion:^{
                    done();
                }];
            });
            
            expect(stateMachine.currentState).to.equal(c);
        });
    });
    
    describe(@"scheduleEvent:", ^{
        
        it(@"switches to the specified state.", ^{
            
            [a addHandlerForEvent:EVENT_A target:b kind:TBSMTransitionExternal];
            
            stateMachine.states = @[a, b];
            [stateMachine setUp:nil];
            
            expect(stateMachine.currentState).to.equal(a);
            
            waitUntil(^(DoneCallback done) {
                [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_A data:nil] withCompletion:^{
                    done();
                }];
            });
            
            expect(stateMachine.currentState).to.equal(b);
        });
        
        it(@"evaluates a guard function, exits the current state, executes transition action and enters the next state.", ^{
            
            NSMutableString *executionSequence = [NSMutableString stringWithString:@""];
            
            a.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, id data) {
                [executionSequence appendString:@"enterA"];
            };
            
            a.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, id data) {
                [executionSequence appendString:@"-exitA"];
            };
            
            b.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, id data) {
                [executionSequence appendString:@"-enterB"];
            };
            
            [a addHandlerForEvent:EVENT_A
                           target:b
                             kind:TBSMTransitionExternal
                           action:^(TBSMState *sourceState, TBSMState *targetState, id data) {
                               [executionSequence appendString:@"-actionA"];
                           }
                            guard:^BOOL(TBSMState *sourceState, TBSMState *targetState, id data) {
                                [executionSequence appendString:@"-guardA"];
                                return YES;
                            }];
            
            stateMachine.states = @[a, b];
            [stateMachine setUp:nil];
            
            waitUntil(^(DoneCallback done) {
                
                // will enter state B
                [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_A data:nil] withCompletion:^{
                    done();
                }];
                
            });
            
            expect(executionSequence).to.equal(@"enterA-guardA-exitA-actionA-enterB");
        });
        
        it(@"evaluates a guard function, and skips switching to the next state.", ^{
            
            __block BOOL didExecuteAction = NO;
            
            [a addHandlerForEvent:EVENT_A
                           target:b
                             kind:TBSMTransitionExternal
                           action:^(TBSMState *sourceState, TBSMState *targetState, id data) {
                               didExecuteAction = YES;
                           }
                            guard:^BOOL(TBSMState *sourceState, TBSMState *targetState, id data) {
                                return NO;
                            }];
            
            stateMachine.states = @[a, b];
            [stateMachine setUp:nil];
            
            waitUntil(^(DoneCallback done) {
                
                // will not enter state B
                [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_A data:nil] withCompletion:^{
                    done();
                }];
            });
            
            expect(didExecuteAction).to.equal(NO);
            expect(stateMachine.currentState).to.equal(a);
        });
        
        it(@"evaluates multiple guard functions, and switches to the next state.", ^{
            
            __block BOOL didExecuteActionA = NO;
            __block BOOL didExecuteActionB = NO;
            
            [a addHandlerForEvent:EVENT_A
                           target:b
                             kind:TBSMTransitionExternal
                           action:^(TBSMState *sourceState, TBSMState *targetState, id data) {
                               didExecuteActionA = YES;
                           }
                            guard:^BOOL(TBSMState *sourceState, TBSMState *targetState, id data) {
                                return NO;
                            }];
            
            [a addHandlerForEvent:EVENT_A
                           target:b
                             kind:TBSMTransitionExternal
                           action:^(TBSMState *sourceState, TBSMState *targetState, id data) {
                               didExecuteActionB = YES;
                           }
                            guard:^BOOL(TBSMState *sourceState, TBSMState *targetState, id data) {
                                return YES;
                            }];
            
            stateMachine.states = @[a, b];
            [stateMachine setUp:nil];
            
            waitUntil(^(DoneCallback done) {
                
                // will enter state B through second transition
                [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_A data:nil] withCompletion:^{
                    done();
                }];
            });
            
            expect(didExecuteActionA).to.equal(NO);
            expect(didExecuteActionB).to.equal(YES);
            expect(stateMachine.currentState).to.equal(b);
        });
        
        it(@"passes source and target state and event data into the enter, exit, action and guard blocks of the involved states.", ^{
            
            __block TBSMState *sourceStateEnter;
            __block TBSMState *targetStateEnter;
            __block id stateDataEnter;
            __block TBSMState *sourceStateExit;
            __block TBSMState *targetStateExit;
            __block id stateDataExit;
            
            __block TBSMState *sourceStateGuard;
            __block TBSMState *targetStateGuard;
            __block TBSMState *sourceStateAction;
            __block TBSMState *targetStateAction;
            __block id actionData;
            __block id guardData;
            
            a.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, id data) {
                sourceStateEnter = sourceState;
                targetStateEnter = targetState;
                stateDataEnter = data;
            };
            
            a.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, id data) {
                sourceStateExit = sourceState;
                targetStateExit = targetState;
                stateDataExit = data;
            };
            
            a.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, id data) {
                sourceStateEnter = sourceState;
                targetStateEnter = targetState;
                stateDataEnter = data;
            };
            
            a.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, id data) {
                sourceStateExit = sourceState;
                targetStateExit = targetState;
                stateDataExit = data;
            };
            
            [a addHandlerForEvent:EVENT_A
                           target:b
                             kind:TBSMTransitionExternal
                           action:^(TBSMState *sourceState, TBSMState *targetState, id data) {
                               sourceStateAction = sourceState;
                               targetStateAction = targetState;
                               actionData = data;
                           }
                            guard:^BOOL(TBSMState *sourceState, TBSMState *targetState, id data) {
                                sourceStateGuard = sourceState;
                                targetStateGuard = targetState;
                                guardData = data;
                                return YES;
                            }];
            
            b.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, id data) {
                sourceStateEnter = sourceState;
                targetStateEnter = targetState;
                stateDataEnter = data;
            };
            
            stateMachine.states = @[a, b];
            [stateMachine setUp:nil];
            
            expect(sourceStateEnter).to.beNil;
            expect(targetStateEnter).to.equal(a);
            expect(stateDataEnter).to.beNil;
            
            waitUntil(^(DoneCallback done) {
                
                // enters state B
                [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_A data:EVENT_DATA_VALUE] withCompletion:^{
                    done();
                }];
                
            });
            expect(sourceStateExit).to.equal(a);
            expect(targetStateExit).to.equal(b);
            expect(stateDataExit).to.equal(EVENT_DATA_VALUE);
            
            expect(guardData).to.equal(EVENT_DATA_VALUE);
            expect(actionData).to.equal(EVENT_DATA_VALUE);
            
            expect(sourceStateEnter).to.equal(a);
            expect(targetStateEnter).to.equal(b);
            expect(stateDataEnter).to.equal(EVENT_DATA_VALUE);
        });
        
        it(@"can re-enter a state.", ^{
            
            __block BOOL didEnterStateA = NO;
            __block BOOL didExitStateA = NO;
            
            a.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, id data) {
                didEnterStateA = YES;
            };
            
            a.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, id data) {
                didExitStateA = YES;
            };
            
            [a addHandlerForEvent:EVENT_A target:a kind:TBSMTransitionExternal];
            
            stateMachine.states = @[a, b];
            
            [stateMachine setUp:nil];
            
            didEnterStateA = NO;
            
            waitUntil(^(DoneCallback done) {
                
                [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_A data:nil] withCompletion:^{
                    done();
                }];
            });
            
            expect(stateMachine.currentState).to.equal(a);
            expect(didExitStateA).to.equal(YES);
            expect(didEnterStateA).to.equal(YES);
        });
    });
    
    describe(@"NSNotificationCenter support.", ^{
        
        it(@"posts a notification when entering the specified state.", ^{
            
            NSNotification *notification = [NSNotification notificationWithName:TBSMStateDidEnterNotification object:a userInfo:@{TBSMTargetStateUserInfo:a, TBSMDataUserInfo:EVENT_DATA_VALUE}];
            
            stateMachine.states = @[a];
            
            expect(^{
                [stateMachine setUp:EVENT_DATA_VALUE];
            }).to.notify(notification);
        });
        
        it(@"posts a notification when exiting the specified state.", ^{
            
            NSNotification *notification = [NSNotification notificationWithName:TBSMStateDidExitNotification object:a userInfo:@{TBSMSourceStateUserInfo:a, TBSMDataUserInfo:EVENT_DATA_VALUE}];
            
            stateMachine.states = @[a];
            [stateMachine setUp:nil];
            
            expect(^{
                [stateMachine tearDown:EVENT_DATA_VALUE];
            }).to.notify(notification);
        });
    });
});

SpecEnd
