/// Turn pur target to stone, forever
/datum/smite/nugget
	name = "Petrify"

/datum/smite/nugget/effect(client/user, mob/living/target)
	. = ..()

	if(!ishuman(target))
		to_chat(user, span_warning("This must be used on a human subtype."), confidential = TRUE)
		return
	target.petrify(INFINITY, /* save_brain = */ FALSE)
