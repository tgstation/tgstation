#define DEFINE_BITFIELD(_variable, _flags) \
GLOBAL_REAL_VAR(_bitfield_##_variable); \
/datum/bitfield/##_variable { \
	flags = ##_flags; \
	variable = #_variable; \
}
