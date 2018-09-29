/obj/item/projectile/plasma
	name = "plasma blast"
	icon_state = "plasmacutter"
	damage_type = BRUTE
	damage = 5
	range = 4
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	var/mine_range = 3 //mines this many additional tiles of rock
	tracer_type = /obj/effect/projectile/tracer/plasma_cutter
	muzzle_type = /obj/effect/projectile/muzzle/plasma_cutter
	impact_type = /obj/effect/projectile/impact/plasma_cutter
	var/pressure_check_scaling = FALSE
	
/obj/item/projectile/plasma/Initialize()	
	. = ..()	
	if(pressure_check_scaling && !lavaland_equipment_pressure_check(get_turf(src)))	
		name = "weakened [name]"	
		damage *= 0.25

/obj/item/projectile/plasma/on_hit(atom/target)
	. = ..()
	if(ismineralturf(target))
		var/turf/closed/mineral/M = target
		M.gets_drilled(firer)
		if(mine_range)
			mine_range--
			range++
		if(range > 0)
			return -1

/obj/item/projectile/plasma/adv
	damage = 7
	range = 5
	mine_range = 5

/obj/item/projectile/plasma/adv/mech
	damage = 40
	range = 9
	mine_range = 3
	dismemberment = 20
	pressure_check_scaling = TRUE
	
/obj/item/projectile/plasma/turret
	//Between normal and advanced for damage, made a beam so not the turret does not destroy glass
	name = "plasma beam"
	damage = 24
	range = 7
	dismemberment = 20
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	pressure_check_scaling = TRUE
