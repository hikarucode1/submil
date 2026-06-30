import Foundation
import Testing
@testable import submil

@Suite struct AffiliateLinkLabelTests {

    @Test func stripsLeadingPRMarker() {
        #expect(AffiliateLinkLabel.stripped("[PR] Adobe CC 学生版で年¥67,200お得 💰")
            == "Adobe CC 学生版で年¥67,200お得 💰")
    }

    @Test func stripsLowercaseAndFullwidthMarkers() {
        #expect(AffiliateLinkLabel.stripped("[pr] foo") == "foo")
        #expect(AffiliateLinkLabel.stripped("［PR］ bar") == "bar")
        #expect(AffiliateLinkLabel.stripped("【PR】 baz") == "baz")
    }

    @Test func keepsTextWithoutMarker() {
        #expect(AffiliateLinkLabel.stripped("Spotify 学割で月¥500お得") == "Spotify 学割で月¥500お得")
    }

    @Test func trimsSurroundingWhitespace() {
        #expect(AffiliateLinkLabel.stripped("  [PR]   間隔あり  ") == "間隔あり")
    }

    @Test func doesNotStripMidStringPR() {
        // 文中の "PR" や角括弧なしの "PR" は誤って除去しない (先頭マーカーのみ対象)。
        #expect(AffiliateLinkLabel.stripped("PRO ツール") == "PRO ツール")
        #expect(AffiliateLinkLabel.stripped("年¥500お得 [PR]") == "年¥500お得 [PR]")
    }
}
