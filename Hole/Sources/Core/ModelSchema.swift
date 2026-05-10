import Foundation
import SwiftData

enum ModelSchema {
    static let allModels: [any PersistentModel.Type] = [
        Entry.self,
        Tag.self,
        VoiceAttachment.self,
        ImageAttachment.self,
        Persona.self,
        Conversation.self,
        Message.self,
        UsageEvent.self
    ]

    @MainActor
    static func makeContainer(inMemory: Bool = false) -> ModelContainer {
        let schema = Schema(allModels)
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            seedBuiltInPersonasIfNeeded(in: container.mainContext)
            return container
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    @MainActor
    private static func seedBuiltInPersonasIfNeeded(in context: ModelContext) {
        let existing = (try? context.fetch(FetchDescriptor<Persona>())) ?? []
        let existingIDs = Set(existing.map(\.id))
        for seed in Persona.makeBuiltInSeeds() where !existingIDs.contains(seed.id) {
            context.insert(seed)
        }
        try? context.save()
    }
}
