/datum/mutation/ranching
	///Required Happiness
	var/happiness
	///temperature required
	var/needed_temperature
	///How much Variance can be in temperature creates a range around the required temperature
	var/temperature_variance
	///Pressure requirements
	var/needed_pressure
	///Pressure Variance
	var/pressure_variance
	///Special foods needed
	var/list/food_requirements = list()
	///Special reagents needed
	var/list/reagent_requirements = list()
	///Special turf requirements
	var/list/needed_turfs = list()
	///Required nearby items
	var/list/nearby_items = list()
	///Needed Breathable Air
	var/list/required_atmos = list()
	///Needed job from nearby players
	var/player_job
	///required liquid depth
	var/liquid_depth
	///Needed species
	var/datum/species/needed_species
	///How hurt someone is, invert is so how damaaged is the number you put so for crit you would put 100
	var/player_health

	///this is used for the guide book to say where it gets this from
	var/can_come_from_string

/datum/mutation/ranching/chicken
	///The typepath of the chicken
	var/mob/living/basic/chicken/chicken_type
	///Egg type for egg so me don't gotta create new chicken
	var/obj/item/food/egg/egg_type
	///Needed Rooster Type
	var/required_rooster

/datum/mutation/ranching/proc/cycle_requirements(atom/checkee, is_egg = FALSE)
	if(check_happiness(checkee, is_egg) && check_food(checkee, is_egg) && check_reagent(checkee, is_egg) && check_items(checkee, is_egg) && check_players_job(checkee, is_egg) && check_species(checkee, is_egg) && check_players_health(checkee, is_egg))
		return TRUE
	else
		return FALSE

/datum/mutation/ranching/proc/check_happiness(atom/checkee, is_egg)
	if(happiness)
		var/checked_happiness = 0
		checked_happiness = SEND_SIGNAL(checkee, COMSIG_HAPPINESS_RETURN_VALUE)

		if(happiness > 0)
			if(!(checked_happiness > happiness))
				return FALSE
		else
			if(!(checked_happiness < happiness))
				return FALSE
	return TRUE

/datum/mutation/ranching/proc/check_food(atom/checkee, is_egg)
	if(is_egg)
		return TRUE
	else
		if(length(food_requirements))
			return FALSE
	return TRUE

/datum/mutation/ranching/proc/check_reagent(atom/checkee, is_egg)
	if(is_egg)
		return TRUE
	else
		if(length(reagent_requirements))
			return FALSE
	return TRUE

/datum/mutation/ranching/proc/check_items(atom/checkee, is_egg)
	if(is_egg)
		return TRUE
	else
		if(length(nearby_items))
			return FALSE
	return TRUE

/datum/mutation/ranching/proc/check_players_job(atom/checkee, is_egg)
	var/passed_check = FALSE
	if(player_job)
		for(var/mob/living/carbon/human/in_range_player in view(3, checkee))
			if(in_range_player.mind.assigned_role == player_job)
				passed_check = TRUE
		if(passed_check == FALSE)
			return FALSE
	return TRUE

/datum/mutation/ranching/proc/check_species(atom/checkee, is_egg)
	var/passed_check = FALSE
	if(needed_species)
		for(var/mob/living/carbon/human/in_range_player in view(3, checkee))
			if(in_range_player.dna.species == needed_species)
				passed_check = TRUE
		if(passed_check == FALSE)
			return FALSE
	return TRUE

/datum/mutation/ranching/proc/check_players_health(atom/checkee, is_egg)
	var/passed_check = FALSE
	if(player_health)
		for(var/mob/living/carbon/human/in_range_player in view(3, checkee))
			if(in_range_player.maxHealth - in_range_player.health >= player_health)
				passed_check = TRUE
		if(passed_check == FALSE)
			return FALSE
	return TRUE
