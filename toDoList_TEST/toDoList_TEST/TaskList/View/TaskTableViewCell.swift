import UIKit
class TaskTableViewCell: UITableViewCell {
    
    // MARK: - UI Elements
//    private lazy var checkBox: UIButton = {
//        let button = UIButton(type: .custom)
//        button.setImage(UIImage(systemName: "checkBoxDisable"), for: .normal)
//        button.setImage(UIImage(systemName: "checkBoxEnable"), for: .selected)
//        button.addTarget(self, action: #selector(toggleCheckBox), for: .touchUpInside)
//        return button
//    }()
    var checkBox = UIImageView()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail // Обрезка текста в конце
        return label
    }()
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.alpha = 0.5
        return label
    }()
    var isCompleted: Bool = false {
            didSet {
                updateTitleAppearance()
            }
        }
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.backgroundColor = .blackBackground
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .black
        
        addSubview(checkBox)
        addSubview(titleLabel)
        addSubview(contentLabel)
        addSubview(dateLabel)
        
        checkBox.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            checkBox.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            checkBox.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            checkBox.widthAnchor.constraint(equalToConstant: 20),
            checkBox.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: checkBox.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            // Убираем фиксированную высоту для titleLabel
            // titleLabel.heightAnchor.constraint(equalToConstant: 20),

            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            contentLabel.leadingAnchor.constraint(equalTo: checkBox.trailingAnchor, constant: 8),
            contentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            

            dateLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 6),
            dateLabel.leadingAnchor.constraint(equalTo: checkBox.trailingAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
        ])
    }
    

       // MARK: - Configure Cell
    func configure(with taskTitle: String, content: String, date: Date, isCompleted: Bool) {
        titleLabel.attributedText = nil
        titleLabel.text = taskTitle
        contentLabel.text = content
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateLabel.text = dateFormatter.string(from: date)
        self.isCompleted = isCompleted
        updateTitleAppearance()
    }
       // MARK: - Update Title Appearance
       private func updateTitleAppearance() {
           if isCompleted {
               checkBox.image = UIImage(named: "checkBoxEnable")!
               titleLabel.alpha = 0.5
               contentLabel.alpha = 0.5
               let attributes: [NSAttributedString.Key: Any] = [
                   .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                   .foregroundColor: UIColor.lightText.withAlphaComponent(0.5)
               ]
               titleLabel.attributedText = NSAttributedString(string: titleLabel.text ?? "", attributes: attributes)
           } else {
               checkBox.image = UIImage(named: "checkBoxDisable")!
               titleLabel.alpha = 1.0
               contentLabel.alpha = 1.0
               let originalText = titleLabel.text ?? ""
               titleLabel.text = originalText
               titleLabel.textColor = .lightText
               titleLabel.font = UIFont.systemFont(ofSize: 16)
               
           }
       }
   }
