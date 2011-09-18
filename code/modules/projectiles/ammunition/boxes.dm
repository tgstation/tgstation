/obj/item/ammo_magazine/a75//Still needs to be gone through
	name = "ammo magazine (.75)"
	icon_state = "gyro"
	New()
		for(var/i = 1, i <= 8, i++)
			stored_ammo += new /obj/item/ammo_casing/a75(src)
		update_icon()


/obj/item/ammo_magazine/c38
	name = "speed loader (.38)"
	icon_state = "38"
	New()
		for(var/i = 1, i <= 7, i++)
			stored_ammo += new /obj/item/ammo_casing/c38(src)
		update_icon()


/obj/item/ammo_magazine/a418
	name = "ammo box (.418)"
	icon_state = "418"
	New()
		for(var/i = 1, i <= 7, i++)
			stored_ammo += new /obj/item/ammo_casing/a418(src)
		update_icon()


/obj/item/ammo_magazine/a666
	name = "ammo box (.666)"
	icon_state = "666"
	New()
		for(var/i = 1, i <= 2, i++)
			stored_ammo += new /obj/item/ammo_casing/a666(src)
		update_icon()


/obj/item/ammo_magazine/c9mm
	name = "Ammunition Box (9mm)"
	icon_state = "9mm"
	origin_tech = "combat=3;materials=2"
	New()
		for(var/i = 1, i <= 30, i++)
			stored_ammo += new /obj/item/ammo_casing/c9mm(src)
		update_icon()

	update_icon()
		desc = text("There are [] round\s left!", stored_ammo.len)


/obj/item/ammo_magazine/c45
	name = "Ammunition Box (.45)"
	icon_state = "9mm"
	origin_tech = "combat=3;materials=2"
	New()
		for(var/i = 1, i <= 30, i++)
			stored_ammo += new /obj/item/ammo_casing/c45(src)
		update_icon()

	update_icon()
		desc = text("There are [] round\s left!", stored_ammo.len)
