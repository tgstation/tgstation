/datum/farm_animal_trait/pigish
	name = "Pigish"
	description = "This animal will eat more than its fair share of food."
	manifest_probability = 35
	continue_probability = 55

/datum/farm_animal_trait/pigish/on_apply(var/mob/living/simple_animal/farm/M)
	M.amount_eaten_herbivore++
	M.amount_eaten_carnivore++
	return

/datum/farm_animal_trait/thirsty
	name = "Thirsty"
	description = "This animal will drink more water than it needs."
	opposite_trait = /datum/farm_animal_trait/hydrated
	manifest_probability = 55
	continue_probability = 75

/datum/farm_animal_trait/thirsty/on_apply(var/mob/living/simple_animal/farm/M)
	M.amount_drank += 10
	return

/datum/farm_animal_trait/hydrated
	name = "Hydrated"
	description = "This animal will drink less water than it needs."
	opposite_trait = /datum/farm_animal_trait/thirsty
	manifest_probability = 55
	continue_probability = 75

/datum/farm_animal_trait/hydrated/on_apply(var/mob/living/simple_animal/farm/M)
	M.amount_drank -= 5
	return