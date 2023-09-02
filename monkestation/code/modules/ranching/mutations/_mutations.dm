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
	var/mob/living/basic/chicken/required_rooster

/datum/mutation/ranching/proc/cycle_requirements(atom/checkee, is_egg = FALSE)
	if(check_happiness(checkee, is_egg) && check_temperature(checkee, is_egg) && check_pressure(checkee, is_egg) && check_food(checkee, is_egg) && check_reagent(checkee, is_egg) && check_turfs(checkee, is_egg) && check_items(checkee, is_egg) && check_breathable_atmos(checkee, is_egg) && check_players_job(checkee, is_egg) && check_liquid_depth(checkee, is_egg) && check_species(checkee, is_egg) && check_players_health(checkee, is_egg))
		return TRUE
	else
		return FALSE

/datum/mutation/ranching/chicken/cycle_requirements(atom/checkee, is_egg)
	if(check_happiness(checkee, is_egg) && check_temperature(checkee, is_egg) && check_pressure(checkee, is_egg) && check_food(checkee, is_egg) && check_reagent(checkee, is_egg) && check_turfs(checkee, is_egg) && check_items(checkee, is_egg) && check_rooster(checkee, is_egg) && check_breathable_atmos(checkee, is_egg) && check_players_job(checkee, is_egg) && check_liquid_depth(checkee, is_egg) && check_species(checkee, is_egg) && check_players_health(checkee, is_egg))
		return TRUE
	else
		return FALSE

/datum/mutation/ranching/proc/check_happiness(atom/checkee, is_egg)
	if(happiness)
		var/checked_happiness = 0
		if(is_egg)
			var/obj/item/food/egg/checked_egg = checkee
			checked_happiness = checked_egg.happiness
		else
			var/mob/living/basic/checked_animal = checkee
			checked_happiness = checked_animal.happiness

		if(happiness > 0)
			if(!(checked_happiness > happiness))
				return FALSE
		else
			if(!(checked_happiness < happiness))
				return FALSE
	return TRUE

/datum/mutation/ranching/proc/check_temperature(atom/checkee, is_egg)
	if(needed_temperature)
		var/turf/temp_turf = get_turf(checkee)

		var/temp_min = needed_temperature
		var/temp_max = needed_temperature

		if(pressure_variance)
			temp_min -= max(pressure_variance, 1)
			temp_max += pressure_variance
		if(!(temp_turf.return_temperature() <= temp_max) && !(temp_turf.return_temperature() >= temp_min))
			return FALSE
	return TRUE

/datum/mutation/ranching/proc/check_pressure(atom/checkee, is_egg)
	if(needed_pressure)

		var/turf/pressure_turf  = get_turf(checkee)
		var/datum/gas_mixture/environment = pressure_turf.return_air()

		var/pressure_min = needed_pressure
		var/pressure_max = needed_pressure

		if(pressure_variance)
			pressure_min -= max(pressure_variance, 0)
			pressure_max += pressure_variance
		if(!(environment.return_pressure() <=  pressure_max) && !(environment.return_pressure() >= pressure_min))
			return FALSE
	return TRUE

/datum/mutation/ranching/proc/check_food(atom/checkee, is_egg)
	if(is_egg)
		var/obj/item/food/egg/checked_egg = checkee
		if(food_requirements.len)
			for(var/food in checked_egg.consumed_food)
				if(food in food_requirements)
					food_requirements -= food
			if(food_requirements.len)
				return FALSE
	else
		var/mob/living/basic/checked_animal = checkee
		if(food_requirements.len)
			for(var/food in checked_animal.consumed_food)
				if(food in food_requirements)
					food_requirements -= food
			if(food_requirements.len)
				return FALSE
	return TRUE

/datum/mutation/ranching/proc/check_reagent(atom/checkee, is_egg)
	if(reagent_requirements.len)
		var/list/needed_reagents = new/list
		for(var/reagent in reagent_requirements)
			needed_reagents += reagent
		var/list/consumed_reagents = list()
		if(is_egg)
			var/obj/item/food/egg/checked_egg = checkee
			consumed_reagents = checked_egg.consumed_reagents
		else
			var/mob/living/basic/checked_animal = checkee
			consumed_reagents = checked_animal.consumed_reagents

		for(var/datum/reagent/reagent as anything in consumed_reagents)
			if(!istype(reagent))
				continue
			if(reagent.type in reagent_requirements)
				needed_reagents -= reagent.type
		if(needed_reagents.len)
			return FALSE
	return TRUE

/datum/mutation/ranching/proc/check_turfs(atom/checkee, is_egg)
	if(needed_turfs.len)
		for(var/turf/in_range_turf in view(2, checkee))
			if(in_range_turf.type in needed_turfs)
				needed_turfs -= in_range_turf.type
		if(needed_turfs.len)
			return FALSE
	return TRUE

/datum/mutation/ranching/proc/check_items(atom/checkee, is_egg)
	if(nearby_items.len)
		var/list/needed_items = list()
		for(var/list_item in nearby_items)
			var/obj/item/needed_item = list_item
			needed_items.Add(needed_item)
		for(var/obj/item/in_range_item in view(3, checkee))
			if(in_range_item.type in nearby_items)
				needed_items -= in_range_item.type
		if(needed_items.len)
			return FALSE
	return TRUE

/datum/mutation/ranching/proc/check_breathable_atmos(atom/checkee, is_egg)
	var/passed_check = FALSE
	if(required_atmos.len)
		var/turf/open/checked_source_turf  = get_turf(checkee)
		for(var/gas in required_atmos)
			if(checked_source_turf.air.gases[gas][MOLES] >= required_atmos[gas])
				passed_check = TRUE
		if(passed_check == FALSE)
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


/datum/mutation/ranching/proc/check_liquid_depth(atom/checkee, is_egg)
	/* FOR THE LIQUIDS TM
	var/passed_check = FALSE
	if(liquid_depth)
		var/turf/open/egg_location = get_turf(checkee.loc)
		if(egg_location.liquids)
			if(egg_location.liquids.height >= liquid_depth)
				passed_check = TRUE
		if(passed_check == FALSE)
			return FALSE
	*/
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

/datum/mutation/ranching/chicken/proc/check_rooster(atom/checkee, is_egg)
	var/passed_check = FALSE
	if(required_rooster)
		var/mob/living/basic/chicken/rooster = required_rooster
		for(var/mob/living/basic/chicken/scanned_chicken in view(1, checkee.loc))
			if(istype(scanned_chicken, rooster.type) && checkee.gender == MALE)
				passed_check = TRUE
		if(passed_check == FALSE)
			return FALSE
	return TRUE
