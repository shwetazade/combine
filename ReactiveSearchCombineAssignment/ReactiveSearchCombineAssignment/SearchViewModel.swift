import Foundation
import Combine

struct ProductResponse: Decodable {
    let products: [Product]
}

struct Product: Decodable {
    let title: String
}

final class SearchViewModel: ObservableObject {

    let searchSubject = PassthroughSubject<String, Never>()

    @Published var searchResults: [String] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        searchSubject
            .map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .map { query in
                if query.count < 3 {
                    return Just([String]()).eraseToAnyPublisher()
                } else {
                    return self.searchProducts(query)
                }
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] titles in
                self?.searchResults = titles
            }
            .store(in: &cancellables)
    }

    func searchProducts(_ query: String) -> AnyPublisher<[String], Never> {
        guard let url = URL(string: "https://dummyjson.com/products/search?q=\(query)") else {
            return Just([String]()).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: ProductResponse.self, decoder: JSONDecoder())
            .map { response in
                response.products.map(\.title)
            }
            .catch { _ in
                Just([String]())
            }
            .eraseToAnyPublisher()
    }
}
