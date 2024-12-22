#include <iostream>
#include "manifold/manifold.h"

manifold::Manifold warpManifold(manifold::Manifold mesh, manifold::vec3(^block)(manifold::vec3)) {
    return mesh.Warp([&block](manifold::vec3& v) {
        v = block(v);
    });
}
