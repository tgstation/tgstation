/obj/item/ammo_casing
	name = "bullet casing"
	desc = "A .357 bullet casing."
	icon = 'ammo.dmi'
	icon_state = "s-casing"
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	throwforce = 1
	w_class = 1.0
	var
		caliber = "357"							//Which kind of guns it can be loaded into
		projectile_type = "/obj/item/projectile"//The bullet type to create when New() is called
		obj/item/projectile/BB = null 			//The loaded bullet


	New()
		..()
		if(projectile_type)
			BB = new projectile_type(src)
		pixel_x = rand(-10.0, 10)
		pixel_y = rand(-10.0, 10)
		dir = pick(cardinal)


	attackby(obj/item/weapon/W as obj, mob/user as mob)
		..()
		if (istype(W, /obj/item/weapon/trashbag))
			var/obj/item/weapon/trashbag/S = W
			if (S.mode == 1)
				for (var/obj/item/ammo_casing/AC in locate(src.x,src.y,src.z))
					if (S.contents.len < S.capacity)
						S.contents += AC;
					else
						user << "\blue The bag is full."
						break
				user << "\blue You pick up all trash."
			else
				if (S.contents.len < S.capacity)
					S.contents += src;
				else
					user << "\blue The bag is full."
			S.update_icon()
		return



//Boxes of ammo
/obj/item/ammo_magazine
	name = "ammo box (.357)"
	desc = "A box of .357 ammo"
	icon_state = "357"
	icon = 'ammo.dmi'
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	item_state = "syringe_kit"
	m_amt = 50000
	throwforce = 2
	w_class = 1.0
	throw_speed = 4
	throw_range = 10
	var
		list/stored_ammo = list()


	New()
		for(var/i = 1, i <= 7, i++)
			stored_ammo += new /obj/item/ammo_casing(src)
		update_icon()


	update_icon()
		icon_state = text("[initial(icon_state)]-[]", stored_ammo.len)
		desc = text("There are [] shell\s left!", stored_ammo.len)
