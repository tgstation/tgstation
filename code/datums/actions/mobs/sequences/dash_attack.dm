/datum/action/cooldown/mob_cooldown/dash_attack
	name = "Dashing And Attacking"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	desc = "Allows you to dash and fire at a target simultaneously."
	cooldown_time = 3 SECONDS
	shared_cooldown = MOB_SHARED_COOLDOWN_2
	sequence_actions = list(
		/datum/action/cooldown/mob_cooldown/charge/basic_charge/blood_drunk_miner = 0.22 SECONDS, // 0.1s windup + 0.12s max dash
		/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/kinetic_accelerator = 0,
	)

/datum/action/cooldown/mob_cooldown/dash_attack/long_burst
	sequence_actions = list(
		/datum/action/cooldown/mob_cooldown/charge/basic_charge/blood_drunk_miner = 0.22 SECONDS,
		/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/kinetic_accelerator/long_burst = 0,
	)
