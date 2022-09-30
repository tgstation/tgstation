/datum/action/cooldown/mob_cooldown/direct_and_aoe
	name = "Direct And AoE Firing"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	desc = "Allows you to shoot directly at a target while also firing around you."
	cooldown_time = 12 SECONDS
	sequence_actions = list(
		/datum/action/cooldown/mob_cooldown/dash = 0.1 SECONDS,
		/datum/action/cooldown/mob_cooldown/projectile_attack/kinetic_accelerator = 0,
	)
