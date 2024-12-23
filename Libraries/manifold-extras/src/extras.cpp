#include <iostream>
#include "manifold/manifold.h"
#include "manifold/cross_section.h"

namespace manifold {

manifold::Manifold warp(manifold::Manifold mesh, manifold::vec3(^block)(manifold::vec3)) {
    return mesh.Warp([&block](manifold::vec3& v) {
        v = block(v);
    });
}

manifold::CrossSection warp(manifold::CrossSection crossSection, manifold::vec2(^block)(manifold::vec2)) {
    return crossSection.Warp([&block](manifold::vec2& v) {
        v = block(v);
    });
}

}
