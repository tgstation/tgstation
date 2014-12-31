/obj/item/weapon/gun/projectile/automatic
	name = "prototype SMG"
	desc = "A prototype three-round burst 9mm submachine gun, designated 'SABR'. Has a threaded barrel for suppressors."
	icon_state = "saber"
	w_class = 3
	origin_tech = "combat=4;materials=2"
	mag_type = /obj/item/ammo_box/magazine/smgm9mm
	var/alarmed = 0
	can_suppress = 1
	burst_size = 3
	fire_delay = 1
	var/select = 0
	action_button_name = "Toggle Fire Mode"

/obj/item/weapon/gun/projectile/automatic/update_icon()
	..()
	overlays.Cut()
	if(!select)
		overlays += "[initial(icon_state)]semi"
	if(select == 1)
		overlays += "[initial(icon_state)]burst"
	icon_state = "[initial(icon_state)][magazine ? "-[magazine.max_ammo]" : ""][chambered ? "" : "-e"][suppressed ? "-suppressed" : ""]"
	return

/obj/item/weapon/gun/projectile/automatic/attackby(var/obj/item/A as obj, mob/user as mob)
	if(..() && chambered)
		alarmed = 0

/obj/item/weapon/gun/projectile/automatic/ui_action_click()
	burst_select()

/obj/item/weapon/gun/projectile/automatic/verb/burst_select()
	set name = "Toggle Fire Mode"
	set category = "Object"
	set desc = "Click to switch fire modes."
	var/mob/living/carbon/human/user = usr
	if(select)
		select = 0
		burst_size = 1
		fire_delay = 0
		user << "<span class='notice'>You switch to semi-automatic.</span>"
	else
		select = 1
		burst_size = initial(burst_size)
		fire_delay = initial(fire_delay)
		user << "<span class='notice'>You switch to [burst_size]-rnd burst.</span>"

	update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/can_shoot()
	return get_ammo()

/obj/item/weapon/gun/projectile/automatic/proc/empty_alarm()
	if(!chambered && !get_ammo() && !alarmed)
		playsound(src.loc, 'sound/weapons/smg_empty_alarm.ogg', 40, 1)
		update_icon()
		alarmed = 1
	return

/obj/item/weapon/gun/projectile/automatic/c20r
	name = "syndicate SMG"
	desc = "A bullpup two-round burst .45 SMG, designated 'C-20r'. Has a 'Scarborough Arms - Per falcis, per pravitas' buttstamp."
	icon_state = "c20r"
	item_state = "c20r"
	origin_tech = "combat=5;materials=2;syndicate=8"
	mag_type = /obj/item/ammo_box/magazine/smgm45
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	fire_delay = 2
	burst_size = 2

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
	burst_size = 1
	fire_delay = 0

/obj/item/weapon/gun/projectile/automatic/l6_saw/burst_select()
	return


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

/obj/item/weapon/gun/projectile/automatic/c90gl
	name = "syndicate assault rifle"
	desc = "A bullpup three-round burst 5.45x39 assault rifle with a unique toploading design, designated 'C-90gl'. Has an attached underbarrel grenade launcher which can be toggled on and off."
	icon_state = "c90gl"
	item_state = "c90gl"
	origin_tech = "combat=5;materials=2;syndicate=8"
	mag_type = /obj/item/ammo_box/magazine/m545
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	action_button_name = "Toggle Grenade Launcher"
	can_suppress = 0
	var/obj/item/weapon/gun/projectile/revolver/grenadelauncher/underbarrel
	burst_size = 3
	fire_delay = 2

/obj/item/weapon/gun/projectile/automatic/c90gl/New()
	..()
	underbarrel = new /obj/item/weapon/gun/projectile/revolver/grenadelauncher(src)
	update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/c90gl/afterattack(var/atom/target, var/mob/living/user, flag, params)
	if(select == 2)
		underbarrel.afterattack(target, user, flag, params)
	else
		..()
		empty_alarm()
		return
/obj/item/weapon/gun/projectile/automatic/c90gl/attackby(var/obj/item/A, mob/user)
	if(select == 2)
		underbarrel.attackby(A, user)
	else
		..()
/obj/item/weapon/gun/projectile/automatic/c90gl/attack_self(var/mob/living/user)
	if(select == 2)
		underbarrel.attack_self(user)
	else
		..()

/obj/item/weapon/gun/projectile/automatic/c90gl/update_icon()
	..()
	overlays.Cut()
	if(!select)
		overlays += "[initial(icon_state)]semi"
	if(select == 1)
		overlays += "[initial(icon_state)]burst"
	if(select == 2)
		overlays += "[initial(icon_state)]gren"
	icon_state = "c90gl[magazine ? "-[Ceiling(get_ammo(0)/6)*6]" : ""][chambered ? "" : "-e"]"
	return

/obj/item/weapon/gun/projectile/automatic/c90gl/burst_select()
	var/mob/living/carbon/human/user = usr
	if(!select)
		select = 1
		burst_size = initial(burst_size)
		fire_delay = initial(fire_delay)
		user << "<span class='notice'>You switch to [burst_size]-rnd burst.</span>"
	if(select == 1)
		select = 2
		user << "<span class='notice'>You switch to grenades.</span>"
	if(select == 2)
		select = 0
		burst_size = 1
		fire_delay = 0
		user << "<span class='notice'>You switch to semi-auto.</span>"
	update_icon()
	return

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
	burst_size = 4