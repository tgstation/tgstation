/obj/structure/ammo_printer
	name = "rusting ammo printer"
	desc = "An ammunition printer covered in rust. It looks like it has enough juice for one more run.."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "brassbox"
	anchored = TRUE
	density = TRUE
	var/used = FALSE
	var/blacklist = list(
		/obj/item/gun/ballistic/revolver/grenadelauncher,
		/obj/item/gun/grenadelauncher,
		/obj/item/gun/ballistic/rocketlauncher,
		/obj/item/gun/ballistic/automatic/gyropistol
	)
	var/obj/item/gun/ballistic/inserted_gun
	var/has_metal = FALSE
	var/total_ammo = 1
	var/ammo_type

/obj/structure/ammo_printer/Initialize()
	. = ..()
	desc = "An ammunition printer covered in rust. It looks like it has enough juice for one more run.. It has 0 sheets of metal loaded."

/obj/structure/ammo_printer/attackby(obj/item/inserted_item, mob/living/user)
	if(used)
		to_chat(user, "<span class='warning'>The printer has no power left!</span>")
		playsound(src, 'sound/machines/uplinkerror.ogg', 25, FALSE)
		return
	if(istype(inserted_item, /obj/item/gun/ballistic))
		if(inserted_gun)
			to_chat(user, "<span class='warning'>A weapon is already loaded into the machine!</span>")
			playsound(src, 'sound/machines/uplinkerror.ogg', 25, FALSE)
			return
		for(var/weapon in blacklist)
			if(istype(inserted_item, weapon))
				to_chat(user, "<span class='warning'>The printer cannot work with weapons of this caliber!</span>")
				playsound(src, 'sound/machines/uplinkerror.ogg', 25, FALSE)
				return
		if(!user.transferItemToLoc(inserted_item, src))
			to_chat(user, "<span class='warning'>The weapon is stuck to your hand!</span>")
			playsound(src, 'sound/machines/uplinkerror.ogg', 25, FALSE)
			return
		inserted_gun = inserted_item
		playsound(src, 'sound/items/deconstruct.ogg', 50, FALSE)
		to_chat(user, "You load the [inserted_item.name] into the printer.")
	if(istype(inserted_item, /obj/item/stack/sheet/iron))
		if (has_metal)
			return
		var/obj/item/stack/sheet/iron/stack = inserted_item
		switch(stack.amount)
			if(0 to 24)
				to_chat(user, "<span class='warning'>You need to insert 25 metal sheets!</span>")
				playsound(src, 'sound/machines/uplinkerror.ogg', 25, FALSE)
				return
			if(25)
				to_chat(user, "<span class='warning'>You insert 25 metal sheets into the machine.</span>")
				playsound(src, 'sound/items/deconstruct.ogg', 50, FALSE)
				qdel(stack)
			else
				stack.add(-25)
		has_metal = TRUE
		desc = "An ammunition printer covered in rust. It looks like it has enough juice for one more run.. It has 25 sheets of metal loaded."

/obj/structure/ammo_printer/interact(mob/user)
	. = ..()
	if(used)
		to_chat(user, "<span class='warning'>The printer has no power left!</span>")
		playsound(src, 'sound/machines/uplinkerror.ogg', 25, FALSE)
		return
	if(!inserted_gun)
		to_chat(user, "<span class='warning'>Insert a weapon first!</span>")
		playsound(src, 'sound/machines/uplinkerror.ogg', 25, FALSE)
		return
	if(!has_metal)
		to_chat(user, "<span class='warning'>You need to insert 25 metal to operate this printer!</span>")
		playsound(src, 'sound/machines/uplinkerror.ogg', 25, FALSE)
		return

	if(inserted_gun.internal_magazine)
		var/obj/item/ammo_box/magazine/internal/mag = inserted_gun.accepted_magazine_type
		ammo_type = initial(mag.ammo_type)
		total_ammo = rand(3,10)
	else
		ammo_type = inserted_gun.accepted_magazine_type
		total_ammo = pick(1,2)
	if(do_after(user, 40, target = src))
		while(total_ammo != 0)
			new ammo_type(src.loc)
			total_ammo -= 1
		inserted_gun.forceMove(src.loc)
		inserted_gun = FALSE
		desc = "An ammunition printer covered in rust. It's out of juice!"
		used = TRUE

/obj/structure/ammo_printer/AltClick(mob/user)
	if(inserted_gun)
		inserted_gun.forceMove(src.loc)
		inserted_gun = null
	else
		to_chat(user, "<span class='warning'>No weapon inserted!</span>")
