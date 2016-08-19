/turf/closed/mineral/random/labormineral
	mineralSpawnChanceList = list(
		/turf/closed/mineral/iron = 100, /turf/closed/mineral/uranium = 1, /turf/closed/mineral/diamond = 1,
		/turf/closed/mineral/gold = 1, /turf/closed/mineral/silver = 1, /turf/closed/mineral/plasma = 1)
	icon_state = "rock_labor"

/turf/closed/mineral/random/labormineral/New()
	icon_state = "rock"
	..()

/turf/closed/mineral/random/labormineral/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/open/floor/plating/lava/smooth/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	defer_change = 1
	mineralSpawnChanceList = list(
		/turf/closed/mineral/iron/volcanic = 100, /turf/closed/mineral/uranium/volcanic = 1, /turf/closed/mineral/diamond/volcanic = 1,
		/turf/closed/mineral/gold/volcanic = 1, /turf/closed/mineral/silver/volcanic = 1, /turf/closed/mineral/plasma/volcanic = 1)