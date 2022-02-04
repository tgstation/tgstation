
/turf/open/floor/engine/hull
	name = "exterior hull plating"
	desc = "Sturdy exterior hull plating that separates you from the uncaring vacuum of space."
	icon_state = "regular_hull"
	initial_gas_mix = AIRLESS_ATMOS
	temperature = TCMB

/turf/open/floor/engine/hull/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode) //no rcd destroying this flooring
	if(passed_mode == RCD_DECONSTRUCT)
		to_chat(user, span_warning("The flooring is too thick to be regularly deconstructed!"))
		return FALSE
	return ..()

/// RCD-immune plating generated only by shuttle code for shuttle ceilings on multi-z maps, should not be mapped in or creatable in any other way
/turf/open/floor/engine/hull/ceiling
	name = "shuttle ceiling plating"
	var/old_turf_type

/turf/open/floor/engine/hull/ceiling/AfterChange(flags, oldType)
	. = ..()
	old_turf_type = oldType

/turf/open/floor/engine/hull/reinforced
	name = "exterior reinforced hull plating"
	desc = "Extremely sturdy exterior hull plating that separates you from the uncaring vacuum of space."
	icon_state = "reinforced_hull"
	heat_capacity = INFINITY
