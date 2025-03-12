#define DEFINE_BITFIELD(_variable, _flags) \
UNLINT(var/const/_bitfield_##_variable = "Bitfield defined multiple times! Need a new var name!";) \
/datum/bitfield/##_variable { \
	flags = ##_flags; \
	variable = #_variable; \
}
