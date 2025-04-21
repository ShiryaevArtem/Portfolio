//
//  CoreDataManager.swift
//  toDoList_TEST
//
//  Created by Ширяев Артем on 17.04.2025.
//

import Foundation
import CoreData
protocol TaskStorageProtocol: AnyObject{
    func saveTasks(_ tasks: [Task], completion: @escaping (Result<Bool, Error>) -> Void)
    func fetchTasks() -> [Task]
    func addTask(_ task: Task)
    func updateTask(_ task: Task)
    func deleteTask(by id: Int)
    
}

public class CoreDataManager: TaskStorageProtocol {
    static let shared = CoreDataManager()
    private let persistentContainer: NSPersistentContainer
    
    init() {
        persistentContainer = NSPersistentContainer(name: "toDoList_TEST")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error { fatalError("CoreData error: \(error)") }
        }
    }
    //Сохраняем данные в БД при первом запуске приложения
    func saveTasks(_ tasks: [Task], completion: @escaping (Result<Bool,Error>) -> Void) {
        let bgContext = persistentContainer.newBackgroundContext()
        bgContext.perform { // Асинхронное выполнение
            tasks.forEach { task in
                let cdTask = CDTask(context: bgContext)
                cdTask.id = Int16(task.id)
                cdTask.title = task.title
                cdTask.todo = task.todo
                cdTask.completed = task.completed
                cdTask.date = task.date
            }
            do{
                try bgContext.save()
                DispatchQueue.main.async {
                    completion(.success(true))
                }
                
            }catch{
                print("Error saveTasks")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    //забираем данные из БД в главном потоке
    func fetchTasks() -> [Task] {
        let request: NSFetchRequest<CDTask> = CDTask.fetchRequest()
        // Сортировка по дате (от новых к старым)
        let dateSort = NSSortDescriptor(
            key: #keyPath(CDTask.date),
            ascending: false
        )
        request.sortDescriptors = [dateSort]
        guard let cdTasks = try? persistentContainer.viewContext.fetch(request) else { return [] }
        
        return cdTasks.map { Task(
            id: Int($0.id),
            userId: 1,
            title: $0.title ?? "",
            todo: $0.todo ?? "",
            completed: $0.completed,
            date: $0.date ?? Date()
        )}
    }
    func addTask(_ task: Task){
        let bgContext = persistentContainer.newBackgroundContext()
        bgContext.perform {
            let request: NSFetchRequest<CDTask> = CDTask.fetchRequest()
            let cdTask = CDTask(context: bgContext)
            cdTask.id = Int16(task.id)
            cdTask.title = task.title
            cdTask.todo = task.todo
            cdTask.completed = task.completed
            cdTask.date = task.date
            do{
                try bgContext.save()
            }catch{
                print("Error addTasks")
            }
        }
    }
    //Обновляем выбранную задачу
    func updateTask(_ task: Task) {
        let bgContext = persistentContainer.newBackgroundContext()
        bgContext.perform {
            let request: NSFetchRequest<CDTask> = CDTask.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", task.id)
            
            if let cdTask = try? bgContext.fetch(request).first {
                cdTask.title = task.title
                cdTask.todo = task.todo
                cdTask.completed = task.completed
                do{
                    try bgContext.save()
                }catch{
                    print("Error updateTasks")
                }
            }
        }
    }
    
    //Удаляем выбранную задачу
    func deleteTask(by id: Int) {
        let bgContext = persistentContainer.newBackgroundContext()
        bgContext.perform {
            let request: NSFetchRequest<CDTask> = CDTask.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", id)
            
            if let task = try? bgContext.fetch(request).first {
                bgContext.delete(task)
                do{
                    try bgContext.save()
                }catch{
                    print("Error deleteTasks")
                }
            }
        }
    }
}



class MockCoreDataStack: NSPersistentContainer {
    init() {
        let model = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
        super.init(name: "toDoList_TEST", managedObjectModel: model)
        
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        self.persistentStoreDescriptions = [description]
        
        self.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load test store: \(error)")
            }
        }
    }
}
