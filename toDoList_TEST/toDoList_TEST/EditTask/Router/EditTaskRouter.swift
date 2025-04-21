
//
//  TaskListRouterProtocol.swift
//  toDoList
//
//  Created by Ширяев Артем on 13.04.2025.
//

import UIKit


protocol EditTaskRouterProtocol: AnyObject {
    static func createModule(with task: Task?) -> UIViewController
    func didTaskEdit(from view: UIViewController)
}

class EditTaskRouter: EditTaskRouterProtocol {
    
    static func createModule(with task: Task?) -> UIViewController {
        let view = EditTaskViewController()
        let presenter = EditTaskPresenter()
        let interactor = EditTaskInteractor()
        let router = EditTaskRouter()

        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        presenter.task = task
        interactor.presenter = presenter
        return view
    }

    func didTaskEdit(from view: UIViewController) {
        let editVC = TaskListRouter.createModule()
        editVC.modalPresentationStyle = .fullScreen
        view.present(editVC, animated: true)
    }
}
