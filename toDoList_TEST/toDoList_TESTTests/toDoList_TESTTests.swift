import XCTest
@testable import toDoList_TEST
class TaskListInteractorTests: XCTestCase {
    var sut: TaskListInteractor!
    var mockStorage: MockTaskStorage!
    var mockAPIManager: MockAPIManager!
    var mockPresenter: MockTaskListPresenter!
    
    override func setUp() {
        super.setUp()
        mockStorage = MockTaskStorage()
        mockAPIManager = MockAPIManager()
        mockPresenter = MockTaskListPresenter()
        
        sut = TaskListInteractor(
            storage: mockStorage,
            apiManager: mockAPIManager
        )
        sut.presenter = mockPresenter
    }
    
    func testAddTask() {
        sut.addTask()
        print(mockStorage.tasks.count)
        XCTAssertEqual(mockStorage.tasks.count, 1)
        XCTAssertEqual(mockPresenter.addedTask?.id, 1)
    }
    
    func testDeleteTask() {
        sut.addTask()
        sut.deleteTask(task: mockStorage.tasks, index: 1)
        XCTAssertEqual(mockStorage.tasks.count, 0)
    }
    func testToggleTask(){
        sut.addTask()
        sut.toggleTaskCompletion(at: 1)
        XCTAssertTrue(mockStorage.task!.completed)
    }
}

class MockTaskListPresenter: TaskListInteractorOutputProtocol {
    var addedTask: Task?
    func didAddTask(task: Task) { addedTask = task
            print("succes added")
    }
    func didFetchTasks(_ tasks: [Task]) {
        print("fetch succes = \(tasks)")
    }
    func didUpdateTask(_ task: Task, at index: Int) {
        print("Updated")
    }
    func didFail(with error: String) {}
    func didSearchResults(_ tasks: [Task]) {}
}
