//
//  EditTaskPresenter.swift
//  toDoList_TEST
//
//  Created by Ширяев Артем on 15.04.2025.
//

import Foundation
import UIKit

protocol EditTaskPresenterProtocol:AnyObject{
    func viewDidLoad()
    func changed(task: Task)
}

class EditTaskPresenter:EditTaskPresenterProtocol,EditTaskInteractorOutputProtocol{
    func changed(task: Task) {
        interactor.change(task: task)
    }
    func didChanded() {
        router?.didTaskEdit(from: view as! UIViewController)
    }
    
    weak var view : EditTaskViewProtocol?
    var interactor: EditTaskInteractorInputProtocol!
    var router: EditTaskRouterProtocol!
    var task: Task?
//MARK: VIEW - > INTEGRATOR
    //MARK: INTEGRATOR - > VIEW
    func showEditScreen(task: Task?) {
        view?.showInfo(task: task)
    }
    func viewDidLoad() {
        interactor.getTask(task: self.task)
    }
}
