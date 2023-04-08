// This file contains experimental flags that may not be production ready yet,
// but that we want to be able to easily flip as well as run on CI.
// Any flag you see here can be flipped with the `-D` CLI argument.
// For example, if you want to enable EXPERIMENT_MY_COOL_FEATURE, compile with -DEXPERIMENT_MY_COOL_FEATURE

// This whole file is commented out right now, but when the time comes for more experiments, feel free to uncomment it.

/*

// Change 515 to the version you want to enable the experiments on.
#if DM_VERSION < 515

// You can't X-macro custom names :(
#ifdef EXPERIMENT_515_MY_EXPERIMENT
#warn EXPERIMENT_515_MY_EXPERIMENT is only available on 515+
#undef EXPERIMENT_515_MY_EXPERIMENT
#endif

#elif defined(UNIT_TESTS)

#define EXPERIMENT_515_MY_EXPERIMENT

#endif

// Change this to the unannounced version of BYOND.
#if DM_VERSION >= 516
#error "Remove all 515 experiments"
#endif

*/
