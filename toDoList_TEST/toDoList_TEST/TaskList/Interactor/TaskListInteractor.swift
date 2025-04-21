import Foundation
protocol TaskListInteractorInputProtocol: AnyObject {
    func fetchTasks()
    func addTask()
    func toggleTaskCompletion(at index: Int)
    func deleteTask(task: [Task], index: Int)
    func searchTasks(with query: String)
}

protocol TaskListInteractorOutputProtocol: AnyObject {
    func didFetchTasks(_ tasks: [Task])
    func didUpdateTask(_ task: Task, at index: Int)
    func didFail(with error: String)
    func didSearchResults(_ tasks: [Task])
    func didAddTask(task: Task)
}

class TaskListInteractor: TaskListInteractorInputProtocol {
    weak var presenter: TaskListInteractorOutputProtocol!
    private var tasks: [Task] = []
    private var storage: TaskStorageProtocol!
    private var apiManager: ApiManagerProtocol!
    
    init(
        storage: TaskStorageProtocol = CoreDataManager(),
        apiManager: ApiManagerProtocol = APIManager()
    ) {
        self.storage = storage
        self.apiManager = apiManager
    }
    
    func fetchTasks() {
        DispatchQueue.global(qos: .userInitiated).async {
            let cachedTasks: [Task] = self.storage.fetchTasks()
            if !cachedTasks.isEmpty {
                DispatchQueue.main.async { [weak self] in
                    self?.presenter.didFetchTasks(cachedTasks)
                    print("DATA IN CD = \n \(cachedTasks)")
                    self?.tasks = cachedTasks
                }
                return
            }
            
            self.apiManager.fetchTasks { [weak self] (result: Result<[Task], Error>) in
                switch result {
                case .success(let fetchedTasks):
                    self?.storage.saveTasks(fetchedTasks){ [weak self] (result: Result<Bool,Error>) in
                        switch result {
                        case .success(let isCompleted):
                            DispatchQueue.main.async {
                                print("Данные загружены? - \(isCompleted)")
                                guard let cachedTasks = self?.storage.fetchTasks() else { return }
                                self?.tasks = cachedTasks
                                self?.presenter.didFetchTasks(cachedTasks)
                            }
                        case .failure(let error):
                            self?.presenter.didFail(with: error.localizedDescription)
                        }
                    }
                    
                case .failure(let error):
                    self?.presenter.didFail(with: error.localizedDescription)
                }
            }
        }
    }
    func searchTasks(with query: String) {
        if query.isEmpty {
            presenter.didSearchResults(tasks)
            return
        }
        
        let filtered = tasks.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.todo.localizedCaseInsensitiveContains(query)
        }
        
        presenter.didSearchResults(filtered)
    }
    
    
    func addTask() {
        let newId = (tasks.max(by: { $0.id < $1.id })?.id ?? 0) + 1
        let newTask = Task(
            id: newId,
            userId: 1, // По умолчанию
            title: "",
            todo: "",
            completed: false, //По умолчанию
            date: Date()
        )
        tasks.append(newTask)
        storage.addTask(newTask)
        presenter.didAddTask(task: newTask)
    }
    
    func toggleTaskCompletion(at index: Int) {
        guard let taskIndex = tasks.firstIndex(where: { $0.id == index }) else { return }
        tasks[taskIndex].completed.toggle() // Изменяем оригинал
        print("Updated task: \(tasks[taskIndex])")
        storage.updateTask(tasks[taskIndex])
        self.presenter.didUpdateTask(tasks[taskIndex], at: taskIndex) // Отправляем оригинал
    }
    
    func deleteTask(task: [Task] , index: Int) {
        guard let taskIndex = tasks.firstIndex(where: { $0.id == index }) else { return }
        storage.deleteTask(by: index)
        tasks.remove(at: taskIndex)
        var newSortTask = task
        guard let taskIndex2 = task.firstIndex(where: { $0.id == index }) else { return }
        newSortTask.remove(at: taskIndex2)
        presenter.didFetchTasks(newSortTask)
    }
}

class MockTaskStorage: TaskStorageProtocol {
    var tasks: [Task] = []
    var task: Task?
    func saveTasks(_ tasks: [Task], completion: @escaping (Result<Bool, Error>) -> Void) {
        self.tasks = tasks
        completion(.success(true))
    }
    
    func fetchTasks() -> [Task] { return tasks }
    func addTask(_ task: Task) { tasks.append(task)
            print("succes added")
    }
    func updateTask(_ task: Task) { self.task = task
            print("succes updated")
    }
    func deleteTask(by id: Int) { tasks.removeAll { $0.id == id }
            print("succes deleted")
    }
}

class MockAPIManager: ApiManagerProtocol {
    var result: Result<[Task], Error> = .success([])
    
    func fetchTasks(completion: @escaping (Result<[Task], Error>) -> Void) {
        completion(result)
    }
}
