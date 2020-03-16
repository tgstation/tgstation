/obj/projectile/crystal
	name = "crystal"
	icon_state = "crystal_square"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 200 // dont get hit by this
	light_range = 2
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	flag = "laser"
	eyeblur = 2
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = LIGHT_COLOR_RED
	ricochets_max = 50
	ricochet_chance = 80
	reflectable = REFLECT_NORMAL
	var/is_test_fire = TRUE
	var/which_emitter = 1
	var/crystal_color = CRYSTAL_COLOR_RED
	var/crystal_size = CRYSTAL_SIZE_MEDIUM
	var/crystal_shape = CRYSTAL_SHAPE_SQUARE


/obj/projectile/crystal/on_hit(atom/target)
	. = ..()
	if(iscarbon(target)) // dont get hit by this
		var/mob/living/carbon/C = target
		C.dust()
	if(istype(target, /obj/machinery/hazmat/anomalous_material))
		var/obj/machinery/hazmat/anomalous_material/AM = target
		AM.crystal_laser_hit(src)