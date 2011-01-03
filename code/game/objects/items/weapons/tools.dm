/*
CONTAINS:

WRENCH
SCREWDRIVER
WELDINGTOOOL
*/


// WRENCH
/obj/item/weapon/wrench/New()
	if (prob(75))
		src.pixel_x = rand(0, 16)
	return




// SCREWDRIVER
/obj/item/weapon/screwdriver/New()
	if (prob(75))
		src.pixel_y = rand(0, 16)
	return

/obj/item/weapon/screwdriver/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M, /mob))
		return

	if((usr.mutations & 16) && prob(50))
		M << "\red You stab yourself in the eye."
		M.sdisabilities |= 1
		M.weakened += 4
		M.bruteloss += 10

	src.add_fingerprint(user)
	if(!(user.zone_sel.selecting == ("eyes" || "head")))
		return ..()
	var/mob/living/carbon/human/H = M

	if(istype(M, /mob/living/carbon/human) && ((H.head && H.head.flags & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || (H.glasses && H.glasses.flags & GLASSESCOVERSEYES)))
		// you can't stab someone in the eyes wearing a mask!
		user << "\blue You're going to need to remove that mask/helmet/glasses first."
		return
	if(istype(M, /mob/living/carbon/alien))//Aliens don't have eyes./N
		user << "\blue You cannot locate any eyes on this creature!"
		return

	for(var/mob/O in viewers(M, null))
		if(O == (user || M))	continue
		if(M == user)	O.show_message(text("\red [] has stabbed themself with []!", user, src), 1)
		else	O.show_message(text("\red [] has been stabbed in the eye with [] by [].", M, src, user), 1)
	if(M != user)
		M << "\red [user] stabs you in the eye with [src]!"
		user << "\red You stab [M] in the eye with [src]!"
	else
		user << "\red You stab yourself in the eyes with [src]!"
	if(istype(M, /mob/living/carbon/human))
		var/datum/organ/external/affecting = M.organs["head"]
		affecting.take_damage(7)
	else
		M.bruteloss += 7
	M.eye_blurry += rand(3,4)
	M.eye_stat += rand(2,4)
	if (M.eye_stat >= 10)
		M << "\red Your eyes start to bleed profusely!"
		M.eye_blurry += 15+(0.1*M.eye_blurry)
		M.disabilities |= 1
		if(M.stat == 2)	return
		if(prob(50))
			M << "\red You drop what you're holding and clutch at your eyes!"
			M.eye_blurry += 10
			M.paralysis += 1
			M.weakened += 4
			M.drop_item()
		if (prob(M.eye_stat - 10 + 1))
			M << "\red You go blind!"
			M.sdisabilities |= 1
	return




// WELDING TOOL
/obj/item/weapon/weldingtool/New()
	var/datum/reagents/R = new/datum/reagents(20)
	reagents = R
	R.my_atom = src
	R.add_reagent("fuel", 20)
	return

/obj/item/weapon/weldingtool/examine()
	set src in usr
	usr << text("\icon[] [] contains [] units of fuel left!", src, src.name, get_fuel() )
	return

/obj/item/weapon/weldingtool/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W,/obj/item/weapon/screwdriver))
		status = !status
		if (status)
			user << "\blue You resecure the welder."
		else
			user << "\blue The welder can now be attached and modified."
		src.add_fingerprint(user)
	else if (status == 1 && istype(W,/obj/item/stack/rods))
		var/obj/item/stack/rods/R = W
		R.use(1)
		var/obj/item/assembly/weld_rod/F = new /obj/item/assembly/weld_rod( user )
		src.loc = F
		F.part1 = src
		if (user.client)
			user.client.screen -= src
		if (user.r_hand == src)
			user.u_equip(src)
			user.r_hand = F
		else
			user.u_equip(src)
			user.l_hand = F
		R.master = F
		src.master = F
		src.layer = initial(src.layer)
		user.u_equip(src)
		if (user.client)
			user.client.screen -= src
		src.loc = F
		F.part2 = W
		F.layer = 20
		R.layer = 20
		F.loc = user
		src.add_fingerprint(user)
	else
		..()

// helper functions for weldingtool fuel use

// return fuel amount
/obj/item/weapon/weldingtool/proc/get_fuel()
	return reagents.get_reagent_amount("fuel")

// remove fuel amount
/obj/item/weapon/weldingtool/proc/use_fuel(var/amount)
	amount = min( get_fuel() , amount)
	reagents.remove_reagent("fuel", amount)
	return

/obj/item/weapon/weldingtool/afterattack(obj/O as obj, mob/user as mob)

	if (istype(O, /obj/reagent_dispensers/fueltank) && get_dist(src,O) <= 1 && !src.welding)
		O.reagents.trans_to(src, 20)
		user << "\blue Welder refueled"
		playsound(src.loc, 'refill.ogg', 50, 1, -6)

	else if (istype(O, /obj/reagent_dispensers/fueltank) && get_dist(src,O) <= 1 && src.welding)
		message_admins("[key_name_admin(user)] triggered a fueltank explosion.")
		user << "\red That was stupid of you."
		explosion(O.loc,-1,0,2)
		if(O)
			del(O)

	else if (src.welding)
		use_fuel(1)


		if (get_fuel() <= 0)
			usr << "\blue Need more fuel!"
			src.welding = 0
			src.force = 3
			src.damtype = "brute"
			src.icon_state = "welder"
		var/turf/location = user.loc
		if (istype(location, /turf))
			location.hotspot_expose(700, 50, 1)
	return


/obj/item/weapon/weldingtool/proc/eyecheck(mob/user as mob)
	//check eye protection
	var/safety = null
	if (istype(user, /mob/living/carbon/human))
		if (istype(user:head, /obj/item/clothing/head/helmet/welding) || istype(user:head, /obj/item/clothing/head/helmet/space))
			safety = 2
		else if (istype(user:glasses, /obj/item/clothing/glasses/sunglasses))
			safety = 1
		else if (istype(user:glasses, /obj/item/clothing/glasses/thermal))
			safety = -1
		else
			safety = 0
	else if(istype(user, /mob/living/carbon))
		safety = 0
	switch(safety)
		if(1)
			usr << "\red Your eyes sting a little."
			user.eye_stat += rand(1, 2)
			if(user.eye_stat > 12)
				user.eye_blurry += rand(3,6)
		if(0)
			usr << "\red Your eyes burn."
			user.eye_stat += rand(2, 4)
			if(user.eye_stat > 10)
				user.eye_blurry += rand(4,10)
		if(-1)
			usr << "\red Your thermals intensify the welder's glow. Your eyes itch and burn severely."
			user.eye_blurry += rand(12,20)
			user.eye_stat += rand(12, 16)
	if(user.eye_stat > 10 && safety < 2)
		user << "\red Your eyes are really starting to hurt. This can't be good for you!"
	if (prob(user.eye_stat - 25 + 1))
		user << "\red You go blind!"
		user.sdisabilities |= 1
	else if (prob(user.eye_stat - 15 + 1))
		user << "\red You go blind!"
		user.eye_blind = 5
		user.eye_blurry = 5
		user.disabilities |= 1
		spawn(100)
			user.disabilities &= ~1

/obj/item/weapon/weldingtool/attack_self(mob/user as mob)
	if(status > 1)	return
	src.welding = !( src.welding )
	if (src.welding)
		if (get_fuel() <= 0)
			user << "\blue Need more fuel!"
			src.welding = 0
			return 0
		user << "\blue You will now weld when you attack."
		src.force = 15
		src.damtype = "fire"
		src.icon_state = "welder1"
		processing_items.Add(src)
	else
		user << "\blue Not welding anymore."
		src.force = 3
		src.damtype = "brute"
		src.icon_state = "welder"
	return

/obj/item/weapon/weldingtool/process()
	if(!welding)
		processing_items.Remove(src)
		return

	var/turf/location = src.loc
	if(istype(location, /mob/))
		var/mob/M = location
		if(M.l_hand == src || M.r_hand == src)
			location = M.loc

	if (istype(location, /turf))
		location.hotspot_expose(700, 5)
