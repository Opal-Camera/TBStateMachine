//
//  TBSMStateMachineBuilderTests.m
//  TBStateMachineTests
//
//  Created by Julian Krumow on 12.04.18.
//  Copyright © 2018 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>
#import <TBStateMachine/TBSMStateMachineBuilder.h>
#import <TBStateMachine/TBSMDebugger.h>

SpecBegin(TBSMStateMachineBuilderTests)

__block NSString *simple;
__block NSString *nested;
__block NSString *pseudo;
__block TBSMStateMachine *stateMachine;

describe(@"TBSMStateMachineBuilder", ^{
    
    beforeEach(^{
        simple = [[NSBundle bundleForClass:[self class]] pathForResource:@"simple" ofType:@"json"];
        nested = [[NSBundle bundleForClass:[self class]] pathForResource:@"nested" ofType:@"json"];
        pseudo = [[NSBundle bundleForClass:[self class]] pathForResource:@"pseudo" ofType:@"json"];
    });
    
    afterEach(^{
        [stateMachine tearDown:nil];
    });
    
    it(@"builds a simple setup", ^{
        
        stateMachine = [TBSMStateMachineBuilder buildFromFile:simple];
        expect(stateMachine.name).to.equal(@"main");
        expect(stateMachine.states.count).to.equal(3);
        
        TBSMState *a = stateMachine.states[0];
        TBSMState *b = stateMachine.states[1];
        TBSMState *c = stateMachine.states[2];
        expect(a.name).to.equal(@"a");
        expect(b.name).to.equal(@"b");
        expect(c.name).to.equal(@"c");
        
        [[TBSMDebugger sharedInstance] debugStateMachine:stateMachine];
        [stateMachine setUp:nil];
        
        waitUntil(^(DoneCallback done) {
            [stateMachine scheduleEventNamed:@"a_b" data:nil];
            [stateMachine scheduleEventNamed:@"b_c" data:nil];
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:@"c_a" data:nil] withCompletion:^{
                done();
            }];
        });
        
        expect(stateMachine.currentState).to.equal(a);
    });
    
    it(@"builds a nested setup", ^{
        
        stateMachine = [TBSMStateMachineBuilder buildFromFile:nested];
        expect(stateMachine.name).to.equal(@"main");
        expect(stateMachine.states.count).to.equal(3);
        
        TBSMSubState *a = stateMachine.states[0];
        TBSMParallelState *b = stateMachine.states[1];
        TBSMState *c = stateMachine.states[2];
        expect(a.name).to.equal(@"a");
        expect(b.name).to.equal(@"b");
        expect(c.name).to.equal(@"c");
        
        expect(a.stateMachine.states.count).to.equal(2);
        expect(b.stateMachines[0].states.count).to.equal(1);
        expect(b.stateMachines[1].states.count).to.equal(2);
        
        expect([stateMachine stateWithPath:@"a/a1"]).notTo.beNil();
        expect([stateMachine stateWithPath:@"a/a2"]).notTo.beNil();
        
        expect([stateMachine stateWithPath:@"b@0/b11"]).notTo.beNil();
        expect([stateMachine stateWithPath:@"b@1/b21"]).notTo.beNil();
        expect([stateMachine stateWithPath:@"b@1/b22"]).notTo.beNil();
        
        expect(c.eventHandlers.count).to.equal(1);
        TBSMEventHandler *handler = c.eventHandlers[@"c_internal"].firstObject;
        expect(handler.target).to.equal(c);
        expect(handler.kind).to.equal(TBSMTransitionInternal);
        
        [[TBSMDebugger sharedInstance] debugStateMachine:stateMachine];
        [stateMachine setUp:nil];
        
        waitUntil(^(DoneCallback done) {
            [stateMachine scheduleEventNamed:@"a1_a2" data:nil];
            [stateMachine scheduleEventNamed:@"a_local" data:nil];
            [stateMachine scheduleEventNamed:@"a1_b" data:nil];
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:@"b11_c" data:nil] withCompletion:^{
                done();
            }];
        });
        
        expect(stateMachine.currentState).to.equal(c);
    });
    
    it(@"builds a pseudostate setup", ^{
        
        stateMachine = [TBSMStateMachineBuilder buildFromFile:pseudo];
        expect(stateMachine.name).to.equal(@"main");
        expect(stateMachine.states.count).to.equal(3);
        
        TBSMSubState *a = stateMachine.states[0];
        TBSMParallelState *b = stateMachine.states[1];
        TBSMState *c = stateMachine.states[2];
        expect(a.name).to.equal(@"a");
        expect(b.name).to.equal(@"b");
        expect(c.name).to.equal(@"c");
        
        [[TBSMDebugger sharedInstance] debugStateMachine:stateMachine];
        [stateMachine setUp:nil];
        
        waitUntil(^(DoneCallback done) {
            [stateMachine scheduleEventNamed:@"fork_b" data:nil];
            [stateMachine scheduleEventNamed:@"b11_join" data:nil];
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:@"b21_join" data:nil] withCompletion:^{
                done();
            }];
        });
        
        expect(stateMachine.currentState).to.equal(c);
    });

});
SpecEnd
