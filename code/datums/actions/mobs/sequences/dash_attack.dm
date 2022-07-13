/datum/action/cooldown/mob_cooldown/dash_attack
	name = "Dashing And Attacking"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	desc = "Allows you to dash and fire at a target simultaneously."
	cooldown_time = 3 SECONDS
	shared_cooldown = MOB_SHARED_COOLDOWN_2
	sequence_actions = list(
		/datum/action/cooldown/mob_cooldown/dash = 0.1 SECONDS,
		/datum/action/cooldown/mob_cooldown/projectile_attack/kinetic_accelerator = 0,
	)
