// A type of antagonist created by the moon ascension
/datum/antagonist/lunatic
	name = "\improper Lunatic"
	hijack_speed = 0
	antagpanel_category = ANTAG_GROUP_HORRORS
	show_in_antagpanel = FALSE
	suicide_cry = "PRAISE THE RINGLEADER!!"
	antag_moodlet = /datum/mood_event/heretics/lunatic
	antag_hud_name = "lunatic"
	can_assign_self_objectives = FALSE
	hardcore_random_bonus = FALSE
	// The mind of the ascended heretic who created us
	var/datum/mind/ascended_heretic
	// The body of the ascended heretic who created us
	var/mob/living/carbon/human/ascended_body
	// Our objective
	var/datum/objective/lunatic/lunatic_obj

/datum/antagonist/lunatic/on_gain()
	// Masters gain an objective before so we dont want duplicates
	for(var/objective in objectives)
		if(!istype(objective, /datum/objective/lunatic))
			continue
		return ..()
	var/datum/objective/lunatic/loony = new()
	objectives += loony
	lunatic_obj = loony
	return ..()

/// Runs when the moon heretic creates us, used to give the lunatic a master
/datum/antagonist/lunatic/proc/set_master(datum/mind/heretic_master, mob/living/carbon/human/heretic_body)
	src.ascended_heretic = heretic_master
	src.ascended_body = heretic_body

	lunatic_obj.master = heretic_master
	lunatic_obj.update_explanation_text()

	to_chat(owner, span_boldnotice("Ruin the lie, save the truth through obeying [heretic_master] the ringleader!"))

/datum/antagonist/lunatic/apply_innate_effects(mob/living/mob_override)
	var/mob/living/our_mob = mob_override || owner.current
	handle_clown_mutation(our_mob, "Ancient knowledge from the moon has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
	our_mob.faction |= FACTION_HERETIC
	add_team_hud(our_mob, /datum/antagonist/lunatic)
	ADD_TRAIT(our_mob, TRAIT_MADNESS_IMMUNE, REF(src))

	var/datum/action/cooldown/lunatic_track/moon_track = new /datum/action/cooldown/lunatic_track()
	var/datum/action/cooldown/spell/touch/mansus_grasp/mad_touch = new /datum/action/cooldown/spell/touch/mansus_grasp()
	mad_touch.Grant(our_mob)
	moon_track.Grant(our_mob)

/datum/antagonist/lunatic/remove_innate_effects(mob/living/mob_override)
	var/mob/living/our_mob = mob_override || owner.current
	handle_clown_mutation(our_mob, removing = FALSE)
	our_mob.faction -= FACTION_HERETIC

// Mood event given to moon acolytes
/datum/mood_event/heretics/lunatic
	description = "THE TRUTH REVEALED, THE LIE SLAIN."
	mood_change = 10

/datum/objective/lunatic
	explanation_text = "Assist your ringleader. If you are seeing this, scroll up in chat for who that is and report this"
	var/datum/mind/master
	// If the person with this objective is a lunatic master
	var/is_master = FALSE

/datum/objective/lunatic/update_explanation_text()
	. = ..()
	if(is_master)
		explanation_text = "Lead your lunatics to further your own goals!"
		return
	explanation_text = "Assist your ringleader [master], do not harm fellow lunatics"

// Lunatic master
/datum/antagonist/lunatic/master
	name = "\improper Ringleader"
	antag_hud_name = "lunatic_master"

/datum/antagonist/lunatic/master/on_gain()
	var/datum/objective/lunatic/loony = new()
	objectives += loony
	loony.is_master = TRUE
	loony.update_explanation_text()
	return ..()

/datum/antagonist/lunatic/master/apply_innate_effects(mob/living/mob_override)
	var/mob/living/our_mob = mob_override || owner.current
	add_team_hud(our_mob, /datum/antagonist/lunatic)
