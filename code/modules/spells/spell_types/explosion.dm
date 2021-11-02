/obj/effect/proc_holder/spell/targeted/explosion
	name = "Explosion"
	desc = "This spell explodes an area."

	school = SCHOOL_EVOCATION

	/// The devastation range of the resulting explosion.
	var/ex_severe = 1
	/// The heavy impact range of the resulting explosion.
	var/ex_heavy = 2
	/// The light impact range of the resulting explosion.
	var/ex_light = 3
	/// The flash range of the resulting explosion.
	var/ex_flash = 4

/obj/effect/proc_holder/spell/targeted/explosion/cast(list/targets,mob/user = usr)
	for(var/mob/living/target in targets)
		if(target.anti_magic_check())
			continue
		explosion(target, devastation_range = ex_severe, heavy_impact_range = ex_heavy, light_impact_range = ex_light, flash_range = ex_flash, explosion_cause = src)

	return
