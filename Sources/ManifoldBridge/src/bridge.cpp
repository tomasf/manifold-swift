#include <iostream>
#include "manifold/manifold.h"
#include "manifold/cross_section.h"

namespace bridge {

// These thin methods exist to bridge between Swift closures and std::function, which does not work automatically yet

manifold::Manifold Warp(const manifold::Manifold& mesh, void(^block)(manifold::vec3&)) {
    return mesh.Warp(block);
}

manifold::CrossSection Warp(const manifold::CrossSection& crossSection, void(^block)(manifold::vec2&)) {
    return crossSection.Warp(block);
}

manifold::Manifold SetProperties(const manifold::Manifold manifold, int numProp, void(^block)(double *newProp, manifold::vec3 position, const double *oldProp)) {
    return manifold.SetProperties(numProp, block);
}

manifold::Manifold LevelSet(double(^block)(manifold::vec3),
                            manifold::Box bounds,
                            double edgeLength,
                            double level,
                            double tolerance,
                            bool canParallel) {
    return manifold::Manifold::LevelSet(block, bounds, edgeLength, level, tolerance, canParallel);
}

} // end namespace
