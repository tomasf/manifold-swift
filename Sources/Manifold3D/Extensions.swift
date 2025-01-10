import Foundation

internal extension Sequence {
    func paired() -> [(Element, Element)] {
        .init(zip(self, dropFirst()))
    }
}
