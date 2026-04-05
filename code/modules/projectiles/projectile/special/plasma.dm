/obj/projectile/plasma
	name = "plasma blast"
	icon_state = "plasmacutter"
	damage_type = BURN
	armor_flag = ENERGY
	damage = 5
	range = 3
	dismemberment = 20
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	tracer_type = /obj/effect/projectile/tracer/plasma_cutter
	muzzle_type = /obj/effect/projectile/muzzle/plasma_cutter
	impact_type = /obj/effect/projectile/impact/plasma_cutter
	// Mines this many additional tiles of rock
	var/mine_range = 3

/obj/projectile/plasma/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if (!ismineralturf(target))
		return
	var/turf/closed/mineral/rock = target
	rock.gets_drilled(firer)
	if (mine_range)
		mine_range -= 1
		// Harder rocks give less extra range
		range += /turf/closed/mineral::tool_mine_speed / rock.tool_mine_speed
	if (range > 0)
		return BULLET_ACT_FORCE_PIERCE

/obj/projectile/plasma/adv
	damage = 7
	range = 4
	mine_range = 4

/obj/projectile/plasma/adv/mech
	damage = 10
	range = 7
	mine_range = 3

/obj/projectile/plasma/turret
	//Between normal and advanced for damage, made a beam so not the turret does not destroy glass
	name = "plasma beam"
	damage = 24
	range = 7
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE

