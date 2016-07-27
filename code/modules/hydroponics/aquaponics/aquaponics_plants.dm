//These datums are used to track ocean plants.
//Note that, by default, one cycle is just one tick of the object subsystem's process().

/datum/aquaponics_plant
	var/name = "Plant"
	var/desc = "A water-based plant."
	var/genetic_desc = "There's nothing special about this plant." //Used during genetic analysis to hint at mutations and how to get them
	var/fluff_desc = "See above." //Used as additional notes
	var/icon //The icon to use during growth; see "aquaponics/plants.dmi"
	var/health = 100 //If this reaches zero, the plant dies
	var/dead = FALSE //Self-explanatory
	var/age = 1 //How many cycles the plant has lived through
	var/lifespan = 80 //How many cycles the plant can survive without taking damage
	var/nutrient_consumption = 0.5 //In percentage, how many nutrients to consume per cycle
	var/growth_cycle = 0 //How many cycles the plant has endured; harvesting resets this to zero
	var/required_growth_cycles = 30 //How many cycles the plant needs until it's ready for harvest
	var/mutation_chance = 33 //Percent chance to mutate when the mutation catalyst is injected
	var/list/mutation_catalysts = list("mutagen") //The reagents needed to induce mutation
	var/list/possible_mutations = list() //Possible mutations in the plant, weighted by rarity in percentage
	var/atom/movable/produce //The object produced by a successful harvest

/datum/aquaponics_plant/proc/harvest()
	growth_cycle = 0
	if(!produce)
		return
	var/produce_amount = rand(1, 5)
	for(var/i in 1 to produce_amount)
		new produce (get_turf(src))
	return 1

/datum/aquaponics_plant/proc/damage(amount)
	health = max(0, health - amount)
	if(!health)
		die()
	return 1

/datum/aquaponics_plant/proc/die()
	dead = TRUE
	return 1
