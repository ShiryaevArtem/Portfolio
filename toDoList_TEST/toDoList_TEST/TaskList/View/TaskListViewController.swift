import UIKit
protocol TaskListViewProtocol: AnyObject {
    func showTasks(_ tasks: [Task])
    func updateTask(_ task: Task)
    func showError(_ message: String)
    func didSearch(for text: String)
}

// Добавляем расширение для цветов
extension UIColor {
    static let darkBackground = UIColor(red: 39/255.0, green: 39/255.0, blue: 41/255.0, alpha: 1.0)
    static let lightText = UIColor(red: 0.957, green: 0.957, blue: 0.957, alpha: 1.0)
    static let blackBackground = UIColor(red: 0.016, green: 0.016, blue: 0.016, alpha: 1.0)
}

class TaskListViewController: UIViewController, TaskListViewProtocol, UISearchBarDelegate {
    
    // MARK: - Properties
    var presenter: TaskListPresenterProtocol!
    private var tasks: [Task] = []
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Задачи"
        label.textColor = .lightText
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.numberOfLines = 1
        return label
    }()
    private lazy var footerView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkBackground
        return view
    }()
    private lazy var scrollView = UIScrollView()
    private lazy var countLabel: UILabel = {
        let countLabel = UILabel()
        countLabel.textColor = .lightText
        countLabel.font =  UIFont.systemFont(ofSize: 11, weight: .regular)
        return countLabel
    }()
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск задач"
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.barTintColor = .lightText
        searchBar.tintColor = .lightText
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.textColor = .lightText
            textField.backgroundColor = .darkBackground
            textField.attributedPlaceholder = NSAttributedString(
                string: "Поиск задач",
                attributes: [.foregroundColor: UIColor.lightText.withAlphaComponent(0.5)]
            )
            // Иконка поиска
            if let glassIconView = textField.leftView as? UIImageView {
                glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
                glassIconView.tintColor = .lightText.withAlphaComponent(0.5)
            }
        }

        return searchBar
    }()
    @objc private func voiceInputTapped() {
        // Обработка нажатия на кнопку микрофона
        print("Голосовой ввод активирован")
        // Здесь можно добавить логику распознавания речи
    }
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(TaskTableViewCell.self, forCellReuseIdentifier: "TaskCell")
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = .blackBackground
        table.isScrollEnabled = true
        table.separatorColor = .lightText.withAlphaComponent(0.2)
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 100
        return table
    }()
    private lazy var addTaskButton: UIButton = {
        let addTaskButton = UIButton()
        addTaskButton.setImage(UIImage(named: "addTaskIcon"), for: .normal)
        addTaskButton.tintColor = .yellow
        addTaskButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        return addTaskButton
    }()
    private var tableViewHeightConstraint: NSLayoutConstraint!
    private let refreshControl = UIRefreshControl()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let micButton = UIButton(type: .system)
        micButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        micButton.tintColor = .lightText
        micButton.addTarget(self, action: #selector(voiceInputTapped), for: .touchUpInside)
        micButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        searchBar.searchTextField.rightView = micButton
        searchBar.searchTextField.rightViewMode = .always
        setupUI()
        presenter.viewDidLoad()
    }
    
    // MARK: - TaskListViewProtocol
    func showTasks(_ tasks: [Task]) {
        refreshControl.endRefreshing()
        self.tasks = tasks
        self.countLabel.text = "\(tasks.count) Задач"
        tableView.reloadData()
        DispatchQueue.main.async {
            self.updateTableViewHeight()
            self.view.layoutIfNeeded()
        }
    }
    
    func updateTask(_ task: Task) {
        guard let taskIndex = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[taskIndex] = task
        tableView.reloadRows(at: [IndexPath(row: taskIndex, section: 0)], with: .automatic)
        self.updateTableViewHeight()
    }
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func didSearch(for text: String) {
        // Передаем запрос презентеру
        presenter.didSearch(for: text)
    }
    
    // MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        didSearch(for: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .blackBackground
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        footerView.addSubview(countLabel)
        footerView.addSubview(addTaskButton)
        //view.addSubview(scrollView) если надо будет, можно добавить
        view.addSubview(tableView)
        view.addSubview(footerView)
        
        // Настройка constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        footerView.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        addTaskButton.translatesAutoresizingMaskIntoConstraints = false
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 100)
        tableViewHeightConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            // ScrollView на весь экран кроме footer
//            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: tableView.topAnchor),
//            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0),
                        // TitleLabel с отступом 20pt от safe area
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
                        
            // SearchBar
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
                        
            // TableView
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: footerView.topAnchor),
            //tableView.heightAnchor.constraint(equalToConstant: 500), // Временное значение
            tableViewHeightConstraint,
            // FooterView внизу экрана
            footerView.heightAnchor.constraint(equalToConstant: 84),
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            //countLabel
            countLabel.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            countLabel.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
            addTaskButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        
            addTaskButton.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
//            addTaskButton.heightAnchor.constraint(equalToConstant: 20),
//            addTaskButton.widthAnchor.constraint(equalToConstant: 20)
                    ])
    }
    override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            tableView.reloadData()
            updateTableViewHeight()
        }
//
    private func updateTableViewHeight() {
        tableView.layoutIfNeeded() // Сначала обновляем layout ячеек
        let contentHeight = tableView.contentSize.height
        let minHeight: CGFloat = 100 // Минимальная высота таблицы
        
        // Устанавливаем высоту таблицы, но не меньше минимальной
        tableViewHeightConstraint.constant = max(contentHeight, minHeight)
        
        // Обновляем layout сразу
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func didTapAddButton() {
        self.presenter.didTapAddTask()
    }
}
// MARK: - UITableViewDataSource & Delegate
extension TaskListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskTableViewCell else {
            return UITableViewCell()
        }
        let task = tasks[indexPath.row]
        cell.configure(with: task.title,content: task.todo, date:task.date, isCompleted: task.completed)
        cell.layoutIfNeeded()
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didToggleTask(at: tasks[indexPath.row].id)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView,
                   willEndContextMenuInteraction configuration: UIContextMenuConfiguration,
                     animator: UIContextMenuInteractionAnimating?) {
            
            // Возвращаем цвет всем видимым ячейкам
            tableView.visibleCells.forEach { cell in
                cell.backgroundColor = .blackBackground
            }
        }
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { [self]  _ in
                //tableView.cellForRow(at: indexPath)?.backgroundColor = .blackBackground
                presenter.didEditTask(task: tasks[indexPath.row])
                print("Редактировать ячейку \(tasks[indexPath.row])")
            }
            let shareAction = UIAction(title: "Поделиться", image: UIImage(systemName: "share")) { _ in
                let task = self.tasks[indexPath.row]
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .short
                let dateText = dateFormatter.string(from: task.date)
                let status = task.completed ? "(Выполнено)" : "(Не выполнено)"
                let shareText = "\(task.title) \n\n \(status)  \n  \(task.todo) \n  \(dateText)"
                // Создаем UIActivityViewController
                let activityViewController = UIActivityViewController(
                    activityItems: [shareText], // Данные для sharing
                    applicationActivities: nil // Дополнительные активности (если есть)
                )
                // Настройка для iPad (если нужно)
                if let popoverController = activityViewController.popoverPresentationController {
                    popoverController.sourceView = self.view
                    popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                }
                // Показываем UIActivityViewController
                //tableView.cellForRow(at: indexPath)?.backgroundColor = .blackBackground
                self.present(activityViewController, animated: true, completion: nil)
                print("Поделиться ячейкой \(indexPath.row)")
                
            }
            let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { [self] _ in
                self.presenter.didDeleteTask(task: tasks, index: tasks[indexPath.row].id)
                print("Удалить ячейку \(indexPath.row)")
                //tableView.cellForRow(at: indexPath)?.backgroundColor = .blackBackground
            }
            tableView.cellForRow(at: indexPath)?.backgroundColor = .darkBackground
            return UIMenu(title: "", children: [editAction,shareAction ,deleteAction])
        }
    }
}

