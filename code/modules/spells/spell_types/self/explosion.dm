/datum/action/cooldown/spell/explosion
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

/datum/action/cooldown/spell/cast(atom/cast_on)
	explosion(
		target,
		devastation_range = ex_severe,
		heavy_impact_range = ex_heavy,
		light_impact_range = ex_light,
		flash_range = ex_flash,
		explosion_cause = src,
	)
