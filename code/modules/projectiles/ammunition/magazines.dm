////////////////INTERNAL MAGAZINES//////////////////////
/obj/item/ammo_box/magazine/internal/cylinder
	name = "revolver cylinder"
	desc = "Oh god, this shouldn't be here"
	ammo_type = /obj/item/ammo_casing/a357
	caliber = "357"
	max_ammo = 7

/obj/item/ammo_box/magazine/internal/cylinder/ammo_count(var/countempties = 1)
	if (!countempties)
		var/boolets = 0
		for (var/i = 1, i <= stored_ammo.len, i++)
			var/obj/item/ammo_casing/bullet = stored_ammo[i]
			if (bullet.BB)
				boolets++
		return boolets
	else
		return ..()

/obj/item/ammo_box/magazine/internal/cylinder/rus357
	name = "russian revolver cylinder"
	desc = "Oh god, this shouldn't be here"
	ammo_type = /obj/item/ammo_casing/a357
	caliber = "357"
	max_ammo = 6
	multiload = 0

/obj/item/ammo_box/magazine/internal/cylinder/rus357/New()
	stored_ammo += new ammo_type(src)

/obj/item/ammo_box/magazine/internal/cylinder/rev38
	name = "d-tiv revolver cylinder"
	desc = "Oh god, this shouldn't be here"
	ammo_type = /obj/item/ammo_casing/c38
	caliber = "38"
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/shot
	name = "shotgun internal magazine"
	desc = "Oh god, this shouldn't be here"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag
	caliber = "shotgun"
	max_ammo = 4
	multiload = 0

/obj/item/ammo_box/magazine/internal/shotcom
	name = "combat shotgun internal magazine"
	desc = "Oh god, this shouldn't be here"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	caliber = "shotgun"
	max_ammo = 8
	multiload = 0

/obj/item/ammo_box/magazine/internal/cylinder/dualshot
	name = "double-barrel shotgun internal magazine"
	desc = "This doesn't even exist"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag
	caliber = "shotgun"
	max_ammo = 2
	multiload = 0

///////////EXTERNAL MAGAZINES////////////////
/obj/item/ammo_box/magazine/m9mm
	name = "magazine (9mm)"
	icon_state = "9x19p"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 8
	multiple_sprites = 2

/obj/item/ammo_box/magazine/msmg9mm
	name = "SMG magazine (9mm)"
	icon_state = "smg9mm"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 18

/obj/item/ammo_box/magazine/msmg9mm/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[round(ammo_count(),3)]"

/obj/item/ammo_box/magazine/m10mm
	name = "magazine (10mm)"
	icon_state = "9x19p"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c10mm
	caliber = "10mm"
	max_ammo = 8
	multiple_sprites = 2

/obj/item/ammo_box/magazine/m12mm
	name = "magazine (12mm)"
	icon_state = "12mm"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/a12mm
	caliber = "12mm"
	max_ammo = 20

/obj/item/ammo_box/magazine/m12mm/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[round(ammo_count(),2)]"

/obj/item/ammo_box/magazine/sm45
	name = "magazine (.45)"
	icon_state = "9x19p"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 12

/obj/item/ammo_box/magazine/sm45/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[ammo_count() ? "8" : "0"]"

/obj/item/ammo_box/magazine/uzim45
	name = "Uzi magazine (.45)"
	icon_state = "uzi45"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 16

/obj/item/ammo_box/magazine/uzim45/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[round(ammo_count(),2)]"

obj/item/ammo_box/magazine/tommygunm45
	name = "tommy gun drum (.45)"
	icon_state = "drum45"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 50

/obj/item/ammo_box/magazine/m50
	name = "magazine (.50ae)"
	icon_state = "50ae"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/a50
	caliber = ".50"
	max_ammo = 7
	multiple_sprites = 1

/obj/item/ammo_box/magazine/m75
	name = "magazine (.75)"
	icon_state = "75"
	ammo_type = /obj/item/ammo_casing/caseless/a75
	caliber = "75"
	multiple_sprites = 2
	max_ammo = 8

/obj/item/ammo_box/magazine/m762
	name = "magazine (7.62mm)"
	icon_state = "a762"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/a762
	caliber = "a762"
	max_ammo = 50


/obj/item/ammo_box/magazine/m762/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[round(ammo_count(),10)]"