/spell/targeted/projectile/dumbfire/fireball
	name = "Fireball"
	desc = "This spell fires a fireball at a target and does not require wizard garb."

	proj_type = /obj/item/projectile/spell_projectile/fireball

	school = "evocation"
	charge_max = 100
	spell_flags = 0
	invocation = "ONI SOMA"
	invocation_type = SpI_SHOUT
	range = 20
	cooldown_min = 20 //10 deciseconds reduction per rank

	spell_flags = 0

	duration = 20
	proj_step_delay = 1

	amt_dam_brute = 20
	amt_dam_fire = 25

	var/ex_severe = -1
	var/ex_heavy = 1
	var/ex_light = 2
	var/ex_flash = 5

	hud_state = "wiz_fireball"

/spell/targeted/projectile/dumbfire/fireball/prox_cast(var/list/targets, spell_holder)
	for(var/mob/living/M in targets)
		apply_spell_damage(M)
	explosion(get_turf(spell_holder), ex_severe, ex_heavy, ex_light, ex_flash)

//PROJECTILE

/obj/item/projectile/spell_projectile/fireball
	name = "fireball"
	icon_state = "fireball"