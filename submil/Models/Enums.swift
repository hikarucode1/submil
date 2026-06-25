import Foundation

enum BillingCycle: String, Codable, CaseIterable {
    case monthly
    case quarterly
    case yearly

    var displayName: String {
        switch self {
        case .monthly:   return "月額"
        case .quarterly: return "3ヶ月"
        case .yearly:    return "年額"
        }
    }
}

enum SubscriptionCategory: String, Codable, CaseIterable {
    case video
    case music
    case learning
    case creative
    case news
    case game
    case storage
    case fitness
    case food
    case productivity
    case other

    var displayName: String {
        switch self {
        case .video:        return "動画"
        case .music:        return "音楽"
        case .learning:     return "学習"
        case .creative:     return "クリエイティブ"
        case .news:         return "ニュース"
        case .game:         return "ゲーム"
        case .storage:      return "ストレージ"
        case .fitness:      return "フィットネス"
        case .food:         return "食事"
        case .productivity: return "仕事効率化"
        case .other:        return "その他"
        }
    }

    var emoji: String {
        switch self {
        case .video:        return "🎬"
        case .music:        return "🎵"
        case .learning:     return "📚"
        case .creative:     return "🎨"
        case .news:         return "📰"
        case .game:         return "🎮"
        case .storage:      return "💾"
        case .fitness:      return "💪"
        case .food:         return "🍔"
        case .productivity: return "🧰"
        case .other:        return "📦"
        }
    }
}

enum UsageRecency: Int, Codable, CaseIterable {
    case today = 5
    case within3days = 4
    case withinWeek = 3
    case withinMonth = 2
    case over = 0

    var score: Int { rawValue }

    var label: String {
        switch self {
        case .today:       return "今日使った"
        case .within3days: return "3日以内"
        case .withinWeek:  return "1週間以内"
        case .withinMonth: return "1ヶ月以内"
        case .over:        return "それ以上前"
        }
    }
}

enum UsageFrequency: Int, Codable, CaseIterable {
    case over20 = 5
    case around10 = 4
    case around5 = 3
    case few = 1
    case rarely = 0

    var score: Int { rawValue }

    var label: String {
        switch self {
        case .over20:   return "月20回以上"
        case .around10: return "月10回くらい"
        case .around5:  return "月5回くらい"
        case .few:      return "月数回"
        case .rarely:   return "ほぼ使わない"
        }
    }
}

enum GoneDifficulty: Int, Codable, CaseIterable {
    case cannotLive = 5
    case somewhat = 3
    case notReally = 1
    case notAtAll = 0

    var score: Int { rawValue }

    var label: String {
        switch self {
        case .cannotLive: return "無いと困る"
        case .somewhat:   return "まあ困る"
        case .notReally:  return "別に困らない"
        case .notAtAll:   return "全く困らない"
        }
    }
}

enum EvaluationResult: String, Codable {
    case keep
    case reconsider
    case cancel

    var label: String {
        switch self {
        case .keep:       return "そのまま継続"
        case .reconsider: return "見直し検討"
        case .cancel:     return "解約推奨"
        }
    }

    /// 結果画面の見出し (#32)
    var headline: String {
        switch self {
        case .keep:       return "今のままでOK"
        case .reconsider: return "ちょっと見直してみる?"
        case .cancel:     return "解約を検討しよう"
        }
    }

    /// 結果画面のアドバイス文 (#32)
    var advice: String {
        switch self {
        case .keep:
            return "しっかり使えています。コスパは良好。このまま継続しましょう。"
        case .reconsider:
            return "使用頻度がやや低めです。本当に必要か、もっと安いプランがないか見直してみましょう。"
        case .cancel:
            return "ほとんど使えていないようです。解約すれば固定費をぐっと減らせます。"
        }
    }

    /// SwiftUI Color の名称。View 側で `Color` にマップする
    var colorName: String {
        switch self {
        case .keep:       return "green"
        case .reconsider: return "yellow"
        case .cancel:     return "red"
        }
    }
}

enum CancellationReason: String, Codable, CaseIterable {
    case unused
    case tooExpensive
    case foundAlternative
    case switchToStudent
    case other

    var label: String {
        switch self {
        case .unused:           return "ほぼ使ってなかった"
        case .tooExpensive:     return "高すぎた"
        case .foundAlternative: return "別のものを見つけた"
        case .switchToStudent:  return "学割版に切り替え"
        case .other:            return "その他"
        }
    }
}
