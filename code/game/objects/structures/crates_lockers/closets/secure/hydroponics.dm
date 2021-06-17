/obj/structure/closet/secure_closet/hydroponics
	name = "botanist's locker"
	req_access = list(ACCESS_HYDROPONICS)
	icon_state = "hydro"

/obj/structure/closet/secure_closet/hydroponics/PopulateContents()
	..()
	new /obj/item/storage/bag/plants/portaseeder(src)
	new /obj/item/plant_analyzer(src)
	new /obj/item/radio/headset/headset_srv(src)
	new /obj/item/cultivator(src)
	new /obj/item/hatchet(src)
	new /obj/item/secateurs(src)

//Plocker
/obj/structure/closet/secure_closet/peach
	name = "peach locker"
	desc = "A huge hollow pitless peach."
	locked = FALSE
	icon_state = "plocker"
	max_integrity = 40
	armor = list(MELEE = 10, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 60, FIRE = 10, ACID = 0)
	can_weld_shut = FALSE
	damage_deflection = 0
	material_drop_amount = 0
	close_sound = "sound/misc/moist_impact.ogg"
	open_sound = "sound/misc/soggy.ogg"
	breakout_time = 100
	var/isDegrading = FALSE //Used to check if the peach locker is degrading
	var/owner = null //The owner of the locker which is set when an impeach is activated
	var/lifespan = 3 MINUTES //Right when the peach locker is created it has this amount of time before it starts degrading

/obj/structure/closet/secure_closet/peach/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/effects/footstep/slime1.ogg', 75, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/closet/secure_closet/peach/togglelock(mob/living/user, silent)
	if(secure && !broken)
		if(owner == user)
			if(iscarbon(user))
				add_fingerprint(user)
			locked = !locked
			user.visible_message("<span class='notice'>[user] [locked ? null : "un"]locks [src].</span>",
							"<span class='notice'>You [locked ? null : "un"]lock [src].</span>")
			update_appearance()
		else if(!silent)
			to_chat(user, "<span class='alert'>Access Denied.</span>")
	else if(secure && broken)
		to_chat(user, "<span class='warning'>\The [src] is broken!</span>")

/obj/structure/closet/secure_closet/peach/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/start_degrading), lifespan)

/**
* Begins the process for the locker to degrade
*/
/obj/structure/closet/secure_closet/peach/proc/start_degrading()
	isDegrading = TRUE
	icon_state = "plocker_degrade"
	desc += " There are ants all over it!"
	update_appearance()
	degrade()

/**
* Degrades the peach locker over time
*/
/obj/structure/closet/secure_closet/peach/proc/degrade()
	if(QDELETED(src) || isDegrading == FALSE)
		return
	src.take_damage(10,BRUTE,"",FALSE)
	if(obj_integrity > 0)
		addtimer(CALLBACK(src, .proc/degrade), 1 MINUTES)

/obj/structure/closet/secure_closet/peach/emag_act(mob/user)
	return

/obj/structure/closet/secure_closet/peach/emp_act(severity)
	return
