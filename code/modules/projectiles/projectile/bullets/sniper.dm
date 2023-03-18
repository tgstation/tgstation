// .50 (Sniper)

/obj/projectile/bullet/p50
	name =".50 bullet"
	speed = 0.4
	range = 400 // Enough to travel from one corner of the Z to the opposite corner and then some.
	damage = 70
	paralyze = 100
	dismemberment = 50
	armour_penetration = 50
	var/breakthings = TRUE

/obj/projectile/bullet/p50/on_hit(atom/target, blocked = 0)
	if(isobj(target) && (blocked != 100) && breakthings)
		var/obj/O = target
		O.take_damage(80, BRUTE, BULLET, FALSE)
	return ..()

/obj/projectile/bullet/p50/soporific
	name =".50 soporific bullet"
	armour_penetration = 0
	damage = 0
	dismemberment = 0
	paralyze = 0
	breakthings = FALSE

/obj/projectile/bullet/p50/soporific/on_hit(atom/target, blocked = FALSE)
	if((blocked != 100) && isliving(target))
		var/mob/living/L = target
		L.Sleeping(400)
	return ..()

/obj/projectile/bullet/p50/penetrator
	name = "penetrator round"
	icon_state = "gauss"
	damage = 60
	range = 50
	projectile_piercing = PASSMOB|PASSVEHICLE
	projectile_phasing = ~(PASSMOB|PASSVEHICLE)
	phasing_ignore_direct_target = TRUE
	dismemberment = 0 //It goes through you cleanly.
	paralyze = 0
	breakthings = FALSE

/obj/projectile/bullet/p50/penetrator/shuttle //Nukeop Shuttle Variety
	icon_state = "gaussstrong"
	damage = 25
	speed = 0.3
	range = 16

/obj/projectile/bullet/p50/marksman
	name = ".50 marksman round"
	damage = 50
	paralyze = 0
	tracer_type = /obj/effect/projectile/tracer/sniper
	impact_type = /obj/effect/projectile/impact/sniper
	muzzle_type = /obj/effect/projectile/muzzle/sniper
	hitscan = TRUE
	impact_effect_type = null
	hitscan_light_intensity = 3
	hitscan_light_range = 0.75
	hitscan_light_color_override = LIGHT_COLOR_DIM_YELLOW
	muzzle_flash_intensity = 5
	muzzle_flash_range = 1
	muzzle_flash_color_override = LIGHT_COLOR_DIM_YELLOW
	impact_light_intensity = 5
	impact_light_range = 1
	impact_light_color_override = LIGHT_COLOR_DIM_YELLOW
	ricochets_max = 1
	ricochet_chance = 100
	ricochet_auto_aim_angle = 45
	ricochet_auto_aim_range = 15
	ricochet_incidence_leeway = 90
	ricochet_decay_damage = 1
	ricochet_shoots_firer = FALSE
