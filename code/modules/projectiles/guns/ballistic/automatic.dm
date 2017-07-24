/obj/item/weapon/gun/ballistic/automatic
	origin_tech = "combat=4;materials=2"
	w_class = WEIGHT_CLASS_NORMAL
	var/alarmed = 0
	var/select = 1
	can_suppress = 1
	burst_size = 3
	fire_delay = 2
	actions_types = list(/datum/action/item_action/toggle_firemode)

/obj/item/weapon/gun/ballistic/automatic/proto
	name = "\improper NanoTrasen Saber SMG"
	desc = "A prototype three-round burst 9mm submachine gun, designated 'SABR'. Has a threaded barrel for suppressors."
	icon_state = "saber"
	mag_type = /obj/item/ammo_box/magazine/smgm9mm
	pin = null

/obj/item/weapon/gun/ballistic/automatic/proto/unrestricted
	pin = /obj/item/device/firing_pin

/obj/item/weapon/gun/ballistic/automatic/update_icon()
	..()
	cut_overlays()
	if(!select)
		add_overlay("[initial(icon_state)]semi")
	if(select == 1)
		add_overlay("[initial(icon_state)]burst")
	icon_state = "[initial(icon_state)][magazine ? "-[magazine.max_ammo]" : ""][chambered ? "" : "-e"][suppressed ? "-suppressed" : ""]"

/obj/item/weapon/gun/ballistic/automatic/attackby(obj/item/A, mob/user, params)
	. = ..()
	if(.)
		return
	if(istype(A, /obj/item/ammo_box/magazine))
		var/obj/item/ammo_box/magazine/AM = A
		if(istype(AM, mag_type))
			var/obj/item/ammo_box/magazine/oldmag = magazine
			if(user.transferItemToLoc(AM, src))
				magazine = AM
				if(oldmag)
					to_chat(user, "<span class='notice'>You perform a tactical reload on \the [src], replacing the magazine.</span>")
					oldmag.dropped()
					oldmag.forceMove(get_turf(src.loc))
					oldmag.update_icon()
				else
					to_chat(user, "<span class='notice'>You insert the magazine into \the [src].</span>")

				playsound(user, 'sound/weapons/autoguninsert.ogg', 60, 1)
				chamber_round()
				A.update_icon()
				update_icon()
				return 1
			else
				to_chat(user, "<span class='warning'>You cannot seem to get \the [src] out of your hands!</span>")

/obj/item/weapon/gun/ballistic/automatic/ui_action_click()
	burst_select()

/obj/item/weapon/gun/ballistic/automatic/proc/burst_select()
	var/mob/living/carbon/human/user = usr
	select = !select
	if(!select)
		burst_size = 1
		fire_delay = 0
		to_chat(user, "<span class='notice'>You switch to semi-automatic.</span>")
	else
		burst_size = initial(burst_size)
		fire_delay = initial(fire_delay)
		to_chat(user, "<span class='notice'>You switch to [burst_size]-rnd burst.</span>")

	playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	update_icon()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/weapon/gun/ballistic/automatic/can_shoot()
	return get_ammo()

/obj/item/weapon/gun/ballistic/automatic/proc/empty_alarm()
	if(!chambered && !get_ammo() && !alarmed)
		playsound(src.loc, 'sound/weapons/smg_empty_alarm.ogg', 40, 1)
		update_icon()
		alarmed = 1
	return

/obj/item/weapon/gun/ballistic/automatic/c20r
	name = "\improper C-20r SMG"
	desc = "A bullpup two-round burst .45 SMG, designated 'C-20r'. Has a 'Scarborough Arms - Per falcis, per pravitas' buttstamp."
	icon_state = "c20r"
	item_state = "c20r"
	origin_tech = "combat=5;materials=2;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/smgm45
	fire_sound = 'sound/weapons/gunshot_smg.ogg'
	fire_delay = 2
	burst_size = 2
	pin = /obj/item/device/firing_pin/implant/pindicate

/obj/item/weapon/gun/ballistic/automatic/c20r/unrestricted
	pin = /obj/item/device/firing_pin

/obj/item/weapon/gun/ballistic/automatic/c20r/Initialize()
	. = ..()
	update_icon()

/obj/item/weapon/gun/ballistic/automatic/c20r/afterattack()
	..()
	empty_alarm()
	return

/obj/item/weapon/gun/ballistic/automatic/c20r/update_icon()
	..()
	icon_state = "c20r[magazine ? "-[Ceiling(get_ammo(0)/4)*4]" : ""][chambered ? "" : "-e"][suppressed ? "-suppressed" : ""]"

/obj/item/weapon/gun/ballistic/automatic/wt550
	name = "security auto rifle"
	desc = "An outdated personal defence weapon. Uses 4.6x30mm rounds and is designated the WT-550 Automatic Rifle."
	icon_state = "wt550"
	item_state = "arg"
	mag_type = /obj/item/ammo_box/magazine/wt550m9
	fire_delay = 2
	can_suppress = 0
	burst_size = 0
	actions_types = list()

/obj/item/weapon/gun/ballistic/automatic/wt550/update_icon()
	..()
	icon_state = "wt550[magazine ? "-[Ceiling(get_ammo(0)/4)*4]" : ""]"

/obj/item/weapon/gun/ballistic/automatic/mini_uzi
	name = "\improper Type U3 Uzi"
	desc = "A lightweight, burst-fire submachine gun, for when you really want someone dead. Uses 9mm rounds."
	icon_state = "mini-uzi"
	origin_tech = "combat=4;materials=2;syndicate=4"
	mag_type = /obj/item/ammo_box/magazine/uzim9mm
	burst_size = 2

/obj/item/weapon/gun/ballistic/automatic/m90
	name = "\improper M-90gl Carbine"
	desc = "A three-round burst 5.56 toploading carbine, designated 'M-90gl'. Has an attached underbarrel grenade launcher which can be toggled on and off."
	icon_state = "m90"
	item_state = "m90"
	origin_tech = "combat=5;materials=2;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/m556
	fire_sound = 'sound/weapons/gunshot_smg.ogg'
	can_suppress = 0
	var/obj/item/weapon/gun/ballistic/revolver/grenadelauncher/underbarrel
	burst_size = 3
	fire_delay = 2
	pin = /obj/item/device/firing_pin/implant/pindicate

/obj/item/weapon/gun/ballistic/automatic/m90/Initialize()
	. = ..()
	underbarrel = new /obj/item/weapon/gun/ballistic/revolver/grenadelauncher(src)
	update_icon()

/obj/item/weapon/gun/ballistic/automatic/m90/unrestricted
	pin = /obj/item/device/firing_pin

/obj/item/weapon/gun/ballistic/automatic/m90/unrestricted/Initialize()
	. = ..()
	underbarrel = new /obj/item/weapon/gun/ballistic/revolver/grenadelauncher/unrestricted(src)
	update_icon()

/obj/item/weapon/gun/ballistic/automatic/m90/afterattack(atom/target, mob/living/user, flag, params)
	if(select == 2)
		underbarrel.afterattack(target, user, flag, params)
	else
		..()
		return
/obj/item/weapon/gun/ballistic/automatic/m90/attackby(obj/item/A, mob/user, params)
	if(istype(A, /obj/item/ammo_casing))
		if(istype(A, underbarrel.magazine.ammo_type))
			underbarrel.attack_self()
			underbarrel.attackby(A, user, params)
	else
		..()
/obj/item/weapon/gun/ballistic/automatic/m90/update_icon()
	..()
	cut_overlays()
	switch(select)
		if(0)
			add_overlay("[initial(icon_state)]semi")
		if(1)
			add_overlay("[initial(icon_state)]burst")
		if(2)
			add_overlay("[initial(icon_state)]gren")
	icon_state = "[initial(icon_state)][magazine ? "" : "-e"]"
	return
/obj/item/weapon/gun/ballistic/automatic/m90/burst_select()
	var/mob/living/carbon/human/user = usr
	switch(select)
		if(0)
			select = 1
			burst_size = initial(burst_size)
			fire_delay = initial(fire_delay)
			to_chat(user, "<span class='notice'>You switch to [burst_size]-rnd burst.</span>")
		if(1)
			select = 2
			to_chat(user, "<span class='notice'>You switch to grenades.</span>")
		if(2)
			select = 0
			burst_size = 1
			fire_delay = 0
			to_chat(user, "<span class='notice'>You switch to semi-auto.</span>")
	playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	update_icon()
	return

/obj/item/weapon/gun/ballistic/automatic/tommygun
	name = "\improper Thompson SMG"
	desc = "Based on the classic 'Chicago Typewriter'."
	icon_state = "tommygun"
	item_state = "shotgun"
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = 0
	origin_tech = "combat=5;materials=1;syndicate=3"
	mag_type = /obj/item/ammo_box/magazine/tommygunm45
	fire_sound = 'sound/weapons/gunshot_smg.ogg'
	can_suppress = 0
	burst_size = 4
	fire_delay = 1

/obj/item/weapon/gun/ballistic/automatic/ar
	name = "\improper NT-ARG 'Boarder'"
	desc = "A robust assault rile used by Nanotrasen fighting forces."
	icon_state = "arg"
	item_state = "arg"
	slot_flags = 0
	origin_tech = "combat=6;engineering=4"
	mag_type = /obj/item/ammo_box/magazine/m556
	fire_sound = 'sound/weapons/gunshot_smg.ogg'
	can_suppress = 0
	burst_size = 3
	fire_delay = 1

// Bulldog shotgun //

/obj/item/weapon/gun/ballistic/automatic/shotgun/bulldog
	name = "\improper Bulldog Shotgun"
	desc = "A semi-auto, mag-fed shotgun for combat in narrow corridors, nicknamed 'Bulldog' by boarding parties. Compatible only with specialized 8-round drum magazines."
	icon_state = "bulldog"
	item_state = "bulldog"
	w_class = WEIGHT_CLASS_NORMAL
	weapon_weight = WEAPON_MEDIUM
	origin_tech = "combat=6;materials=4;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/m12g
	fire_sound = 'sound/weapons/gunshot.ogg'
	can_suppress = 0
	burst_size = 1
	fire_delay = 0
	pin = /obj/item/device/firing_pin/implant/pindicate
	actions_types = list()

/obj/item/weapon/gun/ballistic/automatic/shotgun/bulldog/unrestricted
	pin = /obj/item/device/firing_pin

/obj/item/weapon/gun/ballistic/automatic/shotgun/bulldog/Initialize()
	. = ..()
	update_icon()

/obj/item/weapon/gun/ballistic/automatic/shotgun/bulldog/update_icon()
	cut_overlays()
	if(magazine)
		add_overlay("[magazine.icon_state]")
	icon_state = "bulldog[chambered ? "" : "-e"]"

/obj/item/weapon/gun/ballistic/automatic/shotgun/bulldog/afterattack()
	..()
	empty_alarm()
	return



// L6 SAW //

/obj/item/weapon/gun/ballistic/automatic/l6_saw
	name = "\improper L6 SAW"
	desc = "A heavily modified 1.95x129mm light machine gun, designated 'L6 SAW'. Has 'Aussec Armoury - 2531' engraved on the receiver below the designation."
	icon_state = "l6closed100"
	item_state = "l6closedmag"
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = 0
	origin_tech = "combat=6;engineering=3;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/mm195x129
	weapon_weight = WEAPON_HEAVY
	fire_sound = 'sound/weapons/gunshot_smg.ogg'
	var/cover_open = FALSE
	can_suppress = 0
	burst_size = 3
	fire_delay = 1
	pin = /obj/item/device/firing_pin/implant/pindicate

/obj/item/weapon/gun/ballistic/automatic/l6_saw/unrestricted
	pin = /obj/item/device/firing_pin


/obj/item/weapon/gun/ballistic/automatic/l6_saw/attack_self(mob/user)
	cover_open = !cover_open
	to_chat(user, "<span class='notice'>You [cover_open ? "open" : "close"] [src]'s cover.</span>")
	if(cover_open)
		playsound(user, 'sound/weapons/sawopen.ogg', 60, 1)
	else
		playsound(user, 'sound/weapons/sawclose.ogg', 60, 1)
	update_icon()


/obj/item/weapon/gun/ballistic/automatic/l6_saw/update_icon()
	icon_state = "l6[cover_open ? "open" : "closed"][magazine ? Ceiling(get_ammo(0)/12.5)*25 : "-empty"][suppressed ? "-suppressed" : ""]"
	item_state = "l6[cover_open ? "openmag" : "closedmag"]"


/obj/item/weapon/gun/ballistic/automatic/l6_saw/afterattack(atom/target as mob|obj|turf, mob/living/user as mob|obj, flag, params) //what I tried to do here is just add a check to see if the cover is open or not and add an icon_state change because I can't figure out how c-20rs do it with overlays
	if(cover_open)
		to_chat(user, "<span class='warning'>[src]'s cover is open! Close it before firing!</span>")
	else
		..()
		update_icon()


/obj/item/weapon/gun/ballistic/automatic/l6_saw/attack_hand(mob/user)
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
		to_chat(user, "<span class='notice'>You remove the magazine from [src].</span>")
		playsound(user, 'sound/weapons/magout.ogg', 60, 1)


/obj/item/weapon/gun/ballistic/automatic/l6_saw/attackby(obj/item/A, mob/user, params)
	if(!cover_open && istype(A, mag_type))
		to_chat(user, "<span class='warning'>[src]'s cover is closed! You can't insert a new mag.</span>")
		return
	..()



// SNIPER //

/obj/item/weapon/gun/ballistic/automatic/sniper_rifle
	name = "sniper rifle"
	desc = "A long ranged weapon that does significant damage. No, you can't quickscope."
	icon_state = "sniper"
	item_state = "sniper"
	recoil = 2
	weapon_weight = WEAPON_HEAVY
	mag_type = /obj/item/ammo_box/magazine/sniper_rounds
	fire_delay = 40
	burst_size = 1
	origin_tech = "combat=7"
	can_unsuppress = 1
	can_suppress = 1
	w_class = WEIGHT_CLASS_NORMAL
	zoomable = TRUE
	zoom_amt = 7 //Long range, enough to see in front of you, but no tiles behind you.
	slot_flags = SLOT_BACK
	actions_types = list()


/obj/item/weapon/gun/ballistic/automatic/sniper_rifle/update_icon()
	if(magazine)
		icon_state = "sniper-mag"
	else
		icon_state = "sniper"


/obj/item/weapon/gun/ballistic/automatic/sniper_rifle/syndicate
	name = "syndicate sniper rifle"
	desc = "An illegally modified .50 cal sniper rifle with supression compatibility. Quickscoping still doesn't work."
	pin = /obj/item/device/firing_pin/implant/pindicate
	origin_tech = "combat=7;syndicate=6"

/obj/item/weapon/gun/ballistic/automatic/sniper_rifle/gang
	name = "black market sniper rifle"
	desc = "A long ranged weapon that does significant damage. It is well worn from years of service."
	mag_type = /obj/item/ammo_box/magazine/sniper_rounds/gang

// Old Semi-Auto Rifle //

/obj/item/weapon/gun/ballistic/automatic/surplus
	name = "Surplus Rifle"
	desc = "One of countless obsolete ballistic rifles that still sees use as a cheap deterrent. Uses 10mm ammo and its bulky frame prevents one-hand firing."
	origin_tech = "combat=3;materials=2"
	icon_state = "surplus"
	item_state = "moistnugget"
	weapon_weight = WEAPON_HEAVY
	mag_type = /obj/item/ammo_box/magazine/m10mm/rifle
	fire_delay = 30
	burst_size = 1
	can_unsuppress = 1
	can_suppress = 1
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = SLOT_BACK
	actions_types = list()

/obj/item/weapon/gun/ballistic/automatic/surplus/update_icon()
	if(magazine)
		icon_state = "surplus"
	else
		icon_state = "surplus-e"


// Laser rifle (rechargeable magazine) //

/obj/item/weapon/gun/ballistic/automatic/laser
	name = "laser rifle"
	desc = "Though sometimes mocked for the relatively weak firepower of their energy weapons, the logistic miracle of rechargable ammunition has given Nanotrasen a decisive edge over many a foe."
	icon_state = "oldrifle"
	item_state = "arg"
	mag_type = /obj/item/ammo_box/magazine/recharge
	fire_delay = 2
	can_suppress = 0
	burst_size = 0
	actions_types = list()
	fire_sound = 'sound/weapons/laser.ogg'
	casing_ejector = 0

/obj/item/weapon/gun/ballistic/automatic/laser/update_icon()
	..()
	icon_state = "oldrifle[magazine ? "-[Ceiling(get_ammo(0)/4)*4]" : ""]"
	return
