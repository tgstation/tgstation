/datum/reagent
	var/bladder_per_cycle = 0
	var/bladder_chance_per_cycle = 0

/datum/reagent/on_mob_life(mob/living/M)
	. = ..()
	if(iscarbon(M) && prob(bladder_chance_per_cycle))
		var/mob/living/carbon/C = M
		C.adjust_bladder(bladder_per_cycle)

/datum/reagent/water
	bladder_per_cycle = 0.35
	bladder_chance_per_cycle = 49

/datum/reagent/consumable
	bladder_per_cycle = 0.25
	bladder_chance_per_cycle = 50

/datum/reagent/consumable/banana
	bladder_per_cycle = 5
	bladder_chance_per_cycle = 5

/datum/reagent/consumable/nothing
	bladder_per_cycle = 0 //it's nothing!

/datum/reagent/consumable/spacemountainwind
	bladder_per_cycle = 0.5
	bladder_chance_per_cycle = 55

/datum/reagent/consumable/dr_gibb
	bladder_per_cycle = 0.49
	bladder_chance_per_cycle = 56

/datum/reagent/consumable/space_up
	bladder_per_cycle = 0.5
	bladder_chance_per_cycle = 55

/datum/reagent/consumable/pwr_game
	bladder_per_cycle = 0.75
	bladder_chance_per_cycle = 40