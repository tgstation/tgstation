
/turf/open/floor/engine/hull
	name = "exterior hull plating"
	desc = "Sturdy exterior hull plating that separates you from the uncaring vacuum of space."
	icon_state = "hull"
	initial_gas_mix = AIRLESS_ATMOS
	temperature = TCMB

/turf/open/floor/engine/hull_corner
	name = "exterior hull plating corner"
	desc = "Corner of exterior hull plating that separates you from the uncaring vacuum of space."
	icon_state = "hull_corner"
	initial_gas_mix = AIRLESS_ATMOS
	temperature = TCMB

/turf/open/floor/engine/hull_edge
	name = "exterior hull plating edge"
	desc = "Edge of exterior hull plating that separates you from the uncaring vacuum of space."
	icon_state = "hull_side"
	initial_gas_mix = AIRLESS_ATMOS
	temperature = TCMB


/turf/open/floor/engine/hull_air
	name = "exterior hull plating"
	desc = "Sturdy exterior hull plating that separates you from the uncaring vacuum of space."
	icon_state = "hull"
	temperature = TCMB

/turf/open/floor/engine/hull_corner_air
	name = "exterior hull plating corner"
	desc = "Corner of exterior hull plating that separates you from the uncaring vacuum of space."
	icon_state = "hull_corner"
	temperature = TCMB

/turf/open/floor/engine/hull_edge_air
	name = "exterior hull plating edge"
	desc = "Edge of exterior hull plating that separates you from the uncaring vacuum of space."
	icon_state = "hull_side"
	temperature = TCMB
/turf/open/floor/engine/interior_hull
	name = "interior hull plating"
	desc = "Interior of hull that separates you from the uncaring vacuum of space."
	icon_state = "regular_hull"
	temperature = TCMB

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
