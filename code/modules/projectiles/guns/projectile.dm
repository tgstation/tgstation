#define SPEEDLOADER 0
#define FROM_BOX 1
#define MAGAZINE 2

/obj/item/weapon/gun/projectile
	desc = "A classic revolver. Uses 357 ammo"
	name = "revolver"
	icon_state = "revolver"
	caliber = "357"
	origin_tech = "combat=2;materials=2"
	w_class = 3.0
	m_amt = 1000
	w_type = RECYK_METAL
	recoil = 1
	var/empty_casings = 1 //Set to 0 to not eject empty casings
	var/ammo_type = "/obj/item/ammo_casing/a357"
	var/list/loaded = list()
	var/max_shells = 7
	var/load_method = SPEEDLOADER //0 = Single shells or quick loader, 1 = box, 2 = magazine
	var/obj/item/ammo_magazine/empty_mag = null


/obj/item/weapon/gun/projectile/New()
	..()
	for(var/i = 1, i <= max_shells, i++)
		loaded += new ammo_type(src)
	update_icon()
	return


/obj/item/weapon/gun/projectile/load_into_chamber()
	if(in_chamber)
		return 1 //{R}

	if(!loaded.len)
		return 0
	var/obj/item/ammo_casing/AC = loaded[1] //load next casing.
	loaded -= AC //Remove casing from loaded list.
	if(isnull(AC) || !istype(AC))
		return 0
	if(empty_casings == 1)
		AC.loc = get_turf(src) //Eject casing onto ground.
		if(AC.BB)
			AC.desc += " This one is spent."	//descriptions are magic - only when there's a projectile in the casing
			in_chamber = AC.BB //Load projectile into chamber.
			AC.BB.loc = src //Set projectile loc to gun.
			return 1
		return 0
	else
		if(AC.BB)
			in_chamber = AC.BB //Load projectile into chamber
			AC.BB.loc = src //Set projectile loc to gun
			return 1
		return 0


/obj/item/weapon/gun/projectile/attackby(var/obj/item/A as obj, mob/user as mob)

	var/num_loaded = 0
	if(istype(A, /obj/item/ammo_magazine))
		if((load_method == MAGAZINE) && loaded.len)	return
		var/obj/item/ammo_magazine/AM = A
		for(var/obj/item/ammo_casing/AC in AM.stored_ammo)
			if(loaded.len >= max_shells)
				break
			if(AC.caliber == caliber && loaded.len < max_shells)
				AC.loc = src
				AM.stored_ammo -= AC
				loaded += AC
				num_loaded++
		if(load_method == MAGAZINE)
			user.remove_from_mob(AM)
			empty_mag = AM
			empty_mag.loc = src
	if(istype(A, /obj/item/ammo_casing) && load_method == SPEEDLOADER)
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

/obj/item/weapon/gun/projectile/attack_self(mob/user as mob)
	if (target)
		return ..()
	if (loaded.len)
		if (load_method == SPEEDLOADER)
			var/obj/item/ammo_casing/AC = loaded[1]
			loaded -= AC
			AC.loc = get_turf(src) //Eject casing onto ground.
			user << "\blue You unload shell from \the [src]!"
		if (load_method == MAGAZINE)
			var/obj/item/ammo_magazine/AM = empty_mag
			for (var/obj/item/ammo_casing/AC in loaded)
				AM.stored_ammo += AC
				loaded -= AC
			AM.loc = get_turf(src)
			empty_mag = null
			update_icon()
			user << "\blue You unload magazine from \the [src]!"
	else
		user << "\red Nothing loaded in \the [src]!"



/obj/item/weapon/gun/projectile/examine()
	..()
	usr << "Has [getAmmo()] round\s remaining."
//		if(in_chamber && !loaded.len)
//			usr << "However, it has a chambered round."
//		if(in_chamber && loaded.len)
//			usr << "It also has a chambered round." {R}
	return

/obj/item/weapon/gun/projectile/proc/getAmmo()
	var/bullets = 0
	for(var/obj/item/ammo_casing/AC in loaded)
		if(istype(AC))
			bullets += 1
	return bullets

