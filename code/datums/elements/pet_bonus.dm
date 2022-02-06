/**
 * # Pet bonus element!
 *
 * Bespoke element that plays a fun message, sends a heart out, and gives a stronger mood bonus when you pet this animal.
 * I may have been able to make this work for carbons, but it would have been interjecting on some help mode interactions anyways.
 */
/datum/element/pet_bonus
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2

	///optional cute message to send when you pet your pet!
	var/emote_message
	///actual moodlet given, defaults to the pet animal one
	var/moodlet

/datum/element/pet_bonus/Attach(datum/target, emote_message, moodlet = /datum/mood_event/pet_animal)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	src.emote_message = emote_message
	src.moodlet = moodlet
	RegisterSignal(target, COMSIG_ATOM_ATTACK_HAND, .proc/on_attack_hand)

/datum/element/pet_bonus/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ATOM_ATTACK_HAND)

/datum/element/pet_bonus/proc/on_attack_hand(mob/living/pet, mob/living/petter, list/modifiers)
	SIGNAL_HANDLER

	if(pet.stat != CONSCIOUS || petter.combat_mode || LAZYACCESS(modifiers, RIGHT_CLICK))
		return

	new /obj/effect/temp_visual/heart(pet.loc)
	if(emote_message && prob(33))
		pet.manual_emote(emote_message)
	SEND_SIGNAL(petter, COMSIG_ADD_MOOD_EVENT, pet, moodlet, pet)
