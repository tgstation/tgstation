/datum/brain_trauma/special/renegade
	name = "Paranoid Psychosis"
	desc = "Patient has a psychotic disorder, becoming extremely paranoid of people around him."
	scan_desc = "paranoid psychosis"
	gain_text = "If you see this message, make a github issue report. The trauma initialized wrong."
	lose_text = span_warning("You feel safe once again.")
	can_gain = TRUE
	random_gain = FALSE
	resilience = TRAUMA_RESILIENCE_SURGERY
	var/datum/antagonist/renegade/antagonist
	///If someone is very close to us at the moment
	var/being_viewed = FALSE
	var/total_time_armed = 0 //just for round end fun
	var/time_close = 0
	///Did the person had bad touch before?
	var/had_bad_touch = FALSE

/datum/brain_trauma/special/renegade/on_gain()
	gain_text = span_warning("Everyone around you seems suspicious, are they planning something against you? You cannont trust anyone, you must protect yourself by any means!")
	owner.mind.add_antag_datum(/datum/antagonist/renegade)
	antagonist = owner.mind.has_antag_datum(/datum/antagonist/renegade)
	antagonist.trauma = src
	var/bad_touch = owner.add_quirk(/datum/quirk/bad_touch) //Paranoid people don't like being hugged
	if(!bad_touch)
		had_bad_touch = TRUE
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

	being_viewed = FALSE
	time_close = 0
	REMOVE_TRAIT(owner, TRAIT_NERVOUS_EYES, TRAUMA_TRAIT)

/datum/brain_trauma/special/renegade/proc/too_close()
	time_close += 30
	if(time_close > 1800) //3 minutes
		owner.add_mood_event("paranoid close", /datum/mood_event/paranoid_closesevere)
		if(prob(10))
			if(prob(50))
				to_chat(owner, span_userdanger("[pick("They are standing near me for so long! They are totally plotting something!", "Oh my god! They are just standing there menacingly!", "Will they murder me? They are standing near me for so long!")]"))
			else
				owner.do_jitter_animation(30)
				owner.playsound_local(get_turf(owner), 'sound/effects/singlebeat.ogg', 70, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
				to_chat(owner, span_userdanger("You can feel your heart beating from paranoia!"))
	else
		owner.add_mood_event("paranoid close", /datum/mood_event/paranoid_close)
		if(prob(10))
			to_chat(owner, span_warning("[pick("Why are they so close to me? I'm nervous about this...", "They are plotting something? They are so close...", "I can't control my eyes, they're nervously looking around from this paranoia!")]"))
			ADD_TRAIT(owner, TRAIT_NERVOUS_EYES, TRAUMA_TRAIT)

/datum/brain_trauma/special/renegade/on_lose()
	..()
	owner.playsound_local(get_turf(owner), 'sound/ambience/ambiholy2.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	owner.clear_mood_event("paranoid close")
	owner.clear_mood_event("paranoid armed")
	owner.clear_mood_event("paranoid armored")
	REMOVE_TRAIT(owner, TRAIT_NERVOUS_EYES, TRAUMA_TRAIT)
	if(!had_bad_touch) //So we won't accidentaly delete the quirk they selected themselves, and not the one got from the paranoia
		owner.remove_quirk(/datum/quirk/bad_touch)
	owner.mind.remove_antag_datum(/datum/antagonist/renegade)

/datum/brain_trauma/special/renegade/proc/armed_check()
	var/list/find_weapons = owner.get_contents()
	var/static/list/weapons = typecacheof(list(
		/obj/item/gun,
		/obj/item/melee,
		/obj/item/grenade/frag,
		/obj/item/circular_saw,
		/obj/item/scalpel/advanced,
		/obj/item/surgicaldrill,
		/obj/item/storage/toolbox,
		/obj/item/fireaxe,
		/obj/item/spear,
		/obj/item/knife,
		/obj/item/switchblade,
		/obj/item/flamethrower,
	))

	for(var/obj/item in find_weapons)
		if(weapons[item.type])
			total_time_armed += 30
			owner.add_mood_event("paranoid armed", /datum/mood_event/paranoid_armed)
			return
	owner.add_mood_event("paranoid armed", /datum/mood_event/paranoid_notarmed)
	if(prob(5))
		to_chat(owner, span_warning("I better get some kind of weapon on my hand..."))

/datum/brain_trauma/special/renegade/proc/armored_check()
	var/list/find_armor = owner.get_contents()
	var/static/list/armor = typecacheof(list(
		/obj/item/clothing/head/helmet,
		/obj/item/clothing/suit/armor,
		/obj/item/shield,
	))

	for(var/obj/item in find_armor)
		if(armor[item.type])
			owner.add_mood_event("paranoid armored", /datum/mood_event/paranoid_armored)
			return
		owner.clear_mood_event("paranoid armored")
