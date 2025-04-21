import Foundation
protocol ApiManagerProtocol{
    func fetchTasks(completion: @escaping (Result<[Task], Error>) ->Void)
}
final class APIManager: ApiManagerProtocol {
    static let shared = APIManager()
    private let urlSession = URLSession(configuration: .default)
    private let baseURL = "https://dummyjson.com/todos"
    
    func fetchTasks(completion: @escaping (Result<[Task], Error>) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            guard let url = URL(string: self.baseURL) else {
                completion(.failure(NSError(domain: "Invalid URL", code: -1)))
                return
            }
            
            self.urlSession.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "No data", code: -1)))
                    }
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(TaskResponse.self, from: data)
                    let tasks = response.todos
                    DispatchQueue.main.async {
                        completion(.success(tasks))
                    }
                } catch let decodingError {
                    DispatchQueue.main.async {
                        completion(.failure(decodingError))
                    }
                }
            }.resume()
        }
    }
}
