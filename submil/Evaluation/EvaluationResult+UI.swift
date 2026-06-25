import SwiftUI

/// `EvaluationResult` の表示用プロパティ。
/// モデル層 (Models/Enums.swift) は SwiftUI 非依存に保ち、色・アイコンは UI 層で定義する。
extension EvaluationResult {
    /// 結果に対応する表示色。
    /// reconsider はモデルの `colorName` では "yellow" だが、白背景での視認性を優先し orange を用いる。
    var color: Color {
        switch self {
        case .keep:       return .green
        case .reconsider: return .orange
        case .cancel:     return .red
        }
    }

    /// 結果に対応する SF Symbol。
    var systemImage: String {
        switch self {
        case .keep:       return "checkmark.seal.fill"
        case .reconsider: return "questionmark.circle.fill"
        case .cancel:     return "scissors"
        }
    }
}
