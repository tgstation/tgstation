#define DEFINE_BITFIELD(_variable, _flags) /datum/bitfield/##_variable { \
	flags = ##_flags; \
	variable = #_variable; \
}
