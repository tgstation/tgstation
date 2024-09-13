/// No more sigma rizz for you
/datum/smite/brainrot
	name = "Brainrot phobia"

/datum/smite/brainrot/effect(client/user, mob/living/target)
	. = ..()
	var/mob/living/carbon/brainrotman = target
	brainrotman.gain_trauma(/datum/brain_trauma/mild/phobia/brainrot, TRAUMA_RESILIENCE_LOBOTOMY)
