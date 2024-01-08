#define SIZE_DOESNT_MATTER -1
#define BABIES_ONLY 0
#define ADULTS_ONLY 1

#define NO_GROWTH_NEEDED 0
#define GROWTH_NEEDED 1

/datum/action/innate/slime
	check_flags = AB_CHECK_CONSCIOUS
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	var/needs_growth = NO_GROWTH_NEEDED

/datum/action/innate/slime/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return
	var/mob/living/simple_animal/slime/slime_owner = owner
	if(needs_growth == GROWTH_NEEDED)
		if(slime_owner.amount_grown >= SLIME_EVOLUTION_THRESHOLD)
			return TRUE
		return FALSE
	return TRUE

/mob/living/simple_animal/slime/verb/Feed()
	set category = "Slime"
	set desc = "This will let you feed on any valid creature in the surrounding area. This should also be used to halt the feeding process."

	if(stat)
		return FALSE

	var/list/choices = list()
	for(var/mob/living/nearby_mob in view(1,src))
		if(nearby_mob != src && Adjacent(nearby_mob))
			choices += nearby_mob

	var/choice = tgui_input_list(src, "Who do you wish to feed on?", "Slime Feed", sort_names(choices))
	if(isnull(choice))
		return FALSE
	var/mob/living/victim = choice
	if(can_feed_on(victim))
		start_feeding(victim)
		return TRUE
	return FALSE

/datum/action/innate/slime/feed
	name = "Feed"
	button_icon_state = "slimeeat"


/datum/action/innate/slime/feed/Activate()
	var/mob/living/simple_animal/slime/slime_owner = owner
	slime_owner.Feed()

///Can the slime leech life energy from the target?
/mob/living/simple_animal/slime/proc/can_feed_on(mob/living/meal, silent = FALSE)
	if(!Adjacent(meal))
		return FALSE

	if(buckled)
		stop_feeding()
		return FALSE

	if(issilicon(meal) || meal.mob_biotypes & MOB_ROBOTIC)
		return FALSE

	if(meal.flags_1 & HOLOGRAM_1)
		meal.balloon_alert(src, "no life energy!")
		return FALSE

	if(isanimal(meal))
		var/mob/living/simple_animal/simple_meal = meal
		if(simple_meal.damage_coeff[TOX] <= 0 && simple_meal.damage_coeff[BRUTE] <= 0) //The creature wouldn't take any damage, it must be too weird even for us.
			if(silent)
				return FALSE
			to_chat(src, "<span class='warning'>[pick("This subject is incompatible", \
				"This subject does not have life energy", "This subject is empty", \
				"I am not satisified", "I can not feed from this subject", \
				"I do not feel nourished", "This subject is not food")]!</span>")
			return FALSE
	else if(isbasicmob(meal))
		var/mob/living/basic/basic_meal = meal
		if(basic_meal.damage_coeff[TOX] <= 0 && basic_meal.damage_coeff[BRUTE] <= 0)
			if (silent)
				return FALSE
			to_chat(src, "<span class='warning'>[pick("This subject is incompatible", \
				"This subject does not have life energy", "This subject is empty", \
				"I am not satisified", "I can not feed from this subject", \
				"I do not feel nourished", "This subject is not food")]!</span>")
			return FALSE

	if(isslime(meal))
		if(silent)
			return FALSE
		to_chat(src, span_warning("<i>I can't latch onto another slime...</i>"))
		return FALSE

	if(docile)
		if(silent)
			return FALSE
		to_chat(src, span_notice("<i>I'm not hungry anymore...</i>"))
		return FALSE

	if(stat)
		if(silent)
			return FALSE
		to_chat(src, span_warning("<i>I must be conscious to do this...</i>"))
		return FALSE

	if(meal.stat == DEAD)
		if(silent)
			return FALSE
		to_chat(src, span_warning("<i>This subject does not have a strong enough life energy...</i>"))
		return FALSE

	if(locate(/mob/living/simple_animal/slime) in meal.buckled_mobs)
		if(silent)
			return FALSE
		to_chat(src, span_warning("<i>Another slime is already feeding on this subject...</i>"))
		return FALSE
	return TRUE

///The slime will start feeding on the target
/mob/living/simple_animal/slime/proc/start_feeding(mob/living/target_mob)
	target_mob.unbuckle_all_mobs(force=TRUE) //Slimes rip other mobs (eg: shoulder parrots) off (Slimes Vs Slimes is already handled in can_feed_on())
	if(target_mob.buckle_mob(src, force=TRUE))
		layer = target_mob.layer+0.01 //appear above the target mob
		target_mob.visible_message(span_danger("[name] latches onto [target_mob]!"), \
						span_userdanger("[name] latches onto [target_mob]!"))
	else
		to_chat(src, span_warning("<i>I have failed to latch onto the subject!</i>"))

///The slime will stop feeding
/mob/living/simple_animal/slime/proc/stop_feeding(silent = FALSE, living=TRUE)
	if(!buckled)
		return

	if(!living)
		to_chat(src, "<span class='warning'>[pick("This subject is incompatible", \
		"This subject does not have life energy", "This subject is empty", \
		"I am not satisified", "I can not feed from this subject", \
		"I do not feel nourished", "This subject is not food")]!</span>")

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

/mob/living/simple_animal/slime/verb/Evolve()
	set category = "Slime"
	set desc = "This will let you evolve from baby to adult slime."

	if(stat)
		to_chat(src, "<i>I must be conscious to do this...</i>")
		return
	if(life_stage == SLIME_LIFE_STAGE_ADULT)
		to_chat(src, "<i>I have already evolved...</i>")
		return
	if(amount_grown < SLIME_EVOLUTION_THRESHOLD)
		to_chat(src, "<i>I am not ready to evolve yet...</i>")
		return

	set_life_stage(SLIME_LIFE_STAGE_ADULT)
	amount_grown = 0

	regenerate_icons()
	update_name()

/datum/action/innate/slime/evolve
	name = "Evolve"
	button_icon_state = "slimegrow"
	needs_growth = GROWTH_NEEDED

/datum/action/innate/slime/evolve/Activate()
	var/mob/living/simple_animal/slime/slime_owner = owner
	slime_owner.Evolve()

/mob/living/simple_animal/slime/verb/Reproduce()
	set category = "Slime"
	set desc = "This will make you split into four slimes."

	if(stat != CONSCIOUS)
		balloon_alert(src, "need to be conscious to split!")
		return

	if(!isopenturf(loc))
		balloon_alert(src, "can't reproduce here!")

	if(life_stage != SLIME_LIFE_STAGE_ADULT)
		balloon_alert(src, "not old enough to reproduce!")
		return

	if(amount_grown < SLIME_EVOLUTION_THRESHOLD)
		to_chat(src, "<i>I need to grow myself more before I can reproduce...</i>")
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

		var/mob/living/simple_animal/slime/baby
		baby = new(drop_loc, child_colour)

		if(ckey)
			baby.set_nutrition(new_nutrition) //Player slimes are more robust at spliting. Once an oversight of poor copypasta, now a feature!

		baby.powerlevel = new_powerlevel
		if(i != 1)
			step_away(baby, src)

		baby.set_friends(Friends)
		babies += baby
		baby.mutation_chance = clamp(mutation_chance+(rand(5,-5)),0,100)
		SSblackbox.record_feedback("tally", "slime_babies_born", 1, baby.slime_type.colour)

	var/mob/living/simple_animal/slime/new_slime = pick(babies) // slime that the OG slime will move into.
	new_slime.set_combat_mode(TRUE)

	if(isnull(src.mind))
		new_slime.key = src.key
	else
		src.mind.transfer_to(new_slime)

	qdel(src)

/datum/action/innate/slime/reproduce
	name = "Reproduce"
	button_icon_state = "slimesplit"
	needs_growth = GROWTH_NEEDED

/datum/action/innate/slime/reproduce/Activate()
	var/mob/living/simple_animal/slime/slime_owner = owner
	slime_owner.Reproduce()

#undef SIZE_DOESNT_MATTER
#undef BABIES_ONLY
#undef ADULTS_ONLY
#undef NO_GROWTH_NEEDED
#undef GROWTH_NEEDED
