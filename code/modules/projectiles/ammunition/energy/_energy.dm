/obj/item/ammo_casing/energy
	name = "energy weapon lens"
	desc = "The part of the gun that makes the laser go pew."
	caliber = ENERGY
	projectile_type = /obj/projectile/energy
	slot_flags = null
	var/e_cost = 100 //The amount of energy a cell needs to expend to create this shot.
	var/select_name = CALIBER_ENERGY
	fire_sound = 'sound/weapons/laser.ogg'
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/energy
	heavy_metal = FALSE
