/obj/item/weapon/gun/projectile/automatic //Hopefully someone will find a way to make these fire in bursts or something. --Superxpdude
	name = "submachine gun"
	desc = "A lightweight, fast firing gun. Uses 9mm rounds."
	icon_state = "saber"	//ugly
	w_class = 3.0
	max_shells = 18
	caliber = "9mm"
	origin_tech = "combat=4;materials=2"
	ammo_type = "/obj/item/ammo_casing/c9mm"
	automatic = 1
	fire_delay = 0
	var/unload_directly = 1

/obj/item/weapon/gun/projectile/automatic/isHandgun()
	return 0

/obj/item/weapon/gun/projectile/automatic/attack_self(mob/user as mob)
	if (unload_directly == 1 && loaded.len)
		empty_mag = new /obj/item/ammo_magazine/mc9mm(src)
		empty_mag.stored_ammo = loaded
		empty_mag.icon_state = "9x19p"
		empty_mag.desc = "There are [loaded.len] bullets left!"
		empty_mag.loc = get_turf(src.loc)
		user.put_in_hands(empty_mag)
		empty_mag = null
		loaded = list()
		update_icon()
		user << "<span class='notice'>You remove the magazine from [src].</span>"

/obj/item/weapon/gun/projectile/automatic/attackby(obj/item/ammo_magazine/mc9mm/A as obj, mob/user as mob)
	if(loaded.len)
		user << "<span class='notice'>[src] already has a magazine inserted!</span>"
		return
	else
		user << "<span class='notice'>You insert the magazine!</span>"
		empty_mag = new /obj/item/ammo_magazine/a12mm(src)
		empty_mag.stored_ammo = A.stored_ammo
		empty_mag.icon_state = "12mm"
		empty_mag.desc = "There are [loaded.len] bullets left!"
		loaded = A.stored_ammo
		update_icon()
		del(A)
		return

/obj/item/weapon/gun/projectile/automatic/mini_uzi
	name = "Uzi"
	desc = "A lightweight, fast firing gun, for when you want someone dead. Uses .45 rounds."
	icon_state = "mini-uzi"
	w_class = 3.0
	max_shells = 16
	caliber = ".45"
	origin_tech = "combat=5;materials=2;syndicate=8"
	ammo_type = "/obj/item/ammo_casing/c45"

/obj/item/weapon/gun/projectile/automatic/mini_uzi/attack_self(mob/user as mob)
	if (unload_directly == 1 && loaded.len)
		empty_mag = new /obj/item/ammo_magazine/mc9mm(src)
		empty_mag.stored_ammo = loaded
		empty_mag.icon_state = "9x19p"
		empty_mag.desc = "There are [loaded.len] bullets left!"
		empty_mag.loc = get_turf(src.loc)
		user.put_in_hands(empty_mag)
		empty_mag = null
		loaded = list()
		update_icon()
		user << "<span class='notice'>You remove the magazine from [src].</span>"

/obj/item/weapon/gun/projectile/automatic/mini_uzi/attackby(obj/item/ammo_magazine/mc9mm/A as obj, mob/user as mob)
	if(loaded.len)
		user << "<span class='notice'>[src] already has a magazine inserted!</span>"
		return
	else
		user << "<span class='notice'>You insert the magazine!</span>"
		empty_mag = new /obj/item/ammo_magazine/a12mm(src)
		empty_mag.stored_ammo = A.stored_ammo
		empty_mag.icon_state = "12mm"
		empty_mag.desc = "There are [loaded.len] bullets left!"
		loaded = A.stored_ammo
		update_icon()
		del(A)
		return

/obj/item/weapon/gun/projectile/automatic/mini_uzi/isHandgun()
	return 1


/obj/item/weapon/gun/projectile/automatic/c20r
	name = "\improper C-20r SMG"
	desc = "A lightweight, fast firing gun, for when you REALLY need someone dead. Uses 12mm rounds. Has a 'Scarborough Arms - Per falcis, per pravitas' buttstamp"
	icon_state = "c20r"
	item_state = "c20r"
	w_class = 3.0
	max_shells = 20
	caliber = "12mm"
	origin_tech = "combat=5;materials=2;syndicate=8"
	ammo_type = "/obj/item/ammo_casing/a12mm"
	fire_sound = 'sound/weapons/Gunshot_c20.ogg'
	load_method = 2

/obj/item/weapon/gun/projectile/automatic/c20r/attack_self(mob/user as mob)
	if (unload_directly == 1 && loaded.len)
		empty_mag = new /obj/item/ammo_magazine/a12mm(src)
		empty_mag.stored_ammo = loaded
		empty_mag.icon_state = "12mm"
		empty_mag.desc = "There are [loaded.len] bullets left!"
		empty_mag.loc = get_turf(src.loc)
		user.put_in_hands(empty_mag)
		empty_mag = null
		loaded = list()
		update_icon()
		user << "<span class='notice'>You remove the magazine from [src].</span>"

/obj/item/weapon/gun/projectile/automatic/c20r/attackby(obj/item/ammo_magazine/a12mm/A as obj, mob/user as mob)
	if(loaded.len)
		user << "<span class='notice'>[src] already has a magazine inserted!</span>"
		return
	else
		user << "<span class='notice'>You insert the magazine!</span>"
		empty_mag = new /obj/item/ammo_magazine/a12mm(src)
		empty_mag.stored_ammo = A.stored_ammo
		empty_mag.icon_state = "12mm"
		empty_mag.desc = "There are [loaded.len] bullets left!"
		loaded = A.stored_ammo
		update_icon()
		del(A)
		return

/obj/item/weapon/gun/projectile/automatic/c20r/New()
		..()
		empty_mag = new /obj/item/ammo_magazine/a12mm/empty(src)
		update_icon()
		return


/obj/item/weapon/gun/projectile/automatic/c20r/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
	..()
	if(!loaded.len && empty_mag)
		empty_mag.loc = get_turf(src.loc)
		empty_mag = null
		playsound(user, 'sound/weapons/smg_empty_alarm.ogg', 40, 1)
		update_icon()
	return


/obj/item/weapon/gun/projectile/automatic/c20r/update_icon()
	..()
	if(empty_mag)
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
	caliber = "12mm"
	ammo_type = "/obj/item/ammo_casing/a12mm"
	fire_sound = 'sound/weapons/Gunshot_c20.ogg'
	load_method = 2

/obj/item/weapon/gun/projectile/automatic/xcom/attack_self(mob/user as mob)
	if (unload_directly == 1 && loaded.len)
		empty_mag = new /obj/item/ammo_magazine/a12mm(src)
		empty_mag.stored_ammo = loaded
		empty_mag.icon_state = "12mm"
		empty_mag.desc = "There are [loaded.len] bullets left!"
		empty_mag.loc = get_turf(src.loc)
		user.put_in_hands(empty_mag)
		empty_mag = null
		loaded = list()
		update_icon()
		user << "<span class='notice'>You remove the magazine from [src].</span>"

/obj/item/weapon/gun/projectile/automatic/xcom/attackby(obj/item/ammo_magazine/a12mm/A as obj, mob/user as mob)
	if(loaded.len)
		user << "<span class='notice'>[src] already has a magazine inserted!</span>"
		return
	else
		user << "<span class='notice'>You insert the magazine!</span>"
		empty_mag = new /obj/item/ammo_magazine/a12mm(src)
		empty_mag.stored_ammo = A.stored_ammo
		empty_mag.icon_state = "12mm"
		empty_mag.desc = "There are [loaded.len] bullets left!"
		loaded = A.stored_ammo
		update_icon()
		del(A)
		return

/obj/item/weapon/gun/projectile/automatic/xcom/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
	..()
	if(!loaded.len && empty_mag)
		empty_mag.loc = get_turf(src.loc)
		empty_mag = null
		playsound(user, 'sound/weapons/smg_empty_alarm.ogg', 40, 1)
		update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/l6_saw
	name = "\improper L6 SAW"
	desc = "A rather traditionally made light machine gun with a pleasantly lacquered wooden pistol grip. Has 'Aussec Armoury- 2531' engraved on the reciever"
	icon_state = "l6closed100"
	item_state = "l6closedmag"
	w_class = 4
	slot_flags = 0
	max_shells = 50
	caliber = "a762"
	origin_tech = "combat=5;materials=1;syndicate=2"
	ammo_type = "/obj/item/ammo_casing/a762"
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	load_method = 2
	var/cover_open = 0
	unload_directly = 0
	var/mag_inserted = 1


/obj/item/weapon/gun/projectile/automatic/l6_saw/attack_self(mob/user as mob)
	cover_open = !cover_open
	user << "<span class='notice'>You [cover_open ? "open" : "close"] [src]'s cover.</span>"
	update_icon()


/obj/item/weapon/gun/projectile/automatic/l6_saw/update_icon()
	icon_state = "l6[cover_open ? "open" : "closed"][mag_inserted ? round(loaded.len, 25) : "-empty"]"


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
	if(!cover_open || (cover_open && !mag_inserted))
		..()
	else if(cover_open && mag_inserted)
		//drop the mag
		empty_mag = new /obj/item/ammo_magazine/a762(src)
		empty_mag.stored_ammo = loaded
		empty_mag.icon_state = "a762-[round(loaded.len, 10)]"
		empty_mag.desc = "There are [loaded.len] shells left!"
		empty_mag.loc = get_turf(src.loc)
		user.put_in_hands(empty_mag)
		empty_mag = null
		loaded = list()
		update_icon()
		mag_inserted = 0
		user << "<span class='notice'>You remove the magazine from [src].</span>"


/obj/item/weapon/gun/projectile/automatic/l6_saw/attackby(obj/item/ammo_magazine/a762/A as obj, mob/user as mob)
	if(!cover_open)
		user << "<span class='notice'>[src]'s cover is closed! You can't insert a new mag!</span>"
		return
	else if(cover_open && loaded.len)
		user << "<span class='notice'>[src] already has a magazine inserted!</span>"
		return
	else if(cover_open && !loaded.len)
		user << "<span class='notice'>You insert the magazine!</span>"
		empty_mag = new /obj/item/ammo_magazine/a12mm(src)
		empty_mag.stored_ammo = A.stored_ammo
		empty_mag.icon_state = "12mm"
		empty_mag.desc = "There are [loaded.len] bullets left!"
		loaded = A.stored_ammo
		update_icon()
		del(A)
		return


/* The thing I found with guns in ss13 is that they don't seem to simulate the rounds in the magazine in the gun.
   Afaik, since projectile.dm features a revolver, this would make sense since the magazine is part of the gun.
   However, it looks like subsequent guns that use removable magazines don't take that into account and just get
   around simulating a removable magazine by adding the casings into the loaded list and spawning an empty magazine
   when the gun is out of rounds. Which means you can't eject magazines with rounds in them. The below is a very
   rough and poor attempt at making that happen. -Ausops */