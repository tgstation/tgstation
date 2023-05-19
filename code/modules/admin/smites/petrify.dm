/// Turn pur target to stone, forever
/datum/smite/petrify
	name = "Petrify"

/datum/smite/petrify/effect(client/user, mob/living/target)
	. = ..()

	if(!ishuman(target))
		to_chat(user, span_warning("This must be used on a human subtype."), confidential = TRUE)
		return
	target.petrify(INFINITY, /* save_brain = */ FALSE)
