//
//  NSException+TBSM.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014-2017 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const TBSMException;

/**
 *  This category adds class methods to create NSException instances thrown by the TBStateMachine library.
 */
@interface NSException (TBStateMachine)

/**
 *  Thrown when an object is not of type `TBSMState`.
 *
 *  The `reason:` will contain a description of the object.
 *
 *  @param object The object in question.
 *
 *  @return The `NSException` instance.
 */
+ (NSException *)tbsm_notOfTypeStateException:(id)object;

/**
 *  Thrown when a specified `TBSMState` instance does not exist in the state machine.
 *
 *  The `reason:` will contain the name of the state.
 *
 *  @param stateName The name of the specified `TBSMState`.
 *
 *  @return The `NSException` instance.
 */
+ (NSException *)tbsm_nonExistingStateException:(NSString *)stateName;

/**
 *  Thrown when no initial state has been set on the state machine.
 *
 *  The `reason:` will contain the name of the state machine.
 *
 *  @param stateMachineName The name of the specified `TBSMState`.
 *
 *  @return The `NSException` instance.
 */
+ (NSException *)tbsm_noInitialStateException:(NSString *)stateMachineName;

/**
 *  Thrown when no name was given to a `TBSMState` instance.
 *
 *  @return The `NSException` instance.
 */
+ (NSException *)tbsm_noNameForStateException;

/**
 *  Thrown when no name was given to a pseudo state instance.
 *
 *  @return The `NSException` instance.
 */
+ (NSException *)tbsm_noNameForPseudoStateException;

/**
 *  Thrown when no name was given to a `TBSMEvent` instance.
 *
 *  @return The `NSException` instance.
 */
+ (NSException *)tbsm_noNameForEventException;

/**
 *  Thrown when a given object is not of type `TBSMStateMachine`.
 *
 *  The `reason:` will contain a description of the object.
 *
 *  @param object The object in question.
 *
 *  @return The `NSException` instance.
 */
+ (NSException *)tbsm_notAStateMachineException:(id)object;

/**
 *  Thrown when a `TBSMSubState` or `TBSMParallelState` was instanciated without a sub-machine instance.
 *
 *  @param stateMachineName The name of the specified `TBSMStateMachine` instance.
 *
 *  @return The `NSException` instance.
 */
+ (NSException *)tbsm_missingStateMachineException:(NSString *)stateMachineName;

/**
 *  Thrown when no least common ancestor could be found for a given transition.
 *
 *  @param transitionName The name of the transition.
 *
 *  @return The `NSException` instance.
 */
+ (NSException *)tbsm_noLcaForTransition:(NSString *)transitionName;

/**
 *  Thrown when an event handler has been added with contradicting or missing transition attributes.
 *
 *  @param eventName   The name of the specified event.
 *  @param sourceState The name of the source state.
 *  @param targetState The name of the target state.
 *
 *  @return The `NSException` instance.
 */
+ (NSException *)tbsm_ambiguousTransitionAttributes:(NSString *)eventName source:(nullable NSString *)sourceState target:(nullable NSString *)targetState;

/**
 *  Thrown when a compound transition is not well contructed.
 *
 *  @param pseudoStateName The name of the pseudo state.
 *
 *  @return The `NSException` instance.
 */
+ (NSException *)tbsm_ambiguousCompoundTransitionAttributes:(NSString *)pseudoStateName;

/**
 *  Thrown when no outgoing path from a junction pseudo state could be determined.
 *
 *  @param junctionName The name of the junction pseudo state.
 *
 *  @return The `NSException` instance.
 */
+ (NSException *)tbsm_noOutgoingJunctionPathException:(NSString *)junctionName;

/**
 *  Thrown when an NSOperaionQueue has been set which is not serial.
 *
 *  @param queueName The name of the queue.
 *
 *  @return The `NSException` instance.
 */
+ (NSException *)tbsm_noSerialQueueException:(NSString *)queueName;

/**
 *  Thrown when a specified path could not be resolved to an existing state.
 *
 *  @param path The path that coud not be resolved.
 *
 *  @return The `NSException` instance.
 */
+ (NSException *)tbsm_invalidPath:(NSString *)path;

@end
NS_ASSUME_NONNULL_END
