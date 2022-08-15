import Foundation

// MARK: - Codable, Initializers, and Stored Properties

/**
 Represents either a branch or a leaf node in a file system-like tree hierarchy.

 Nodes can either be of branch (folder) or leaf (file) type. The branch type nodes can contain other nodes as children, but the leaf nodes instead store an associated string value. The meaning of this string value is client-specific, but one possible use is to store a unique object ID, and have a separate "object provider" component that maps the
 IDs to the actual instances of the objects represented in the hierarchy. This design makes
 the node implementation "payload agnostic", and therefore makes serialization (conformance
 to `Codable`) of a whole node tree possible.
 */
public class Node: Codable {

  /**
   A custom, user-defined string for visual identification purposes.
   */
  public var name: String

  /**
   A string used to identify the hierarchical object represented by the node. The mapping between
   this value and the represented object is client-defined.

   This property is optional to allow for "pure container" nodes such as folders in a file system.
   */
  public var value: String?

  /**
   The parent node in the tree hierarchy. This value is ignored when comparing nodes (to avoid
   infinite recursion). Read-only (use insert/remove API to modify tree).
   */
  public internal(set) var parent: Node?

  /**
   The child nodes in the hierarchy. This value is skipped when encoding the node if the array is
   empty, to save space. Read-only (use insert/remove API to modify tree).
    */
  public internal(set) var children: [Node]

  /**
   Creates a new node.
   */
  public init(name: String = "", value: String? = nil, children: [Node] = []) {
    self.value = value
    self.name = name
    self.children = children
    children.forEach {
      $0.removeFromParent()
      $0.parent = self
    }
  }

  // MARK: - Coding Support

  private enum CodingKeys: String, CodingKey {
    case name
    case value
    case children
  }

  public required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    self.value = try values.decodeIfPresent(String.self, forKey: .value)
    self.name = try values.decode(String.self, forKey: .name)

    // Children array is skipped from the JSON if empty, to save space.
    if let children = try values.decodeIfPresent([Node].self, forKey: .children) {
      self.children = children
      children.forEach { $0.parent = self }
    } else {
      self.children = []
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)

    if let value = value {
      try container.encode(value, forKey: .value)
    }
    // Children array is skipped from the JSON if empty, to save space.
    if children.count > 0 {
      try container.encode(children, forKey: .children)
    }
  }
}
