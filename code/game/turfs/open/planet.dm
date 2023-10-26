/turf/open/misc/dirt
	gender = PLURAL
	name = "dirt"
	desc = "Upon closer examination, it's still dirt."
	icon = 'icons/turf/floors.dmi'
	icon_state = "dirt"
	base_icon_state = "dirt"
	baseturfs = /turf/open/chasm/jungle
	initial_gas_mix = OPENTURF_LOW_PRESSURE
	planetary_atmos = TRUE
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE

/turf/open/misc/dirt/station
	name = "dirt flooring" //FOR THE LOVE OF GOD USE THIS INSTEAD OF DIRT FOR STATION MAPS
	desc = "You heard this place was dirty, but this is just absurd."
	baseturfs = /turf/open/floor/plating
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = FALSE

/turf/open/misc/dirt/jungle
	slowdown = 0.5
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS

/turf/open/misc/dirt/dark
	icon_state = "greenerdirt"
	base_icon_state = "greenerdirt"

/turf/open/misc/dirt/dark/station
	baseturfs = /turf/open/floor/plating
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = FALSE

/turf/open/misc/dirt/dark/station/airless
	initial_gas_mix = AIRLESS_ATMOS
	temperature = TCMB

/turf/open/misc/dirt/dark/jungle
	slowdown = 0.5
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS

/turf/open/misc/dirt/jungle/dark
	icon_state = "greenerdirt"
	base_icon_state = "greenerdirt"

/turf/open/misc/dirt/jungle/wasteland //Like a more fun version of living in Arizona.
	name = "cracked earth"
	desc = "Looks a bit dry."
	icon = 'icons/turf/floors.dmi'
	icon_state = "wasteland"
	base_icon_state = "wasteland"
	slowdown = 1
	var/floor_variance = 15

/turf/open/misc/dirt/jungle/wasteland/Initialize(mapload)
	.=..()
	if(prob(floor_variance))
		icon_state = "[initial(icon_state)][rand(0,12)]"

/turf/open/misc/dirt/jungle/wasteland/break_tile()
	. = ..()
	icon_state = "[initial(icon_state)]0"

/turf/open/misc/grass/jungle
	name = "jungle grass"
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/misc/dirt
	desc = "Greener on the other side."
	icon_state = "junglegrass"
	base_icon_state = "junglegrass"
	smooth_icon = 'icons/turf/floors/junglegrass.dmi'

/turf/open/misc/grass/broken_states()
	return list("jungle_damaged")

/turf/open/misc/grass/burnt_states()
	return list("jungle_damaged")

/turf/open/misc/grass/jungle/lavaland
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/turf/closed/mineral/random/jungle
	baseturfs = /turf/open/misc/dirt/dark/jungle

/turf/closed/mineral/random/jungle/mineral_chances()
	return list(
		/obj/item/stack/ore/bluespace_crystal = 1,
		/obj/item/stack/ore/diamond = 1,
		/obj/item/stack/ore/gold = 10,
		/obj/item/stack/ore/iron = 40,
		/obj/item/stack/ore/plasma = 20,
		/obj/item/stack/ore/silver = 12,
		/obj/item/stack/ore/titanium = 11,
		/obj/item/stack/ore/uranium = 5,
	)

/turf/closed/mineral/random/jungle/space_safe
	baseturfs = /turf/open/misc/dirt/dark/station/airless
