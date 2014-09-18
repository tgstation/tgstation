/obj/item/weapon/gun/projectile/automatic //Hopefully someone will find a way to make these fire in bursts or something. --Superxpdude
	name = "submachine gun"
	desc = "A lightweight, fast firing gun. Uses 9mm rounds."
	icon_state = "saber"	//ugly
	w_class = 3.0
	max_shells = 18
	caliber = list("9mm" = 1)
	origin_tech = "combat=4;materials=2"
	ammo_type = /obj/item/ammo_casing/c9mm
	automatic = 1
	fire_delay = 0
	var/burstfire = 0 //Whether or not the gun fires multiple bullets at once
	var/burst_count = 3
	load_method = 2
	mag_type = /obj/item/ammo_storage/magazine/smg9mm

/obj/item/weapon/gun/projectile/automatic/New()
	..()
	stored_magazine = new mag_type(src)
	loaded = stored_magazine.stored_ammo
	update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/isHandgun()
	return 0

/obj/item/weapon/gun/projectile/automatic/verb/ToggleFire()
	set name = "Toggle Burstfire"
	set category = "Object"
	burstfire = !burstfire
	usr << "You toggle \the [src]'s firing setting to [burstfire ? "burst fire" : "single fire"]."

/obj/item/weapon/gun/projectile/automatic/Fire()
	if(burstfire == 1)
		if(ready_to_fire())
			fire_delay = 0
		else
			usr << "<span class='warning'>\The [src] is still cooling down!</span>"
			return
		var/shots_fired = 0 //haha, I'm so clever
		var/to_shoot = min(burst_count, loaded.len)
		for(var/i = 1; i <= to_shoot; i++)
			..()
			shots_fired++
		message_admins("[usr] just shot [shots_fired] burst fire bullets out of [loaded.len + shots_fired] from their [src].")
		fire_delay = shots_fired * 10
	else
		..()

/obj/item/weapon/gun/projectile/automatic/mini_uzi
	name = "Uzi"
	desc = "A lightweight, fast firing gun, for when you want someone dead. Uses .45 rounds."
	icon_state = "mini-uzi"
	w_class = 3.0
	max_shells = 10
	burst_count = 3
	caliber = list(".45" = 1)
	origin_tech = "combat=5;materials=2;syndicate=8"
	ammo_type = /obj/item/ammo_casing/c45
	mag_type = /obj/item/ammo_storage/magazine/uzi45

/obj/item/weapon/gun/projectile/automatic/mini_uzi/isHandgun()
	return 1

/obj/item/weapon/gun/projectile/automatic/c20r
	name = "\improper C-20r SMG"
	desc = "A lightweight, fast firing gun, for when you REALLY need someone dead. Uses 12mm rounds. Has a 'Scarborough Arms - Per falcis, per pravitas' buttstamp"
	icon_state = "c20r"
	item_state = "c20r"
	w_class = 3.0
	max_shells = 20
	burst_count = 4
	caliber = list("12mm" = 1)
	origin_tech = "combat=5;materials=2;syndicate=8"
	ammo_type = /obj/item/ammo_casing/a12mm
	mag_type = /obj/item/ammo_storage/magazine/a12mm
	fire_sound = 'sound/weapons/Gunshot_c20.ogg'
	load_method = 2
	auto_mag_drop = 1

/obj/item/weapon/gun/projectile/automatic/c20r/update_icon()
	..()
	if(stored_magazine)
		icon_state = "c20r-[round(loaded.len,4)]"
	else
		icon_state = "c20r"
	return

/obj/item/weapon/gun/projectile/automatic/xcom
	name = "\improper Assault Rifle"
	desc = "A lightweight, fast firing gun, issued to shadow organization members."
	icon_state = "xcomassaultrifle"
	origin_tech = "combat=5;materials=2"
	item_state = "c20r"
	w_class = 3.0
	max_shells = 20
	burst_count = 4
	caliber = list("12mm" = 1)
	ammo_type = /obj/item/ammo_casing/a12mm
	mag_type = /obj/item/ammo_storage/magazine/a12mm
	fire_sound = 'sound/weapons/Gunshot_c20.ogg'
	load_method = 2
	auto_mag_drop = 1

/obj/item/weapon/gun/projectile/automatic/l6_saw
	name = "\improper L6 SAW"
	desc = "A rather traditionally made light machine gun with a pleasantly lacquered wooden pistol grip. Has 'Aussec Armoury- 2531' engraved on the reciever"
	icon_state = "l6closed100"
	item_state = "l6closedmag"
	w_class = 4
	slot_flags = 0
	max_shells = 50
	burst_count = 5
	caliber = list("a762" = 1)
	origin_tech = "combat=5;materials=1;syndicate=2"
	ammo_type = /obj/item/ammo_casing/a762
	mag_type = /obj/item/ammo_storage/magazine/a762
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	load_method = 2
	var/cover_open = 0


/obj/item/weapon/gun/projectile/automatic/l6_saw/attack_self(mob/user as mob)
	cover_open = !cover_open
	user << "<span class='notice'>You [cover_open ? "open" : "close"] [src]'s cover.</span>"
	update_icon()


/obj/item/weapon/gun/projectile/automatic/l6_saw/update_icon()
	icon_state = "l6[cover_open ? "open" : "closed"][stored_magazine ? round(loaded.len, 25) : "-empty"]"


/obj/item/weapon/gun/projectile/automatic/l6_saw/afterattack(atom/target as mob|obj|turf, mob/living/user as mob|obj, flag, params) //what I tried to do here is just add a check to see if the cover is open or not and add an icon_state change because I can't figure out how c-20rs do it with overlays
	if(cover_open)
		user << "<span class='notice'>[src]'s cover is open! Close it before firing!</span>"
	else
		..()
		update_icon()


/obj/item/weapon/gun/projectile/automatic/l6_saw/attack_hand(mob/user as mob)
	if(loc != user)
		..()
		return	//let them pick it up
	if(!cover_open)
		..()
	else if(cover_open && stored_magazine) //since attack_self toggles the cover and not the magazine, we use this instead
		//drop the mag
		RemoveMag(user)
		user << "<span class='notice'>You remove the magazine from [src].</span>"


/obj/item/weapon/gun/projectile/automatic/l6_saw/attackby(obj/item/ammo_storage/magazine/a762/A as obj, mob/user as mob)
	if(!cover_open)
		user << "<span class='notice'>[src]'s cover is closed! You can't insert a new mag!</span>"
		return
	else if(cover_open)
		..()

/obj/item/weapon/gun/projectile/automatic/l6_saw/force_removeMag() //special because of its cover
	if(cover_open && stored_magazine)
		RemoveMag(usr)
		usr << "<span class='notice'>You remove the magazine from [src].</span>"
	else if(stored_magazine)
		usr << "<span class='rose'>The [src]'s cover has to be open to do that!</span>"
	else
		usr << "<span class='rose'>There is no magazine to remove!</span>"


/* The thing I found with guns in ss13 is that they don't seem to simulate the rounds in the magazine in the gun.
   Afaik, since projectile.dm features a revolver, this would make sense since the magazine is part of the gun.
   However, it looks like subsequent guns that use removable magazines don't take that into account and just get
   around simulating a removable magazine by adding the casings into the loaded list and spawning an empty magazine
   when the gun is out of rounds. Which means you can't eject magazines with rounds in them. The below is a very
   rough and poor attempt at making that happen. -Ausops */

/* Guns now properly store and move magazines and bullets about. Moving bullets from loaded to the magazine and back again on actions
   still feels poorly coded and hacky, but it's more trouble than this to attempt to modify gun code any further. Perhaps a braver
   soul than I might feel that some injustice was done in quitting most of the way there, but I think this is modular enough. */