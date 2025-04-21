import UIKit
protocol TaskListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapAddTask()
    func didDeleteTask(task: [Task], index: Int)
    func didToggleTask(at index: Int)
    func didEditTask( task: Task)
    func didSearch(for text: String)  // Добавляем этот метод
}

class TaskListPresenter: TaskListPresenterProtocol, TaskListInteractorOutputProtocol {

    
    func didAddTask(task: Task) {
        router.showTaskEdit(for: task, from: view as! UIViewController)
        print("new task in present")
    }
    
    func didTapAddTask() {
        interactor.addTask()
    }
    
    func didSearchResults(_ tasks: [Task]) {
            view?.showTasks(tasks)
        }
    
    weak var view: TaskListViewProtocol?
    var interactor: TaskListInteractorInputProtocol!
    var router: TaskListRouterProtocol!
    
    func viewDidLoad() {
        interactor.fetchTasks()
    }
    
    func didEditTask(task: Task) {
        router.showTaskEdit(for: task, from: view as! UIViewController)
    }
    
    func didDeleteTask(task: [Task], index: Int) {
        interactor.deleteTask(task: task, index: index)
    }
    
    func didToggleTask(at index: Int) {
        interactor.toggleTaskCompletion(at: index)
        print("presenter =  \(index)")
    }
    
    // MARK: - TaskListInteractorOutputProtocol
    func didFetchTasks(_ tasks: [Task]) {
        view?.showTasks(tasks)
    }
    
    func didUpdateTask(_ task: Task, at index: Int) {
        view?.updateTask(task)
    }
    
    func didFail(with error: String) {
        view?.showError(error)
    }
    func didSearch(for text: String) {
            interactor.searchTasks(with: text)
        }
}

