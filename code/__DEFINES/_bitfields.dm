#define DEFINE_BITFIELD(_variable, _flags) /datum/bitfield/##_variable { \
	flags = ##_flags; \
	variable = #_variable; \
} \
/datum/bitfield/##_variable/return_sources() { \
	. = ..(); \
	. += list(list(__FILE__, __LINE__)); \
}
