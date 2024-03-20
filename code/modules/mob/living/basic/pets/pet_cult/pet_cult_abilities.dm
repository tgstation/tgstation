/datum/action/cooldown/spell/conjure/revive_rune
	name = "Create Revival Rune"
	button_icon = 'icons/obj/antags/cult/rune.dmi'
	button_icon_state = "1"
	background_icon_state = "bg_cult"
	overlay_icon_state = "bg_cult_border"
	spell_requirements = NONE
	cooldown_time = 30 SECONDS
	summon_type = list(
		/obj/effect/rune/raise_dead,
	)
	summon_radius = 0
	create_summon_timer = 5 SECONDS
	sound = 'sound/magic/exit_blood.ogg'
