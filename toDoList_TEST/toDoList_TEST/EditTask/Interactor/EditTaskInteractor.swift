//
//  EditTaskInteractor.swift
//  toDoList_TEST
//
//  Created by Ширяев Артем on 15.04.2025.
//

import Foundation
protocol EditTaskInteractorInputProtocol: AnyObject{
    func getTask(task:Task?)
    func change(task: Task)
}
protocol EditTaskInteractorOutputProtocol: AnyObject{
    func showEditScreen(task: Task?)
    func didChanded()
}


class EditTaskInteractor: EditTaskInteractorInputProtocol{
    //private let coreDataManager = CoreDataManager.shared
    var task: Task?
    weak var presenter: EditTaskInteractorOutputProtocol?
    private var storage: TaskStorageProtocol!
    
    init(storage: TaskStorageProtocol = CoreDataManager()) {
            self.storage = storage
        }
    
    func getTask(task: Task?) {
        self.task = task
        self.presenter?.showEditScreen(task: self.task)
    }
    func change(task: Task) {
        //здесь будет запись в БД изменений
        self.task = task
        storage.updateTask(task)
        presenter?.didChanded()
    }
}


