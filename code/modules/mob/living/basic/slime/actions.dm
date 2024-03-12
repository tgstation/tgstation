/datum/action/innate/slime
	check_flags = AB_CHECK_CONSCIOUS
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	var/needs_growth = FALSE
	var/nutrition_cost = 0

/datum/action/innate/slime/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return

	var/mob/living/basic/slime/slime_owner = owner

	if(slime_owner.nutrition < nutrition_cost)
		return FALSE

	if(!needs_growth) //always available if does not need growth
		return TRUE

	return slime_owner.amount_grown >= SLIME_EVOLUTION_THRESHOLD

//Evolving

/datum/action/innate/slime/evolve
	name = "Evolve"
	button_icon_state = "slimegrow"
	desc = "This will let you evolve from baby to adult slime."
	needs_growth = TRUE
	nutrition_cost = SLIME_EVOLUTION_COST

/datum/action/innate/slime/evolve/Activate()
	var/mob/living/basic/slime/slime_owner = owner
	slime_owner.evolve()

///Turns a baby slime into an adult slime
/mob/living/basic/slime/proc/evolve()

	if(stat)
		balloon_alert(src, "unconscious!")
		return
	if(life_stage == SLIME_LIFE_STAGE_ADULT)
		balloon_alert(src, "already adult!")
		return
	if(amount_grown < SLIME_EVOLUTION_THRESHOLD)
		balloon_alert(src, "need to grow!")
		return
	if(nutrition < SLIME_EVOLUTION_COST)
		balloon_alert(src, "need food!")
		return

	adjust_nutrition(-SLIME_EVOLUTION_COST)

	set_life_stage(SLIME_LIFE_STAGE_ADULT)
	update_name()
	regenerate_icons()

	amount_grown = 0

//Reproduction

/datum/action/innate/slime/reproduce
	name = "Reproduce"
	button_icon_state = "slimesplit"
	desc = "This will make you split into four slimes."
	needs_growth = TRUE

/datum/action/innate/slime/reproduce/Activate()
	var/mob/living/basic/slime/slime_owner = owner
	slime_owner.reproduce()

///Splits the slime into multiple children if possible
/mob/living/basic/slime/proc/reproduce()
	if(stat != CONSCIOUS)
		balloon_alert(src, "need to be conscious to split!")
		return

	if(!isopenturf(loc))
		balloon_alert(src, "can't reproduce here!")

	if(life_stage != SLIME_LIFE_STAGE_ADULT)
		balloon_alert(src, "not old enough to reproduce!")
		return

	if(amount_grown < SLIME_EVOLUTION_THRESHOLD)
		balloon_alert(src, "I need to be bigger...")
		return

	var/list/babies = list()
	var/new_nutrition = round(nutrition * 0.9)
	var/new_powerlevel = round(powerlevel / 4)
	var/turf/drop_loc = drop_location()

	var/list/slime_friends = list()
	for(var/faction_member in faction)
		var/mob/living/possible_friend = locate(faction_member) in GLOB.mob_living_list
		if(QDELETED(possible_friend))
			continue
		slime_friends += possible_friend

	for(var/i in 1 to 4)
		var/child_colour

		if(mutation_chance >= 100)
			child_colour = /datum/slime_type/rainbow
		else if(prob(mutation_chance))
			child_colour = pick_weight(slime_type.mutations)
		else
			child_colour = slime_type.type

		var/mob/living/basic/slime/baby
		baby = new(drop_loc, child_colour)

		if(ckey)
			baby.set_nutrition(new_nutrition) //Player slimes are more robust at spliting. Once an oversight of poor copypasta, now a feature!

		baby.powerlevel = new_powerlevel
		if(i != 1)
			step_away(baby, src)

		for(var/slime_friend in slime_friends)
			baby.befriend(slime_friend)

		babies += baby
		baby.mutation_chance = clamp(mutation_chance+(rand(5,-5)),0,100)
		SSblackbox.record_feedback("tally", "slime_babies_born", 1, baby.slime_type.colour)

	var/mob/living/basic/slime/new_slime = pick(babies) // slime that the OG slime will move into.
	new_slime.set_combat_mode(TRUE)

	if(isnull(mind))
		new_slime.key = key
	else
		mind.transfer_to(new_slime)

	qdel(src)
