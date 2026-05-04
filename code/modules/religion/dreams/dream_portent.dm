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
		"O great shepherd [GLOB.deity], grant me a vision of the future!..",
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
	if(!user.SetSleeping(10 SECONDS))
		to_chat(user, span_warning("You fail to fall asleep."))
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

	// removes any pre-existing vague portents in the dream pool so we can give the real deal
	for(var/datum/dream/random/vague_portent/existing in dream_pool)
		dream_pool -= existing

	dream_pool[new /datum/dream/specific_portent()] = 2000

/datum/religion_rites/dream_portent/proc/check_portent(mob/living/carbon/dreamer, datum/dream/current_dream)
	SIGNAL_HANDLER

	if(istype(current_dream, /datum/dream/specific_portent))
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

	qdel(src)

/datum/mood_event/dream_interrupted
	mood_change = -2
	description = "I was rudely awakened from my dreams!"
	timeout = 5 MINUTES

/datum/mood_event/dream_failed
	mood_change = -2
	description = "I couldn't receive a clear vision from my dreams!"
	timeout = 5 MINUTES

/datum/dream/specific_portent
	weight = 0
	sleep_until_finished = TRUE

/datum/dream/specific_portent/GenerateDream(mob/living/carbon/dreamer)
	. = list()
	. += span_cyan("a portent of the future")

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
		"walking through a featureless landscape, shapes begin to form" = "finally, the shapes fade away, leaving you alone in the void",
		"you see yourself sleeping peacefully" = "finally, you see yourself waking up calmly",
		"your third eye opens to reveal a hidden truth" = "finally, your third eye closes, but the vision lingers in your mind",
	)
	var/picked_portent = pick(portent_types)

	. += span_cyan(picked_portent)
	for(var/part in get_portent(dreamer))
		. += span_cyan(part)
	. += span_cyan(portent_types[picked_portent])

/datum/dream/specific_portent/proc/get_portent(mob/living/carbon/dreamer)
	if(prob(1))
		GLOB.religious_sect.adjust_favor(25, dreamer)
		return pick(list(
			list("reply hazy", "try again later"),
			list("ask again later"),
			list("better not tell you now"),
			list("cannot predict now"),
			list("concentrate and ask again"),
		))

	for(var/datum/antagonist/nightmare/nightmare in GLOB.antagonists)
		if(nightmare.owner?.current?.stat == CONSCIOUS)
			return pick(list(
				list("you have a terrible nightmare", "filled with indescribable horrors", "leaving you with a lingering sense of dread"),
				list("you have a terrible nightmare", "filled with visions of your own death", "leaving you with a lingering sense of doom"),
				list("you have a terrible nightmare", "filled with horrible memories of your past", "leaving you with a lingering sense of sadness"),
				list("you have a terrible nightmare", "filled with fear of the unknown", "leaving you with a lingering sense of anxiety"),
				list("you have a terrible nightmare", "filled with stabbing pain and suffocating darkness", "leaving you with a lingering sense of panic"),
			))

	for(var/datum/team/cult/cult in GLOB.antagonist_teams)
		if(cult.cult_ascendent)
			return list("the Blood Geometer, Nar'sie, invades your dream", "her pressence overwhelming and suffocating", "she eyes you greedily")

	for(var/datum/antagonist/heretic/heretic in GLOB.antagonists)
		if(!heretic.ascended)
			continue
		if(heretic.owner?.current?.stat != CONSCIOUS)
			return list(
				"the doors of the Mansus loom ahead of you",
				"intricately decorated - but cracked, broken, and sealed shut",
				"a great [IS_HERETIC(dreamer) ? "force" : "evil"] locked away for good",
			)

		var/list/heretic_text = list("the doors of the Mansus loom ahead of you", "intricately decorated - and ajar", "you look through the crack")
		switch(prob(75) ? heretic.heretic_path.route : null)
			if(PATH_ASH)
				heretic_text += "beyond it, you see a barren wasteland"
				heretic_text += "all life long gone, scorched to ash and dust"
				heretic_text += "you can hardly breathe through the smog"
			if(PATH_FLESH)
				heretic_text += "beyond it, you see a vast sea of blood"
				heretic_text += "the screams of the drowning fill the air"
				heretic_text += "the blood laps at your feet"
			if(PATH_VOID)
				heretic_text += "beyond it, a vast emptiness stretches out in all directions"
				heretic_text += "the silence is deafening"
				heretic_text += "you know you are not alone"
			if(PATH_COSMIC)
				heretic_text += "beyond it, you see the birth and death of stars, galaxies colliding in a cosmic dance"
				heretic_text += "the beauty of it all is overwhelming"
				heretic_text += "you feel insignificant"
			if(PATH_BLADE)
				heretic_text += "beyond it, you see a great battle unfolding"
				heretic_text += "countless warriors grappling in an endless war"
				heretic_text += "the sound of clashing steel and cries of the fallen fill the air"
			if(PATH_LOCK)
				heretic_text += "beyond it, you see an endless labyrinth"
				heretic_text += "the walls shifting and changing as you navigate it"
				heretic_text += "no matter which turn you take, you cannot find an exit"
			if(PATH_MOON)
				heretic_text += "beyond it, you bear witness to a grand carnival"
				heretic_text += "filled with strange sights and smells, but endless joy and laughter"
				heretic_text += "you can't shake the feeling something is wrong"
			else
				heretic_text += "what lies beyond cannot be comprehended"
				heretic_text += "the sheer magnitude of overwhelms you"
				heretic_text += "you feel a strange mix of awe and terror"

		return heretic_text

	for(var/datum/antagonist/wizard/wizard in GLOB.antagonists)
		if(wizard.owner?.current?.stat != CONSCIOUS)
			return
		if(wizard.ritual?.times_completed < GRAND_RITUAL_RUNES_WARNING_POTENCY)
			if(prob(1))
				return list(
					"a garish fool puts on a show",
					"many lament their antics, but some are amused",
					"they seem to have no sense of right or wrong",
					"what an asshole",
				)
			return

		if(wizard.ritual.times_completed == GRAND_RITUAL_FINALE_COUNT)
			return list(
				"the magician appears once more",
				"they ignore you, bowing to an unseen audience",
				"you hear a crowd cheering and applause",
				"a bright light envelops you, blinding you",
				"when your vision returns, the magician is gone",
			)

		if(wizard.ritual.times_completed == GRAND_RITUAL_IMMINENT_FINALE_POTENCY)
			return list(
				"the magician greets you once more, grinning",
				"they tell you the grand finale is near",
				"you can feel the air around you crackling with magical energy",
				"they magician winks, promising an unforgettable show",
				"before you can question, they vanish once again",
			)

		return list(
			"a robed figure manifests in your dream",
			"they introduce themselves as the magician",
			"a demonstration of their powers leaves you in awe",
			"they leave as suddenly as they arrived",
		)

	for(var/obj/machinery/nuclearbomb/bomb as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/nuclearbomb))
		if(bomb.timing)
			return pick(list(
				list("you see", "a supernova", "bright and blinding", "consuming everything in an instant"),
				list("you see", "a mushroom cloud on the horizon", "a sign of devastation and ruin"),
				list("you see", "a ticking clock", "counting down to an inevitable disaster"),
				list("you see", "a looming tower atop a rocky mountain", "a lightning strikes it, bringing it down", "a sign of imminent calamity"),
			))

	for(var/obj/item/disk/nuclear/nuke_disk as anything in SSpoints_of_interest.real_nuclear_disks)
		var/area/disk_loc = get_area(nuke_disk)
		if(!istype(disk_loc, /area/station) && !istype(disk_loc, /area/space))
			return pick(list(
				list("you see", "a dying star", "slowly dimming", "on the verge of collapse"),
				list("you see", "a fool, dancing aimlessly", "they holds a ticking bomb", "a sign of recklessness"),
				list("you see", "a hanging man", "swaying gently in the breeze", "a sign of surrender"),
				list("you see", "a looming tower atop a rocky mountain", "it rains heavily around you", "a sign of calamity"),
			))

	for(var/mob/living/carbon/human/clone as anything in GLOB.human_list)
		if(clone != dreamer && clone.real_name == dreamer.real_name && clone.stat == CONSCIOUS && prob(50))
			return list(
				"you see yourself",
				"in a foggy mirror",
				"the reflection is warped and distorted",
				"but unquestionably you",
			)

	if(prob(length(dreamer.get_all_orbiters()) * 20))
		return list(
			"you feel a ghostly [pick("presence", "entity", "figure")]",
			"it seems to be trying to communicate with you",
			"yet you can't comprehend its message",
			"a sense of sadness and longing washes over you",
		)

	if(IS_HERETIC(dreamer) && prob(50))
		var/datum/antagonist/heretic/heretic = GET_HERETIC(dreamer)
		if(prob(75) && !heretic.feast_of_owls)
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

		return list("you see", "a large door ahead", "intricately decorated and emanating a powerful aura", "but never opening", "no matter how long you wait")

	var/dead = 0
	for(var/mob/deceased as anything in GLOB.player_list)
		if(deceased.stat == DEAD)
			dead += 1

	switch(dead / length(GLOB.joined_player_list))
		if(0.25 to 0.5)
			return pick(list(
				list("you find yourself", "in a small graveyard", "humble in size but lovingly maintained", "with fresh flowers on the graves"),
				list("you see", "a vision of spirits", "floating throughout the station"),
			))
		if(0.5 to 0.75)
			return pick(list(
				list("you find yourself", "in a dimly lit hallway", "with a sense of dread in the air"),
				list("you see", "a vision of an encroaching darkness", "threatening you eerily"),
			))
		if(0.75 to 0.9)
			return pick(list(
				list("you find yourself", "in a lonely ballroom", "barely lit with flickering lights"),
				list("you see", "a picture of a silent battlefield", "no clear victor, but heavy losses on all sides"),
			))
		if(0.9 to 1)
			return pick(list(
				list("you find yourself", "alone", "no sight but your darkness", "no sound but your heartbeat", "a bleak and hopeless vision"),
				list("you see", "a vision of yourself, alone", "in a desolate wasteland", "with no signs of life or hope in sight"),
			))

	var/max_law_changes = 0
	for(var/mob/living/silicon/ai/ai as anything in GLOB.ai_list)
		max_law_changes = max(max_law_changes, ai.law_change_counter)

	if(prob(clamp((max_law_changes - 10) * 10, 0, 50)))
		return pick(list(
			list("you see", "a twisted and sickly tree", "with branches that seem to reach into every aspect of the station", "its roots drip with a inky black liquid"),
			list("you see", "a corrupt political figure", "surrounded by sycophants and puppets", "pulling the strings from behind the scenes"),
			list("you see", "buzzing electronics", "wires that seem to snake off into the distance", "it bathes you in red light and static"),
		))

	if(EMERGENCY_ESCAPED_OR_ENDGAMED)
		return list("you see", "a new beginning on the horizon", "it feels warm")

	if(EMERGENCY_PAST_POINT_OF_NO_RETURN)
		return list("you see", "salvation just out of reach")

	if(prob(75) || GLOB.communications_controller.announced_greenshift)
		if(length(GLOB.admins) >= 5)
			return list("you see", "a gathering of powerful beings in the distance", "their intentions unclear")

		switch(SSdynamic.current_tier.tier)
			if(0)
				return list("you see", "a flourishing field", "teeming with life and vitality", "a symbol of hope for the future")
			if(1)
				return pick(list(
					list("you see", "a lone figure in the distance", "shrouded in mystery"),
					list("you see", "a [pick("beast", "monster", "animal")] stalking through the shadows", "its intentions unknown"),
					list("you see", "a [pick("fog", "haze", "cloud")] rolling in", "obscuring everything in its path"),
				))
			if(2)
				return pick(list(
					list("you find yourself", "in a branching forest", "dark and with many potential paths"),
					list("you find yourself", "in an old city", "still bustling with activity", "but with an omnipresent feel of decay"),
				))
			if(3)
				return list("you find yourself", "in a burning city", "flames reaching high", "but everyone doing their best to survive")
			if(4)
				return list("you find yourself", "in a chaotic battlefield", "with no clear sides or victors", "only endless conflict and suffering")

	return list("you see", "nothing of note", "but have a lingering feeling of unease about the future")

/datum/dream/random/vague_portent
	weight = 0
	sleep_until_finished = TRUE

/datum/dream/random/vague_portent/get_dream_nouns(mob/living/carbon/dreamer)
	var/list/antags = list()
	for(var/datum/antagonist/antag as anything in GLOB.antagonists)
		antags |= LOWER_TEXT(antag.jobban_flag || antag.pref_flag)

	if(prob(80) || !length(antags))
		for(var/datum/dynamic_ruleset/ruleset as anything in subtypesof(/datum/dynamic_ruleset))
			antags |= LOWER_TEXT(initial(ruleset.jobban_flag) || initial(ruleset.pref_flag))

	// chance to make nightmares the focus of the dream
	var/nightmare_id = /datum/antagonist/nightmare::jobban_flag || /datum/antagonist/nightmare::pref_flag
	if(prob(20) && (LOWER_TEXT(nightmare_id) in antags))
		return list(LOWER_TEXT(nightmare_id))

	return antags
