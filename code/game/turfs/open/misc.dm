/// Used as a parent type for types that want to allow construction, but do not want to be floors
/// I wish I could use components for turfs at scale
/// Please do not bloat this. Love you <3
/turf/open/misc
	name = "coder/mapper fucked up"
	desc = "report on GitHub please"

	flags_1 = NO_SCREENTIPS_1 | CAN_BE_DIRTY_1
	turf_flags = IS_SOLID | NO_RUST

	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

	underfloor_accessibility = UNDERFLOOR_INTERACTABLE
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN
	canSmoothWith = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_OPEN_FLOOR

	thermal_conductivity = 0.02
	heat_capacity = 20000
	tiled_dirt = TRUE

/turf/open/misc/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	. = ..()
	if(.)
		return TRUE

	if(istype(attacking_item, /obj/item/stack/rods))
		build_with_rods(attacking_item, user)
		return TRUE

	if(ismetaltile(attacking_item))
		build_with_floor_tiles(attacking_item, user)
		return TRUE

/turf/open/misc/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/turf/open/misc/ex_act(severity, target)
	. = ..()

	if(target == src)
		ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
		return TRUE
	if(is_explosion_shielded(severity))
		return FALSE

	if(target)
		severity = EXPLODE_LIGHT

	switch(severity)
		if(EXPLODE_DEVASTATE)
			ScrapeAway(2, flags = CHANGETURF_INHERIT_AIR)
		if(EXPLODE_HEAVY)
			switch(rand(1, 3))
				if(1 to 2)
					ScrapeAway(2, flags = CHANGETURF_INHERIT_AIR)
				if(3)
					if(prob(80))
						ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
					else
						break_tile()
					hotspot_expose(1000,CELL_VOLUME)
		if(EXPLODE_LIGHT)
			if (prob(50))
				break_tile()
				hotspot_expose(1000,CELL_VOLUME)

	return TRUE

/turf/open/misc/is_explosion_shielded(severity)
	if(severity >= EXPLODE_DEVASTATE)
		return FALSE
	for(var/obj/blocker in src)
		if(blocker.density)
			return TRUE
	return FALSE

/turf/open/misc/blob_act(obj/structure/blob/B)
	return

/turf/open/misc/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_TURF)
		if(the_rcd.rcd_design_path != /turf/open/floor/plating/rcd)
			return FALSE

		return list("delay" = 0, "cost" = 3)
	return FALSE

/turf/open/misc/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	if(rcd_data["[RCD_DESIGN_MODE]"] == RCD_TURF)
		if(rcd_data["[RCD_DESIGN_PATH]"] != /turf/open/floor/plating/rcd)
			return FALSE

		place_on_top(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
		return TRUE
	return FALSE
