import Foundation

// MARK: - Supporting Types

/**
 Error constants thrown by the Node class when exceptional circumstances are encountered.
 */
public enum NodeError: LocalizedError {
  /**
   Typically thrown when you attempt a branch-specific operation on a leaf node or vice-versa. The
   associated string provides more specific information.
   */
  case invalidOperation(detail: String)
}
