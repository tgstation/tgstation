#define SPEEDLOADER 0 //the gun takes bullets directly
#define FROM_BOX 1
#define MAGAZINE 2 //the gun takes a magazine into gun storage

/obj/item/weapon/gun/projectile
	desc = "A classic revolver. Uses 357 ammo"
	name = "revolver"
	icon_state = "revolver"
	caliber = list("357" = 1)
	origin_tech = "combat=2;materials=2"
	w_class = 3.0
	m_amt = 1000
	w_type = RECYK_METAL
	recoil = 1
	var/ammo_type = "/obj/item/ammo_casing/a357"
	var/list/loaded = list()
	var/max_shells = 7 //only used by guns with no magazine
	var/load_method = SPEEDLOADER //0 = Single shells or quick loader, 1 = box, 2 = magazine
	var/obj/item/ammo_storage/magazine/stored_magazine = null
	var/obj/item/ammo_casing/chambered = null
	var/mag_type = ""

	var/gun_flags = EMPTYCASINGS	//Yay, flags

/obj/item/weapon/gun/projectile/New()
	..()
	if(mag_type && load_method == 2)
		stored_magazine = new mag_type(src)
		chamber_round()
	else
		for(var/i = 1, i <= max_shells, i++)
			loaded += new ammo_type(src)
	update_icon()
	return

//loads the argument magazine into the gun
/obj/item/weapon/gun/projectile/proc/LoadMag(var/obj/item/ammo_storage/magazine/AM, var/mob/user)
	if(istype(AM, text2path(mag_type)) && !stored_magazine)
		if(user)
			user.drop_item(AM)
			usr << "<span class='notice'>You load the magazine into \the [src].</span>"
		AM.loc = src
		stored_magazine = AM
		chamber_round()
		AM.update_icon()
		update_icon()
		return 1
	return 0

/obj/item/weapon/gun/projectile/proc/RemoveMag(var/mob/user)
	if(stored_magazine)
		stored_magazine.loc = get_turf(src.loc)
		if(user)
			user.put_in_hands(stored_magazine)
			usr << "<span class='notice'>You pull the magazine out of \the [src]!</span>"
		stored_magazine.update_icon()
		stored_magazine = null
		update_icon()
		return 1
	return 0

/obj/item/weapon/gun/projectile/verb/force_removeMag()
	set name = "Remove Magazine"
	set category = "Object"
	set src in range(0)
	if(stored_magazine)
		RemoveMag()
	else
		usr << "<span class='rose'>There is no magazine to remove!</span>"


/obj/item/weapon/gun/projectile/proc/chamber_round() //Only used by guns with magazine
	if(chambered || !stored_magazine)
		return 0
	else
		var/obj/item/ammo_casing/round = stored_magazine.get_round()
		if(istype(round))
			chambered = round
			chambered.loc = src
			return 1
	return 0

/obj/item/weapon/gun/projectile/proc/getAC()
	var/obj/item/ammo_casing/AC = null
	if(mag_type && load_method == 2)
		AC = chambered
	else if(getAmmo())
		AC = loaded[1] //load next casing.
	return AC

/obj/item/weapon/gun/projectile/process_chambered()
	var/obj/item/ammo_casing/AC = getAC()
	if(in_chamber)
		return 1 //{R}
	if(isnull(AC) || !istype(AC))
		return
	if(mag_type && load_method == 2)
		chambered = null //Remove casing from chamber.
		chamber_round()
	else
		loaded -= AC //Remove casing from loaded list.
	if(gun_flags &EMPTYCASINGS)
		AC.loc = get_turf(src) //Eject casing onto ground.
	if(AC.BB)
		in_chamber = AC.BB //Load projectile into chamber.
		AC.BB.loc = src //Set projectile loc to gun.
		AC.BB = null //Empty casings
		AC.update_icon()
		return 1
	return 0

/obj/item/weapon/gun/projectile/attackby(var/obj/item/A as obj, mob/user as mob)

	if(istype(A, /obj/item/gun_part/silencer) && src.gun_flags &SILENCECOMP)
		if(user.l_hand != src && user.r_hand != src)	//if we're not in his hands
			user << "<span class='notice'>You'll need [src] in your hands to do that.</span>"
			return
		user.drop_item()
		user << "<span class='notice'>You screw [A] onto [src].</span>"
		silenced = A	//dodgy?
		w_class = 3
		A.loc = src		//put the silencer into the gun
		update_icon()
		return 1

	var/num_loaded = 0
	if(istype(A, /obj/item/ammo_storage/magazine))
		var/obj/item/ammo_storage/magazine/AM = A
		if(load_method == MAGAZINE)
			if(!stored_magazine)
				LoadMag(AM, user)
			else
				user << "<span class='rose'>There is already a magazine loaded in \the [src]!</span>"
		else
			user << "<span class='rose'>You can't load \the [src] with a magazine, dummy!</span>"
	if(istype(A, /obj/item/ammo_storage) && load_method != MAGAZINE)
		var/obj/item/ammo_storage/AS = A
		var/success_load = AS.LoadInto(AS, src)
		if(success_load)
			user << "<span class='notice'>You successfully fill the [src] with [success_load] shell\s from the [AS]</span>"
	if(istype(A, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/AC = A
		//message_admins("Loading the [src], with [AC], [AC.caliber] and [caliber.len]") //Enable this for testing
		if(AC.BB && caliber[AC.caliber]) // a used bullet can't be fired twice
			if(load_method == MAGAZINE && !chambered)
				user.drop_item()
				AC.loc = src
				chambered = AC
				num_loaded++
			else if(getAmmo() < max_shells)
				user.drop_item()
				AC.loc = src
				loaded += AC
				num_loaded++

	if(num_loaded)
		user << "\blue You load [num_loaded] shell\s into \the [src]!"
	A.update_icon()
	update_icon()
	return

/obj/item/weapon/gun/projectile/attack_self(mob/user as mob)
	if (target)
		return ..()
	if (loaded.len || stored_magazine)
		if (load_method == SPEEDLOADER)
			var/obj/item/ammo_casing/AC = loaded[1]
			loaded -= AC
			AC.loc = get_turf(src) //Eject casing onto ground.
			user << "\blue You unload \the [AC] from \the [src]!"
			update_icon()
			return
		if (load_method == MAGAZINE && stored_magazine)
			RemoveMag(user)
	else if(loc == user)
		if(chambered) // So it processing unloading of a bullet first
			var/obj/item/ammo_casing/AC = chambered
			AC.loc = get_turf(src) //Eject casing onto ground.
			chambered = null
			user << "\blue You unload \the [AC] from \the [src]!"
			update_icon()
			return
		if(silenced)
			if(user.l_hand != src && user.r_hand != src)
				..()
				return
			user << "<span class='notice'>You unscrew [silenced] from [src].</span>"
			user.put_in_hands(silenced)
			silenced = 0
			w_class = 2
			update_icon()
			return
	else
		user << "\red Nothing loaded in \the [src]!"

/obj/item/weapon/gun/projectile/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
	..()
	if(!chambered && stored_magazine && !stored_magazine.ammo_count() && gun_flags &AUTOMAGDROP) //auto_mag_drop decides whether or not the mag is dropped once it empties
		RemoveMag()
		playsound(user, 'sound/weapons/smg_empty_alarm.ogg', 40, 1)
	return

/obj/item/weapon/gun/projectile/examine(mob/user)
	..()
	usr << "Has [getAmmo()] round\s remaining."
//		if(in_chamber && !loaded.len)
//			usr << "However, it has a chambered round."
//		if(in_chamber && loaded.len)
//			usr << "It also has a chambered round." {R}
	if(istype(silenced, /obj/item/gun_part/silencer))
		usr <<"It has a supressor attached to the barrel."
	return

/obj/item/weapon/gun/projectile/proc/getAmmo()
	var/bullets = 0
	if(mag_type && load_method == 2)
		if(stored_magazine)
			bullets += stored_magazine.ammo_count()
		if(chambered)
			bullets++
	else
		for(var/obj/item/ammo_casing/AC in loaded)
			if(istype(AC))
				bullets += 1
	return bullets

