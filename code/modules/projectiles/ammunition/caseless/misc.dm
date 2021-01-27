/obj/item/ammo_casing/caseless/laser
	name = "laser casing"
	desc = "You shouldn't be seeing this."
	caliber = "laser"
	icon_state = "s-casing-live"
	slot_flags = null
	projectile_type = /obj/projectile/beam
	fire_sound = 'sound/weapons/laser.ogg'
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/energy

/obj/item/ammo_casing/caseless/laser/gatling
	projectile_type = /obj/projectile/beam/weak/penetrator
	variance = 0.8
	click_cooldown_override = 1

	// Harpoons (Ballistic Harpoon Gun)

/obj/item/ammo_casing/caseless/harpoon
	name = "harpoon"
	caliber = "harpoon"
	icon_state = "magspear"
	projectile_type = /obj/projectile/bullet/harpoon
