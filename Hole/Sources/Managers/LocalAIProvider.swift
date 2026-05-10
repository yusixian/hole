import Foundation

struct LocalAIProvider: AIProvider {
    let kind: AIProviderKind = .localStub

    func reflect(
        on body: String,
        persona: PersonaSnapshot,
        language: AILanguage
    ) async throws -> AIInsight {
        let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return AIInsight(echo: nil, summary: nil, moodSuggested: nil, tagsSuggested: [])
        }

        let preview = String(trimmed.prefix(60))
        let moodGuess = guessMood(from: trimmed.lowercased(), language: language)
        let tagGuess = guessTags(from: trimmed.lowercased(), language: language)

        let echo = makeEcho(persona: persona, preview: preview, language: language)
        let summary = makeSummary(preview: preview, language: language)

        return AIInsight(
            echo: echo,
            summary: summary,
            moodSuggested: moodGuess,
            tagsSuggested: tagGuess
        )
    }

    private func makeEcho(persona: PersonaSnapshot, preview: String, language: AILanguage) -> String {
        switch (persona.id, language) {
        case ("listener", .zh):
            "听到你说\u{201C}\(preview)\u{201D}\u{3002}你愿意再多说一些吗？"
        case ("listener", .en):
            "I hear you saying “\(preview)”. Want to say more about it?"
        case ("warmFriend", .zh):
            "嗯，看到这些字心里软了一下。今天先抱抱自己。"
        case ("warmFriend", .en):
            "Reading this softened me a bit. Be gentle with yourself today."
        case ("wiseMentor", .zh):
            "事如其感，感如其念。试着只观察这一念，不评价它。"
        case ("wiseMentor", .en):
            "Things feel as we frame them. Try observing this thought without judging it."
        case ("mirror", .zh):
            "你写下的是：\u{201C}\(preview)\u{201D}\u{3002}它对你意味着什么？"
        case ("mirror", .en):
            "What you wrote: “\(preview)”. What does it mean to you?"
        case (_, .zh):
            "我读完了你写的字。愿你今天被温柔以待。"
        case (_, .en):
            "I have read your words. May you be treated gently today."
        }
    }

    private func makeSummary(preview: String, language: AILanguage) -> String {
        switch language {
        case .zh: "今日主题：\(preview)"
        case .en: "Today’s theme: \(preview)"
        }
    }

    private func guessMood(from lower: String, language: AILanguage) -> Mood? {
        let positive: [String]
        let negative: [String]
        let neutral: [String]
        switch language {
        case .zh:
            positive = ["开心", "快乐", "舒畅", "幸福", "温暖", "感激"]
            negative = ["难过", "痛苦", "焦虑", "崩溃", "失落", "委屈", "累", "疲", "孤独", "孤单"]
            neutral = ["平静", "还好", "一般", "无聊"]
        case .en:
            positive = ["happy", "joy", "grateful", "warm", "calm love"]
            negative = ["sad", "anxious", "angry", "tired", "hopeless", "lonely"]
            neutral = ["okay", "fine", "neutral", "tired"]
        }
        if positive.contains(where: lower.contains) { return .good }
        if negative.contains(where: lower.contains) { return .low }
        if neutral.contains(where: lower.contains) { return .neutral }
        return nil
    }

    private func guessTags(from lower: String, language: AILanguage) -> [String] {
        let pairs: [(needle: String, tag: String)]
        switch language {
        case .zh:
            pairs = [
                ("工作", "工作"), ("加班", "工作"),
                ("睡", "睡眠"), ("失眠", "睡眠"),
                ("跑步", "运动"), ("锻炼", "运动"),
                ("家人", "家人"), ("朋友", "朋友"),
                ("孤", "孤独"), ("一个人", "孤独")
            ]
        case .en:
            pairs = [
                ("work", "work"), ("meeting", "work"),
                ("sleep", "sleep"), ("insomnia", "sleep"),
                ("run", "exercise"), ("gym", "exercise"),
                ("family", "family"), ("friend", "friends"),
                ("alone", "solitude"), ("lonely", "solitude")
            ]
        }
        var seen = Set<String>()
        var out: [String] = []
        for pair in pairs where lower.contains(pair.needle) && !seen.contains(pair.tag) {
            seen.insert(pair.tag)
            out.append(pair.tag)
            if out.count >= 3 { break }
        }
        return out
    }
}
