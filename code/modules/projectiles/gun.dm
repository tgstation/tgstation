 #define SAWN_INTACT  0
 #define SAWN_OFF     1
 #define SAWN_SAWING -1

/obj/item/weapon/gun
	name = "gun"
	desc = "It's a gun. It's pretty terrible, though."
	icon = 'icons/obj/gun.dmi'
	icon_state = "detective"
	item_state = "gun"
	flags =  CONDUCT
	slot_flags = SLOT_BELT
	m_amt = 2000
	w_class = 3.0
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	force = 5.0
	origin_tech = "combat=1"
	attack_verb = list("struck", "hit", "bashed")

	var/fire_sound = "gunshot"
	var/suppressed = 0
	var/can_suppress = 0
	var/recoil = 0
	var/clumsy_check = 1
	var/obj/item/ammo_casing/chambered = null
	var/trigger_guard = 1
	var/sawn_desc = null
	var/sawn_state = SAWN_INTACT
	var/burst_size = 1
	var/fire_delay = 0

/obj/item/weapon/gun/proc/process_chamber()
	return 0

/obj/item/weapon/gun/proc/special_check(var/mob/M) //Placeholder for any special checks, like detective's revolver.
	return 1

//check if there's enough ammo/energy/whatever to shoot one time
//i.e if clicking would make it shoot
/obj/item/weapon/gun/proc/can_shoot()
	return 1

/obj/item/weapon/gun/proc/shoot_with_empty_chamber(mob/living/user as mob|obj)
	user << "<span class='danger'>*click*</span>"
	playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	return

/obj/item/weapon/gun/proc/shoot_live_shot(mob/living/user as mob|obj, var/pointblank = 0, var/mob/pbtarget = null, var/message = 1)
	if(recoil)
		spawn()
			shake_camera(user, recoil + 1, recoil)

	if(suppressed)
		playsound(user, fire_sound, 10, 1)
	else
		playsound(user, fire_sound, 50, 1)
		if(!message)
			return
		if(pointblank)
			user.visible_message("<span class='danger'>[user] fires [src] point blank at [pbtarget]!</span>", "<span class='danger'>You fire [src] point blank at [pbtarget]!</span>", "You hear a [istype(src, /obj/item/weapon/gun/energy) ? "laser blast" : "gunshot"]!")
		else
			user.visible_message("<span class='danger'>[user] fires [src]!</span>", "<span class='danger'>You fire [src]!</span>", "You hear a [istype(src, /obj/item/weapon/gun/energy) ? "laser blast" : "gunshot"]!")

/obj/item/weapon/gun/emp_act(severity)
	for(var/obj/O in contents)
		O.emp_act(severity)

/obj/item/weapon/gun/afterattack(atom/target as mob|obj|turf, mob/living/carbon/human/user as mob|obj, flag, params)//TODO: go over this
	if(flag) //It's adjacent, is the user, or is on the user's person
		if(istype(target, /mob/) && target != user && !(target in user.contents)) //We make sure that it is a mob, it's not us or part of us.
			if(user.a_intent == "harm") //Flogging action
				return
		else
			return

	//Exclude lasertag guns from the CLUMSY check.
	if(clumsy_check && can_shoot())
		if(istype(user, /mob/living))
			var/mob/living/M = user
			if (M.disabilities & CLUMSY && prob(40))
				user << "<span class='danger'>You shoot yourself in the foot with \the [src]!</span>"
				process_fire(user,user,0,params)
				M.drop_item()
				return

	if(isliving(user))
		var/mob/living/L = user
		if(!can_trigger_gun(L))
			return

	process_fire(target,user,1,params)

/obj/item/weapon/gun/proc/can_trigger_gun(mob/living/carbon/user)
	if (!user.IsAdvancedToolUser())
		user << "<span class='notice'>You don't have the dexterity to do this!</span>"
		return 0

	if(trigger_guard)
		if(istype(user) && user.dna)
			if(user.dna.check_mutation(HULK))
				user << "<span class='notice'>Your meaty finger is much too large for the trigger guard!</span>"
				return 0
			if(NOGUNS in user.dna.species.specflags)
				user << "<span class='notice'>Your fingers don't fit in the trigger guard!</span>"
				return 0
	return 1

/obj/item/weapon/gun/proc/process_fire(atom/target as mob|obj|turf, mob/living/user as mob|obj, var/message = 1, params)

	add_fingerprint(user)

	if(!special_check(user))
		return

	for(var/i = 1 to burst_size)
		if(!issilicon(user))
			if( i>1 && !(src in get_both_hands(user))) //for burst firing
				break
		if(chambered)
			if(!chambered.fire(target, user, params, , suppressed))
				shoot_with_empty_chamber(user)
				break
			else
				if(!special_check(user))
					return
				if(get_dist(user, target) <= 1) //Making sure whether the target is in vicinity for the pointblank shot
					shoot_live_shot(user, 1, target, message)
				else
					shoot_live_shot(user, 0, target, message)
		else
			shoot_with_empty_chamber(user)
			break
		process_chamber()
		update_icon()
		sleep(fire_delay)

	if(user.hand)
		user.update_inv_l_hand(0)
	else
		user.update_inv_r_hand(0)

/obj/item/weapon/gun/attack(mob/M as mob, mob/user)
	if(user.a_intent == "harm") //Flogging
		..()
	else
		return