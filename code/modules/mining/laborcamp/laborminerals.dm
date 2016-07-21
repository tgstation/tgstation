/turf/closed/mineral/random/labormineral
	mineralSpawnChanceList = list(
		/turf/closed/mineral/iron = 100, /turf/closed/mineral/uranium = 1, /turf/closed/mineral/diamond = 1,
		/turf/closed/mineral/gold = 1, /turf/closed/mineral/silver = 1, /turf/closed/mineral/plasma = 1)
	icon_state = "rock_labor"

/turf/closed/mineral/random/labormineral/New()
	icon_state = "rock"
	..()