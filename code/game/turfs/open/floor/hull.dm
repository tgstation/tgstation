
/turf/open/floor/hull
	name = "exterior hull plating"
	desc = "Sturdy exterior hull plating that separates you from the uncaring vacuum of space."
	icon_state = "regular_hull"
	thermal_conductivity = 0.025
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE

/turf/open/floor/hull/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode) //no rcd destroying this flooring
	if(passed_mode == RCD_FLOORWALL)
		to_chat(user, "<span class='notice'>You build a wall.</span>")
		ChangeTurf(/turf/closed/wall)
		return TRUE
	return FALSE


/turf/open/floor/hull/reinforced
	name = "exterior reinforced hull plating"
	desc = "Extremely sturdy exterior hull plating that separates you from the uncaring vacuum of space."
	icon_state = "reinforced_hull"
	heat_capacity = INFINITY
