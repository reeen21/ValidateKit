import SwiftUI

/// Defines where error messages should be positioned relative to the field.
///
/// Use this enum to control the layout of error messages in `ValidationTextField` and `ValidationSecureField`.
public enum ErrorPosition {
    /// Display errors below the field.
    ///
    /// This is the default position and works well for most form layouts.
    case below
    
    /// Display errors above the field.
    ///
    /// Useful when fields are stacked vertically and you want errors to appear before the field.
    case above
    
    /// Display errors to the trailing side (right in LTR languages, left in RTL).
    ///
    /// Useful for horizontal form layouts where space is limited vertically.
    case trailing
}
