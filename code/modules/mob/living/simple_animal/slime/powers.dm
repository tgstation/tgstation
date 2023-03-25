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
	var/mob/living/simple_animal/slime/S = owner
	if(needs_growth == GROWTH_NEEDED)
		if(S.amount_grown >= SLIME_EVOLUTION_THRESHOLD)
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
	if(CanFeedon(victim))
		Feedon(victim)
		return TRUE
	return FALSE

/datum/action/innate/slime/feed
	name = "Feed"
	button_icon_state = "slimeeat"


/datum/action/innate/slime/feed/Activate()
	var/mob/living/simple_animal/slime/S = owner
	S.Feed()

/mob/living/simple_animal/slime/proc/CanFeedon(mob/living/meal, silent = FALSE)
	if(!Adjacent(meal))
		return FALSE

	if(buckled)
		Feedstop()
		return FALSE

	if(issilicon(meal) || meal.mob_biotypes & MOB_ROBOTIC)
		return FALSE

	if(isanimal(meal))
		var/mob/living/simple_animal/simple_meal = meal
		if(simple_meal.damage_coeff[TOX] <= 0 && simple_meal.damage_coeff[CLONE] <= 0) //The creature wouldn't take any damage, it must be too weird even for us.
			if(silent)
				return FALSE
			to_chat(src, "<span class='warning'>[pick("This subject is incompatible", \
				"This subject does not have life energy", "This subject is empty", \
				"I am not satisified", "I can not feed from this subject", \
				"I do not feel nourished", "This subject is not food")]!</span>")
			return FALSE
	else if(isbasicmob(meal))
		var/mob/living/basic/basic_meal = meal
		if(basic_meal.damage_coeff[TOX] <= 0 && basic_meal.damage_coeff[CLONE] <= 0)
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
	if(transformeffects & SLIME_EFFECT_SILVER)
		return FALSE
	return TRUE

/mob/living/simple_animal/slime/proc/Feedon(mob/living/M)
	M.unbuckle_all_mobs(force=1) //Slimes rip other mobs (eg: shoulder parrots) off (Slimes Vs Slimes is already handled in CanFeedon())
	if(M.buckle_mob(src, force=TRUE))
		layer = M.layer+0.01 //appear above the target mob
		M.visible_message(span_danger("[name] latches onto [M]!"), \
						span_userdanger("[name] latches onto [M]!"))
	else
		to_chat(src, span_warning("<i>I have failed to latch onto the subject!</i>"))

/mob/living/simple_animal/slime/proc/Feedstop(silent = FALSE, living=1)
	if(buckled)
		if(!living)
			to_chat(src, "<span class='warning'>[pick("This subject is incompatible", \
			"This subject does not have life energy", "This subject is empty", \
			"I am not satisified", "I can not feed from this subject", \
			"I do not feel nourished", "This subject is not food")]!</span>")
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
	if(!is_adult)
		if(amount_grown >= SLIME_EVOLUTION_THRESHOLD)
			is_adult = 1
			maxHealth = 200
			if(transformeffects & SLIME_EFFECT_METAL)
				maxHealth = round(maxHealth * 1.3)
			amount_grown = 0
			for(var/datum/action/innate/slime/evolve/E in actions)
				E.Remove(src)
			var/datum/action/innate/slime/reproduce/reproduce_action = new
			reproduce_action.Grant(src)
			regenerate_icons()
			update_name()
		else
			to_chat(src, "<i>I am not ready to evolve yet...</i>")
	else
		to_chat(src, "<i>I have already evolved...</i>")

/datum/action/innate/slime/evolve
	name = "Evolve"
	button_icon_state = "slimegrow"
	needs_growth = GROWTH_NEEDED

/datum/action/innate/slime/evolve/Activate()
	var/mob/living/simple_animal/slime/S = owner
	S.Evolve()

/mob/living/simple_animal/slime/verb/Reproduce()
	set category = "Slime"
	set desc = "This will make you split into four Slimes."

	if(stat)
		to_chat(src, "<i>I must be conscious to do this...</i>")
		return

	if(is_adult)
		if(amount_grown >= SLIME_EVOLUTION_THRESHOLD)
			if(stat)
				to_chat(src, "<i>I must be conscious to do this...</i>")
				return

			var/list/babies = list()
			var/new_nutrition = round(nutrition * 0.9)
			var/new_powerlevel = round(powerlevel / 4)

			var/turf/drop_loc = drop_location()
			var/childamount = 4
			var/new_adult = FALSE
			if(transformeffects & SLIME_EFFECT_GREY)
				childamount++
			if(transformeffects & SLIME_EFFECT_CERULEAN)
				childamount = 2
				new_nutrition = round(nutrition * 0.5)
				new_powerlevel = round(powerlevel / 2)
				new_adult = TRUE
			for(var/i=1, i<=childamount, i++)
				var/force_colour = FALSE
				var/step_away = TRUE
				if(i == 1)
					step_away = FALSE
					if(transformeffects & SLIME_EFFECT_BLUE)
						force_colour = TRUE
				if(transformeffects & SLIME_EFFECT_CERULEAN)
					force_colour = TRUE
				var/mob/living/simple_animal/slime/M = make_baby(drop_loc, new_adult, new_nutrition, new_powerlevel, force_colour, step_away)
				babies += M

			var/mob/living/simple_animal/slime/new_slime = pick(babies)
			new_slime.set_combat_mode(TRUE)
			if(src.mind)
				src.mind.transfer_to(new_slime)
			else
				new_slime.key = src.key
			qdel(src)
		else
			to_chat(src, "<i>I am not ready to reproduce yet...</i>")
	else
		to_chat(src, "<i>I am not old enough to reproduce yet...</i>")

/mob/living/simple_animal/slime/proc/make_baby(drop_loc, new_adult, new_nutrition, new_powerlevel, force_original_colour=FALSE, step_away=TRUE)
	var/child_colour = colour
	if(!force_original_colour)
		if(prob(mutation_chance))
			if(transformeffects & SLIME_EFFECT_PYRITE)
				slime_mutation = mutation_table(pick(slime_colours - list("rainbow")))
			else if(mutation_chance >= 100)
				child_colour = "rainbow"
			child_colour = slime_mutation[rand(1,4)]
		else
			child_colour = colour
	var/mob/living/simple_animal/slime/M = new(drop_loc, child_colour, new_adult)
	M.transformeffects = transformeffects
	if(ckey || transformeffects & SLIME_EFFECT_CERULEAN)
		M.set_nutrition(new_nutrition) //Player slimes are more robust at spliting. Once an oversight of poor copypasta, now a feature!
	M.powerlevel = new_powerlevel
	if(transformeffects & SLIME_EFFECT_METAL)
		M.maxHealth = round(M.maxHealth * 1.3)
		M.health = M.maxHealth
	if(transformeffects & SLIME_EFFECT_PINK)
		M.grant_language(/datum/language/common, TRUE, TRUE)
		var/datum/language_holder/LH = M.get_language_holder()
		LH.selected_language = /datum/language/common
	if(transformeffects & SLIME_EFFECT_LIGHT_PINK)
		M.master = master
	M.Friends = Friends.Copy()
	if(step_away)
		step_away(M,src)
	M.mutation_chance = clamp(mutation_chance+(rand(5,-5)),0,100)
	SSblackbox.record_feedback("tally", "slime_babies_born", 1, M.colour)
	return M

/mob/living/simple_animal/slime/proc/random_tp()
	var/power = rand(1,powerlevel)
	do_teleport(src, get_turf(src), power, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)
	powerlevel -= power

/datum/action/innate/slime/reproduce
	name = "Reproduce"
	button_icon_state = "slimesplit"
	needs_growth = GROWTH_NEEDED

/datum/action/innate/slime/reproduce/Activate()
	var/mob/living/simple_animal/slime/S = owner
	S.Reproduce()
