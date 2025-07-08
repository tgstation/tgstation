/// POWER GAMING ON MY SERVER??? MAKE THEM QUIVER IN THE MERE PRESENCE OF POWER
/datum/smite/ocky_icky
	name = "Power Gaming phobia"

/datum/smite/ocky_icky/effect(client/user, mob/living/target)
	. = ..()
	var/mob/living/carbon/gamer = target
	gamer.gain_trauma(/datum/brain_trauma/mild/phobia/power_gaming, TRAUMA_RESILIENCE_LOBOTOMY)

