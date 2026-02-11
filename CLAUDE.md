# Pixel Studio

A native macOS visual website builder that generates SvelteKit projects.

## Tech Stack

- **UI:** SwiftUI (components) + AppKit (NSSplitViewController for editor layout)
- **Persistence:** SwiftData (local) + CloudKit (backup)
- **Preview:** WKWebView rendering live HTML from visual tree
- **Code Generation:** SvelteKit project output
- **Minimum Target:** macOS 26.2, Xcode 26.2

## Key Constraints

- **NO** SwiftUI `List`, `Toolbar`, or `NavigationSplitView` — all custom implementations
- AppKit `NSSplitViewController` for the 3-pane editor (sidebar/content/inspector)
- SwiftUI for all UI within those panes via `NSHostingController`
- The canvas preview renders raw HTML/CSS — NOT compiled SvelteKit code
- SvelteKit code generation is a separate output step (Git tab)
- App Sandbox enabled — use security-scoped bookmarks for file access
- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` (Swift 6 concurrency)

## Architecture

### Windows
- **Start Window** (`id: "start"`) — two-column: branding/actions (left), project list (right)
- **Editor Window** (`WindowGroup for: UUID.self`) — per-project, no title bar, no safe area

### Editor Layout (AppKit NSSplitView)
- **Sidebar** (left, collapsible): custom toolbar + tab bar (Pages/Navigator/Assets/Components)
- **Content** (center): custom toolbar + canvas with WKWebView live preview
- **Inspector** (right, collapsible): custom toolbar + tab bar (Style/Settings/Git)

### Data Models (SwiftData)
- `Project` → has many `Page`, `DesignToken`, `Component`, `Asset`, `Breakpoint`
- `Page` → has many root `Node` (route/page mapping)
- `Node` → recursive tree (parent/children), has many `StyleProperty`, many-to-many `DesignToken`
- `StyleProperty` → flat record: one CSS property per breakpoint per node
- `DesignToken` → reusable style values, become CSS custom properties (`--token-name`)

### Key Files
- `Pixel_StudioApp.swift` — app entry point, dual-window scene, SwiftData container
- `EditorSplitViewController.swift` — AppKit NSSplitViewController (3 panes)
- `EditorHostView.swift` — NSViewControllerRepresentable bridge
- `EditorState.swift` — @Observable class for editor selection/UI state
- `Node.swift` — core recursive DOM tree model
- `StyleProperty.swift` — individual CSS property record per node per breakpoint

## Directory Structure

```
Pixel Studio/
  Pixel_StudioApp.swift
  Pixel_Studio.entitlements
  App/                          (AppState, EditorState)
  Models/                       (SwiftData: Project, Page, Node, StyleProperty, etc.)
  Models/Enums/                 (NodeType, CSSPropertyKey, CSSUnit, etc.)
  Models/ValueTypes/            (CSSLength, CSSColor, CSSBoxSides, etc.)
  Views/StartWindow/            (StartWindowView, ProjectList, NewProjectSheet)
  Views/Editor/                 (EditorHostView, EditorSplitViewController)
  Views/Editor/Sidebar/         (SidebarContainer, Pages/, Navigator/, Assets/, Components/)
  Views/Editor/Content/         (ContentContainer, Canvas, BlockInsert, Breakpoints)
  Views/Editor/Inspector/       (InspectorContainer, Style/, Settings/, Git/)
  Views/Shared/                 (CollapsibleSection, LengthInput, BoxSidesEditor, etc.)
  Extensions/                   (Node+StyleHelpers, Color+CSS, etc.)
  Services/HTMLRenderer/        (HTMLRenderService, CSSGenerationService, PreviewServer)
  Services/CodeGeneration/      (SvelteKitGenerator, RouteGenerator, etc.)
  Services/Git/                 (GitService)
  Services/Persistence/         (PersistenceController, CloudKitSyncManager)
  Preview/                      (WebPreviewView, PreviewCoordinator)
  Resources/SvelteKitTemplates/ (package.json.template, etc.)
```

## Implementation Phases

### Phase 1: Foundation — COMPLETED
- [x] Entitlements file + pbxproj update (read-write file access)
- [x] 11 enum types (NodeType, CSSPropertyKey, CSSUnit, BlockCategory, etc.)
- [x] 8 value types (CSSLength, CSSColor, CSSBoxSides, CSSCorners, etc.)
- [x] 8 SwiftData models (Project, Page, Node, StyleProperty, DesignToken, Component, Asset, Breakpoint)
- [x] App entry point rewrite (dual-window, SwiftData container)
- [x] AppState + EditorState
- [x] Start Window views (StartWindowView, ProjectList, ProjectRow, NewProjectSheet)
- [x] Editor shell (EditorSplitViewController, EditorHostView, all 3 pane containers)
- [x] Sidebar tabs (Pages, Navigator, Assets, Components) with basic CRUD
- [x] Inspector toolbar with Style/Settings/Git tabs (placeholders)
- [x] Content toolbar with page name + Run button (placeholder canvas)
- [x] Block insert sheet, asset import sheet, new component sheet
- **Build status:** 0 Swift errors, 0 warnings (codesign fails due to macOS 26.2 toolchain — not code-related)

### Phase 2: Enhanced Editor Shell — COMPLETED
- [x] Drag-and-drop reorder in navigator (nodes can be reparented, pages can be reordered)
- [x] Inline rename (double-click) for pages and nodes (with Escape to cancel)
- [x] Multi-select in navigator (Cmd+click toggle, tracked in selectedNodeIDs)
- [x] Context menu actions: wrap in div/section/article/link, copy/cut/paste, duplicate, toggle visibility/lock, delete
- [x] Root-level drop zone in navigator for moving nodes to page root
- [x] NodeSnapshot clipboard system for copy/paste across nodes
- [x] Page drag reorder with sort order updates
- **Build status:** 0 Swift errors, 0 warnings

### Phase 3: Canvas and Live Preview — COMPLETED
- [x] HTMLRenderService (node tree → HTML document with click-to-select JS, hover highlights, selection outlines)
- [x] CSSGenerationService (styles → CSS with media queries, design token variables, CSS reset)
- [x] PreviewServer (NWListener local HTTP server on auto-assigned port, serves HTML on localhost)
- [x] WebPreviewView (WKWebView NSViewRepresentable with JS bridge — click selects node, hover highlights)
- [x] PreviewCoordinator (@Observable, owns server + render services, regenerates HTML, highlights selection)
- [x] CanvasView (Figma-style artboard with breakpoint label, shadow, zoom via scaleEffect)
- [x] ContentContainerView updated with actual canvas, block insert sheet, empty state
- [x] ContentToolbarView updated with block insert button, breakpoint dropdown, zoom controls
- [x] BreakpointDropdown (menu picker with breakpoint list + edit sheet trigger)
- [x] EditBreakpointsSheet (add/edit/delete breakpoints, inline editing)
- **Build status:** 0 Swift errors, 0 warnings

### Phase 4: Inspector — Style & Settings — TODO
- [ ] Node+StyleHelpers extension (read/write StyleProperty)
- [ ] Shared components: CollapsibleSection, LengthInputField, BoxSidesEditor, ColorPickerField, CustomTokenField
- [ ] Style tab: 10 sections (Styles/Layout/Spacing/Size/Position/Typography/Backgrounds/Borders/Effects/Custom)
- [ ] Settings tab: context-sensitive per node type (image, link, text, form, generic)
- [ ] Design token system (create, apply, manage tokens)

### Phase 5: Code Generation — TODO
- [ ] SvelteKit template resources (package.json, svelte.config.js, etc.)
- [ ] ProjectScaffolder (project skeleton)
- [ ] RouteGenerator (Page → +page.svelte)
- [ ] LayoutGenerator (+layout.svelte with slot)
- [ ] ComponentGenerator (.svelte component files)
- [ ] StylesheetGenerator (app.css with tokens as CSS custom properties)
- [ ] SvelteKitGenerator orchestrator

### Phase 6: Git Integration — TODO
- [ ] GitService (wraps /usr/bin/git via Process)
- [ ] GenerateProjectView (generate button + directory picker)
- [ ] GitDiffView (syntax-highlighted diff)
- [ ] GitCommitView + GitPushView

### Phase 7: CloudKit & Polish — TODO
- [ ] CloudKit entitlements + sync manager
- [ ] Undo/Redo integration with UndoManager
- [ ] Keyboard shortcuts (Cmd+Z, Cmd+C/V/X, Delete, Cmd+D, Cmd+G)
- [ ] Drag-and-drop from block popover
- [ ] Dark mode verification
- [ ] Error handling throughout

## Key Architectural Decisions

1. **AppKit NSSplitViewController** for 3-pane layout — each pane is NSHostingController wrapping SwiftUI
2. **Local HTTP server** (NWListener) for WKWebView preview — enables relative resource loading
3. **StyleProperty as flat SwiftData records** — one record per CSS property per breakpoint per node (simple querying, undo/redo)
4. **HTML preview ≠ SvelteKit** — canvas renders raw HTML/CSS; SvelteKit generation is separate
5. **Security-scoped bookmarks** for persistent file access within sandbox
6. **Design tokens as first-class SwiftData entities** with bidirectional node relationships

## Build Notes

- Uses `PBXFileSystemSynchronizedRootGroup` — files placed in the target directory are auto-included in build (no manual pbxproj edits needed)
- `ENABLE_USER_SELECTED_FILES = readwrite` (upgraded from readonly)
- Bundle ID: `com.perezstudio.Pixel-Studio`
- Development Team: `YPGUL25V6H`
