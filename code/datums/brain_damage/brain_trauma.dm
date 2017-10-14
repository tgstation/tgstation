/datum/brain_trauma
	var/name = "Brain Trauma"
	var/desc = "A trauma caused by brain damage, which causes issues to the patient."
	var/scan_desc = "a generic brain trauma" //description when detected by a health scanner
	var/mob/living/carbon/owner //the poor bastard
	var/gain_text = "<span class='notice'>You feel traumatized.</span>"
	var/lose_text = "<span class='notice'>You no longer feel traumatized.</span>"
	var/permanent = FALSE //can this be cured by removing the brain damage?

/datum/brain_trauma/New(mob/living/carbon/C, _permanent)
	owner = C
	permanent = _permanent
	on_gain()

/datum/brain_trauma/Destroy()
	owner.traumas -= src
	on_lose()
	return ..()

//Called on life ticks
/datum/brain_trauma/proc/on_life()
	return

//Called when given to a mob
/datum/brain_trauma/proc/on_gain()
	to_chat(owner, gain_text)

//Called when removed from a mob
/datum/brain_trauma/proc/on_lose()
	to_chat(owner, lose_text)

