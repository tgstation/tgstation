/obj/item/ammo_casing/caseless/a84mm
	desc = "An 84mm anti-armour rocket."
	caliber = "84mm"
	icon_state = "s-casing-live"
	projectile_type = /obj/item/projectile/bullet/a84mm

/obj/item/ammo_casing/caseless/a75
	desc = "A .75 bullet casing."
	caliber = "75"
	icon_state = "s-casing-live"
	projectile_type = /obj/item/projectile/bullet/gyro
	use_projectile_generator = TRUE

/obj/item/ammo_casing/caseless/a75/setup_generator()
	. = ..()
	if(istype(generator))
		generator.AddComponent(/datum/component/impact_explode, 0, 0, 2)
