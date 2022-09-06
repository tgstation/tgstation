/// Strikes the target with a lightning bolt
/datum/smite/curse_of_babel
	name = "Curse of Babel"

/datum/smite/curse_of_babel/effect(client/user, mob/living/carbon/target)
	. = ..()
	if(!iscarbon(target))
		to_chat(user, span_warning("This must be used on a carbon mob."), confidential = TRUE)
		return

	curse_of_babel(target)
	to_chat(target, span_userdanger("The gods have punished you for your sins!"), confidential = TRUE)
