/datum/action/cooldown/mob_cooldown
	name = "Standard Mob Cooldown Ability"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	desc = "Click this ability to attack."
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 5 SECONDS
	text_cooldown = TRUE
	click_to_activate = TRUE
	shared_cooldown = MOB_SHARED_COOLDOWN_1
