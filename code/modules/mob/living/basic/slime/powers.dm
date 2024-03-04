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

//Feeding

/datum/action/innate/slime/feed
	name = "Feed"
	button_icon_state = "slimeeat"
	desc = "This will let you feed on any valid creature in the surrounding area. This should also be used to halt the feeding process."


/datum/action/innate/slime/feed/Activate()
	var/mob/living/basic/slime/slime_owner = owner

	if(slime_owner.stat)
		slime_owner.balloon_alert(slime_owner, "unconscious!")
		return

	if(slime_owner.buckled)
		slime_owner.stop_feeding()
		return

	var/list/choices = list()
	for(var/mob/living/nearby_mob in view(1,slime_owner))
		if(nearby_mob != slime_owner && slime_owner.Adjacent(nearby_mob) && nearby_mob.appears_alive())
			choices += nearby_mob

	if(length(choices) == 1)
		if(!slime_owner.can_feed_on(choices[1]))
			return FALSE
		slime_owner.start_feeding(choices[1])
		return TRUE

	var/choice = tgui_input_list(slime_owner, "Who do you wish to feed on?", "Slime Feed", sort_names(choices))
	if(isnull(choice))
		to_chat(world, "No mob to choose from")
		return FALSE
	var/mob/living/victim = choice
	if(slime_owner.can_feed_on(victim))
		slime_owner.start_feeding(victim)
		return TRUE
	return FALSE


///Can the slime leech life energy from the target?
/mob/living/basic/slime/proc/can_feed_on(mob/living/meal, silent = FALSE)

	if(stat)
		if(silent)
			return FALSE
		balloon_alert(src, span_warning("unconscious!"))
		return FALSE

	if(hunger_disabled)
		if(silent)
			return FALSE
		balloon_alert(src, span_notice("not hungry!"))
		return FALSE

	if(!Adjacent(meal))
		return FALSE

	if(meal.stat == DEAD)
		if(silent)
			return FALSE
		balloon_alert(src, span_warning("no life energy!"))
		return FALSE

	if(locate(/mob/living/basic/slime) in meal.buckled_mobs)
		if(silent)
			return FALSE
		balloon_alert(src, span_warning("another slime in the way!"))
		return FALSE

	if(issilicon(meal) || meal.mob_biotypes & MOB_ROBOTIC || meal.flags_1 & HOLOGRAM_1)
		balloon_alert(src, "no life energy!")
		return FALSE

	if(isslime(meal))
		if(silent)
			return FALSE
		balloon_alert(src, "can't eat slime!")
		return FALSE

	if(isanimal(meal))
		var/mob/living/simple_animal/simple_meal = meal
		if(simple_meal.damage_coeff[TOX] <= 0 && simple_meal.damage_coeff[BRUTE] <= 0) //The creature wouldn't take any damage, it must be too weird even for us.
			if(silent)
				return FALSE
			balloon_alert(src, "not food!")
			return FALSE
	else if(isbasicmob(meal))
		var/mob/living/basic/basic_meal = meal
		if(basic_meal.damage_coeff[TOX] <= 0 && basic_meal.damage_coeff[BRUTE] <= 0)
			if (silent)
				return FALSE
			balloon_alert(src, "not food!")
			return FALSE

	return TRUE

///The slime consumes the mob's lifeforce
/mob/living/basic/slime/proc/feed_process(seconds_per_tick = SSMOBS_DT)

	if(isanimal_or_basicmob(buckled))
		var/mob/living/animal_victim = buckled

		var/totaldamage = 0 //total damage done to this unfortunate animal
		var/need_mob_update
		need_mob_update = totaldamage += animal_victim.adjustBruteLoss(rand(2, 4) * 0.5 * seconds_per_tick, updating_health = FALSE)
		need_mob_update += totaldamage += animal_victim.adjustToxLoss(rand(1, 2) * 0.5 * seconds_per_tick, updating_health = FALSE)
		if(need_mob_update)
			animal_victim.updatehealth()

		if(totaldamage >= 0) // AdjustBruteLoss returns a negative value on succesful damage adjustment
			stop_feeding(FALSE, FALSE)
			return

	adjust_nutrition((rand(7, 15) * 0.5 * seconds_per_tick))

	//Heal yourself.
	adjustBruteLoss(-1.5 * seconds_per_tick)

///The slime will start feeding on the target
/mob/living/basic/slime/proc/start_feeding(mob/living/target_mob)
	target_mob.unbuckle_all_mobs(force=TRUE) //Slimes rip other mobs (eg: shoulder parrots) off (Slimes Vs Slimes is already handled in can_feed_on())
	if(target_mob.buckle_mob(src, force=TRUE))
		layer = target_mob.layer+0.01 //appear above the target mob
		target_mob.visible_message(span_danger("[name] latches onto [target_mob]!"), \
						span_userdanger("[name] latches onto [target_mob]!"))
	else
		balloon_alert(src, "latch failed!")

///The slime will stop feeding
/mob/living/basic/slime/proc/stop_feeding(silent = FALSE, living=TRUE)
	if(!buckled)
		return

	if(!living)
		balloon_alert(src, "not food!")
	var/mob/living/victim = buckled

	if(istype(victim))
		var/bio_protection = 100 - victim.getarmor(null, BIO)
		if(prob(bio_protection))
			victim.apply_status_effect(/datum/status_effect/slimed, slime_type.rgb_code, slime_type.colour == SLIME_TYPE_RAINBOW)

	if(!silent)
		visible_message(span_warning("[src] lets go of [buckled]!"), \
						span_notice("<i>I stopped feeding.</i>"))
	layer = initial(layer)
	buckled.unbuckle_mob(src,force=TRUE)

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

		//todo: set friends
		//baby.set_friends(Friends)
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
