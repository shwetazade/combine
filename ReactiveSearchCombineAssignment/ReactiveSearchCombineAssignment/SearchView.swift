import SwiftUI
import Combine

struct SearchView: View {

    @State private var searchText = ""
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        VStack {

            TextField("Search products", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding()
                .onChange(of: searchText) {
                    viewModel.searchSubject.send(searchText)
                }

            List(viewModel.searchResults, id: \.self) { title in
                Text(title)
            }
        }
    }
}
