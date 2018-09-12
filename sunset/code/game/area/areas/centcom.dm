/area/sunset/infiltrator_base
	name = "Syndicate Infiltrator Base"
	icon = 'icons/turf/areas.dmi'
	icon_state = "red"
	blob_allowed = FALSE
	requires_power = FALSE
	has_gravity = TRUE
	noteleport = TRUE
	flags_1 = NONE
	ambientsounds = HIGHSEC
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/sunset/infiltrator_base/poweralert(state, obj/source)
	return

/area/sunset/infiltrator_base/atmosalert(danger_level, obj/source)
	return

/area/sunset/infiltrator_base/jail
	name = "Syndicate Infiltrator Base Brig"

//headcanon lore: this is some random snowy moon that the syndies use as a base
/area/sunset/infiltrator_base/outside
	name = "Syndicate Base X-77"
	icon_state = "yellow"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED