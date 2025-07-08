/// POWER GAMING ON MY SERVER??? MAKE THEM QUIVER IN THE MERE PRESENCE OF POWER
/datum/smite/power_gaming
	name = "Power Gaming phobia"

/datum/smite/power_gaming/effect(client/user, mob/living/target)
	. = ..()
	var/mob/living/carbon/gamer = target
	gamer.gain_trauma(/datum/brain_trauma/mild/phobia/power_gaming, TRAUMA_RESILIENCE_LOBOTOMY)
