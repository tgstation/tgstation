// 40mm (Grenade Launcher

/obj/projectile/bullet/a40mm
	name ="40mm grenade"
	desc = "USE A WEEL GUN"
	icon_state= "bolter"
	damage = 60
	embedding = null
	shrapnel_type = null

/obj/projectile/bullet/a40mm/on_hit(atom/target, blocked = 0, pierce_hit)
	..()
	explosion(target, devastation_range = -1, light_impact_range = 2, flame_range = 3, flash_range = 1, adminlog = FALSE, explosion_cause = src)
	return BULLET_ACT_HIT

// China lake stuff

/obj/projectile/bullet/clblastnade
	name ="Blast Grenade"
	desc = "Do a barrel roll!"
	icon_state = "bolter"
	damage = 80

/obj/projectile/bullet/clblastnade/on_hit(atom/target, blocked = 0, pierce_hit)
	..()
	explosion(target, -1, 4, 6, 8, 0, flame_range = 10)
	return BULLET_ACT_HIT


/obj/projectile/bullet/clhighexplo
	name ="Frag Grenade"
	desc = "Press 'A' to shoot!"
	icon_state = "bolter"
	damage = 20

/obj/projectile/bullet/clhighexplo/on_hit(atom/target, blocked = 0, pierce_hit)
	..()
	explosion(target, -1, 7, 12, 16, 0, flame_range = 16)
	return BULLET_ACT_HIT
