/obj/item/weapon/gun/projectile
	desc = "A classic revolver. Uses 357 ammo"
	name = "revolver"
	icon_state = "revolver"
	caliber = "357"
	origin_tech = "combat=2;materials=2"
	w_class = 3.0
	m_amt = 1000

	var
		ammo_type = "/obj/item/ammo_casing/a357"
		list/loaded = list()
		max_shells = 7
		load_method = 0 //0 = Single shells or quick loader, 1 = box, 2 = magazine
		obj/item/ammo_magazine/empty_mag = null


	New()
		..()
		for(var/i = 1, i <= max_shells, i++)
			loaded += new ammo_type(src)
		update_icon()
		return


	load_into_chamber()
		if(in_chamber)
			return 1

		if(!loaded.len)
			return 0

		var/obj/item/ammo_casing/AC = loaded[1] //load next casing.
		loaded -= AC //Remove casing from loaded list.
		AC.loc = get_turf(src) //Eject casing onto ground.
		AC.desc += " This one is spent."	//descriptions are magic

		if(AC.BB)
			in_chamber = AC.BB //Load projectile into chamber.
			AC.BB.loc = src //Set projectile loc to gun.
			return 1
		return 0


	attackby(var/obj/item/A as obj, mob/user as mob)

		var/num_loaded = 0
		if(istype(A, /obj/item/ammo_magazine))
			if((load_method == 2) && loaded.len)	return
			var/obj/item/ammo_magazine/AM = A
			for(var/obj/item/ammo_casing/AC in AM.stored_ammo)
				if(loaded.len >= max_shells)
					break
				if(AC.caliber == caliber && loaded.len < max_shells)
					AC.loc = src
					AM.stored_ammo -= AC
					loaded += AC
					num_loaded++
			if(load_method == 2)
				user.remove_from_mob(AM)
				empty_mag = AM
				empty_mag.loc = src
		if(istype(A, /obj/item/ammo_casing) && !load_method)
			var/obj/item/ammo_casing/AC = A
			if(AC.caliber == caliber && loaded.len < max_shells)
				user.drop_item()
				AC.loc = src
				loaded += AC
				num_loaded++
		if(num_loaded)
			user << "\blue You load [num_loaded] shell\s into the gun!"
		A.update_icon()
		update_icon()
		return


	examine()
		..()
		usr << "Has [loaded.len] round\s remaining."
		if(in_chamber && !loaded.len)
			usr << "However, it has a chambered round."
		if(in_chamber && loaded.len)
			usr << "It also has a chambered round."
		return

