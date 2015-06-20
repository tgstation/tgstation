/obj/item/ammo_casing
	name = "bullet casing"
	desc = "A bullet casing."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "s-casing"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = 1.0
	var/fire_sound = null						//What sound should play when this ammo is fired
	var/caliber = null							//Which kind of guns it can be loaded into
	var/projectile_type = null					//The bullet type to create when New() is called
	var/obj/item/projectile/BB = null 			//The loaded bullet
	var/pellets = 0								//Pellets for spreadshot
	var/variance = 0							//Variance for inaccuracy fundamental to the casing
	var/delay = 0								//Delay for energy weapons

/obj/item/ammo_casing/New()
	..()
	if(projectile_type)
		BB = new projectile_type(src)
	pixel_x = rand(-10.0, 10)
	pixel_y = rand(-10.0, 10)
	dir = pick(alldirs)
	update_icon()

/obj/item/ammo_casing/update_icon()
	..()
	icon_state = "[initial(icon_state)][BB ? "-live" : ""]"
	desc = "[initial(desc)][BB ? "" : " This one is spent"]"

/obj/item/ammo_casing/proc/newshot() //For energy weapons, shotgun shells and wands (!).
	if (!BB)
		BB = new projectile_type(src)
	return

/obj/item/ammo_casing/attackby(obj/item/ammo_box/box as obj, mob/user as mob, params)
	if (!istype(box, /obj/item/ammo_box))
		return
	if(isturf(src.loc))
		var/boolets = 0
		for(var/obj/item/ammo_casing/bullet in src.loc)
			if (box.stored_ammo.len >= box.max_ammo)
				break
			if (bullet.BB)
				if (box.give_round(bullet, 0))
					boolets++
			else
				continue
		if (boolets > 0)
			box.update_icon()
			user << "<span class='notice'>You collect [boolets] shell\s. [box] now contains [box.stored_ammo.len] shell\s.</span>"
		else
			user << "<span class='warning'>You fail to collect anything!</span>"

//Boxes of ammo
/obj/item/ammo_box
	name = "ammo box (null_reference_exception)"
	desc = "A box of ammo."
	icon_state = "357"
	icon = 'icons/obj/ammo.dmi'
	flags = CONDUCT
	slot_flags = SLOT_BELT
	item_state = "syringe_kit"
	m_amt = 30000
	throwforce = 2
	w_class = 1.0
	throw_speed = 3
	throw_range = 7
	var/list/stored_ammo = list()
	var/ammo_type = /obj/item/ammo_casing
	var/max_ammo = 7
	var/multiple_sprites = 0
	var/caliber
	var/multiload = 1

/obj/item/ammo_box/New()
	for(var/i = 1, i <= max_ammo, i++)
		stored_ammo += new ammo_type(src)
	update_icon()

/obj/item/ammo_box/proc/get_round(var/keep = 0)
	if (!stored_ammo.len)
		return null
	else
		var/b = stored_ammo[stored_ammo.len]
		stored_ammo -= b
		if (keep)
			stored_ammo.Insert(1,b)
		return b

/obj/item/ammo_box/proc/give_round(var/obj/item/ammo_casing/R, var/replace_spent = 0)
	// Boxes don't have a caliber type, magazines do. Not sure if it's intended or not, but if we fail to find a caliber, then we fall back to ammo_type.
	if(!R || (caliber && R.caliber != caliber) || (!caliber && R.type != ammo_type))
		return 0

	if (stored_ammo.len < max_ammo)
		stored_ammo += R
		R.loc = src
		return 1

	//for accessibles magazines (e.g internal ones) when full, start replacing spent ammo
	else if(replace_spent)
		for(var/obj/item/ammo_casing/AC in stored_ammo)
			if(!AC.BB)//found a spent ammo
				stored_ammo -= AC
				AC.loc = get_turf(src.loc)

				stored_ammo += R
				R.loc = src
				return 1

	return 0

/obj/item/ammo_box/attackby(var/obj/item/A as obj, mob/user as mob, params, var/silent = 0, var/replace_spent = 0)
	var/num_loaded = 0
	if(istype(A, /obj/item/ammo_box))
		var/obj/item/ammo_box/AM = A
		for(var/obj/item/ammo_casing/AC in AM.stored_ammo)
			var/did_load = give_round(AC, replace_spent)
			if(did_load)
				AM.stored_ammo -= AC
				num_loaded++
			if(!did_load || !multiload)
				break
	if(istype(A, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/AC = A
		if(give_round(AC, replace_spent))
			user.drop_item()
			AC.loc = src
			num_loaded++

	if(num_loaded)
		if(!silent)
			user << "<span class='notice'>You load [num_loaded] shell\s into \the [src]!</span>"
		A.update_icon()
		update_icon()

	return num_loaded

/obj/item/ammo_box/attack_self(mob/user as mob)
	var/obj/item/ammo_casing/A = get_round()
	if(A)
		user.put_in_hands(A)
		user << "<span class='notice'>You remove a round from \the [src]!</span>"
		update_icon()

/obj/item/ammo_box/update_icon()
	switch(multiple_sprites)
		if(1)
			icon_state = "[initial(icon_state)]-[stored_ammo.len]"
		if(2)
			icon_state = "[initial(icon_state)]-[stored_ammo.len ? "[max_ammo]" : "0"]"
	desc = "[initial(desc)] There are [stored_ammo.len] shell\s left!"

//Behavior for magazines
/obj/item/ammo_box/magazine/proc/ammo_count()
	return stored_ammo.len