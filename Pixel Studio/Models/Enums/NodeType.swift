import Foundation

enum NodeType: String, Codable, CaseIterable, Sendable {
    // Layout
    case div, section, header, footer, nav, main, aside, article

    // Text
    case h1, h2, h3, h4, h5, h6, p, span, blockquote, pre, code

    // Media
    case img, video, audio, iframe

    // Form
    case form, input, textarea, select, option, button, label, fieldset, legend

    // List
    case ul, ol, li

    // Table
    case table, thead, tbody, tfoot, tr, th, td

    // Interactive
    case a, details, summary

    // Semantic
    case figure, figcaption, mark, time, abbr, hr, br

    // SvelteKit specific
    case slot

    var category: BlockCategory {
        switch self {
        case .div, .section, .header, .footer, .nav, .main, .aside, .article:
            return .layout
        case .h1, .h2, .h3, .h4, .h5, .h6, .p, .span, .blockquote, .pre, .code:
            return .text
        case .img, .video, .audio, .iframe:
            return .media
        case .form, .input, .textarea, .select, .option, .button, .label, .fieldset, .legend:
            return .form
        case .ul, .ol, .li:
            return .list
        case .table, .thead, .tbody, .tfoot, .tr, .th, .td:
            return .table
        case .a, .details, .summary:
            return .interactive
        case .figure, .figcaption, .mark, .time, .abbr, .hr, .br, .slot:
            return .semantic
        }
    }

    var displayName: String {
        switch self {
        case .div:         return "Div"
        case .section:     return "Section"
        case .header:      return "Header"
        case .footer:      return "Footer"
        case .nav:         return "Nav"
        case .main:        return "Main"
        case .aside:       return "Aside"
        case .article:     return "Article"
        case .h1:          return "Heading 1"
        case .h2:          return "Heading 2"
        case .h3:          return "Heading 3"
        case .h4:          return "Heading 4"
        case .h5:          return "Heading 5"
        case .h6:          return "Heading 6"
        case .p:           return "Paragraph"
        case .span:        return "Span"
        case .blockquote:  return "Blockquote"
        case .pre:         return "Preformatted"
        case .code:        return "Code"
        case .img:         return "Image"
        case .video:       return "Video"
        case .audio:       return "Audio"
        case .iframe:      return "iFrame"
        case .form:        return "Form"
        case .input:       return "Input"
        case .textarea:    return "Text Area"
        case .select:      return "Select"
        case .option:      return "Option"
        case .button:      return "Button"
        case .label:       return "Label"
        case .fieldset:    return "Fieldset"
        case .legend:      return "Legend"
        case .ul:          return "Unordered List"
        case .ol:          return "Ordered List"
        case .li:          return "List Item"
        case .table:       return "Table"
        case .thead:       return "Table Head"
        case .tbody:       return "Table Body"
        case .tfoot:       return "Table Foot"
        case .tr:          return "Table Row"
        case .th:          return "Table Header"
        case .td:          return "Table Cell"
        case .a:           return "Link"
        case .details:     return "Details"
        case .summary:     return "Summary"
        case .figure:      return "Figure"
        case .figcaption:  return "Figcaption"
        case .mark:        return "Mark"
        case .time:        return "Time"
        case .abbr:        return "Abbreviation"
        case .hr:          return "Horizontal Rule"
        case .br:          return "Line Break"
        case .slot:        return "Slot"
        }
    }

    var canHaveChildren: Bool {
        switch self {
        case .img, .input, .hr, .br:
            return false
        default:
            return true
        }
    }

    var isSelfClosing: Bool {
        switch self {
        case .img, .input, .hr, .br:
            return true
        default:
            return false
        }
    }

    var systemImage: String {
        switch self {
        case .div:         return "rectangle"
        case .section:     return "rectangle.split.3x1"
        case .header:      return "rectangle.topthird.inset.filled"
        case .footer:      return "rectangle.bottomthird.inset.filled"
        case .nav:         return "sidebar.leading"
        case .main:        return "rectangle.center.inset.filled"
        case .aside:       return "sidebar.trailing"
        case .article:     return "doc.text"
        case .h1, .h2, .h3, .h4, .h5, .h6:
            return "textformat.size"
        case .p:           return "text.alignleft"
        case .span:        return "textformat"
        case .blockquote:  return "text.quote"
        case .pre, .code:  return "chevron.left.forwardslash.chevron.right"
        case .img:         return "photo"
        case .video:       return "play.rectangle"
        case .audio:       return "speaker.wave.2"
        case .iframe:      return "macwindow"
        case .form:        return "doc.plaintext"
        case .input:       return "character.cursor.ibeam"
        case .textarea:    return "text.alignleft"
        case .select:      return "chevron.up.chevron.down"
        case .option:      return "list.bullet"
        case .button:      return "button.horizontal"
        case .label:       return "tag"
        case .fieldset:    return "rectangle.dashed"
        case .legend:      return "text.badge.star"
        case .ul:          return "list.bullet"
        case .ol:          return "list.number"
        case .li:          return "list.bullet.indent"
        case .table:       return "tablecells"
        case .thead, .tbody, .tfoot:
            return "tablecells"
        case .tr:          return "rectangle.split.1x2"
        case .th, .td:     return "rectangle"
        case .a:           return "link"
        case .details:     return "chevron.right"
        case .summary:     return "text.line.first.and.arrowtriangle.forward"
        case .figure:      return "photo.on.rectangle"
        case .figcaption:  return "text.below.photo"
        case .mark:        return "highlighter"
        case .time:        return "clock"
        case .abbr:        return "textformat.abc"
        case .hr:          return "minus"
        case .br:          return "return"
        case .slot:        return "rectangle.dashed.badge.record"
        }
    }
}
