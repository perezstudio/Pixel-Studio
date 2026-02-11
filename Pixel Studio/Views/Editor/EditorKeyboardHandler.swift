import AppKit
import SwiftData

/// Handles keyboard shortcuts for the editor via NSEvent local monitoring.
/// Installed on EditorSplitViewController and dispatches to EditorState + ModelContext.
final class EditorKeyboardHandler {
    private let project: Project
    private let editorState: EditorState
    private let modelContext: ModelContext
    private var monitor: Any?

    init(project: Project, editorState: EditorState, modelContext: ModelContext) {
        self.project = project
        self.editorState = editorState
        self.modelContext = modelContext
    }

    func install() {
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return event }
            if self.handleKeyEvent(event) {
                return nil // consumed
            }
            return event // pass through
        }
    }

    func uninstall() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
        }
        monitor = nil
    }

    // MARK: - Event Dispatch

    private func handleKeyEvent(_ event: NSEvent) -> Bool {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let key = event.keyCode

        // Don't intercept if editing text inline
        if editorState.editingNodeID != nil || editorState.editingPageID != nil {
            return false
        }

        // Don't intercept if a text field/editor is first responder
        if let firstResponder = NSApp.keyWindow?.firstResponder,
           firstResponder is NSTextView || firstResponder is NSTextField {
            return false
        }

        // Cmd+Z — Undo
        if flags == .command, event.charactersIgnoringModifiers == "z" {
            return handleUndo()
        }

        // Cmd+Shift+Z — Redo
        if flags == [.command, .shift], event.charactersIgnoringModifiers == "z" {
            return handleRedo()
        }

        // Cmd+C — Copy
        if flags == .command, event.charactersIgnoringModifiers == "c" {
            return handleCopy()
        }

        // Cmd+X — Cut
        if flags == .command, event.charactersIgnoringModifiers == "x" {
            return handleCut()
        }

        // Cmd+V — Paste
        if flags == .command, event.charactersIgnoringModifiers == "v" {
            return handlePaste()
        }

        // Cmd+D — Duplicate
        if flags == .command, event.charactersIgnoringModifiers == "d" {
            return handleDuplicate()
        }

        // Cmd+G — Group in div
        if flags == .command, event.charactersIgnoringModifiers == "g" {
            return handleGroupInDiv()
        }

        // Cmd+A — Select all
        if flags == .command, event.charactersIgnoringModifiers == "a" {
            return handleSelectAll()
        }

        // Delete / Backspace
        if flags.isEmpty, (key == 51 || key == 117) { // 51=backspace, 117=forward delete
            return handleDelete()
        }

        return false
    }

    // MARK: - Undo / Redo

    private func handleUndo() -> Bool {
        guard let undoManager = modelContext.undoManager, undoManager.canUndo else { return false }
        undoManager.undo()
        return true
    }

    private func handleRedo() -> Bool {
        guard let undoManager = modelContext.undoManager, undoManager.canRedo else { return false }
        undoManager.redo()
        return true
    }

    // MARK: - Delete

    private func handleDelete() -> Bool {
        let idsToDelete = editorState.selectedNodeIDs
        guard !idsToDelete.isEmpty, let page = selectedPage else { return false }

        for id in idsToDelete {
            if let node = findNode(id: id, in: page.rootNodes) {
                modelContext.delete(node)
            }
        }
        editorState.clearNodeSelection()
        return true
    }

    // MARK: - Copy

    private func handleCopy() -> Bool {
        guard let nodeID = editorState.selectedNodeID,
              let page = selectedPage,
              let node = findNode(id: nodeID, in: page.rootNodes) else { return false }

        editorState.clipboardNodeSnapshot = NodeSnapshot(from: node)
        return true
    }

    // MARK: - Cut

    private func handleCut() -> Bool {
        guard let nodeID = editorState.selectedNodeID,
              let page = selectedPage,
              let node = findNode(id: nodeID, in: page.rootNodes) else { return false }

        editorState.clipboardNodeSnapshot = NodeSnapshot(from: node)
        editorState.clearNodeSelection()
        modelContext.delete(node)
        return true
    }

    // MARK: - Paste

    private func handlePaste() -> Bool {
        guard let snapshot = editorState.clipboardNodeSnapshot else { return false }

        let newNode = snapshot.materialize()

        if let nodeID = editorState.selectedNodeID,
           let page = selectedPage,
           let target = findNode(id: nodeID, in: page.rootNodes),
           target.nodeType.canHaveChildren {
            newNode.sortOrder = target.children.count
            newNode.parent = target
            target.children.append(newNode)
            target.isExpanded = true
        } else if let page = selectedPage {
            newNode.sortOrder = page.rootNodes.count
            newNode.page = page
            page.rootNodes.append(newNode)
        } else {
            return false
        }

        editorState.selectNode(newNode.id)
        return true
    }

    // MARK: - Duplicate

    private func handleDuplicate() -> Bool {
        guard let nodeID = editorState.selectedNodeID,
              let page = selectedPage,
              let node = findNode(id: nodeID, in: page.rootNodes) else { return false }

        let snapshot = NodeSnapshot(from: node)
        let duplicate = snapshot.materialize()
        duplicate.name = (node.name ?? node.nodeType.displayName) + " Copy"

        if let parent = node.parent {
            duplicate.sortOrder = parent.children.count
            duplicate.parent = parent
            parent.children.append(duplicate)
        } else {
            duplicate.sortOrder = page.rootNodes.count
            duplicate.page = page
            page.rootNodes.append(duplicate)
        }

        editorState.selectNode(duplicate.id)
        return true
    }

    // MARK: - Group in Div

    private func handleGroupInDiv() -> Bool {
        guard let nodeID = editorState.selectedNodeID,
              let page = selectedPage,
              let node = findNode(id: nodeID, in: page.rootNodes) else { return false }

        let wrapper = Node(nodeType: .div, name: "Group")

        if let parent = node.parent {
            wrapper.sortOrder = node.sortOrder
            wrapper.parent = parent
            parent.children.append(wrapper)
            node.parent = wrapper
            node.sortOrder = 0
            wrapper.children.append(node)
            parent.children.removeAll { $0.id == node.id && $0.parent?.id != wrapper.id }
        } else {
            wrapper.sortOrder = node.sortOrder
            wrapper.page = page
            page.rootNodes.append(wrapper)
            node.page = nil
            node.parent = wrapper
            node.sortOrder = 0
            wrapper.children.append(node)
            page.rootNodes.removeAll { $0.id == node.id && $0.page != nil }
        }

        editorState.selectNode(wrapper.id)
        return true
    }

    // MARK: - Select All

    private func handleSelectAll() -> Bool {
        guard let page = selectedPage else { return false }

        var allIDs: Set<UUID> = []
        collectNodeIDs(page.rootNodes, into: &allIDs)
        editorState.selectedNodeIDs = allIDs
        editorState.selectedNodeID = allIDs.first
        return true
    }

    // MARK: - Helpers

    private var selectedPage: Page? {
        guard let pageID = editorState.selectedPageID else { return nil }
        return project.pages.first { $0.id == pageID }
    }

    private func findNode(id: UUID, in nodes: [Node]) -> Node? {
        for node in nodes {
            if node.id == id { return node }
            if let found = findNode(id: id, in: node.children) { return found }
        }
        return nil
    }

    private func collectNodeIDs(_ nodes: [Node], into ids: inout Set<UUID>) {
        for node in nodes {
            ids.insert(node.id)
            collectNodeIDs(node.children, into: &ids)
        }
    }
}
