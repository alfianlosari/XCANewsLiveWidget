//
//  ArticleProvider.swift
//  XCANews
//
//  Created by Alfian Losari on 10/16/21.
//

import Foundation
import WidgetKit

struct CachedArticle {
    let timestamp: Date
    let articles: [ArticleWidgetModel]
}

struct ArticleProvider: IntentTimelineProvider {
    
    typealias Entry = ArticleEntry
    typealias Intent = SelectCategoryIntent
    
    static let newsAPI = NewsAPI.shared
    static let urlSession = URLSession.shared
    static var cache: [Category: CachedArticle] = [:]
    
    func placeholder(in context: Context) -> ArticleEntry {
        .placeholder
    }
    
    func getSnapshot(for configuration: SelectCategoryIntent, in context: Context, completion: @escaping (ArticleEntry) -> Void) {
        Task {
            let entry = await getArticleEntry(for: Category(configuration.category))
            completion(entry)
        }
    }
    
    func getTimeline(for configuration: SelectCategoryIntent, in context: Context, completion: @escaping (Timeline<ArticleEntry>) -> Void) {
        Task {
            let entry = await getArticleEntry(for: Category(configuration.category))
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60 * 60)))
            completion(timeline)
        }
    }
    
    private func getArticleEntry(for category: Category) async -> ArticleEntry {
        let entry: ArticleEntry
        let date = Date()

        do {
            let articles: [ArticleWidgetModel]
            if let cachedArticles = Self.cache[category], (Date().timeIntervalSince1970 - cachedArticles.timestamp.timeIntervalSince1970) < (60 * 60) {
                articles = cachedArticles.articles
            } else {
                articles = try await Self.getArticles(for: category, pageSize: 20)
                Self.cache[category] = .init(timestamp: date, articles: articles)
            }
            entry = articles.isEmpty ? .placeholder : .init(date: date, state: .articles(articles.shuffled()), category: category)
        } catch {
            entry = .init(date: date, state: .failure(error), category: category)
        }
        return entry
    }
    
    static func getArticles(for category: Category, pageSize: Int = 5) async throws -> [ArticleWidgetModel] {
        let articles = try await newsAPI.fetch(from: category,  pageSize: pageSize)
        
        return try await withThrowingTaskGroup(of: ArticleWidgetModel.self) { group in
            for article in articles {
                group.addTask { await fetchImageData(from: article) }
            }
            
            var results = [ArticleWidgetModel]()
            for try await result in group {
                results.append(result)
            }
            
            return results.sorted { $0.article?.publishedAt ?? Date() > $1.article?.publishedAt ?? Date()}
        }
    }
    
    static func fetchImageData(from article: Article) async -> ArticleWidgetModel {
        guard let url = article.imageURL,
              let (data, response) = try? await urlSession.data(from: url),
              let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                  return .init(state: .article(article: article, imageData: nil))
              }
        
        return .init(state: .article(article: article, imageData: data))
    }
}
