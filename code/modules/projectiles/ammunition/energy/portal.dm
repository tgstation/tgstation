/obj/item/ammo_casing/energy/wormhole
	projectile_type = /obj/projectile/beam/wormhole
	e_cost = 0 // Can't use the macro
	harmful = FALSE
	fire_sound = 'sound/items/weapons/pulse3.ogg'
	select_name = "blue"
	//Weakref to the gun that shot us
	var/datum/weakref/gun
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/blue

/obj/item/ammo_casing/energy/wormhole/orange
	projectile_type = /obj/projectile/beam/wormhole/orange
	select_name = "orange"
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/red

/obj/item/ammo_casing/energy/wormhole/Initialize(mapload, obj/item/gun/energy/wormhole_projector/wh)
	. = ..()
	gun = WEAKREF(wh)

/obj/item/ammo_casing/energy/wormhole/throw_proj(atom/target, turf/targloc, mob/living/user, params, spread, atom/fired_from)
	. = ..()
	if(istype(loaded_projectile, /obj/projectile/beam/wormhole))
		var/obj/projectile/beam/wormhole/WH = loaded_projectile
		WH.gun = gun
