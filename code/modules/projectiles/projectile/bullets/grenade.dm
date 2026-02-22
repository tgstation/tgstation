// 40mm (Grenade Launcher

/obj/projectile/bullet/a40mm
	name ="40mm grenade"
	desc = "USE A WEEL GUN"
	icon_state= "bolter"
	damage = 60
	embed_type = null
	shrapnel_type = null
	var/ex_dev_range = -1
	var/ex_light_range = 2
	var/ex_flame_range = 3

/obj/projectile/bullet/a40mm/on_hit(atom/target, blocked = 0, pierce_hit)
	..()
	explosion(target, devastation_range = ex_dev_range, light_impact_range = ex_light_range, flame_range = ex_flame_range, flash_range = 1, adminlog = FALSE, explosion_cause = src)
	grenade_extra_effect(target)
	return BULLET_ACT_HIT

/obj/projectile/bullet/a40mm/proc/grenade_extra_effect(atom/target)
	if(!prob(1))
		return

	if(isliving(target))
		var/mob/living/living_target = target
		playsound(living_target, 'sound/effects/coin2.ogg', 40, TRUE)
		new /obj/effect/temp_visual/crit(get_turf(living_target))

/obj/projectile/bullet/a40mm/incendiary
	name = "40mm incendiary grenade"
	desc = "If you're seeing this, you are probably about to have really bad day."
	damage = 10 // About the only mercy you're getting.
	ex_light_range = 1
	ex_flame_range = 4

/obj/projectile/bullet/a40mm/incendiary/grenade_extra_effect(atom/target, blocked = 0, pierce_hit)
	if(iscarbon(target))
		var/mob/living/carbon/poor_burning_dork = target
		poor_burning_dork.adjust_fire_stacks(damage*2)
		poor_burning_dork.ignite_mob()
	for(var/turf/nearby_turf as anything in RANGE_TURFS(ex_flame_range, target))
		new /obj/effect/hotspot(nearby_turf)
