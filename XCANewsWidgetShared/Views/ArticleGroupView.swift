//
//  ArticleGroupView.swift
//  XCANews
//
//  Created by Alfian Losari on 10/16/21.
//

import SwiftUI
import WidgetKit

struct ArticleRowView: View {
    
    let article: ArticleWidgetModel
    
    var body: some View {
        HStack(alignment: .top) {
            if let imageData = article.imageData {
                ImageBackgroundView(data: imageData)
                    .frame(width: 40, height: 40)
                    .cornerRadius(8)
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(Color.gray.opacity(0.7))
                    .frame(width: 40, height: 40)
            }
            
            Text(article.subtitle)
                .lineLimit(2).font(.caption)
        }
        .redacted(reason: article.isPlaceholder ? .placeholder : .init())
    }
    
}

struct ArticleGroupView: View {
    
    let articles: [ArticleWidgetModel]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(articles) { article in
                Link(destination: article.url) {
                    ArticleRowView(article: article)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                if articles.last?.id != article.id {
                    Divider().frame(height: 0.5)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct ArticleGroupView_Previews: PreviewProvider {
    
    static let stubs = ArticleWidgetModel.stubs
    
    static var previews: some View {
        Group {
            ArticleGroupView(articles: Array(stubs.prefix(2)))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            ArticleGroupView(articles: Array(stubs.prefix(4)))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            
            ArticleGroupView(articles: Array(ArticleWidgetModel.placeholders.prefix(2)))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
