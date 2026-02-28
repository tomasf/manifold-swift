#include <iostream>
#include "manifold/manifold.h"
#include "manifold/cross_section.h"

#ifdef __APPLE__
#include <pthread.h>
#include <oneapi/tbb/task_scheduler_observer.h>

namespace {
    // Sets QoS on TBB worker threads to improve scheduling on Apple Silicon.
    // Reduces priority inversion warnings and allows workers to run on P-cores.
    // Called from Swift init methods to register the observer before TBB work begins.
    class AppleQoSObserver : public tbb::task_scheduler_observer {
    public:
        AppleQoSObserver() { observe(true); }
        void on_scheduler_entry(bool is_worker) override {
            if (is_worker) {
                pthread_set_qos_class_self_np(QOS_CLASS_USER_INITIATED, 0);
            }
        }
    };

    pthread_once_t qos_once = PTHREAD_ONCE_INIT;
    void doInitQoS() {
        static AppleQoSObserver observer;
    }
}

void initializeQoS() {
    pthread_once(&qos_once, doInitQoS);
}
#else
void initializeQoS() {}
#endif

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
