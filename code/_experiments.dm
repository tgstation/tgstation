// This file contains experimental flags that may not be production ready yet,
// but that we want to be able to easily flip as well as run on CI.
// Any flag you see here can be flipped with the `-D` CLI argument.
// For example, if you want to enable EXPERIMENT_MY_COOL_FEATURE, compile with -DEXPERIMENT_MY_COOL_FEATURE

// EXPERIMENT_515_QDEL_HARD_REFERENCE
// - Hold a hard reference for qdeleted items, and check ref_count, rather than using refs. Requires 515+.

// EXPERIMENT_515_DONT_CACHE_REF
// - Avoids `text_ref` caching, aided by improvements to ref() speed in 515.

#if DM_VERSION < 515

	// You can't X-macro custom names :(
	#ifdef EXPERIMENT_MY_COOL_FEATURE
		#warn EXPERIMENT_MY_COOL_FEATURE is only available on 515+
		#undef EXPERIMENT_MY_COOL_FEATURE
	#endif
#elif defined(UNIT_TESTS)
	#define EXPERIMENT_MY_COOL_FEATURE
#endif

#if DM_VERSION >= 516
	#error "Remove all 515 experiments"
#endif
