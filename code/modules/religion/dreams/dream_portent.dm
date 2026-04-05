/datum/religion_rites/dream_portent
	name = "Dream Portent"
	desc = "Immediately fall into a slumber and receive a portent of the future. \
		The vision may be difficult to interpret, but will likely come true in some form. \
		Any form of harm will awaken you and disrupt the vision."
	favor_cost = 50
	rite_flags = NONE
	ritual_length = 6 SECONDS

/datum/religion_rites/dream_portent/New()
	. = ..()
	ritual_invocations = list(
		"O great shepard [GLOB.deity], grant me a vision of the future!..",
		"That our flock may persevere through the trials to come...",
	)

/datum/religion_rites/dream_portent/can_afford(mob/living/user)
	if(!..())
		return FALSE
	if(!iscarbon(user))
		to_chat(user, span_warning("You are not the sort of creature that can receive a portent."))
		return FALSE
	return TRUE

/datum/religion_rites/dream_portent/invoke_effect(mob/living/user, atom/religious_tool)
	for(var/obj/item/book/bible/bible in user.held_items)
		ADD_TRAIT(bible, TRAIT_NODROP, type)

	if(!user.SetSleeping(10 SECONDS))
		to_chat(user, span_warning("You fail to fall asleep."))
		for(var/obj/item/book/bible/bible in user.held_items)
			REMOVE_TRAIT(bible, TRAIT_NODROP, type)
		return FALSE

	user.visible_message(span_notice("[user] suddenly falls into a deep slumber, [user.p_their()] eyes fluttering..."))
	user.adjust_drowsiness(30 SECONDS)
	return ..()

/datum/religion_rites/dream_portent/post_invoke_effects(mob/living/user, atom/religious_tool)
	. = ..()
	RegisterSignal(user, COMSIG_PRE_DREAMING, PROC_REF(add_portent))
	RegisterSignal(user, COMSIG_START_DREAMING, PROC_REF(check_portent))
	RegisterSignal(user, COMSIG_END_DREAMING, PROC_REF(end_portent))
	RegisterSignal(user, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(interrupt_portent))
	addtimer(CALLBACK(src, PROC_REF(force_dream), user), rand(2, 5) SECONDS, TIMER_DELETE_ME) // force the dream to start immediately

/datum/religion_rites/dream_portent/proc/force_dream(mob/living/carbon/dreamer)
	if(!iscarbon(dreamer) || HAS_TRAIT(dreamer, TRAIT_DREAMING))
		return // dreamed naturally already
	dreamer.dream()

/datum/religion_rites/dream_portent/proc/add_portent(mob/living/carbon/dreamer, list/dream_pool)
	SIGNAL_HANDLER

	dream_pool[new /datum/dream/portent] = 2000

/datum/religion_rites/dream_portent/proc/check_portent(mob/living/carbon/dreamer, datum/dream/current_dream)
	SIGNAL_HANDLER

	if(istype(current_dream, /datum/dream/portent))
		return

	to_chat(dreamer, span_cyan("Your mind wanders, yet you receive no clear vision... You must try again later."))
	refund(0.8)
	dreamer.adjust_drowsiness(10 SECONDS)
	dreamer.add_mood_event("dream_failed", /datum/mood_event/dream_failed)

/datum/religion_rites/dream_portent/proc/interrupt_portent(mob/living/carbon/dreamer, damage_amount)
	SIGNAL_HANDLER

	if(!prob(damage_amount * 10)) // higher damage = higher chance to interrupt
		return

	to_chat(dreamer, span_warning("Your dream is interrupted as you are harmed!"))
	dreamer.SetSleeping(0)
	dreamer.adjust_drowsiness(10 SECONDS)
	dreamer.add_mood_event("dream_interrupted", /datum/mood_event/dream_interrupted)

/datum/religion_rites/dream_portent/proc/end_portent(mob/living/carbon/dreamer, datum/dream/current_dream)
	SIGNAL_HANDLER

	for(var/obj/item/book/bible/bible in dreamer.held_items)
		REMOVE_TRAIT(bible, TRAIT_NODROP, type)

	qdel(src)

/datum/mood_event/dream_interrupted
	mood_change = -2
	description = "I was rudely awakened from my dreams!"
	timeout = 5 MINUTES

/datum/mood_event/dream_failed
	mood_change = -2
	description = "I couldn't receive a clear vision from my dreams!"
	timeout = 5 MINUTES

/datum/dream/portent
	weight = 0
	sleep_until_finished = TRUE

/datum/dream/portent/GenerateDream(mob/living/carbon/dreamer)
	. = list()
	. += span_cyan("you receive a portent of the future...")

	var/list/portent_types = list(
		"[GLOB.deity] greets you warmly" = "[GLOB.deity] bids you farewell, though you feel their presence watch over you",
		"a crystal ball reveals a vision of the future" = "ultimately, the crystal ball returns to its normal, opaque state",
		"a divine light blinds you, revealing glimpses of what is to come" = "finally, the light fades, leaving you with a lingering warmth",
		"a full moon illuminates the sky" = "the moon crosses the horizon, bringing forth a new dawn",
		"a mysterious figure appears, cloaked in shadow" = "they depart, leaving you with a sense of [pick("wonder", "dread", "curiosity", "foreboding")]",
		"an incomprehensible entity envelops you, showing you visions of the past, present, and future" = "the entity releases you, leaving you with a sense of awe and fear",
		"an old [pick("man", "woman", "prophet", "oracle")] approaches you, offering cryptic advice" = "they vanish before you can ask any questions",
		"the stars align in a way you've never seen before" = "finally, the stars return to their normal constellations",
		"the trees ahead parts to reveal a hidden path" = "ultimately, you lose the path as the trees sway back into place",
		"walking through a featureless landscape, shapes begin to form" = "finally, the shapes fade away, leaving alone in the void",
		"you see yourself sleeping peacefully" = "finally, you see yourself waking up calmly",
		"your third eye opens to reveal a hidden truth" = "finally, your third eye closes, but the vision lingers in your mind",
	)
	var/picked_portent = pick(portent_types)

	. += span_cyan(picked_portent)
	for(var/part in get_portent(dreamer))
		. += span_cyan(part)
	. += span_cyan(portent_types[picked_portent])

/datum/dream/portent/proc/get_portent(mob/living/carbon/dreamer)
	if(prob(1))
		GLOB.religious_sect.adjust_favor(25, dreamer)
		return pick(
			list("reply hazy", "try again later"),
			list("ask again later"),
			list("better not tell you now"),
			list("cannot predict now"),
			list("concentrate and ask again"),
		)

	for(var/datum/antagonist/nightmare/nightmare as anything in GLOB.antagonists)
		if(nightmare.owner?.current?.stat == CONSCIOUS)
			return list("A terrifying nightmare lurks", "it stalks you", "it waits for the perfect moment to strike", "its presence fills you with dread")

	for(var/datum/team/cult/cult as anything in GLOB.antagonist_teams)
		if(cult.cult_ascendent)
			return list("The Blood Geometer, Nar'sie, invades your dream", "her pressence overwhelming and suffocating", "she eyes you greedily")

	for(var/datum/antagonist/heretic/heretic in GLOB.antagonists)
		if(heretic.ascended && heretic.owner?.current?.stat == CONSCIOUS)
			return list("The doors of the Mansus loom ahead of you", "intricately decorated, and cracked open", "its presence oppressive and suffocating")

	for(var/datum/antagonist/wizard/wizard in GLOB.antagonists)
		if(wizard.owner?.current?.stat != CONSCIOUS)
			return
		if(wizard.ritual?.times_completed < GRAND_RITUAL_RUNES_WARNING_POTENCY)
			return

		var/wizname = pick("Archmage", "Magus", "Sorcerer", "Conjurer", "Warlock")
		if(wizard.ritual.times_completed == GRAND_RITUAL_FINALE_COUNT)
			return list(
				"The [wizname] has completed their ritual",
				"you see them standing triumphantly amidst the ruins of the station",
				"their power absolute and unchallenged",
			)

		if(wizard.ritual.times_completed == GRAND_RITUAL_IMMINENT_FINALE_POTENCY)
			return list(
				"The [wizname]'s ritual is nearly complete",
				"you can energy flowing from them like a swarm of locusts",
				"consuming everything in its path",
			)

		return list(
			"A powerful [wizname] orbits the station",
			"with no sense of right or wrong",
			"ready to sow chaos at a moment's notice",
		)

	for(var/obj/machinery/nuclearbomb/bomb as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/nuclearbomb))
		if(bomb.timing)
			return pick(
				list("you see", "a supernova", "bright and blinding", "consuming everything in an instant"),
				list("you see", "a mushroom cloud on the horizon", "a sign of devastation and ruin"),
				list("you see", "a ticking clock", "counting down to an unknown but inevitable disaster"),
			)

	for(var/mob/living/carbon/human/clone as anything in GLOB.human_list)
		if(clone != dreamer && clone.real_name == dreamer.real_name && clone.stat == CONSCIOUS && prob(50))
			return list("you see yourself", "in a foggy mirror", "the reflection, barely visible")

	if(prob(length(dreamer.get_all_orbiters()) * 20))
		return list(
			"you feel a ghostly [pick("presence", "entity", "figure")]",
			"it seems to be trying to communicate with you",
			"yet you can't comprehend its message",
			"a sense of sadness and longing washes over you",
		)

	if(IS_HERETIC(dreamer) && prob(50))
		var/datum/antagonist/heretic/heretic = GET_HERETIC(dreamer)
		switch(heretic.heretic_path?.route)
			if(PATH_START)
				return list("you see", "a fork in the road ahead", "the path before you uncertain and full of potential")
			if(PATH_ASH)
				return list("you see", "a barren wasteland ahead", "burned trees line the horizon", "the air thick with smoke and ash", "a bleak and desolate sight")
			if(PATH_FLESH)
				return list("you see", "a legion of amalgamations ahead", "twisted and grotesque", "marching in unison towards an unknown destination")
			if(PATH_VOID)
				return list("you see", "nothingness ahead", "a void that seems to swallow all light and hope", "the silence deafening and oppressive")
			if(PATH_COSMIC)
				return list("you see", "the birth of a new star", "radiant and full of potential", "an awe-inspiring sight")
			if(PATH_BLADE)
				return list("you see", "a towering fortress ahead", "its walls lined with stalwart defenders", "each and every one bowing in respect to you")
			if(PATH_LOCK)
				return list("you see", "and endless labyrinth", "the walls shifting and changing as you navigate it", "a test of your resolve and cunning")
			if(PATH_MOON)
				return list("you see", "an everlasting carnival", "the air filled with joy and laughter", "but with an undercurrent of melancholy and longing")
			else
				return list("you see", "a large door ahead", "intricately decorated and emanating a powerful aura", "but never opening", "no matter how long you wait")

	var/dead = 0
	for(var/mob/deceased as anything in GLOB.player_list)
		if(deceased.stat == DEAD)
			dead += 1

	switch(dead / length(GLOB.joined_player_list))
		if(0.25 to 0.5)
			return pick(
				list("you find yourself", "in a small graveyard", "humble in size but lovingly maintained", "with fresh flowers on the graves"),
				list("you see", "a vision of spirits", "floating throughout the station"),
			)
		if(0.5 to 0.75)
			return pick(
				list("you find yourself", "in a dimly lit hallway", "with a sense of dread in the air"),
				list("you see", "a vision of an encroaching darkness", "threatening you eerily"),
			)
		if(0.75 to 0.9)
			return pick(
				list("you find yourself", "in a lonely ballroom", "barely lit with flickering lights"),
				list("you see", "a picture of a silent battlefield", "no clear victor, but heavy losses on all sides"),
			)
		if(0.9 to 1)
			return list("you see", "a vision of yourself, alone", "in a desolate wasteland", "with no signs of life or hope in sight")

	if(prob(50) || GLOB.communications_controller.announced_greenshift)
		if(length(GLOB.admins) >= 5)
			return list("you see", "a gathering of powerful beings in the distance", "their intentions unclear")

		switch(SSdynamic.current_tier.tier)
			if(0)
				return list("you see", "a flourishing field", "teeming with life and vitality", "a symbol of hope for the future")
			if(1)
				return pick(
					list("you see", "a lone figure in the distance", "shrouded in mystery"),
					list("you see", "a [pick("beast", "monster", "animal")] stalking through the shadows", "its intentions unknown"),
					list("you see", "a [pick("fog", "haze", "cloud")] rolling in", "obscuring everything in its path"),
				)
			if(2)
				return pick(
					list("you find yourself", "in a branching forest", "dark and with many potential paths"),
					list("you find yourself", "in an old city", "still bustling with activity", "but with an omnipresent feel of decay"),
				)
			if(3)
				return list("you find yourself", "in a burning city", "flames reaching high", "but everyone doing their best to survive")
			if(4)
				return list("you find yourself", "in a chaotic battlefield", "with no clear sides or victors", "only endless conflict and suffering")

	var/max_law_changes = 0
	for(var/mob/living/silicon/ai/ai as anything in GLOB.ai_list)
		max_law_changes = max(max_law_changes, ai.law_change_counter)

	if(prob(50) && max_law_changes >= 15)
		return pick(
			list("you see", "a twisted and sickly tree", "with branches that seem to reach into every aspect of the station", "its roots drip with a inky black liquid"),
			list("you see", "a corrupt political figure", "surrounded by sycophants and puppets", "pulling the strings from behind the scenes"),
			list("you see", "buzzing electronics", "wires that seem to snake off into the distance", "flickering with an eerie, unnatural light"),
		)

	if(EMERGENCY_ESCAPED_OR_ENDGAMED)
		return list("you see", "a new beginning on the horizon", "it feels warm")

	if(EMERGENCY_PAST_POINT_OF_NO_RETURN)
		return list("you see", "salvation just out of reach")

	return list("you see", "nothing of note", "but have a lingering feeling of unease about the future")
