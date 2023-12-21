/datum/action/cooldown/slasher
	name = "Slasher Possession"
	desc = "You've been possessed by the Slasher... not actually, please report this to coders"
	background_icon = 'goon/icons/mob/slasher.dmi'
	background_icon_state = "slasher_background"
	button_icon = 'goon/icons/mob/slasher.dmi'
	button_icon_state = "slasher_template"
	buttontooltipstyle = "cult"
	transparent_when_unavailable = TRUE
	click_to_activate = FALSE

/datum/action/cooldown/slasher/IsAvailable(feedback = FALSE)
	return next_use_time <= world.time
