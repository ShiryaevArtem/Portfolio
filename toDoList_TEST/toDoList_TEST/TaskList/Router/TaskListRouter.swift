//
//  TaskListRouterProtocol.swift
//  toDoList
//
//  Created by Ширяев Артем on 13.04.2025.
//

import UIKit


protocol TaskListRouterProtocol: AnyObject {
    static func createModule() -> UIViewController
    func showTaskEdit(for task: Task, from view: UIViewController)
}

class TaskListRouter: TaskListRouterProtocol {
    // MARK: - Properties
    private weak var viewController: UIViewController?
    
    // MARK: - TaskListRouterProtocol
    static func createModule() -> UIViewController {
        let view = TaskListViewController()
        let presenter = TaskListPresenter()
        let interactor = TaskListInteractor()
        let router = TaskListRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        
        router.viewController = view
        return view
    }
    
    func showTaskEdit(for task: Task, from view: UIViewController) {
        let editVC = EditTaskRouter.createModule(with: task)
        editVC.modalPresentationStyle = .fullScreen
        view.present(editVC, animated: true)
    }
}
