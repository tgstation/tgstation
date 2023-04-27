/datum/action/cooldown/web_sneak
	name = "Sneak"
	desc = "Blend into the shadows to stalk your prey."
	button_icon_state = "alien_sneak"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	/// The alpha we go to when sneaking.
	var/sneak_alpha = 75

/datum/action/cooldown/web_sneak/Grant(mob/grant_to)

