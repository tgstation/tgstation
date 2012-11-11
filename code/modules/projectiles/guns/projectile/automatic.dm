/obj/item/weapon/gun/projectile/automatic //Hopefully someone will find a way to make these fire in bursts or something. --Superxpdude
	name = "Submachine Gun"
	desc = "A lightweight, fast firing gun. Uses 9mm rounds."
	icon_state = "saber"
	w_class = 3.0
	max_shells = 18
	caliber = "9mm"
	origin_tech = "combat=4;materials=2"
	ammo_type = "/obj/item/ammo_casing/c9mm"



/obj/item/weapon/gun/projectile/automatic/mini_uzi
	name = "Mini-Uzi"
	desc = "A lightweight, fast firing gun, for when you want someone dead. Uses .45 rounds."
	icon_state = "mini-uzi"
	w_class = 3.0
	max_shells = 20
	caliber = ".45"
	origin_tech = "combat=5;materials=2;syndicate=8"
	ammo_type = "/obj/item/ammo_casing/c45"



/obj/item/weapon/gun/projectile/automatic/c20r
	name = "C-20r SMG"
	desc = "A lightweight, fast firing gun, for when you REALLY need someone dead. Uses 12mm rounds. Has a 'Scarborough Arms - Per falcis, per pravitas' buttstamp"
	icon_state = "c20r"
	item_state = "c20r"
	w_class = 3.0
	max_shells = 20
	caliber = "12mm"
	origin_tech = "combat=5;materials=2;syndicate=8"
	ammo_type = "/obj/item/ammo_casing/a12mm"
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	load_method = 2


	New()
		..()
		empty_mag = new /obj/item/ammo_magazine/a12mm/empty(src)
		update_icon()
		return


	afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
		..()
		if(!loaded.len && empty_mag)
			empty_mag.loc = get_turf(src.loc)
			empty_mag = null
			playsound(user, 'sound/weapons/smg_empty_alarm.ogg', 40, 1)
			update_icon()
		return


	update_icon()
		..()
		overlays = null
		if(empty_mag)
			overlays += "c20r-[round(loaded.len,4)]"
		return






/obj/item/weapon/gun/projectile/automatic/l6_saw
	name = "L6 SAW"
	w_class = 4
	desc = "A rather traditionally made light machine gun with a pleasantly lacquered wooden pistol grip. Has 'Aussec Armoury- 2531' engraved on the reciever"
	icon_state = "l4closed100"
	item_state = "l6closedmag"
	max_shells = 50
	caliber = "a762"
	origin_tech = "combat=5;materials=1;syndicate=2"
	ammo_type = "/obj/item/ammo_casing/a762"
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	load_method = 2
	//recoil = 1
	var/cover_open = 0
	var/mag_inserted = 1

	attack_self(mob/user as mob)
		if(!cover_open && mag_inserted)
			cover_open = 1
			icon_state = "l4open[round(((loaded.len)*2),25)]"
			item_state = "l6openmag"
			usr << "You open the [src]'s cover, allowing you to swap magazines."
		else if(cover_open && mag_inserted)
			cover_open = 0
			icon_state = "l4closed[round(((loaded.len)*2),25)]"
			item_state = "l6closedmag"
			usr << "You close the [src]'s cover."
		else if(!cover_open && !mag_inserted)
			cover_open = 1
			icon_state = "l4opennomag"
			item_state = "l6opennomag"
			usr << "You open the [src]'s cover, allowing you to swap magazines."
		else if(cover_open && !mag_inserted)
			cover_open = 0
			icon_state = "l4closednomag"
			item_state = "l6closednomag"
			usr << "You close the [src]'s cover."
			update_icon() //another update_icon() thing here, I know it's repeated in afterattack() but this one also takes into account cover_open
		if(!cover_open)
			icon_state = "l4closed[round(((loaded.len)*2),25)]"
			item_state = "l6closedmag"
		else
			icon_state = "l4open[round(((loaded.len)*2),25)]"
			item_state = "l6openmag"
		//update_inv_l_hand()
		//update_inv_r_hand()

	afterattack(atom/target as mob|obj|turf, mob/living/user as mob|obj, flag, params) //what I tried to do here is just add a check to see if the cover is open or not and add an icon_state change because I can't figure out how c-20rs do it with overlays
		if(cover_open)
			usr << "The SAW cover is open! Close it before firing!"
		else
			..()
			if(!cover_open && mag_inserted)
				icon_state = "l4closed[round(((loaded.len)*2),25)]"
				item_state = "l6closedmag"
			else if(!cover_open && !mag_inserted)
				icon_state = "l4closednomag"
				item_state = "l6nomag"
		//update_inv_l_hand()
		//update_inv_r_hand()

	/obj/item/weapon/gun/projectile/automatic/l6_saw/verb/remove_magazine()
		set category = "Object"
		set name = "Remove SAW magazine."
		set src in view(1)
		var/mob/M = usr

		if(usr.canmove && !usr.stat && !usr.restrained() && !M.paralysis && ! M.stunned)
			if(!cover_open)
				usr << "The [src]'s cover is closed! You can't remove the magazine!"
			else if (!cover_open && !mag_inserted)
				usr << "The [src]'s cover is open but there's no magazine for you to remove!"
			else if (cover_open && mag_inserted)
				drop_mag()
				loaded = list()
				mag_inserted = 0
				icon_state = "l4opennomag"
				item_state = "l6opennomag"
				usr << "You remove the magazine from the [src]!"
		//update_inv_l_hand()
		//update_inv_r_hand()

	/obj/item/weapon/gun/projectile/automatic/l6_saw/proc/drop_mag()
		empty_mag = new /obj/item/ammo_magazine/a762(src)
		empty_mag.stored_ammo = loaded
		empty_mag.icon_state = "a762-[round((loaded.len),10)]"
		//desc = "There are [loaded] shells left!"
		empty_mag.loc = get_turf(src.loc)
		empty_mag = null


	/obj/item/weapon/gun/projectile/automatic/l6_saw/attackby(var/obj/item/A as obj, mob/user as mob)
		if(!cover_open)
			usr << "The [src]'s cover is closed! You can't insert a new mag!"
		else if (cover_open && mag_inserted)
			usr << "The [src] already has a magazine inserted!"
		else if (cover_open && !mag_inserted)
			mag_inserted = 1
			usr << "You insert the magazine!"
			icon_state = "l4openmag[round(((loaded.len)*2),25)]"
			item_state = "l6openmag"
			update_icon()
			..()
		//update_inv_l_hand() something pete suggested. Dunno if this is a proc already defined way up in the obj/ thing
		//update_inv_r_hand() or if it's something I have to define myself


/* The thing I found with guns in ss13 is that they don't seem to simulate the rounds in the magazine in the gun.
   Afaik, since projectile.dm features a revolver, this would make sense since the magazine is part of the gun.
   However, it looks like subsequent guns that use removable magazines don't take that into account and just get
   around simulating a removable magazine by adding the casings into the loaded list and spawning an empty magazine
   when the gun is out of rounds. Which means you can't eject magazines with rounds in them. The below is a very
   rough and poor attempt at making that happen. -Ausops */

