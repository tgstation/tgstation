/// Turn pur target to stone, forever
/datum/smite/petrify
	name = "Petrify"

/datum/smite/petrify/effect(client/user, mob/living/target)
	. = ..()

	if(!ishuman(target))
		to_chat(user, span_warning("This must be used on a human subtype."), confidential = TRUE)
		return
	var/mob/living/carbon/human/human_target = target
	human_target.petrify(statue_timer = INFINITY, save_brain = FALSE)

/datum/smite/petrify/divine
	name = "Petrify (Divine)"
	smite_flags = SMITE_DIVINE|SMITE_DELAY|SMITE_STUN
