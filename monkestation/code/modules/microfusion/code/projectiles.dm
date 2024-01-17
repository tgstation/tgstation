/obj/item/ammo_casing
	///What volume should the sound play at?
	var/fire_sound_volume = 50

/obj/item/ammo_casing/energy/laser/microfusion
	name = "microfusion energy lens"
	projectile_type = /obj/projectile/beam/laser/microfusion
	e_cost = LASER_SHOTS(10, STANDARD_CELL_CHARGE) // 10 shots with a normal cell.
	select_name = "laser"
	fire_sound = 'modular_skyrat/modules/microfusion/sound/laser_1.ogg'
	fire_sound_volume = 100

/obj/item/ammo_casing/proc/refresh_shot()
	loaded_projectile = new projectile_type(src, src)

/obj/projectile/beam/laser/microfusion
	name = "microfusion laser"
	icon = 'modular_skyrat/modules/microfusion/icons/projectiles.dmi'
	damage = 25

/obj/projectile/beam/microfusion_disabler
	name = "microfusion disabler laser"
	icon = 'modular_skyrat/modules/microfusion/icons/projectiles.dmi'
	icon_state = "disabler"
	damage = 41
	damage_type = STAMINA
	armor_flag = ENERGY
	hitsound = 'sound/weapons/tap.ogg'
	eyeblur = 0
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE
	tracer_type = /obj/effect/projectile/tracer/disabler
	muzzle_type = /obj/effect/projectile/muzzle/disabler
	impact_type = /obj/effect/projectile/impact/disabler

/obj/projectile/beam/laser/microfusion/superheated
	name = "superheated microfusion laser"
	icon_state = "laser_greyscale"
	damage = 20 //Trading damage for fire stacks
	color = LIGHT_COLOR_FIRE
	light_color = LIGHT_COLOR_FIRE

/obj/projectile/beam/laser/microfusion/superheated/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(isliving(target))
		var/mob/living/living = target
		living.adjust_fire_stacks(2)
		living.ignite_mob()

/obj/projectile/beam/laser/microfusion/hellfire
	name = "hellfire microfusion laser"
	icon_state = "laser_greyscale"
	wound_bonus = 0
	damage = 20 // You are trading damage for a significant wound bonus and speed increase
	speed = 0.6
	color = LIGHT_COLOR_FLARE
	light_color = LIGHT_COLOR_FLARE

/obj/projectile/beam/laser/microfusion/scatter
	name = "scatter microfusion laser"

/obj/projectile/beam/laser/microfusion/scatter/max
	name = "scatter microfusion laser"

/obj/projectile/beam/laser/microfusion/repeater
	damage = 12.5

/obj/projectile/beam/laser/microfusion/penetrator
	name = "focused microfusion laser"
	damage = 20
	armour_penetration = 50

/obj/projectile/beam/laser/microfusion/lance
	name = "lance microfusion laser"
	damage = 50 // We're turning the gun into a heavylaser
	tracer_type = /obj/effect/projectile/tracer/heavy_laser
	muzzle_type = /obj/effect/projectile/muzzle/heavy_laser
	impact_type = /obj/effect/projectile/impact/heavy_laser
	speed = 0.4

/obj/projectile/beam/laser/microfusion/xray
	name = "x-ray microfusion laser"
	icon_state = "laser_greyscale"
	color = COLOR_GREEN
	light_color = COLOR_GREEN
	projectile_piercing = PASSCLOSEDTURF|PASSGRILLE|PASSGLASS

/obj/projectile/beam/laser/microfusion/honk
	name = "funny microfusion laser"
	icon_state = "laser_greyscale"
	color = COLOR_VIVID_YELLOW
	light_color = COLOR_VIVID_YELLOW
	damage_type = STAMINA
	damage = 25
	armor_flag = ENERGY
	hitsound = 'sound/misc/slip.ogg'
	impact_type = /obj/effect/projectile/impact/disabler

/obj/projectile/beam/laser/microfusion/honk/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery, 20)
