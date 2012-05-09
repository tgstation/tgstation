/*
CONTAINS:
FORK
ROLLING PIN
KNIFE

*/


/obj/item/weapon/kitchen/utensil/New()
	if (prob(60))
		src.pixel_y = rand(0, 4)
	return





// FORK

/obj/item/weapon/kitchen/utensil/fork/attack(mob/living/M as mob, mob/living/carbon/user as mob)
	if(istype(M,/mob/living/carbon) || istype(M,/mob/living/simple_animal/livestock))
		if (bite)
			if(M == user)
				user.visible_message( \
					"\blue [user] eats a delicious forkful of [bite]!", \
					"\blue You eat a delicious forkful of [bite]!")
			else
				user.visible_message( \
					"\blue [user] feeds [M] a delicious forkful of [bite]!", \
					"\blue You feed [M] a delicious forkful of [bite]!")
			spawn(0)
				bite.reagents.reaction(M, INGEST)
				bite.reagents.trans_to(M)
				del(bite)
				src.icon_state = "fork"
		else if(user.zone_sel.selecting == "eyes")
			if((user.mutations & CLUMSY) && prob(50))
				M = user
			return eyestab(M, user)
		else
			user << "\red Your fork does not have any food on it."
	else
		user << "\red You can't seem to feed [M]."

/obj/item/weapon/kitchen/utensil/fork/afterattack(obj/item/weapon/reagent_containers/food/snacks/snack as obj, mob/living/carbon/user as mob)
	if(istype(snack))
		if(bite)
			user << "\red You already have [bite] on your fork."
		else
			bite = new snack.type(src)
			icon_state = "forkloaded"
			user.visible_message( \
				"[user] takes a piece of [bite] with their fork!", \
				"\blue You take a piece of [bite] with your fork!" \
			)
			if(bite.reagents && snack.reagents)	//transfer bit's worth of reagents to
				bite.reagents.clear_reagents()
				if(snack.reagents.total_volume)
					snack.reagents.reaction(src, TOUCH) // react "food" with fork
					spawn(0)
						if(snack.reagents.total_volume > snack.bitesize)
							snack.reagents.trans_to(bite, snack.bitesize)
						else
							snack.reagents.trans_to(bite, snack.reagents.total_volume)
						snack.bitecount++
						if(!snack.reagents.total_volume)
							// due to the trash code being hard-coded to place in hand, do magic trick
							// free active hand
							user.drop_item(src)

							// consumption fills active hand, drop it back down
							snack.On_Consume()
							var/obj/trash = user.get_active_hand()
							if(trash)
								user.drop_item(trash)
								trash.loc = get_turf(snack.loc) // move trash to snack's turf

							// put fork back in hand
							user.put_in_hand(src)
							user << "\red You grab the last bite of [snack]."
							del(snack)
	else
		return ..()





// ROLLING PIN
/* //Honestly this doesn't even work and is very silly. -- Erthilo
/obj/item/weapon/kitchen/rollingpin/attack(mob/M as mob, mob/living/user as mob)
	if ((user.mutations & CLUMSY) && prob(50))
		user << "\red The [src] slips out of your hand and hits your head."
		user.take_organ_damage(10)
		user.Paralyse(2)
		return
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")

	log_admin("ATTACK: [user] ([user.ckey]) attacked [M] ([M.ckey]) with [src].")
	message_admins("ATTACK: [user] ([user.ckey]) attacked [M] ([M.ckey]) with [src].")
	log_attack("<font color='red'>[user.name] ([user.ckey]) used the [src.name] to attack [M.name] ([M.ckey])</font>")

	if (M.stat < 2 && M.health < 50 && prob(90))
		var/mob/H = M
		// ******* Check
		if ((istype(H, /mob/living/carbon/human) && istype(H, /obj/item/clothing/head) && H.flags & 8 && prob(80)))
			M << "\red The helmet protects you from being hit hard in the head!"
			return
		var/time = rand(2, 6)
		if (prob(75))
			M.Paralyse(time)
		else
			M.Stun(time)
		if(M.stat != 2)	M.stat = 1
		for(var/mob/O in viewers(M, null))
			O.show_message(text("\red <B>[] has been knocked unconscious!</B>", M), 1, "\red You hear someone fall.", 2)
	else
		M << text("\red [] tried to knock you unconcious!",user)
		M.eye_blurry += 3

	return
*/





// KNIFE

/obj/item/weapon/kitchen/utensil/knife/attack(target as mob, mob/living/user as mob)
	if ((user.mutations & CLUMSY) && prob(50))
		user << "\red You accidentally cut yourself with the [src]."
		user.take_organ_damage(20)
		return
	return ..()
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////// TRAY -Agouri :3   ///////////////////////////////////////////////

/obj/item/weapon/tray/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)

	// Drop all the things. All of them.
	overlays = null
	for(var/obj/item/I in carrying)
		I.loc = M.loc
		carrying.Remove(I)
		if(isturf(I.loc))
			spawn()
				for(var/i = 1, i <= rand(1,2), i++)
					if(I)
						step(I, pick(NORTH,SOUTH,EAST,WEST))
						sleep(rand(2,4))


	if((user.mutations & CLUMSY) && prob(50))              //What if he's a clown?
		M << "\red You accidentally slam yourself with the [src]!"
		M.Weaken(1)
		user.take_organ_damage(2)
		if(prob(50))
			playsound(M, 'trayhit1.ogg', 50, 1)
			return
		else
			playsound(M, 'trayhit2.ogg', 50, 1) //sound playin'
			return //it always returns, but I feel like adding an extra return just for safety's sakes. EDIT; Oh well I won't :3

	var/mob/living/carbon/human/H = M      ///////////////////////////////////// /Let's have this ready for later.


	if(!(user.zone_sel.selecting == ("eyes" || "head"))) //////////////hitting anything else other than the eyes
		if(prob(33))
			src.add_blood(H)
			var/turf/location = H.loc
			if (istype(location, /turf/simulated))
				location.add_blood(H)     ///Plik plik, the sound of blood

		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")

		log_admin("ATTACK: [user] ([user.ckey]) attacked [M] ([M.ckey]) with [src].")
		message_admins("ATTACK: [user] ([user.ckey]) attacked [M] ([M.ckey]) with [src].")
		log_attack("<font color='red'>[user.name] ([user.ckey]) used the [src.name] to attack [M.name] ([M.ckey])</font>")


		if(prob(15))
			M.Weaken(3)
			M.take_organ_damage(3)
		else
			M.take_organ_damage(5)
		if(prob(50))
			playsound(M, 'trayhit1.ogg', 50, 1)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red <B>[] slams [] with the tray!</B>", user, M), 1)
			return
		else
			playsound(M, 'trayhit2.ogg', 50, 1)  //we applied the damage, we played the sound, we showed the appropriate messages. Time to return and stop the proc
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red <B>[] slams [] with the tray!</B>", user, M), 1)
			return




	if(istype(M, /mob/living/carbon/human) && ((H.head && H.head.flags & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || (H.glasses && H.glasses.flags & GLASSESCOVERSEYES)))
		M << "\red You get slammed in the face with the tray, against your mask!"
		if(prob(33))
			src.add_blood(H)
			if (H.wear_mask)
				H.wear_mask.add_blood(H)
			if (H.head)
				H.head.add_blood(H)
			if (H.glasses && prob(33))
				H.glasses.add_blood(H)
			var/turf/location = H.loc
			if (istype(location, /turf/simulated))     //Addin' blood! At least on the floor and item :v
				location.add_blood(H)

		if(prob(50))
			playsound(M, 'trayhit1.ogg', 50, 1)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red <B>[] slams [] with the tray!</B>", user, M), 1)
		else
			playsound(M, 'trayhit2.ogg', 50, 1)  //sound playin'
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red <B>[] slams [] with the tray!</B>", user, M), 1)
		if(prob(10))
			M.Stun(rand(1,3))
			M.take_organ_damage(3)
			return
		else
			M.take_organ_damage(5)
			return

	else //No eye or head protection, tough luck!
		M << "\red You get slammed in the face with the tray!"
		if(prob(33))
			src.add_blood(M)
			var/turf/location = H.loc
			if (istype(location, /turf/simulated))
				location.add_blood(H)

		if(prob(50))
			playsound(M, 'trayhit1.ogg', 50, 1)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red <B>[] slams [] in the face with the tray!</B>", user, M), 1)
		else
			playsound(M, 'trayhit2.ogg', 50, 1)  //sound playin' again
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red <B>[] slams [] in the face with the tray!</B>", user, M), 1)
		if(prob(30))
			M.Stun(rand(2,4))
			M.take_organ_damage(4)
			return
		else
			M.take_organ_damage(8)
			if(prob(30))
				M.Weaken(2)
				return
			return


/*
===============~~~~~================================~~~~~====================
=																			=
=  Code for trays carrying things. By Doohl for Doohl erryday Doohl Doohl~  =
=																			=
===============~~~~~================================~~~~~====================
*/
/obj/item/weapon/tray/proc/calc_carry()
	// calculate the weight of the items on the tray
	var/val = 0 // value to return

	for(var/obj/item/I in carrying)
		if(I.w_class == 1.0)
			val ++
		else if(I.w_class == 2.0)
			val += 3
		else
			val += 5

	return val

/obj/item/weapon/tray/pickup(mob/user)
	overlays = null

	if(!isturf(loc))
		return

	for(var/obj/item/I in loc)
		if( I != src && !I.anchored && !istype(I, /obj/item/clothing/under) && !istype(I, /obj/item/clothing/suit) && !istype(I, /obj/item/projectile) )
			var/add = 0
			if(I.w_class == 1.0)
				add = 1
			else if(I.w_class == 2.0)
				add = 3
			else
				add = 5
			if(calc_carry() + add >= max_carry)
				break

			I.loc = src
			carrying.Add(I)
			overlays += image("icon" = I.icon, "icon_state" = I.icon_state, "layer" = 30 + I.layer)

/obj/item/weapon/tray/dropped(mob/user)
	var/foundtable = 0
	for(var/obj/structure/table/T in loc)
		foundtable = 1
		break

	overlays = null

	for(var/obj/item/I in carrying)
		I.loc = loc
		carrying.Remove(I)
		if(!foundtable && isturf(loc))
			// if no table, presume that the person just shittily dropped the tray on the ground and made a mess everywhere!
			spawn()
				for(var/i = 1, i <= rand(1,2), i++)
					if(I)
						step(I, pick(NORTH,SOUTH,EAST,WEST))
						sleep(rand(2,4))





/////////////////////////////////////////////////////////////////////////////////////////
//Enough with the violent stuff, here's what happens if you try putting food on it
/////////////////////////////////////////////////////////////////////////////////////////////



/*/obj/item/weapon/tray/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/kitchen/utensil/fork))
		if (W.icon_state == "forkloaded")
			user << "\red You already have omelette on your fork."
			return
		W.icon = 'kitchen.dmi'
		W.icon_state = "forkloaded"
		viewers(3,user) << "[user] takes a piece of omelette with his fork!"
		reagents.remove_reagent("nutriment", 1)
		if (reagents.total_volume <= 0)
			del(src)*/


/*			if (prob(33))
						var/turf/location = H.loc
						if (istype(location, /turf/simulated))
							location.add_blood(H)
					if (H.wear_mask)
						H.wear_mask.add_blood(H)
					if (H.head)
						H.head.add_blood(H)
					if (H.glasses && prob(33))
						H.glasses.add_blood(H)
					if (istype(user, /mob/living/carbon/human))
						var/mob/living/carbon/human/user2 = user
						if (user2.gloves)
							user2.gloves.add_blood(H)
						else
							user2.add_blood(H)
						if (prob(15))
							if (user2.wear_suit)
								user2.wear_suit.add_blood(H)
							else if (user2.w_uniform)
								user2.w_uniform.add_blood(H)*/