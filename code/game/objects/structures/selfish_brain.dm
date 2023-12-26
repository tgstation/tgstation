//From code\datums\status_effects\debuffs\blindness.dm
#define CAN_BE_BLIND(mob) (!isanimal_or_basicmob(mob) && !isbrain(mob) && !isrevenant(mob))

/obj/structure/selfish_brain
	name = "???"
	desc = "how selfish"
	icon_state = "barrel"
	max_integrity = 100
	integrity_failure = 0.85
	anchored = TRUE
	density = TRUE
	/// How far away this can blind someone
	var/blind_range = 2
	/// If we can whisper something right now
	var/can_whisper = TRUE
	/// How long until this can whisper something again, death whispers not included
	var/whisper_cooldown = 10 SECONDS
	/// The distance someone has to be for this to start saying some proximity voicelines
	var/start_talking_distance = 3
	/// A list of whispers this can say when it steals eyesight from someone
	var/list/stolen_whispers = list(
		"if i could just borrow this",
		"sorry about this",
		"thank you",
	)
	/// voicelines this says when someone is close and is blinded by selfish_brain_blind
	var/list/proximity_voice_lines = list(
		"there i am",
		"i hope you don't mind",
		"just a little longer",
		"only for a little while",
		"sorry",
	)
	/// voicelines this says when someone is close and not blinded by selfish_brain_blind
	var/list/proximity_voice_lines_not_blinded = list(
		"i understand",
		"you're not so different",
		"over here"
	)
	/// A list of whispers that this can say when it is destroyed
	var/list/death_whispers = list(
		"i didn't mean any harm",
		"i'm sorry",
		"i only wanted to see",
		"forgive me",
		"how selfish of me",
		"it was wrong of me",
	)

/obj/structure/selfish_brain/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/structure/selfish_brain/atom_break(damage_flag)
	. = ..()

	STOP_PROCESSING(SSfastprocess, src)
	var/chosen_message = pick(death_whispers)
	src.say(chosen_message)
	new /obj/item/shard(drop_location())
	new /obj/item/organ/internal/brain(drop_location())
	new /obj/item/organ/internal/tongue/selfish_brain(drop_location())
	update_appearance()

/obj/structure/selfish_brain/process(seconds_per_tick)
	// If someone is close whisper if this can
	for (var/mob/living/whisper_to_candidate in range(start_talking_distance, src))
		if(whisper_to_candidate.has_status_effect(/datum/status_effect/selfish_brain_blind))
			try_to_whisper(proximity_voice_lines)
		else
			try_to_whisper(proximity_voice_lines_not_blinded)

	// Blind all mobs within its range and in maintenance temporarily
	for (var/mob/living/candidate in range(blind_range, src))
		//Check if they are in maintenance
		var/area/candidate_area = get_area(candidate)
		if(!istype(candidate_area, /area/station/maintenance))
			continue

		candidate.apply_status_effect(/datum/status_effect/selfish_brain_blind)
		try_to_whisper(stolen_whispers)

/// The status effect this gives to mobs in it's range, makes people temporarily blind
/datum/status_effect/selfish_brain_blind
	id = "selfish_brain_blind"
	alert_type = /atom/movable/screen/alert/status_effect/selfish_brain_blind
	duration = 1 SECONDS
	status_type = STATUS_EFFECT_REFRESH

/atom/movable/screen/alert/status_effect/selfish_brain_blind
	name = "Sight Stolen"
	desc = "sorry, im only borrowing it"

/datum/status_effect/selfish_brain_blind/on_apply()
	if(!CAN_BE_BLIND(owner) || owner.is_blind())
		return FALSE

	owner.become_blind(id)
	return TRUE

/datum/status_effect/selfish_brain_blind/on_remove()
	owner.cure_blind(id)

/// Make it so this always whispers its messages
/obj/structure/selfish_brain/send_speech(message, range = 7, obj/source = src, bubble_type, list/spans, datum/language/message_language, list/message_mods = list(), forced = FALSE, tts_message, list/tts_filter)
	message_mods[WHISPER_MODE] = MODE_WHISPER
	range = 2

	. = ..()

/// Try to speak and set its whisper cooldown
/// available_lines is a list of lines this can choose from
/obj/structure/selfish_brain/proc/try_to_whisper(var/list/available_lines)
	if(!can_whisper)
		return

	var/chosen_line = pick(available_lines)
	say(chosen_line)
	can_whisper = FALSE
	addtimer(VARSET_CALLBACK(src, can_whisper, TRUE), whisper_cooldown)

#undef CAN_BE_BLIND
