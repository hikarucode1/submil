#if DEBUG
import Foundation
import SwiftData

enum SampleData {
    /// Debug 用にサンプル 3 件を投入する。既に何か入っていたら何もしない。
    @MainActor
    static func seed(into context: ModelContext) {
        let existing = try? context.fetch(FetchDescriptor<Subscription>())
        guard existing?.isEmpty ?? true else { return }

        let netflix = Subscription(
            serviceName: "Netflix",
            amount: 1490,
            billingCycle: .monthly,
            billingDay: 15,
            category: .video
        )
        let spotify = Subscription(
            serviceName: "Spotify",
            amount: 9800,
            billingCycle: .yearly,
            billingDay: 1,
            category: .music
        )
        spotify.isActive = false  // CancellationLog と整合
        context.insert(netflix)
        context.insert(spotify)

        let evaluation = UsageEvaluation(
            subscription: netflix,
            lastUsed: .within3days,
            frequency: .around10,
            difficulty: .somewhat
        )
        context.insert(evaluation)

        let cancellation = CancellationLog(
            from: spotify,
            reason: .switchToStudent,
            note: "学割版に切り替え"
        )
        context.insert(cancellation)
    }
}
#endif
