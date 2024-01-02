/turf/closed/mineral/random/asteroid/rockplanet
	name = "iron rock"
	icon = 'icons/turf/mining.dmi'
	icon_state = "redrock"
	//smooth_icon = 'icons/turf/walls/red_wall.dmi'
	base_icon_state = "red_wall"
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	baseturfs = /turf/open/misc/asteroid/rockplanet
	turf_type = /turf/open/misc/asteroid/rockplanet
	//mineralSpawnChanceList = list(/obj/item/stack/ore/uranium = 7, /obj/item/stack/ore/diamond = 1, /obj/item/stack/ore/gold = 5,
	//	/obj/item/stack/ore/silver = 7, /obj/item/stack/ore/plasma = 15, /obj/item/stack/ore/iron = 55, /obj/item/stack/ore/titanium = 6,
	//	/turf/closed/mineral/gibtonite/rockplanet = 4, /obj/item/stack/ore/bluespace_crystal = 1)
	mineralChance = 30

/turf/closed/mineral/gibtonite/rockplanet
	name = "iron rock"
	icon = 'icons/turf/mining.dmi'
	icon_state = "redrock"
	base_icon_state = "red_wall"
	baseturfs = /turf/open/misc/asteroid/rockplanet
	turf_type = /turf/open/misc/asteroid/rockplanet

/turf/open/misc/asteroid/rockplanet
	name = "rockplanet sand"
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/misc/asteroid/rockplanet

/turf/open/floor/plating/rockplanet
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/misc/asteroid/rockplanet

/turf/open/floor/plating/rust/rockplanet
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/misc/asteroid/rockplanet
