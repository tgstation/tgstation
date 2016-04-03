/turf/simulated/mineral/random/labormineral
	mineralSpawnChanceList = list(
		/turf/simulated/mineral/uranium = 1, /turf/simulated/mineral/iron = 100,
		/turf/simulated/mineral/diamond = 1, /turf/simulated/mineral/gold = 1,
		/turf/simulated/mineral/silver = 1, /turf/simulated/mineral/plasma = 1/*, "Adamantine" =5, "Cave" = 1 */) //Don't suffocate the prisoners with caves
	icon_state = "rock_labor"

/turf/simulated/mineral/random/labormineral/New()
	icon_state = "rock"
	..()