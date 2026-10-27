#include "manifold/manifold.h"

/// Initialize TBB QoS settings for optimal performance on Apple Silicon.
void initializeQoS();

namespace bridge {
manifold::Manifold Warp(const manifold::Manifold& mesh, void(^block)(manifold::vec3&));
manifold::CrossSection Warp(const manifold::CrossSection& crossSection, void(^block)(manifold::vec2&));

manifold::Manifold SetProperties(const manifold::Manifold manifold, int numProp, void(^block)(double *newProp, manifold::vec3 position, const double *oldProp));

manifold::Manifold LevelSet(double(^block)(manifold::vec3),
                            manifold::Box bounds,
                            double edgeLength,
                            double level,
                            double tolerance,
                            bool canParallel);

// ExecutionContext copies share their state, so these take the context by value. That lets Swift
// call them on a context it never mutates, while another thread cancels it.
void Cancel(manifold::ExecutionContext context);
manifold::Manifold FromMeshGL(manifold::ExecutionContext context, const manifold::MeshGL64& mesh);
manifold::Manifold Smooth(manifold::ExecutionContext context,
                          const manifold::MeshGL64& mesh,
                          const std::vector<manifold::Smoothness>& sharpenedEdges);
manifold::Manifold LevelSet(manifold::ExecutionContext context,
                            double(^block)(manifold::vec3),
                            manifold::Box bounds,
                            double edgeLength,
                            double level,
                            double tolerance,
                            bool canParallel);

using ivec64 = manifold::la::vec<uint64_t, 3>;
}
