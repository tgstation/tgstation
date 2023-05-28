/datum/brain_trauma/special/renegade
	name = "Paranoid Psychosis"
	desc = "Patient has a psychotic disorder, becoming extremely paranoid of people around him."
	scan_desc = "paranoid psychosis"
	gain_text = "If you see this message, make a github issue report. The trauma initialized wrong."
	lose_text = span_warning("You feel safe once again.")
	can_gain = TRUE
	random_gain = FALSE
	resilience = TRAUMA_RESILIENCE_LOBOTOMY
	var/datum/antagonist/renegade/antagonist
	///If someone is very close to us at the moment
	var/being_viewed = FALSE
	var/total_time_armed = 0 //just for round end fun
	var/time_close = 0

/datum/brain_trauma/special/renegade/on_gain()
	gain_text = span_warning("Everyone around you seems suspicious, are they planning something against you? You cannont trust anyone, you must protect yourself by any means!")
	owner.mind.add_antag_datum(/datum/antagonist/renegade)
	antagonist = owner.mind.has_antag_datum(/datum/antagonist/renegade)
	antagonist.trauma = src
	..()
	//antag stuff//
	antagonist.forge_objectives(owner.mind)
	antagonist.greet()

/datum/brain_trauma/special/renegade/on_life(seconds_per_tick, times_fired)
	armed_check()
	armored_check()

	if(locate(/mob/living/carbon) in viewers(1, owner)-owner)
		being_viewed = TRUE
		too_close()
		return

	owner.add_mood_event("paranoid close", /datum/mood_event/paranoid_alone)
	being_viewed = FALSE
	time_close = 0

/datum/brain_trauma/special/renegade/proc/too_close()
	time_close += 30
	if(time_close > 1800) //3 minutes
		owner.add_mood_event("paranoid close", /datum/mood_event/paranoid_closesevere)
	else
		owner.add_mood_event("paranoid close", /datum/mood_event/paranoid_close)

/datum/brain_trauma/special/renegade/on_lose()
	..()
	owner.clear_mood_event("paranoid close")
	owner.clear_mood_event("paranoid armed")
	owner.clear_mood_event("paranoid armored")
	owner.mind.remove_antag_datum(/datum/antagonist/renegade)

/datum/brain_trauma/special/renegade/handle_speech(datum/source, list/speech_args)
	if(!being_viewed)
		return
	if(prob(25)) // 25% chances to be nervous and stutter.
		if(prob(50)) // 12.5% chance (previous check taken into account) of doing something suspicious.
			addtimer(CALLBACK(src, PROC_REF(on_failed_social_interaction)), rand(1, 3) SECONDS)
		else if(!owner.has_status_effect(/datum/status_effect/speech/stutter))
			to_chat(owner, span_warning("This person is being too close to you, you're nervous about this..."))
		owner.set_stutter_if_lower(6 SECONDS)

/datum/brain_trauma/special/renegade/proc/on_failed_social_interaction()
	if(QDELETED(owner) || owner.stat >= UNCONSCIOUS)
		return
	switch(rand(1, 100))
		if(1 to 40)
			INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob, emote), "shiver")
			to_chat(owner, span_userdanger("You shiver from fear!"))
		if(41 to 80)
			INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob, emote), "glare")
			to_chat(owner, span_userdanger("You violently glare at the person near you!"))
		if(81 to 90)
			INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob, emote), "twitch")
			shake_camera(owner, 1, 1)
			to_chat(owner, span_userdanger("You twitch violently!"))
		if(91 to 100) //Rare violent response to person being too close
			owner.say("STAY AWAY FROM ME!!", forced = "paranoia")
			to_chat(owner, span_userdanger("You cannot stand this anymore! You scream loudly for them to stay away!"))

/datum/brain_trauma/special/renegade/proc/armed_check()
	var/list/find_weapons = owner.get_contents()
	var/static/list/weapons = typecacheof(list(
		/obj/item/gun,
		/obj/item/melee,
		/obj/item/grenade/frag,
		/obj/item/shield,
		/obj/item/circular_saw,
		/obj/item/scalpel/advanced,
		/obj/item/surgicaldrill,
		/obj/item/pneumatic_cannon,
		/obj/item/storage/toolbox,
		/obj/item/fireaxe,
		/obj/item/spear,
		/obj/item/knife,
		/obj/item/switchblade,
	))

	for(var/obj/item in find_weapons)
		if(weapons[item.type])
			owner.add_mood_event("paranoid armed", /datum/mood_event/paranoid_armed)
			return
	owner.add_mood_event("paranoid armed", /datum/mood_event/paranoid_notarmed)

/datum/brain_trauma/special/renegade/proc/armored_check()
	var/list/find_armor = owner.get_contents()
	var/static/list/armor = typecacheof(list(
		/obj/item/clothing/head/helmet,
		/obj/item/clothing/suit/armor,
	))

	for(var/obj/item in find_armor)
		if(armor[item.type])
			owner.add_mood_event("paranoid armored", /datum/mood_event/paranoid_armored)
			return
		owner.clear_mood_event("paranoid armored")
