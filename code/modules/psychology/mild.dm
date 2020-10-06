/datum/disorder/kleptomania
	name = "Kleptomania"
	desc = "Disorder classified by an unresistable urge to steal items."
	max_resistance = MED_RESISTANCE
	trait_mods = list(TRAIT_FEARLESS = -5,TRAIT_RELAXED = -3,TRAIT_TENSED = 1,TRAIT_CONTROLLED = 2)

/datum/disorder/kleptomania/on_life()
	. = ..()
	var/mob/living/carbon/human/humie = owner.current
	if(prob(10) && !humie.get_active_held_item())
		var/list/steal_list = list()
		for(var/obj/item/item in spiral_range_turfs(1,humie))
			steal_list += item
		var/obj/item/item_to_steal = pick(steal_list)
		item_to_steal.attack_hand(humie)

/datum/disorder/psychosis
	name = "Chronic Hallucinatory Psychosis"
	desc = "Disorder classified by constant hallucinations and speech slurring."
	max_resistance = MED_RESISTANCE
	trait_mods = list(TRAIT_FEARLESS = -2,TRAIT_RELAXED = 1,TRAIT_TENSED = -1,TRAIT_CONTROLLED = 2)

/datum/disorder/psychosis/on_life()
	. = ..()
	var/mob/living/carbon/human/humie = owner.current
	humie.hallucination += 2
	if(prob(10))
		humie.slurring += 10
	if(prob(10))
		humie.stuttering += 5

	if(prob(5))
		var/msg = pick("You feel someone is watching you... "," You hear a whisper of someone talking about you... "," You notice other people looking at you...","You notice people smirking at you...", "You feel being watched from the shadows...")
		to_chat(humie,"<span class='warning'>[msg]</warning>")

/datum/disorder/restless
	name = "Restless Movement Disorder"
	desc = "Disorder classified by jitteryness and inability to stop moving."
	max_resistance = MED_RESISTANCE
	trait_mods = list(TRAIT_FEARLESS = 0,TRAIT_RELAXED = 2,TRAIT_TENSED = -2,TRAIT_CONTROLLED = 1)
	var/last_turf

/datum/disorder/restless/on_add(mob/living/carbon/human/human_owner)
	. = ..()
	last_turf = get_turf(human_owner)

/datum/disorder/restless/on_life()
	. = ..()
	var/mob/living/carbon/human/humie = owner.current
	var/current_turf = get_turf(owner.current)
	if(current_turf == last_turf)
		if(prob(5))
			to_chat(humie,"<span class='warning'>You can't just stop moving!</warning>")
		humie.Jitter(5)
		if((humie.mobility_flags & MOBILITY_MOVE) && !ismovable(humie.loc))
			for(var/i in 1 to 4)
				step(humie, pick(GLOB.cardinals))
	last_turf = current_turf

/datum/disorder/hoarder
	name = "Compulsive Hoarding Disorder"
	desc = "Disorder classified by a corrosive need to hoard a specific type of object."
	max_resistance = MED_RESISTANCE
	trait_mods = list(TRAIT_FEARLESS = 0,TRAIT_RELAXED = 2,TRAIT_TENSED = -2,TRAIT_CONTROLLED = 1)

	var/list/obj/item/possible_items = list(/obj/item/toy,
	/obj/item/stamp,
	/obj/item/shard,
	/obj/item/reagent_containers/food/drinks/bottle,
	/obj/item/kitchen/knife)
	var/list/obj/item/needed_item
	var/greed_level = 0

/datum/disorder/hoarder/on_life()
	. = ..()
	if(!check_items())
		SEND_SIGNAL(owner.current, COMSIG_ADD_MOOD_EVENT, "collectors_itch", /datum/mood_event/collectors_itch)
		SEND_SIGNAL(owner.current, COMSIG_CLEAR_MOOD_EVENT, "collectors_satisfaction", /datum/mood_event/collectors_satisfacton)
	else
		SEND_SIGNAL(owner.current, COMSIG_CLEAR_MOOD_EVENT, "collectors_itch", /datum/mood_event/collectors_itch)
		SEND_SIGNAL(owner.current, COMSIG_ADD_MOOD_EVENT, "collectors_satisfaction", /datum/mood_event/collectors_satisfacton)

/datum/disorder/hoarder/proc/check_items()
	var/mob/living/carbon/human/humie = owner.current
	var/stolen_count = 0
	var/list/all_items = humie.get_all_gear()
	for(var/obj/I in all_items) //Check for wanted items
		if(is_type_in_typecache(I, needed_item))
			stolen_count++
	return stolen_count >= greed_level

/datum/disorder/hoarder/proc/increase_greed()
	to_chat(owner.current, "<span class='boldwarning'>You feel your greed expanding...</span>")
	greed_level++
	addtimer(CALLBACK(src, .proc/increase_greed), 5 MINUTES)

/datum/disorder/hoarder/proc/announce_item()
	switch(needed_item)
		if(/obj/item/toy)
			to_chat(owner.current,"<span class='boldwarning'>You feel a great need to collect toys of all kind!</span>")
		if(/obj/item/stamp)
			to_chat(owner.current,"<span class='boldwarning'>You feel a great need to collect stamps!</span>")
		if(/obj/item/shard)
			to_chat(owner.current,"<span class='boldwarning'>You feel a great need to collect shards!</span>")
		if(/obj/item/reagent_containers/food/drinks/bottle)
			to_chat(owner.current,"<span class='boldwarning'>You feel a great need to collect bottles of all kind!</span>")
		if(/obj/item/kitchen/knife)
			to_chat(owner.current,"<span class='boldwarning'>You feel a great need to collect knives of all kind!</span>")

/datum/disorder/hoarder/on_add(mob/living/carbon/human/human_owner)
	. = ..()
	needed_item = pick(possible_items)
	announce_item()
	needed_item = typecacheof(needed_item)
	increase_greed()

/datum/disorder/tensed
	name = "Psychoaffective Tensing Disorder"
	desc = "Disorder classified by constant arm muscle tensing, prohibiting the patient from dropping any objects."
	max_resistance = LOW_RESISTANCE
	trait_mods = list(TRAIT_FEARLESS = 3,TRAIT_RELAXED = 3,TRAIT_TENSED = -10,TRAIT_CONTROLLED = -2)

/datum/disorder/tensed/on_add(mob/living/carbon/human/human_owner)
	. = ..()
	ADD_TRAIT(human_owner,TRAIT_TENSED_ARMS,type)

/datum/disorder/tensed/on_remove(mob/living/carbon/human/human_owner)
	. = ..()
	REMOVE_TRAIT(human_owner,TRAIT_TENSED_ARMS,type)

/datum/disorder/narcolepsy
	name = "Narcolepsy"
	desc = "Patient may involuntarily fall asleep during normal activities."
	max_resistance = MED_RESISTANCE
	trait_mods = list(TRAIT_RELAXED = -2,TRAIT_TENSED = 2,TRAIT_CONTROLLED = 1)

/datum/disorder/narcolepsy/on_life()
	. = ..()
	var/mob/living/carbon/human/humie = owner.current
	if(humie.IsSleeping())
		return
	var/sleep_chance = 1
	if(humie.m_intent == MOVE_INTENT_RUN)
		sleep_chance += 2
	if(humie.drowsyness)
		sleep_chance += 3
	if(prob(sleep_chance))
		to_chat(humie, "<span class='warning'>You fall asleep.</span>")
		humie.Sleeping(60)
	else if(!humie.drowsyness && prob(sleep_chance * 2))
		to_chat(owner, "<span class='warning'>You feel tired...</span>")
		humie.drowsyness += 10

/datum/disorder/monophobia
	name = "Monophobia"
	desc = "Patient feels sick and distressed when not around other people, leading to potentially lethal levels of stress."
	max_resistance = HIGH_RESISTANCE
	trait_mods = list(TRAIT_FEARLESS = 1,TRAIT_RELAXED = 2,TRAIT_TENSED = -3,TRAIT_CONTROLLED = 1)
	var/stress = 0

/datum/disorder/monophobia/on_add(mob/living/carbon/human/human_owner)
	. = ..()
	if(check_alone())
		to_chat(owner.current, "<span class='warning'>You feel really lonely...</span>")
	else
		to_chat(owner.current, "<span class='notice'>You feel safe, as long as you have people around you.</span>")

/datum/disorder/monophobia/on_life()
	. = ..()
	if(check_alone())
		stress = min(stress + 0.5, 100)
		if(stress > 10 && (prob(5)))
			stress_reaction()
	else
		stress = max(stress - 4, 0)

/datum/disorder/monophobia/proc/check_alone()
	var/mob/living/carbon/human/humie = owner.current
	if(humie.is_blind())
		return TRUE
	for(var/mob/living/mobie in oview(humie, 7))
		if(!isliving(mobie)) //ghosts ain't people
			continue
		if((istype(mobie, /mob/living/simple_animal/pet)) || mobie.ckey)
			return FALSE
	return TRUE

/datum/disorder/monophobia/proc/stress_reaction()
	var/mob/living/carbon/human/humie = owner.current
	if(humie.stat != CONSCIOUS)
		return

	var/high_stress = (stress > 60) //things get psychosomatic from here on
	switch(rand(1,6))
		if(1)
			if(!high_stress)
				to_chat(humie, "<span class='warning'>You feel sick...</span>")
			else
				to_chat(humie, "<span class='warning'>You feel really sick at the thought of being alone!</span>")
			addtimer(CALLBACK(humie, /mob/living/carbon.proc/vomit, high_stress), 50) //blood vomit if high stress
		if(2)
			if(!high_stress)
				to_chat(humie, "<span class='warning'>You can't stop shaking...</span>")
				humie.dizziness += 20
				humie.add_confusion(20)
				humie.Jitter(20)
			else
				to_chat(humie, "<span class='warning'>You feel weak and scared! If only you weren't alone...</span>")
				humie.dizziness += 20
				humie.add_confusion(20)
				humie.Jitter(20)
				humie.adjustStaminaLoss(50)

		if(3, 4)
			if(!high_stress)
				to_chat(humie, "<span class='warning'>You feel really lonely...</span>")
			else
				to_chat(humie, "<span class='warning'>You're going mad with loneliness!</span>")
				humie.hallucination += 30

		if(5)
			if(!high_stress)
				to_chat(humie, "<span class='warning'>Your heart skips a beat.</span>")
				humie.adjustOxyLoss(8)
			else
				if(prob(15))
					humie.set_heartattack(TRUE)
					to_chat(humie, "<span class='userdanger'>You feel a stabbing pain in your heart!</span>")
				else
					to_chat(humie, "<span class='userdanger'>You feel your heart lurching in your chest...</span>")
					humie.adjustOxyLoss(8)

/datum/disorder/anxiety
	name = "Social Anxiety"
	desc = "Disorder classifed by incredible awkwardness around people, and inability to express themselves when around a lot of people."
	max_resistance = HIGH_RESISTANCE
	trait_mods = list(TRAIT_FEARLESS = 1,TRAIT_RELAXED = 2,TRAIT_TENSED = -3,TRAIT_CONTROLLED = 1)
	var/dumb_thing = TRUE

/datum/disorder/anxiety/on_add(mob/living/carbon/human/human_owner)
	. = ..()
	RegisterSignal(owner.current, COMSIG_MOB_EYECONTACT, .proc/eye_contact)
	RegisterSignal(owner.current, COMSIG_MOB_EXAMINATE, .proc/looks_at_floor)

/datum/disorder/anxiety/on_remove()
	. = ..()
	UnregisterSignal(owner.current, list(COMSIG_MOB_EYECONTACT, COMSIG_MOB_EXAMINATE))

/datum/disorder/anxiety/on_life()
	. = ..()
	var/nearby_people = 0
	for(var/mob/living/carbon/human/H in oview(3, owner.current))
		if(H.client)
			nearby_people++
	var/mob/living/carbon/human/H = owner.current
	if(prob(2 + nearby_people))
		H.stuttering = max(3, H.stuttering)
	else if(prob(min(3, nearby_people)) && !H.silent)
		to_chat(H, "<span class='danger'>You retreat into yourself. You <i>really</i> don't feel up to talking.</span>")
		H.silent = max(10, H.silent)
	else if(prob(0.5) && dumb_thing)
		to_chat(H, "<span class='userdanger'>You think of a dumb thing you said a long time ago and scream internally.</span>")
		dumb_thing = FALSE //only once per life
		if(prob(1))
			new/obj/item/food/spaghetti/pastatomato(get_turf(H)) //now that's what I call spaghetti code

// small chance to make eye contact with inanimate objects/mindless mobs because of nerves
/datum/disorder/anxiety/proc/looks_at_floor(datum/source, atom/A)
	SIGNAL_HANDLER

	var/mob/living/mind_check = A
	if(prob(85) || (istype(mind_check) && mind_check.mind))
		return

	addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, owner.current, "<span class='smallnotice'>You make eye contact with [A].</span>"), 3)

/datum/disorder/anxiety/proc/eye_contact(datum/source, mob/living/other_mob, triggering_examiner)
	SIGNAL_HANDLER

	if(prob(75))
		return
	var/msg
	if(triggering_examiner)
		msg = "You make eye contact with [other_mob], "
	else
		msg = "[other_mob] makes eye contact with you, "

	var/mob/living/carbon/human/humie = owner.current
	switch(rand(1,3))
		if(1)
			humie.Jitter(10)
			msg += "causing you to start fidgeting!"
		if(2)
			humie.stuttering = max(3, humie.stuttering)
			msg += "causing you to start stuttering!"
		if(3)
			humie.Stun(2 SECONDS)
			msg += "causing you to freeze up!"

	SEND_SIGNAL(humie, COMSIG_ADD_MOOD_EVENT, "anxiety_eyecontact", /datum/mood_event/anxiety_eyecontact)
	addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, humie, "<span class='userdanger'>[msg]</span>"), 3) // so the examine signal has time to fire and this will print after
	return COMSIG_BLOCK_EYECONTACT


