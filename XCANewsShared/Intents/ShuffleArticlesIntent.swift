//
//  File.swift
//  XCANews
//
//  Created by Alfian Losari on 10/06/23.
//

import AppIntents

struct ShuffleArticlesIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Shuffle articles"
    
    @Parameter(title: "Category")
    var category: String
    
    init() {}
    
    init(category: String) {
        self.category = category
    }
    
    func perform() async throws -> some IntentResult {
        let date = Date()
        let category = Category(rawValue: category) ?? .general
        if let cachedArticles = ArticleProvider.cache[category], (date.timeIntervalSince1970 - cachedArticles.timestamp.timeIntervalSince1970) >= (60 * 60) {
            let articles = try await ArticleProvider.getArticles(for: category, pageSize: 20)
            ArticleProvider.cache[category] = .init(timestamp: date, articles: articles)
        }
        return .result()
    }
    
    
}

