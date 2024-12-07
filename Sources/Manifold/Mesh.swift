import ManifoldCPP

public struct Mesh {
    internal let mesh: manifold.Manifold

    internal init(_ mesh: manifold.Manifold) {
        self.mesh = mesh
    }
}

public extension Mesh {
    var isEmpty: Bool {
        mesh.IsEmpty()
    }

    var boundingBox: (any Vector3, any Vector3) {
        let box = mesh.BoundingBox()
        return (box.min, box.max)
    }

    var vertexCount: Int {
        mesh.NumVert()
    }

    var edgeCount: Int {
        mesh.NumEdge()
    }

    var triangleCount: Int {
        mesh.NumTri()
    }

    var surfaceArea: Double {
        mesh.SurfaceArea()
    }

    var volume: Double {
        mesh.Volume()
    }
}

public extension Mesh {
    static var empty: Self {
        Self(manifold.Manifold())
    }

    static func tetrahedron() -> Self {
        Self(manifold.Manifold.Tetrahedron())
    }

    static func sphere(radius: Double, segmentCount: Int) -> Self {
        Self(manifold.Manifold.Sphere(radius, Int32(segmentCount)))
    }

    static func cylinder(height: Double, bottomRadius: Double, topRadius: Double, segmentCount: Int) -> Self {
        Self(manifold.Manifold.Cylinder(height, bottomRadius, topRadius, Int32(segmentCount)))
    }

    static func cube(size: any Vector3) -> Self {
        Self(manifold.Manifold.Cube(size.vec3))
    }
}

public extension Mesh {
    func boolean(_ op: BooleanOperation, with other: Mesh) -> Self {
        Self(mesh.Boolean(other.mesh, op.manifoldOp))
    }

    func batchBoolean(_ op: BooleanOperation, with other: [Mesh]) -> Self {
        Self(manifold.Manifold.BatchBoolean(.init(other.map(\.mesh)), op.manifoldOp))
    }

    func decompose() -> [Mesh] {
        mesh.Decompose().map(Mesh.init)
    }

    func transform(_ transform: any Matrix3x4) -> Self {
        Self(mesh.Transform(transform.mat3x4))
    }

    func translate(_ translation: any Vector3) -> Self {
        Self(mesh.Translate(translation.vec3))
    }

    func scale(_ scale: any Vector3) -> Self {
        Self(mesh.Scale(scale.vec3))
    }

    func rotate(_ rotation: any Vector3) -> Self {
        Self(mesh.Rotate(rotation.x, rotation.y, rotation.z))
    }
    
    func hull() -> Self {
        Self(mesh.Hull())
    }
}
