#define DEFINE_BITFIELD(_variable, _flags) \
/* Important note: This exists to throw a compile time warning if more then one bitfield with the same name is defined */ \
/* This is required to avoid dupes in vv, and any consumers of our bitfield metainfo procs */ \
GLOBAL_REAL_VAR(_bitfield_##_variable); \
/datum/bitfield/##_variable { \
	flags = ##_flags; \
	variable = #_variable; \
}
