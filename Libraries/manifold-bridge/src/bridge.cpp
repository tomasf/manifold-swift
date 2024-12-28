#include <iostream>
#include "manifold/manifold.h"
#include "manifold/cross_section.h"

namespace bridge {

// These thin methods exist to bridge between Swift closures and std::function, which does not work automatically yet

manifold::Manifold Warp(const manifold::Manifold& mesh, void(^block)(manifold::vec3&)) {
    return mesh.Warp(block);
}

/*
manifold::Manifold Warp(const manifold::Manifold& mesh, void(^block)(manifold::vec3&)) {
    return mesh.WarpBatch([&block](manifold::VecView<manifold::vec3> vecs) {
        for (manifold::vec3& p : vecs) {
            block(p);
        }
    });
}
*/

manifold::CrossSection Warp(const manifold::CrossSection& crossSection, void(^block)(manifold::vec2&)) {
    return crossSection.Warp(block);
}

}
