/obj/structure/holobubble
	name = "holographic wall"
	desc = "See through wall that stops atmospherics from entering, but let's people through"
	icon_state = "holobarrier-0"
	base_icon_state = "holobarrier"
	density = TRUE
	layer = ABOVE_OBJ_LAYER //Just above doors
	anchored = TRUE //initially is 0 for tile smoothing
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	CanAtmosPass = ATMOS_PASS_NO
	rad_insulation = RAD_HEAVY_INSULATION
	flags_ricochet = RICOCHET_SHINY
	receive_ricochet_chance_mod = 0
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_HOLOBUBBLE)
	canSmoothWith = list(SMOOTH_GROUP_HOLOBUBBLE)


	var/list/blocked_factions = list()

/obj/structure/holobubble/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(.)
		return

	if(!ismob(mover))
		return TRUE

	var/mob/some_mob = mover

	for(var/faction in blocked_factions)
		if(faction in some_mob.faction)
			return FALSE

	return TRUE
