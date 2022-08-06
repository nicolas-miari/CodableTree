import Foundation

// MARK: - Codable, Initializers, and Stored Properties

/**
 Represents either a branch or a leaf node in a file system-like tree hierarchy.

 Nodes can either be of branch (folder) or leaf (file) type. The branch type nodes can contain other
 nodes as children, but the leaf nodes instead store an associated string value. The meaning of this
 string value is client-specific, but one possible use is to store a unique object ID, and have a
 separate "object provider" component that maps the IDs to the actual instances of the objects
 represented in the hierarchy. This design makes the node implementation "payload agnostic", and
 therefore makes serialization (conformance to Codable) of a whole node tree possible.
 */
public class Node: Codable {

  /**
   The name of the node, for display purposes.

   Although this is a user-defined value does not affect the structure of a tree, nodes with
   different names will always compare as unequal.
   */
  public var name: String

  /**
   The parent node in the tree hierarchy (the parent is always a branch type node).

   This value is ignored when comparing nodes (to avoid infinite recursion).
   */
  public internal(set) var parent: Node?

  /**
   Specified the type of node (branch or leaf), and provides access to its contents (children or
   payload, respectively).
   */
  internal var nodeType: NodeType

  /**
   Constants specifying the two possible types of nodes in a tree.
   */
  internal enum NodeType {
    /**
     Node type of a **leaf** node. The associated value is the payload string.

     To decouple the Node implementation from any specific contained type and make encoding easier,
     the payload is a String instead of an object of some parameterized type. The client code would
     typically store some sort of custom object identifier in this string, and use a separate object
     provider to retrieve the actual object represented by the node on demand.
     */
    case leaf(payload: String)

    /**
     Node type of a **branch** node. The associated type is an array of child nodes, each of which
     can be either leaf or branch.
     */
    case branch(children: [Node])
  }

  /**
   Creates a **branch** node with the specified name and child nodes.

   The child nodes are first removed from their previous parent.
   */
  public init(name: String, children: [Node] = []) {
    self.name = name
    self.nodeType = .branch(children: children)
    children.forEach {
      $0.removeFromParent()
      $0.parent = self
    }
  }

  /**
   Creates a **leaf** node with the specified name and payload (value).
   */
  public init(name: String, payload: String) {
    self.name = name
    self.nodeType = .leaf(payload: payload)
  }

  // MARK: - Coding Support

  private enum CodingKeys: String, CodingKey {
    case name
    case content
  }

  public required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    name = try values.decode(String.self, forKey: .name)

    do {
      // First, assume the node is of branch type and attempt to decode its children...
      let children = try values.decode([Node].self, forKey: .content)
      nodeType = .branch(children: children)
      children.forEach { $0.parent = self }

    } catch {
      // ...if that fails, assume it's a leaf instead, and attempt to decode its payload. If that
      // too fails, assume corrupted data and throw the error forward.
      let payload = try values.decode(String.self, forKey: .content)
      nodeType = .leaf(payload: payload)
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)

    switch nodeType {
    case .leaf(let payload):
      try container.encode(payload, forKey: .content)
    case .branch(let children):
      try container.encode(children, forKey: .content)
    }
  }
}
