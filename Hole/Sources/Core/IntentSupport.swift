import Foundation
import SwiftData

@MainActor
enum IntentSupport {
    static func sharedContainer() throws -> ModelContainer {
        ModelSchema.makeContainer()
    }
}
