import Foundation
struct Task: Codable, Identifiable {
    let id: Int
    let userId: Int
    var title: String
    var todo: String
    var completed: Bool
    var date: Date
    
    // Упрощенный инициализатор
    init(id: Int, userId: Int, title: String, todo: String, completed: Bool, date: Date) {
        self.id = id
        self.userId = userId
        self.title = title
        self.todo = todo
        self.completed = completed
        self.date = date
    }
    
    // Инициализатор для декодирования из JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        userId = try container.decode(Int.self, forKey: .userId)
        todo = try container.decode(String.self, forKey: .todo)
        completed = try container.decode(Bool.self, forKey: .completed)
        title = "Task #\(id)"
        date = Date()
    }
}

struct TaskResponse: Codable {
    let todos: [Task]
    let total: Int
    let skip: Int
    let limit: Int
    
    enum CodingKeys: String, CodingKey {
        case todos, total, skip, limit
    }
}
