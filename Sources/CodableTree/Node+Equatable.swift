import Foundation

// MARK: - Equatable

extension Node: Equatable {

  public static func == (lhs: Node, rhs: Node) -> Bool {
    guard lhs.name == rhs.name else {
      return false
    }
    switch (lhs.nodeType, rhs.nodeType) {
    case (.leaf, .branch), (.branch, .leaf):
      return false

    case (.leaf(let leftPayload), .leaf(let rightPayload)):
      return leftPayload == rightPayload

    case (.branch(let leftChildren), .branch(let rightChildren)):
      guard leftChildren.count == rightChildren.count else {
        return false
      }
      return leftChildren == rightChildren
    }
  }
}
