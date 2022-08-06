import Foundation

// MARK: - Equatable

extension Node: Equatable {

  public static func == (lhs: Node, rhs: Node) -> Bool {
    guard lhs.name == rhs.name else {
      print("Different names: \(lhs.name) vs. \(rhs.name)")
      return false
    }
    switch (lhs.nodeType, rhs.nodeType) {
    case (.leaf, .branch), (.branch, .leaf):
      print("Different types")
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