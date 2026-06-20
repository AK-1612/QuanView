import Foundation
import SwiftUI
import Combine

@MainActor
class DirectoryViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedCategory: DirectoryCategory? = nil
    
    var filteredItems: [DirectoryItem] {
        let baseList = DirectoryItem.database
        
        return baseList.filter { item in
            let matchesCategory = selectedCategory == nil || item.category == selectedCategory
            let matchesSearch = searchText.isEmpty ||
                item.name.localizedCaseInsensitiveContains(searchText) ||
                item.subtitle.localizedCaseInsensitiveContains(searchText) ||
                item.symbol.localizedCaseInsensitiveContains(searchText)
            
            return matchesCategory && matchesSearch
        }
    }
}
