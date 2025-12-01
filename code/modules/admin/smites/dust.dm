/datum/smite/dust
	name = "Dust"

/datum/smite/dust/effect(client/user, mob/living/target)
	. = ..()
	target.dust(just_ash = FALSE, drop_items = TRUE, force = TRUE)

/datum/smite/dust/divine
	name = "Dust (Divine)"
	smite_flags = SMITE_DIVINE|SMITE_DELAY|SMITE_STUN
