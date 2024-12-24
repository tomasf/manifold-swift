#include <iostream>
#include "manifold/manifold.h"
#include "manifold/cross_section.h"

namespace manifold {

// These thin methods exist to bridge between Swift closures and std::function, which does not work automatically yet

manifold::Manifold warp(manifold::Manifold mesh, void(^block)(manifold::vec3&)) {
    return mesh.Warp(block);
}

manifold::CrossSection warp(manifold::CrossSection crossSection, void(^block)(manifold::vec2&)) {
    return crossSection.Warp(block);
}

}
