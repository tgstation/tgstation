/// Spawns a little worm nearby
/datum/action/cooldown/mob_cooldown/hivelord_spawn
	name = "Spawn Brood"
	desc = "Release an attack form to an adjacent square to attack your target or anyone nearby."
	button_icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	button_icon_state = "hivelord_brood"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"
	click_to_activate = TRUE
	cooldown_time = 2 SECONDS
	melee_cooldown_time = 0
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	shared_cooldown = NONE
