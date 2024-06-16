/datum/action/cooldown/mob_cooldown/assume_form/assume_appearances(atom/movable/target_atom)
	. = ..()
	owner?.update_name_tag()

/datum/action/cooldown/mob_cooldown/assume_form/reset_appearances()
	. = ..()
	owner?.update_name_tag()
