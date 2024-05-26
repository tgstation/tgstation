/// "Immerses" the player, making them unable to use some OOC terms IC
/datum/smite/christian_minecraft
	name = "Christian Minecraft Server"

/datum/smite/christian_minecraft/effect(client/user, mob/living/target)
	. = ..()
	var/mob/living/carbon/ocker = target
	ocker.gain_trauma(/datum/brain_trauma/mild/phobia/christian_minecraft, TRAUMA_RESILIENCE_LOBOTOMY)
	to_chat(ocker,span_ratvar("Welcome to our Christian Minecraft Server."))
