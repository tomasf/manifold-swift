import ManifoldCPP

public struct Mesh {
    internal let mesh: manifold.Manifold

    internal init(_ mesh: manifold.Manifold) {
        self.mesh = mesh
    }
}

public extension Mesh {
    static func compose(meshes: [Mesh]) -> Mesh {
        Self(manifold.Manifold.Compose(.init(meshes.map(\.mesh))))
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

    var originalID: Int? {
        let id = mesh.OriginalID()
        return id == -1 ? nil : Int(id)
    }

    func asOriginal() -> Mesh {
        Mesh(mesh.AsOriginal())
    }

    func meshData() -> any MeshData {
        mesh.GetMeshGL64()
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

    static func boolean(_ op: BooleanOperation, with children: [Mesh]) -> Self {
        Self(manifold.Manifold.BatchBoolean(.init(children.map(\.mesh)), op.manifoldOp))
    }
}

public extension Mesh {
    func boolean(_ op: BooleanOperation, with other: Mesh) -> Self {
        Self(mesh.Boolean(other.mesh, op.manifoldOp))
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

public extension Mesh {
    func split(by cutter: Mesh) -> (Mesh, Mesh) {
        let results = mesh.Split(cutter.mesh)
        return (Mesh(results.first), Mesh(results.second))
    }

    func split(by plane: Vector3, originOffset: Double) -> (Mesh, Mesh) {
        let results = mesh.SplitByPlane(plane.vec3, originOffset)
        return (Mesh(results.first), Mesh(results.second))
    }

    func trim(by plane: Vector3, originOffset: Double) -> Mesh {
        Mesh(mesh.TrimByPlane(plane.vec3, originOffset))
    }
}

public extension Mesh {
    func projection() -> CrossSection {
        CrossSection(manifold.CrossSection(mesh.Project(), .Positive))
    }
    
    func slice(at z: Double) -> CrossSection {
        CrossSection(manifold.CrossSection(mesh.Slice(z), .Positive))
    }
}

public extension Mesh {
    enum CircularSegments {
        case defaults
        case fixed (count: Int)
        case dynamic (minAngle: Double, minEdgeLength: Double)
    }

    static func setCircleQuality(_ segments: CircularSegments) {
        switch segments {
        case .defaults:
            manifold.Quality.ResetToDefaults()

        case .fixed(count: let count):
            manifold.Quality.SetCircularSegments(Int32(count))

        case .dynamic(minAngle: let minAngle, minEdgeLength: let minEdgeLength):
            manifold.Quality.SetCircularSegments(0)
            manifold.Quality.SetMinCircularAngle(minAngle)
            manifold.Quality.SetMinCircularEdgeLength(minEdgeLength)
        }
    }

    static func circularSegmentCount(for radius: Double) -> Int {
        Int(manifold.Quality.GetCircularSegments(radius))
    }
}
