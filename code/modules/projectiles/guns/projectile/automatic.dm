/obj/item/weapon/gun/projectile/automatic //Hopefully someone will find a way to make these fire in bursts or something. --Superxpdude
	name = "prototype SMG"
	desc = "A lightweight, prototype 9mm submachine gun, designated 'SABR'. Has a threaded barrel for suppressors."
	icon_state = "saber"
	w_class = 3
	origin_tech = "combat=4;materials=2"
	mag_type = /obj/item/ammo_box/magazine/smgm9mm
	var/alarmed = 0
	can_suppress = 1

/obj/item/weapon/gun/projectile/automatic/update_icon()
	..()
	icon_state = "[initial(icon_state)][magazine ? "-[magazine.max_ammo]" : ""][chambered ? "" : "-e"][suppressed ? "-suppressed" : ""]"
	return

/obj/item/weapon/gun/projectile/automatic/attackby(var/obj/item/A as obj, mob/user as mob)
	if(..() && chambered)
		alarmed = 0

/obj/item/weapon/gun/projectile/automatic/proc/empty_alarm()
	if(!chambered && !get_ammo() && !alarmed)
		playsound(src.loc, 'sound/weapons/smg_empty_alarm.ogg', 40, 1)
		update_icon()
		alarmed = 1
	return

/obj/item/weapon/gun/projectile/automatic/c20r
	name = "syndicate SMG"
	desc = "A lightweight, bullpup .45 SMG, designated 'C-20r'. Has a 'Scarborough Arms - Per falcis, per pravitas' buttstamp."
	icon_state = "c20r"
	item_state = "c20r"
	origin_tech = "combat=5;materials=2;syndicate=8"
	mag_type = /obj/item/ammo_box/magazine/smgm45
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'

/obj/item/weapon/gun/projectile/automatic/c20r/New()
	..()
	update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/c20r/afterattack()
	..()
	empty_alarm()
	return

/obj/item/weapon/gun/projectile/automatic/c20r/update_icon()
	..()
	icon_state = "c20r[magazine ? "-[Ceiling(get_ammo(0)/4)*4]" : ""][chambered ? "" : "-e"][suppressed ? "-suppressed" : ""]"
	return



/obj/item/weapon/gun/projectile/automatic/l6_saw
	name = "syndicate LMG"
	desc = "A heavily modified 7.62 light machine gun, designated 'L6 SAW'. Has 'Aussec Armoury - 2531' engraved on the reciever below the designation."
	icon_state = "l6closed100"
	item_state = "l6closedmag"
	w_class = 5
	slot_flags = 0
	origin_tech = "combat=5;materials=1;syndicate=2"
	mag_type = /obj/item/ammo_box/magazine/m762
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	var/cover_open = 0
	can_suppress = 0

/obj/item/weapon/gun/projectile/automatic/l6_saw/attack_self(mob/user as mob)
	cover_open = !cover_open
	user << "<span class='notice'>You [cover_open ? "open" : "close"] [src]'s cover.</span>"
	update_icon()


/obj/item/weapon/gun/projectile/automatic/l6_saw/update_icon()
	icon_state = "l6[cover_open ? "open" : "closed"][magazine ? Ceiling(get_ammo(0)/12.5)*25 : "-empty"]"


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
	if(!cover_open || (cover_open && !magazine))
		..()
	else if(cover_open && magazine)
		//drop the mag
		magazine.update_icon()
		magazine.loc = get_turf(src.loc)
		user.put_in_hands(magazine)
		magazine = null
		update_icon()
		user << "<span class='notice'>You remove the magazine from [src].</span>"


/obj/item/weapon/gun/projectile/automatic/l6_saw/attackby(var/obj/item/A as obj, mob/user as mob)
	if(!cover_open)
		user << "<span class='notice'>[src]'s cover is closed! You can't insert a new mag!</span>"
		return
	..()

/obj/item/weapon/gun/projectile/automatic/bulldog
	name = "syndicate shotgun"
	desc = "A compact, mag-fed semi-automatic shotgun for combat in narrow corridors, nicknamed 'Bulldog' by boarding parties. Compatible only with specialized 8-round drum magazines."
	icon_state = "bulldog"
	item_state = "bulldog"
	w_class = 3.0
	origin_tech = "combat=5;materials=4;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/m12g
	fire_sound = 'sound/weapons/Gunshot.ogg'
	can_suppress = 0

/obj/item/weapon/gun/projectile/automatic/bulldog/New()
	..()
	update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/bulldog/proc/update_magazine()
	if(magazine)
		src.overlays = 0
		overlays += "[magazine.icon_state]"
		return

/obj/item/weapon/gun/projectile/automatic/bulldog/update_icon()
	src.overlays = 0
	update_magazine()
	icon_state = "bulldog[chambered ? "" : "-e"]"
	return

/obj/item/weapon/gun/projectile/automatic/bulldog/afterattack()
	..()
	empty_alarm()
	return


/obj/item/weapon/gun/projectile/automatic/c90gl
	name = "syndicate assault rifle"
	desc = "A bullpup and compact 5.45x39 assault rifle with a unique toploading design, designated 'C-90gl'. Has an attached underbarrel grenade launcher which can be toggled on and off."
	icon_state = "c90gl"
	item_state = "c90gl"
	origin_tech = "combat=5;materials=2;syndicate=8"
	mag_type = /obj/item/ammo_box/magazine/m545
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	action_button_name = "Toggle Grenade Launcher"
	can_suppress = 0
	var/select = 1 //1 for boolets, 0 for explosions.
	var/obj/item/weapon/gun/projectile/revolver/grenadelauncher/underbarrel

/obj/item/weapon/gun/projectile/automatic/c90gl/New()
	..()
	underbarrel = new /obj/item/weapon/gun/projectile/revolver/grenadelauncher(src)
	update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/c90gl/afterattack(var/atom/target, var/mob/living/user, flag, params)
	if(select)
		..()
		empty_alarm()
		return
	else
		underbarrel.afterattack(target, user, flag, params)

/obj/item/weapon/gun/projectile/automatic/c90gl/attackby(var/obj/item/A, mob/user)
	if(select)
		..()
	else
		underbarrel.attackby(A, user)

/obj/item/weapon/gun/projectile/automatic/c90gl/attack_self(var/mob/living/user)
	if(select)
		..()
	else
		underbarrel.attack_self(user)



/obj/item/weapon/gun/projectile/automatic/c90gl/update_icon()
	..()
	overlays.Cut()
	if(select)
		overlays += "c90prim"
	else
		overlays += "c90gren"
	icon_state = "c90gl[magazine ? "-[Ceiling(get_ammo(0)/6)*6]" : ""][chambered ? "" : "-e"]"
	return

/obj/item/weapon/gun/projectile/automatic/c90gl/proc/underbarrel_swap()
	var/mob/living/carbon/human/user = usr
	if(select)
		select = 0
		user << "<span class='notice'>You switch to grenades.</span>"
	else
		select = 1
		user << "<span class='notice'>You switch to bullets.</span>"

	update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/c90gl/ui_action_click()
	underbarrel_swap()



/obj/item/weapon/gun/projectile/automatic/tommygun
	name = "tommy gun"
	desc = "A genuine 'Chicago Typewriter'."
	icon_state = "tommygun"
	item_state = "tommygun"
	slot_flags = 0
	origin_tech = "combat=5;materials=1;syndicate=2"
	mag_type = /obj/item/ammo_box/magazine/tommygunm45
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	can_suppress = 0
