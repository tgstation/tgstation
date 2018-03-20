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
	"item_flags" = list("BEING_REMOVED" = BEING_REMOVED, "IN_INVENTORY" = IN_INVENTORY, "FORCE_STRING_OVERRIDE" = FORCE_STRING_OVERRIDE, "NEEDS_PERMIT" = NEEDS_PERMIT),
	"admin_flags" = list("BUILDMODE" = R_BUILDMODE, "ADMIN" = R_ADMIN, "BAN" = R_BAN, "FUN" = R_FUN, "SERVER" = R_SERVER, "DEBUG" = R_DEBUG, "POSSESS" = R_POSSESS, "PERMISSIONS" = R_PERMISSIONS, "STEALTH" = R_STEALTH, "POLL" = R_POLL, "VAREDIT" = R_VAREDIT, "SOUNDS" = R_SOUNDS, "SPAWN" = R_SPAWN, "AUTOLOGIN" = R_AUTOLOGIN, "DBRANKS" = R_DBRANKS),
	"appearance_flags" = list("LONG_GLIDE" = LONG_GLIDE, "RESET_COLOR" = RESET_COLOR, "RESET_ALPHA" = RESET_ALPHA, "RESET_TRANSFORM" = RESET_TRANSFORM, "NO_CLIENT_COLOR" = NO_CLIENT_COLOR, "KEEP_TOGETHER" = KEEP_TOGETHER, "KEEP_APART" = KEEP_APART, "PLANE_MASTER" = PLANE_MASTER, "TILE_BOUND" = TILE_BOUND, "PIXEL_SCALE" = PIXEL_SCALE),
	"sight" = list("SEE_INFRA" = SEE_INFRA, "SEE_SELF" = SEE_SELF, "SEE_MOBS" = SEE_MOBS, "SEE_OBJS" = SEE_OBJS, "SEE_TURFS" = SEE_TURFS, "SEE_PIXELS" = SEE_PIXELS, "SEE_THRU" = SEE_THRU, "SEE_BLACKNESS" = SEE_BLACKNESS, "BLIND" = BLIND),
	))
