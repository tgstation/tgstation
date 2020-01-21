/mob/living/silicon/robot/on_mobility_loss()
	. = ..()
	update_action_buttons_icon()

/mob/living/silicon/robot/on_mobility_gain()
	. = ..()
	update_action_buttons_icon()
