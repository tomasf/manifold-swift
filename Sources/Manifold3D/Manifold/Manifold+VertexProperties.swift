import Foundation
import ManifoldCPP
import ManifoldBridge

public extension Manifold {
    func setProperties(channelCount: Int, getter function: @escaping (_ position: Vector, _ oldProperties: [Double]) -> [Double]) -> Self {
        let oldCount = propertyCount
        return Self(bridge.SetProperties(mesh, .init(channelCount)) { newProps, position, oldProps in
            let props = function(.init(position), Array(UnsafeBufferPointer(start: oldProps, count: oldCount)))
            _ = UnsafeMutableBufferPointer(start: newProps, count: channelCount)
                .update(from: props)
        })
    }

    func calculateNormals(channelIndex: Int, minSharpAngle: Double = 60) -> Self {
        Self(mesh.CalculateNormals(Int32(channelIndex), minSharpAngle))
    }

    func calculateCurvature(gaussianChannelIndex: Int, meanChannelIndex: Int) -> Self {
        Self(mesh.CalculateCurvature(Int32(gaussianChannelIndex), Int32(meanChannelIndex)))
    }
}
