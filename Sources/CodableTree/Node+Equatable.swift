import Foundation

// MARK: - Equatable

extension Node: Equatable {

  public static func == (lhs: Node, rhs: Node) -> Bool {
    guard lhs.name == rhs.name else {
      return false
    }
    guard lhs.value == rhs.value else {
      return false
    }
    /**
     Compare array sizes first, to bail out before performing the more costly member-wise comparison
     of the full arrays (it is possible that `Foundation.Array where Element: Equatable` already has
     this optimization in place, but still...)
     */
    guard lhs.children.count == rhs.children.count else {
      return false
    }
    return lhs.children == rhs.children
  }
}
