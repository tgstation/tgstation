/datum/action/cooldown/spell/basic_projectile/juggernaut
	name = "Gauntlet Echo"
	desc = "Channels energy into your gauntlet - firing its essence forward in a slow moving, yet devastating, attack."
	button_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "cultfist"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

	sound = 'sound/weapons/resonator_blast.ogg'

	cooldown_time = 35 SECONDS
	spell_requirements = NONE

	projectile_type = /obj/projectile/magic/aoe/juggernaut
