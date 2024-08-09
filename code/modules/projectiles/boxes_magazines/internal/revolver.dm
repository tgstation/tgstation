/obj/item/ammo_box/magazine/internal/cylinder/rev38
	name = "detective revolver cylinder"
	ammo_type = /obj/item/ammo_casing/c38
	caliber = CALIBER_38
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/cylinder/short310
	name = "\improper Sakhno-Manni revolver cylinder"
	ammo_type = /obj/item/ammo_casing/short310
	caliber = CALIBER_SHORT310
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/cylinder/rus357
	name = "\improper Russian revolver cylinder"
	ammo_type = /obj/item/ammo_casing/a357
	caliber = CALIBER_357
	max_ammo = 6
	multiload = FALSE
	start_empty = TRUE

/obj/item/ammo_box/magazine/internal/cylinder/rus357/Initialize(mapload)
	. = ..()
	for (var/i in 1 to max_ammo - 1)
		stored_ammo += new /obj/item/ammo_casing/a357/spent(src)
	stored_ammo += new /obj/item/ammo_casing/a357(src)
