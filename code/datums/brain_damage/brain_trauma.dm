//Brain Traumas are the new actual brain damage. Brain damage itself acts as a way to acquire traumas: every time brain damage is dealt, there's a chance of receiving a trauma.
//This chance gets higher the higher the mob's brainloss is. Removing traumas is a separate thing from removing brain damage: you can get restored to full brain operativity,
//but keep the quirks, until repaired by mannitol (for mild/special ones) or brain surgery (for severe ones).
/datum/brain_trauma
	var/name = "Brain Trauma"
	var/desc = "A trauma caused by brain damage, which causes issues to the patient."
	var/scan_desc = "a generic brain trauma" //description when detected by a health scanner
	var/mob/living/carbon/owner //the poor bastard
	var/obj/item/organ/brain/brain //the poor bastard's brain
	var/gain_text = "<span class='notice'>You feel traumatized.</span>"
	var/lose_text = "<span class='notice'>You no longer feel traumatized.</span>"
	var/can_gain = TRUE //can this be gained through random traumas?
	var/resilience = TRAUMA_RESILIENCE_BASIC //how hard is this to cure?

/datum/brain_trauma/Destroy()
	brain.traumas -= src
	if(owner)
		on_lose()
	brain = null
	owner = null
	return ..()

//Called on life ticks
/datum/brain_trauma/proc/on_life()
	return
	
//Called on death
/datum/brain_trauma/proc/on_death()
	return

//Called when given to a mob
/datum/brain_trauma/proc/on_gain()
	to_chat(owner, gain_text)

//Called when removed from a mob
/datum/brain_trauma/proc/on_lose(silent)
	if(!silent)
		to_chat(owner, lose_text)

//Called when hearing a spoken message
/datum/brain_trauma/proc/on_hear(message, speaker, message_language, raw_message, radio_freq)
	return message

//Called when speaking
/datum/brain_trauma/proc/on_say(message)
	return message
