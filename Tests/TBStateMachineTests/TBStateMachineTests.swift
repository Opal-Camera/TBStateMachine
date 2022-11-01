import XCTest
@testable import TBStateMachine

final class TBStateMachineTests: XCTestCase {
    func testCreation() throws {
        let testMachine = TBStateMachine.TBSMStateMachine(name: "Test")
        XCTAssertNotNil(testMachine)
    }
    
    func testUsable() throws {
        // Setup the machine
        let testMachine = TBStateMachine.TBSMStateMachine(name: "Test")
        testMachine.scheduledEventsQueue = {
            let opQueue = OperationQueue()
            opQueue.maxConcurrentOperationCount = 1
            return opQueue
        }()
        
        // Do we have it?
        XCTAssertNotNil(testMachine)
        
        // Set up some states and handlers
        var inNoStateForTesting = false
        
        let noState = TBSMState(name: "No State")
        noState.enterBlock = { _ in
            inNoStateForTesting = true
        }
                
        let group = DispatchGroup()
        group.enter()
        
        let testState = TBSMState(name: "Test State")
        testState.enterBlock = { _ in
            inNoStateForTesting = false
            group.leave()
        }
        
        noState.addHandler(forEvent: "An event", target: testState)
        testState.addHandler(forEvent: "No State", target: noState)
        
        // Start the machine
        testMachine.setStates([noState, testState])
        testMachine.initialState = noState
        testMachine.setUp(nil)
        
        XCTAssertTrue(inNoStateForTesting)
        
        // Make sure it switches
        testMachine.scheduleEventNamed("An event", data: nil)
        group.wait()
        
        XCTAssertFalse(inNoStateForTesting)
    }
}
