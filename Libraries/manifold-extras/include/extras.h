#include "manifold/manifold.h"

namespace manifold {
manifold::Manifold warp(manifold::Manifold mesh, manifold::vec3(^block)(manifold::vec3));
manifold::CrossSection warp(manifold::CrossSection crossSection, manifold::vec2(^block)(manifold::vec2));

using i64vec3 = la::vec<uint64_t, 3>;
}
