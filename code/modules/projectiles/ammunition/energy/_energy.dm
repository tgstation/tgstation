/obj/item/ammo_casing/energy
	name = "energy weapon lens"
	desc = "The part of the gun that makes the laser go pew."
	caliber = ENERGY
	projectile_type = /obj/projectile/energy
	slot_flags = null
	fire_sound = 'sound/items/weapons/laser.ogg'
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/red
	newtonian_force = 0.5
	muzzle_flash_color = LIGHT_COLOR_CYAN

	///The amount of energy a cell needs to expend to create this shot.
	var/e_cost = LASER_SHOTS(10, STANDARD_CELL_CHARGE)
	var/select_name = CALIBER_ENERGY
	///Energy casing specific flags: (PROJECTILE_CANT_COPY)
	var/energy_projectile_flags = NONE
