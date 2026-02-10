import Foundation

enum CSSPropertyKey: String, Codable, CaseIterable, Sendable {
    // Layout
    case display
    case flexDirection = "flex-direction"
    case flexWrap = "flex-wrap"
    case justifyContent = "justify-content"
    case alignItems = "align-items"
    case alignContent = "align-content"
    case alignSelf = "align-self"
    case flex
    case flexGrow = "flex-grow"
    case flexShrink = "flex-shrink"
    case flexBasis = "flex-basis"
    case gridTemplateColumns = "grid-template-columns"
    case gridTemplateRows = "grid-template-rows"
    case gridColumn = "grid-column"
    case gridRow = "grid-row"
    case gap
    case rowGap = "row-gap"
    case columnGap = "column-gap"
    case gridAutoFlow = "grid-auto-flow"
    case gridAutoColumns = "grid-auto-columns"
    case gridAutoRows = "grid-auto-rows"

    // Spacing
    case marginTop = "margin-top"
    case marginRight = "margin-right"
    case marginBottom = "margin-bottom"
    case marginLeft = "margin-left"
    case paddingTop = "padding-top"
    case paddingRight = "padding-right"
    case paddingBottom = "padding-bottom"
    case paddingLeft = "padding-left"

    // Size
    case width
    case height
    case minWidth = "min-width"
    case minHeight = "min-height"
    case maxWidth = "max-width"
    case maxHeight = "max-height"

    // Position
    case position
    case top
    case right
    case bottom
    case left
    case zIndex = "z-index"

    // Typography
    case fontFamily = "font-family"
    case fontSize = "font-size"
    case fontWeight = "font-weight"
    case fontStyle = "font-style"
    case lineHeight = "line-height"
    case letterSpacing = "letter-spacing"
    case textAlign = "text-align"
    case textDecoration = "text-decoration"
    case textTransform = "text-transform"
    case whiteSpace = "white-space"
    case wordBreak = "word-break"
    case color

    // Background
    case backgroundColor = "background-color"
    case backgroundImage = "background-image"
    case backgroundSize = "background-size"
    case backgroundPosition = "background-position"
    case backgroundRepeat = "background-repeat"

    // Border
    case borderTopWidth = "border-top-width"
    case borderRightWidth = "border-right-width"
    case borderBottomWidth = "border-bottom-width"
    case borderLeftWidth = "border-left-width"
    case borderTopStyle = "border-top-style"
    case borderRightStyle = "border-right-style"
    case borderBottomStyle = "border-bottom-style"
    case borderLeftStyle = "border-left-style"
    case borderTopColor = "border-top-color"
    case borderRightColor = "border-right-color"
    case borderBottomColor = "border-bottom-color"
    case borderLeftColor = "border-left-color"
    case borderTopLeftRadius = "border-top-left-radius"
    case borderTopRightRadius = "border-top-right-radius"
    case borderBottomRightRadius = "border-bottom-right-radius"
    case borderBottomLeftRadius = "border-bottom-left-radius"

    // Effects
    case opacity
    case boxShadow = "box-shadow"
    case textShadow = "text-shadow"
    case transform
    case transition
    case overflow
    case overflowX = "overflow-x"
    case overflowY = "overflow-y"
    case cursor
    case pointerEvents = "pointer-events"
    case userSelect = "user-select"
    case objectFit = "object-fit"
    case objectPosition = "object-position"

    // Custom
    case custom
}
