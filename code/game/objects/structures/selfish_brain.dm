//From code\datums\status_effects\debuffs\blindness.dm
#define CAN_BE_BLIND(mob) (!isanimal_or_basicmob(mob) && !isbrain(mob) && !isrevenant(mob))

/obj/structure/selfish_brain
	name = "???"
	desc = "how selfish"
	icon_state = "selfishbrain"
	max_integrity = 100
	integrity_failure = 0.85
	anchored = TRUE
	density = TRUE
	/// Proximity monitor to detect if someone is in our range to blind
	var/datum/proximity_monitor/blind_proximity_monitor
	/// How far away this can blind someone
	var/blind_range = 12
	/// If we can whisper something right now
	var/can_whisper = TRUE
	/// How long until this can whisper something again, death whispers not included
	var/whisper_cooldown = 12 SECONDS
	/// voicelines this says when someone is close and is blinded by selfish_brain_blind
	var/list/proximity_voice_lines = list(
		"there i am",
		"i hope you don't mind",
		"just a little longer",
		"only for a little while",
		"sorry",
	)
	/// voicelines this says when someone is close and not blinded by selfish_brain_blind
	var/list/proximity_voice_lines_didnt_blind = list(
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
	blind_proximity_monitor = new(src, blind_range, FALSE)

/obj/structure/selfish_brain/Destroy()
	QDEL_NULL(blind_proximity_monitor)
	return ..()

/// Make it so this always whispers its messages
/obj/structure/selfish_brain/send_speech(message, range = 7, obj/source = src, bubble_type, list/spans, datum/language/message_language, list/message_mods = list(), forced = FALSE, tts_message, list/tts_filter)
	message_mods[WHISPER_MODE] = MODE_WHISPER
	range = 2

	return ..()

/obj/structure/selfish_brain/atom_break(damage_flag)
	. = ..()
	broken = TRUE
	QDEL_NULL(blind_proximity_monitor)
	var/chosen_message = pick(death_whispers)
	src.say(chosen_message)
	new /obj/item/shard(drop_location())
	new /obj/item/organ/internal/brain(drop_location())
	new /obj/item/organ/internal/tongue/selfish_brain(drop_location())
	new /obj/item/mod/module/malfunctioning_eyesight_sharer(drop_location())
	playsound(src, 'sound/effects/glassbr1.ogg', 50, FALSE)
	playsound(src, 'sound/effects/meatslap.ogg', 100, FALSE)
	update_appearance()

/obj/structure/selfish_brain/update_icon_state()
	. = ..()
	icon_state = initial(icon_state)
	if(broken)
		icon_state = "selfishbrain_broken"

/obj/structure/selfish_brain/update_desc()
	. = ..()
	desc = initial(desc)
	if(broken)
		desc = "A smashed machine with a bloody rod sticking out from the broken glass. Whatever this was is irreparably broken now."

/obj/structure/selfish_brain/HasProximity(atom/movable/proximity_check_mob)
	if(blind_proximity_monitor == null)
		return
	var/mob/living/blinding_mob
	if (!isliving(proximity_check_mob))
		return
	blinding_mob = proximity_check_mob

	// Blind all mobs within its range and in maintenance temporarily
	//Check if they are in maintenance
	var/area/candidate_area = get_area(blinding_mob)
	if(istype(candidate_area, /area/station/maintenance))
		var/datum/status_effect/selfish_brain_blind/this_blinding_effect
		this_blinding_effect = blinding_mob.has_status_effect(/datum/status_effect/selfish_brain_blind)
		//If this already blinded the mob, update the status effect's last_allowed_turf
		if (!isnull(this_blinding_effect))
			this_blinding_effect.update_last_allowed_turf(get_turf(blinding_mob))
		//Otherwise apply the blinding effect
		else
			blinding_mob.apply_status_effect(/datum/status_effect/selfish_brain_blind, src)

	//Start whispering
	if(blinding_mob.has_status_effect(/datum/status_effect/selfish_brain_blind))
		try_to_whisper(proximity_voice_lines)
	else if (blinding_mob.is_blind())
		try_to_whisper(proximity_voice_lines_didnt_blind)

/// Try to speak and set its whisper cooldown
/// available_lines is a list of lines this can choose from
/obj/structure/selfish_brain/proc/try_to_whisper(var/list/available_lines)
	if(!can_whisper)
		return

	var/chosen_line = pick(available_lines)
	say(chosen_line)
	can_whisper = FALSE
	addtimer(VARSET_CALLBACK(src, can_whisper, TRUE), whisper_cooldown)

/// The status effect this gives to mobs in it's range, makes people temporarily blind
/datum/status_effect/selfish_brain_blind
	id = "selfish_brain_blind"
	alert_type = /atom/movable/screen/alert/status_effect/selfish_brain_blind
	status_type = STATUS_EFFECT_UNIQUE
	duration = -1
	///The linked /obj/structure/selfish_brain that applies this
	var/obj/structure/selfish_brain/linked_structure
	///The last turf we were on that the linked_structure said was okay
	/// moving to a turf that the linked structure doesn't explictly allow will remove this
	var/turf/last_allowed_turf

/datum/status_effect/selfish_brain_blind/on_creation(mob/living/new_owner, obj/structure/selfish_brain/new_linked_structure)
	. = ..()

	linked_structure = new_linked_structure
	last_allowed_turf = get_turf(owner)

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

/datum/status_effect/selfish_brain_blind/tick(seconds_between_ticks)
	if(isnull(linked_structure) || linked_structure.broken == TRUE)
		owner.remove_status_effect(/datum/status_effect/selfish_brain_blind)
		return
	//Check if we moved from our original turf
	if(get_turf(owner) != last_allowed_turf)
		owner.remove_status_effect(/datum/status_effect/selfish_brain_blind)

/datum/status_effect/selfish_brain_blind/Destroy()
	. = ..()

	linked_structure = null
	last_allowed_turf = null

/datum/status_effect/selfish_brain_blind/proc/update_last_allowed_turf(turf/new_turf)
	last_allowed_turf = new_turf

#undef CAN_BE_BLIND
