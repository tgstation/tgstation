/obj/crate
	desc = "A crate."
	name = "Crate"
	icon = 'storage.dmi'
	icon_state = "crate"
	density = 1
	var/openicon = "crateopen"
	var/closedicon = "crate"
	req_access = null
	var/opened = 0
	var/locked = 0
	flags = FPRINT
	m_amt = 7500
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER

/obj/crate/internals
	desc = "A internals crate."
	name = "Internals crate"
	icon = 'storage.dmi'
	icon_state = "o2crate"
	density = 1
	openicon = "o2crateopen"
	closedicon = "o2crate"

/obj/crate/medical
	desc = "A medical crate."
	name = "Medical crate"
	icon = 'storage.dmi'
	icon_state = "medicalcrate"
	density = 1
	openicon = "medicalcrateopen"
	closedicon = "medicalcrate"

/obj/crate/rcd
	desc = "A crate for the storage of the RCD."
	name = "RCD crate"
	icon = 'storage.dmi'
	icon_state = "crate"
	density = 1
	openicon = "crateopen"
	closedicon = "crate"

/obj/crate/freezer
	desc = "A freezer."
	name = "Freezer"
	icon = 'storage.dmi'
	icon_state = "freezer"
	density = 1
	openicon = "freezeropen"
	closedicon = "freezer"

/obj/crate/bin
	desc = "A large bin."
	name = "Large bin"
	icon = 'storage.dmi'
	icon_state = "largebin"
	density = 1
	openicon = "largebinopen"
	closedicon = "largebin"

/obj/crate/radiation
	desc = "A crate with a radiation sign on it."
	name = "Radioactive gear crate"
	icon = 'storage.dmi'
	icon_state = "radiation"
	density = 1
	openicon = "radiationopen"
	closedicon = "radiation"

/obj/item/clothing/suit/radiation

/obj/crate/secure/weapon
	desc = "A secure weapons crate."
	name = "Weapons crate"
	icon = 'storage.dmi'
	icon_state = "weaponcrate"
	density = 1
	openicon = "weaponcrateopen"
	closedicon = "weaponcrate"

/obj/crate/secure/plasma
	desc = "A secure plasma crate."
	name = "Plasma crate"
	icon = 'storage.dmi'
	icon_state = "plasmacrate"
	density = 1
	openicon = "plasmacrateopen"
	closedicon = "plasmacrate"

/obj/crate/secure/gear
	desc = "A secure gear crate."
	name = "Gear crate"
	icon = 'storage.dmi'
	icon_state = "secgearcrate"
	density = 1
	openicon = "secgearcrateopen"
	closedicon = "secgearcrate"

/obj/crate/secure/bin
	desc = "A secure bin."
	name = "Secure bin"
	icon_state = "largebins"
	openicon = "largebinsopen"
	closedicon = "largebins"
	redlight = "largebinr"
	greenlight = "largebing"
	sparks = "largebinsparks"
	emag = "largebinemag"

/obj/crate/secure
	desc = "A secure crate."
	name = "Secure crate"
	icon_state = "securecrate"
	openicon = "securecrateopen"
	closedicon = "securecrate"
	var/redlight = "securecrater"
	var/greenlight = "securecrateg"
	var/sparks = "securecratesparks"
	var/emag = "securecrateemag"
	var/broken = 0
	locked = 1

/obj/crate/hydroponics
	name = "Hydroponics crate"
	desc = "All you need to destroy those pesky weeds and pests."
	icon = 'storage.dmi'
	icon_state = "hydrocrate"
	openicon = "hydrocrateopen"
	closedicon = "hydrocrate"
	density = 1
/*	New() // This stuff shouldn't be here, it should be in /datum/supply_packs/hydroponics
		..()
		new /obj/item/weapon/plantbgone(src)
		new /obj/item/weapon/plantbgone(src)
		new /obj/item/weapon/plantbgone(src)
		new /obj/item/weapon/minihoe(src)
		new /obj/item/weapon/weedspray(src)
		new /obj/item/weapon/weedspray(src)
		new /obj/item/weapon/pestspray(src)
		new /obj/item/weapon/pestspray(src)
		new /obj/item/weapon/pestspray(src) */

/obj/crate/hydroponics/prespawned
	//This exists so the prespawned hydro crates spawn with their contents.
/*	name = "Hydroponics crate"
	desc = "All you need to destroy those pesky weeds and pests."
	icon = 'storage.dmi'
	icon_state = "hydrocrate"
	openicon = "hydrocrateopen"
	closedicon = "hydrocrate"
	density = 1*/
	New()
		..()
		new /obj/item/weapon/plantbgone(src)
		new /obj/item/weapon/plantbgone(src)
		new /obj/item/weapon/plantbgone(src)
		new /obj/item/weapon/minihoe(src)
//		new /obj/item/weapon/weedspray(src)
//		new /obj/item/weapon/weedspray(src)
//		new /obj/item/weapon/pestspray(src)
//		new /obj/item/weapon/pestspray(src)
//		new /obj/item/weapon/pestspray(src)

/obj/crate/New()
	..()
	spawn(1)
		if(!opened)		// if closed, any item at the crate's loc is put in the contents
			for(var/obj/item/I in src.loc)
				if(I.density || I.anchored || I == src) continue
				I.loc = src

/obj/crate/secure/New()
	..()
	if(locked)
		overlays = null
		overlays += redlight
	else
		overlays = null
		overlays += greenlight

/obj/crate/rcd/New()
	..()
	new /obj/item/weapon/rcd_ammo(src)
	new /obj/item/weapon/rcd_ammo(src)
	new /obj/item/weapon/rcd_ammo(src)
	new /obj/item/weapon/rcd(src)

/obj/crate/radiation/New()
	..()
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/clothing/head/radiation(src)

/obj/crate/proc/open()
	playsound(src.loc, 'click.ogg', 15, 1, -3)

	for(var/obj/O in src)
		O.loc = get_turf(src)
	for(var/mob/M in src)
		M.loc = get_turf(src)

	icon_state = openicon
	src.opened = 1

/obj/crate/proc/close()
	playsound(src.loc, 'click.ogg', 15, 1, -3)
	for(var/obj/O in get_turf(src))
		if(O.density || O.anchored || O == src) continue
		O.loc = src
	icon_state = closedicon
	src.opened = 0

/obj/crate/attack_hand(mob/user as mob)
	if(!locked)
		if(opened) close()
		else open()
	else
		user << "\red It's locked."
	return

/obj/crate/secure/attack_hand(mob/user as mob)
	if(locked && allowed(user) && !broken)
		user << "\blue You unlock the [src]."
		src.locked = 0
		overlays = null
		overlays += greenlight
	return ..()

/obj/crate/secure/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/card) && src.allowed(user) && !locked && !opened && !broken)
		user << "\red You lock the [src]."
		src.locked = 1
		overlays = null
		overlays += redlight
		return
	else if (istype(W, /obj/item/weapon/card/emag) && locked &&!broken)
		overlays = null
		overlays += emag
		overlays += sparks
		spawn(6) overlays -= sparks //Tried lots of stuff but nothing works right. so i have to use this *sadface*
		playsound(src.loc, 'sparks4.ogg', 75, 1)
		src.locked = 0
		src.broken = 1
		user << "\blue You unlock the [src]."
		return

	return ..()

/obj/crate/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/crate/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/packageWrap))
		var/obj/item/weapon/packageWrap/O = W
		if (O.amount > 3)
			var/obj/bigDelivery/P = new /obj/bigDelivery(get_turf(src.loc))
			P.wrapped = src
			src.loc = P
			O.amount -= 3
	else if(opened)
		user.drop_item()
		if(W)
			W.loc = src.loc
	else return attack_hand(user)

/obj/crate/secure/emp_act(severity)
	for(var/obj/O in src)
		O.emp_act(severity)
	if(!broken && !opened  && prob(50/severity))
		if(!locked)
			src.locked = 1
			overlays = null
			overlays += redlight
		else
			overlays = null
			overlays += emag
			overlays += sparks
			spawn(6) overlays -= sparks //Tried lots of stuff but nothing works right. so i have to use this *sadface*
			playsound(src.loc, 'sparks4.ogg', 75, 1)
			src.locked = 0
	if(!opened && prob(20/severity))
		if(!locked)
			open()
		else
			src.req_access = list()
			src.req_access += pick(get_all_accesses())
	..()


/obj/crate/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/obj/O in src.contents)
				del(O)
			del(src)
			return
		if(2.0)
			for(var/obj/O in src.contents)
				if(prob(50))
					del(O)
			del(src)
			return
		if(3.0)
			if (prob(50))
				del(src)
			return
		else
	return
