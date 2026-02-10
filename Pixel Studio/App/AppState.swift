import SwiftUI

@Observable
final class AppState {
    var openProjectIDs: Set<UUID> = []
    var defaultBreakpointWidth: Int = 1280
}
