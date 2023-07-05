/datum/smite/cluwneify
	name = "Cluwneify"

/datum/smite/cluwneify/effect(client/user, mob/living/target)
	. = ..()
	target.cluwne()
