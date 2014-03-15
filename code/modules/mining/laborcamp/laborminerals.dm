/turf/simulated/mineral/random/labormineral
	mineralSpawnChanceList = list("Uranium" = 1, "Iron" = 100, "Diamond" = 1, "Gold" = 1, "Silver" = 1, "Plasma" = 1/*, "Adamantine" =5, "Cave" = 1 */) //Don't suffocate the prisoners with caves
	icon_state = "rock_labor"

/turf/simulated/mineral/random/labormineral/New()
	icon_state = "rock"
	..()