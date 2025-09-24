//Brain Traumas are the new actual brain damage. Brain damage itself acts as a way to acquire traumas: every time brain damage is dealt, there's a chance of receiving a trauma.
//This chance gets higher the higher the mob's brainloss is. Removing traumas is a separate thing from removing brain damage: you can get restored to full brain operativity,
// but keep the quirks, until repaired by neurine, surgery, lobotomy or magic; depending on the resilience
// of the trauma.

/datum/brain_trauma
	/// Tracks abstract types of brain traumas, useful for determining traumas that should not exist
	abstract_type = /datum/brain_trauma
	var/name = "Brain Trauma"
	var/desc = "A trauma caused by brain damage, which causes issues to the patient."
	var/scan_desc = "generic brain trauma" //description when detected by a health scanner
	var/mob/living/carbon/owner //the poor bastard
	var/obj/item/organ/brain/brain //the poor bastard's brain
	var/gain_text = span_notice("You feel traumatized.")
	var/lose_text = span_notice("You no longer feel traumatized.")
	var/can_gain = TRUE
	var/random_gain = TRUE //can this be gained through random traumas?
	var/resilience = TRAUMA_RESILIENCE_BASIC //how hard is this to cure?

/datum/brain_trauma/Destroy()
	// Handles our references with our brain
	brain?.remove_trauma_from_traumas(src)
	if(owner)
		log_game("[key_name_and_tag(owner)] has lost the following brain trauma: [type]")
		on_lose()
		owner = null
	return ..()

//Called on life ticks
/datum/brain_trauma/proc/on_life(seconds_per_tick, times_fired)
	return

//Called on death
/datum/brain_trauma/proc/on_death()
	return

//Called when given to a mob
/datum/brain_trauma/proc/on_gain()
	SHOULD_CALL_PARENT(TRUE)
	if(gain_text)
		to_chat(owner, gain_text)
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	RegisterSignal(owner, COMSIG_MOVABLE_HEAR, PROC_REF(handle_hearing))
	return TRUE

//Called when removed from a mob
/datum/brain_trauma/proc/on_lose(silent)
	SHOULD_CALL_PARENT(TRUE)
	if(!silent && lose_text)
		to_chat(owner, lose_text)
	UnregisterSignal(owner, COMSIG_MOB_SAY)
	UnregisterSignal(owner, COMSIG_MOVABLE_HEAR)

//Called when hearing a spoken message
/datum/brain_trauma/proc/handle_hearing(datum/source, list/hearing_args)
	SIGNAL_HANDLER

	UnregisterSignal(owner, COMSIG_MOVABLE_HEAR)

//Called when speaking
/datum/brain_trauma/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	UnregisterSignal(owner, COMSIG_MOB_SAY)
