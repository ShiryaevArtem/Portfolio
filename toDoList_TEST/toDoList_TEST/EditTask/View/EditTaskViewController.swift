//
//  EditTaskViewController.swift
//  toDoList_TEST
//
//  Created by Ширяев Артем on 15.04.2025.
//

import UIKit

protocol EditTaskViewProtocol: AnyObject{
    func showInfo(task:Task?)
}

class EditTaskViewController: UIViewController,EditTaskViewProtocol {
    //MARK: INIT
    var presenter: EditTaskPresenterProtocol!
    private var task: Task?
    private lazy var titleLabel : UITextField = {
        titleLabel = UITextField()
        titleLabel.textColor = .lightText
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return titleLabel
    }()
    private lazy var todoLabel : UITextView = {
        todoLabel = UITextView()
        todoLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        todoLabel.textColor = .lightText
        todoLabel.textContainer.maximumNumberOfLines = 0
        todoLabel.textContainer.lineBreakMode = .byWordWrapping
        todoLabel.backgroundColor = .blackBackground
        todoLabel.insertTextPlaceholder(with: todoLabel.contentSize)
        return todoLabel
    }()
    private lazy var dateLabel : UILabel = {
        dateLabel = UILabel()
        dateLabel.textColor = .lightText
        dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        dateLabel.alpha = 0.5

        return dateLabel
    }()
    private lazy var cancelButton: UIButton = {
        let backButton = UIButton(type: .system)
        backButton.setTitle("Назад", for: .normal)
        backButton.titleLabel?.font = UIFont(name: "regular", size: 17)
        backButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        backButton.tintColor = .yellow // Цвет текста и изображения
        backButton.addTarget(self, action: #selector(handleBackButtonTapped), for: .touchUpInside)
          // Настройка расположения текста и изображения
        backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)
        backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)
        return backButton
    }()
    
    //MARK: Protocols Methods
    func showInfo(task: Task?) {
        print("finally \(task!)")
        if task?.title == "" {
            self.titleLabel.placeholder = "Новая задача"
        }else{
            self.titleLabel.text = task?.title
        }
        self.todoLabel.text = task?.todo
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        self.dateLabel.text = dateFormatter.string(from: task?.date ?? Date())
        self.task = task
    }
    //MARK: LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
    }
    
    //MARK: PRIVATE METHODS
    private func setupUI(){
        view.backgroundColor = .blackBackground
        view.addSubview(cancelButton)
        view.addSubview(titleLabel)
        view.addSubview(todoLabel)
        view.addSubview(dateLabel)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        todoLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            //CANCELBUTTON
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            //TITLE
            titleLabel.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            //titleLabel.heightAnchor.constraint(equalToConstant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            //DATE
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant:8),
            dateLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            //CONTENT
            todoLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            todoLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            todoLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            todoLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    @objc func handleBackButtonTapped(){
        presenter.changed(task: editTask()!)
    }
    private func editTask()-> Task?{
        self.task?.title = titleLabel.text ?? " "
        self.task?.todo = todoLabel.text ?? " "
        return self.task
    }
}
