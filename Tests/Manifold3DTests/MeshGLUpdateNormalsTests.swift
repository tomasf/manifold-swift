import Testing
@testable import Manifold3D

@Test func `updateNormals preserves mesh dimensions`() {
    let source: TestManifold = .sphere(radius: 1.0, segmentCount: 32)
        .calculateNormals(channelIndex: 3)
    let mesh = source.meshGL(normalChannelIndex: 3)

    let updated = mesh.updateNormals(channelIndex: 3)

    #expect(updated.triangleCount == mesh.triangleCount)
    #expect(updated.vertexCount == mesh.vertexCount)
    #expect(updated.propertyCount == mesh.propertyCount)
}

@Test func `updateNormals is idempotent`() {
    // After the first call, run metadata is cleared, so a second call must
    // leave the property data unchanged.
    let source: TestManifold = .sphere(radius: 1.0, segmentCount: 16)
        .calculateNormals(channelIndex: 3)
    let once = source.meshGL(normalChannelIndex: 3).updateNormals(channelIndex: 3)
    let twice = once.updateNormals(channelIndex: 3)

    #expect(once.vertexProperties == twice.vertexProperties)
}
