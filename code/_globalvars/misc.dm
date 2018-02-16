GLOBAL_VAR_INIT(admin_notice, "") // Admin notice that all clients see when joining the server

GLOBAL_VAR_INIT(timezoneOffset, 0) // The difference betwen midnight (of the host computer) and 0 world.ticks.

	// For FTP requests. (i.e. downloading runtime logs.)
	// However it'd be ok to use for accessing attack logs and such too, which are even laggier.
GLOBAL_VAR_INIT(fileaccess_timer, 0)

GLOBAL_VAR_INIT(TAB, "&nbsp;&nbsp;&nbsp;&nbsp;")

GLOBAL_DATUM_INIT(data_core, /datum/datacore, new)

GLOBAL_VAR_INIT(CELLRATE, 0.002)  // multiplier for watts per tick <> cell storage (eg: .002 means if there is a load of 1000 watts, 20 units will be taken from a cell per second)
GLOBAL_VAR_INIT(CHARGELEVEL, 0.001) // Cap for how fast cells charge, as a percentage-per-tick (.001 means cellcharge is capped to 1% per second)

GLOBAL_LIST_EMPTY(powernets)

GLOBAL_VAR_INIT(bsa_unlock, FALSE)	//BSA unlocked by head ID swipes

GLOBAL_LIST_EMPTY(player_details)	// ckey -> /datum/player_details

GLOBAL_LIST_INIT(bitfields, list(
	"obj_flags" = list("EMAGGED" = EMAGGED, "IN_USE" = IN_USE, "CAN_BE_HIT" = CAN_BE_HIT, "BEING_SHOCKED" = BEING_SHOCKED, "DANGEROUS_POSSESSION" = DANGEROUS_POSSESSION, "ON_BLUEPRINTS" = ON_BLUEPRINTS, "UNIQUE_RENAME" = UNIQUE_RENAME),
	"datum_flags" = list("DF_USE_TAG" = DF_USE_TAG, "DF_VAR_EDITED" = DF_VAR_EDITED),
	"item_flags" = list("BEING_REMOVED" = BEING_REMOVED, "IN_INVENTORY" = IN_INVENTORY, "FORCE_STRING_OVERRIDE" = FORCE_STRING_OVERRIDE, "NEEDS_PERMIT" = NEEDS_PERMIT)
	))
