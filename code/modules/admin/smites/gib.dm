/// Gibs the target
/datum/smite/gib
	name = "Gib"

/datum/smite/gib/effect(client/user, mob/living/target)
	. = ..()
	target.gib(DROP_ORGANS|DROP_BODYPARTS)

/datum/smite/gib/divine
	name = "Gib (Divine)"
	smite_flags = SMITE_DIVINE|SMITE_DELAY|SMITE_STUN
