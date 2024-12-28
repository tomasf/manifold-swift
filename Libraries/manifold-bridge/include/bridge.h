#include "manifold/manifold.h"

namespace bridge {
manifold::Manifold Warp(const manifold::Manifold& mesh, void(^block)(manifold::vec3&));
manifold::CrossSection Warp(const manifold::CrossSection& crossSection, void(^block)(manifold::vec2&));

uint64_t GetFaceID(const manifold::MeshGL64& mesh, uint64_t index);

using i64vec3 = manifold::la::vec<uint64_t, 3>;
}
