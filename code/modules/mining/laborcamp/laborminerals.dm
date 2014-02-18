/turf/simulated/mineral/random/labormineral
	mineralSpawnChanceList = list("Uranium" = 5, "Iron" = 100, "Diamond" = 1, "Gold" = 5, "Silver" = 5, "Plasma" = 25/*, "Adamantine" =5, "Cave" = 1 */) //Don't suffocate the prisoners with caves
	icon_state = "rock_labor"

/turf/simulated/mineral/random/labormineral/New()
	icon_state = "rock"
	..()