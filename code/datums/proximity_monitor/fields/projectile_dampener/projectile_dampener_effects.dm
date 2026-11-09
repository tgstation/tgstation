///datum that holds the effects we have on bullet catching
/datum/dampener_projectile_effects
	///new projectiles speeds
	var/projectile_speed_multiplier = 0.4
	/// new projectiles damage
	var/projectile_damage_multiplier = 0.75
	/// new projectiles knockdown
	var/projectile_knockdown_multiplier = 0.66
	/// new projectiles stun
	var/projectile_stun_multiplier = 0.66
	/// new projectiles stamina damage
	var/projectile_stamina_multiplier = 0.66

/datum/dampener_projectile_effects/proc/apply_effects(obj/projectile/bullet)
	if(projectile_speed_multiplier)
		bullet.speed *= projectile_speed_multiplier
	if(projectile_damage_multiplier)
		bullet.damage *= projectile_damage_multiplier
	if(projectile_knockdown_multiplier)
		bullet.knockdown *= projectile_knockdown_multiplier
	if(projectile_stamina_multiplier)
		bullet.stamina *= projectile_stamina_multiplier
	if(projectile_stun_multiplier)
		bullet.stun *= projectile_stun_multiplier

/datum/dampener_projectile_effects/proc/remove_effects(obj/projectile/bullet)
	bullet.speed /= projectile_speed_multiplier
	bullet.damage /= projectile_damage_multiplier
	bullet.knockdown /= projectile_knockdown_multiplier
	bullet.stamina /= projectile_stamina_multiplier
	bullet.stun /= projectile_stun_multiplier

/datum/dampener_projectile_effects/peacekeeper
	projectile_speed_multiplier = 0.66
	projectile_damage_multiplier = 0.5
	projectile_knockdown_multiplier = 1
	projectile_stun_multiplier = 1
	projectile_stamina_multiplier = 1
