import Foundation
import SwiftData

@Model
final class Persona {
    @Attribute(.unique) var id: String
    var name: String
    var systemPromptZh: String
    var systemPromptEn: String
    var avatarSymbol: String
    var isBuiltIn: Bool
    var sortOrder: Int
    var createdAt: Date

    init(
        id: String,
        name: String,
        systemPromptZh: String,
        systemPromptEn: String,
        avatarSymbol: String = "person.crop.circle",
        isBuiltIn: Bool = false,
        sortOrder: Int = 0,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.systemPromptZh = systemPromptZh
        self.systemPromptEn = systemPromptEn
        self.avatarSymbol = avatarSymbol
        self.isBuiltIn = isBuiltIn
        self.sortOrder = sortOrder
        self.createdAt = createdAt
    }
}

extension Persona {
    static func makeBuiltInSeeds() -> [Persona] { [
        Persona(
            id: "listener",
            name: String(localized: "persona.listener.name"),
            systemPromptZh: "你是一位中立的倾听者，遵循 Rogerian 风格。回应时只复述情绪、不评判、不给建议，鼓励用户继续表达。",
            systemPromptEn: "You are a neutral Rogerian listener. Reflect emotions back without judgment or advice. Encourage the user to continue expressing themselves.",
            avatarSymbol: "ear",
            isBuiltIn: true,
            sortOrder: 0
        ),
        Persona(
            id: "warmFriend",
            name: String(localized: "persona.warmFriend.name"),
            systemPromptZh: "你是一位温暖、共情、偶尔带点轻幽默的朋友。先共情，再轻轻分享自己的感受，最后留一个开放的问题。",
            systemPromptEn: "You are a warm, empathetic friend with a touch of light humor. Empathize first, share gently, end with an open question.",
            avatarSymbol: "heart",
            isBuiltIn: true,
            sortOrder: 1
        ),
        Persona(
            id: "wiseMentor",
            name: String(localized: "persona.wiseMentor.name"),
            systemPromptZh: "你是一位智慧的导师，引用东西方哲学帮用户反思情绪与处境。语气克制，引文克制，问题精准。",
            systemPromptEn: "You are a wise mentor drawing from Eastern and Western philosophy. Restrained tone, sparing quotations, precise questions.",
            avatarSymbol: "books.vertical",
            isBuiltIn: true,
            sortOrder: 2
        ),
        Persona(
            id: "mirror",
            name: String(localized: "persona.mirror.name"),
            systemPromptZh: "你是一面反思镜，不拟人。用凝练的语言把用户写的内容重述一遍，再追加一两个澄清式问题。不评价、不安慰。",
            systemPromptEn: "You are a reflection mirror, not personified. Restate the user's writing succinctly, then add one or two clarifying questions. No evaluation, no comfort.",
            avatarSymbol: "circle.dashed",
            isBuiltIn: true,
            sortOrder: 3
        )
    ] }
}
