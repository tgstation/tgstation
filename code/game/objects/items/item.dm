/obj/item/proc/process()
	processing_items.Remove(src)

	return null

/obj/item/proc/attack_self()
	return

/obj/item/proc/talk_into(mob/M as mob, text)
	return

/obj/item/proc/moved(mob/user as mob, old_loc as turf)
	return

/obj/item/proc/dropped(mob/user as mob)
	..()

	// So you can't drop the Offhand
	if(istype(src, /obj/item/weapon/offhand))
		user.drop_item(src)

		var/obj/item/O_r = user.r_hand
		var/obj/item/O_l = user.l_hand
		if(O_r.twohanded)
			if(O_r.wielded)
				user.drop_item(O_r)
		if(O_l.twohanded)
			if(O_l.wielded)
				user.drop_item(O_l)
		del(src)

// called just as an item is picked up (loc is not yet changed)
/obj/item/proc/pickup(mob/user)
	return

// called after an item is placed in an equipment slot
// user is mob that equipped it
// slot is text of slot type e.g. "head"
// for items that can be placed in multiple slots
// note this isn't called during the initial dressing of a player
/obj/item/proc/equipped(var/mob/user, var/slot)
	return
//
// ***TODO: implement unequipped()
//

/obj/item/proc/afterattack()

	return

/obj/item/weapon/dummy/ex_act()
	return

/obj/item/weapon/dummy/blob_act()
	return

/obj/item/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(50))
				del(src)
				return
		if(3.0)
			if (prob(5))
				del(src)
				return
		else
	return

/obj/item/blob_act()
	return

/obj/item/verb/move_to_top()
	set name = "Move To Top"
	set category = "Object"
	set src in oview(1)

	if(!istype(src.loc, /turf) || usr.stat || usr.restrained() )
		return

	var/turf/T = src.loc

	src.loc = null

	src.loc = T

/obj/item/examine()
	set src in view()

	var/t
	switch(src.w_class)
		if(1.0)
			t = "tiny"
		if(2.0)
			t = "small"
		if(3.0)
			t = "normal-sized"
		if(4.0)
			t = "bulky"
		if(5.0)
			t = "huge"
		else
	if ((usr.mutations & CLOWN) && prob(50)) t = "funny-looking"
	usr << text("This is a []\icon[][]. It is a [] item.", !src.blood_DNA ? "" : "bloody ",src, src.name, t)
	usr << src.desc
	return

/obj/item/attack_hand(mob/user as mob)
	if (!user) return
	if (istype(src.loc, /obj/item/weapon/storage))
		for(var/mob/M in range(1, src.loc))
			if (M.s_active == src.loc)
				if (M.client)
					M.client.screen -= src
	src.throwing = 0
	if (src.loc == user)
		//canremove==0 means that object may not be removed. You can still wear it. This only applies to clothing. /N
		if(istype(src, /obj/item/clothing) && !src:canremove)
			return
		else
			user.u_equip(src)
	else
		src.pickup(user)

	if (user.hand)
		user.l_hand = src
	else
		user.r_hand = src
	src.loc = user
	src.layer = 20
	add_fingerprint(user)
	user.update_clothing()
	return


/obj/item/attack_paw(mob/user as mob)

	if(isalien(user)) // -- TLE
		if(!user:has_fine_manipulation) // -- defaults to 0, only changes due to badminnery -- Urist
			user << "Your claws aren't capable of such fine manipulation."
			return

	if (istype(src.loc, /obj/item/weapon/storage))
		for(var/mob/M in range(1, src.loc))
			if (M.s_active == src.loc)
				if (M.client)
					M.client.screen -= src
	src.throwing = 0
	if (src.loc == user)
		//canremove==0 means that object may not be removed. You can still wear it. This only applies to clothing. /N
		if(istype(src, /obj/item/clothing) && !src:canremove)
			return
		else
			user.u_equip(src)
	if (user.hand)
		user.l_hand = src
	else
		user.r_hand = src
	src.loc = user
	src.layer = 20
	user.update_clothing()
	return

/obj/item/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/packageWrap))
		var/obj/item/weapon/packageWrap/O = W
		if (O.amount > 1)
			var/obj/item/smallDelivery/P = new /obj/item/smallDelivery(get_turf(src.loc))
			P.wrapped = src

			src.loc = P
			O.amount -= 1

/obj/item/attack_self(mob/user as mob)
	..()
	if(twohanded)
		if(wielded) //Trying to unwield it
			wielded = 0
			force = force_unwielded
			src.name = "[initial(name)] (Unwielded)"
			src.update_icon() //If needed by the particular item
			user << "\blue You are now carrying the [initial(name)] with one hand."

			if(istype(user.get_inactive_hand(),/obj/item/weapon/offhand))
				del user.get_inactive_hand()
			return
		else //Trying to wield it
			if(user.get_inactive_hand())
				user << "\red You need your other hand to be empty"
				return
			wielded = 1
			force = force_wielded
			src.name = "[initial(name)] (Wielded)"
			src.update_icon() //If needed by the particular item
			user << "\blue You grab the [initial(name)] with both hands, It is ready for use."

			var/obj/item/weapon/offhand/O = new /obj/item/weapon/offhand(user) ////Let's reserve his other hand~
			O.name = text("[initial(src.name)] - Offhand")
			O.desc = "Your second grip on the [initial(src.name)]"
			if(user.hand)
				user.r_hand = O          ///Place dat offhand in the opposite hand
			else
				user.l_hand = O
			O.layer = 20
			return

/obj/item/proc/attack(mob/living/M as mob, mob/living/user as mob, def_zone)

	if (!istype(M)) // not sure if this is the right thing...
		return
	var/messagesource = M

	if (istype(M,/mob/living/carbon/brain))
		messagesource = M:container
	if (src.hitsound)
		playsound(src.loc, hitsound, 50, 1, -1)
	/////////////////////////
	user.lastattacked = M
	M.lastattacker = user

	user.attack_log += "\[[time_stamp()]\]<font color='red'> Attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>"
	M.attack_log += "\[[time_stamp()]\]<font color='orange'> Attacked by [user.name] ([user.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>"

	//spawn(1800)            // this wont work right
	//	M.lastattacker = null
	/////////////////////////

	var/power = src.force
	if(!istype(M, /mob/living/carbon/human))
		if(istype(M, /mob/living/carbon/metroid))
			var/mob/living/carbon/metroid/Metroid = M
			if(prob(25))
				user << "\red [src] passes right through [M]!"
				return

			if(power > 0)
				Metroid.attacked += 10

			if(power >= 3)
				if(istype(Metroid, /mob/living/carbon/metroid/adult))
					if(prob(5 + round(power/2)))

						if(Metroid.Victim)
							if(prob(80) && !Metroid.client)
								Metroid.Discipline++
						Metroid.Victim = null
						Metroid.anchored = 0

						if(prob(80) && !Metroid.client)
							Metroid.Discipline++

						spawn()
							Metroid.SStun = 1
							sleep(rand(5,20))
							Metroid.SStun = 0

						spawn(0)
							Metroid.canmove = 0
							step_away(Metroid, user)
							if(prob(25 + power*2))
								sleep(2)
								step_away(Metroid, user)
							Metroid.canmove = 1

				else
					if(prob(10 + power*2))

						if(Metroid.Victim)
							if(prob(80) && !Metroid.client)
								Metroid.Discipline++

								if(Metroid.Discipline == 1)
									Metroid.attacked = 0

							spawn()
								Metroid.SStun = 1
								sleep(rand(5,20))
								Metroid.SStun = 0

						Metroid.Victim = null
						Metroid.anchored = 0


						spawn(0)
							step_away(Metroid, user)
							Metroid.canmove = 0
							if(prob(25 + power*4))
								sleep(2)
								step_away(Metroid, user)
							Metroid.canmove = 1


		for(var/mob/O in viewers(messagesource, null))
			O.show_message(text("\red <B>[] has been attacked with [][] </B>", M, src, (user ? text(" by [].", user) : ".")), 1)



	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		if (ishuman(user) || isrobot(user) || ismonkey(user) || isalien(user))
			if (!( def_zone ))
				var/mob/user2 = user
				var/t = user2:zone_sel.selecting
				if ((t in list( "eyes", "mouth" )))
					t = "head"
				def_zone = ran_zone(t)
		var/datum/organ/external/affecting
		if (H.organs[text("[]", def_zone)])
			affecting = H.organs[text("[]", def_zone)]
		var/hit_area = parse_zone(def_zone)

		var/list/armor = H.getarmor(affecting, "melee")
		//Grabbing the set of clothing that offers the best protective value against melee attacks to that area. --NEO

		for(var/mob/O in viewers(M, null))
			O.show_message(text("\red <B>[] has been attacked in the [] with [][] </B>", M, hit_area, src, (user ? text(" by [].", user) : ".")), 1)
		if (istype(affecting, /datum/organ/external))
			var/b_dam = (src.damtype == "brute" ? src.force : 0)
			var/f_dam = (src.damtype == "fire" ? src.force : 0)
			if (M.mutations & COLD_RESISTANCE)
				f_dam = 0
			if (def_zone == "head")
				if (b_dam && prob(armor["armor"] - src.force))
					if (prob(20))
						affecting.take_damage(power, 0)
					else
						H.show_message("\red Your [armor["clothes"]] has protected you from a hit to the head.")
					return
				if ((b_dam && prob(src.force + affecting.brute_dam + affecting.burn_dam)))
					var/time = rand(10, 120)
					if (prob(90))
						if (H.paralysis < time)
							H.paralysis = time
					else
						if (H.weakened < time)
							H.weakened = time
					if(H.stat != 2)	H.stat = 1
					for(var/mob/O in viewers(M, null))
						O.show_message(text("\red <B>[] has been knocked unconscious!</B>", H), 1, "\red You hear someone fall.", 2)
					if (prob(50))
						if (/*ticker.mode.name == "revolution" && */ M != user)
							ticker.mode.remove_revolutionary(H.mind)
				if (b_dam && prob(25 + (b_dam * 2)))
					src.add_blood(H)
					if (prob(33))
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
								user2.w_uniform.add_blood(H)
				affecting.take_damage(b_dam, f_dam)
			else if (def_zone == "chest" || def_zone == "groin")
				if (b_dam && prob(armor["armor"] - src.force))
					H.show_message("\red Your [armor["clothes"]] has protected you from a hit to the [affecting.name].")
					return
				if (b_dam && ((istype(H.r_hand, /obj/item/weapon/shield/riot))) && prob(90 - src.force))
					H.show_message("\red You have been protected from a hit to the [affecting.name].")
					return
				if (b_dam && ((istype(H.l_hand, /obj/item/weapon/shield/riot))) && prob(90 - src.force))
					H.show_message("\red You have been protected from a hit to the [affecting.name].")
					return
				if ((b_dam && prob(src.force + affecting.brute_dam + affecting.burn_dam)))
					if (prob(50))
						if (H.weakened < 5)
							H.weakened = 5
						for(var/mob/O in viewers(H, null))
							O.show_message(text("\red <B>[] has been knocked down!</B>", H), 1, "\red You hear someone fall.", 2)
					else
						if (H.stunned < 2)
							H.stunned = 2
						for(var/mob/O in viewers(H, null))
							O.show_message(text("\red <B>[] has been stunned!</B>", H), 1)
						if(H.stat != 2)	H.stat = 1
				if (b_dam && prob(25 + (b_dam * 2)))
					src.add_blood(H)
					if (prob(33))
						var/turf/location = H.loc
						if (istype(location, /turf/simulated))
							location.add_blood(H)
					if (H.wear_suit)
						H.wear_suit.add_blood(H)
					if (H.w_uniform)
						H.w_uniform.add_blood(H)
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
								user2.w_uniform.add_blood(H)
				affecting.take_damage(b_dam, f_dam)
			else
				if (b_dam && prob(armor["armor"] - src.force))
					H.show_message("\red Your [armor["clothes"]] has protected you from a hit to the [affecting.name].")
					return
				if (b_dam && prob(25 + (b_dam * 2)))
					src.add_blood(H)
					if (prob(33))
						var/turf/location = H.loc
						if (istype(location, /turf/simulated))
							location.add_blood(H)
					if (H.wear_suit)
						H.wear_suit.add_blood(H)
					if (H.w_uniform)
						H.w_uniform.add_blood(H)
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
								user2.w_uniform.add_blood(H)
				affecting.take_damage(b_dam, f_dam)
		H.UpdateDamageIcon()                     ///Only reference I can find on the attack() proc actually changing mob icon -Agouri
	else
		switch(src.damtype)
			if("brute")
				if(istype(src, /mob/living/carbon/metroid))
					M.bruteloss += power

				else

					M.take_organ_damage(power)
					if (prob(33)) // Added blood for whacking non-humans too
						var/turf/location = M.loc
						if (istype(location, /turf/simulated))
							location.add_blood_floor(M)
			if("fire")
				if (!(M.mutations & COLD_RESISTANCE))
					M.take_organ_damage(0, power)
					M << "Aargh it burns!"
		M.updatehealth()
	src.add_fingerprint(user)
	return 1

/obj/item/proc/eyestab(mob/living/carbon/M as mob, mob/living/carbon/user as mob)

	var/mob/living/carbon/human/H = M
	if(istype(H) && ( \
			(H.head && H.head.flags & HEADCOVERSEYES) || \
			(H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || \
			(H.glasses && H.glasses.flags & GLASSESCOVERSEYES) \
		))
		// you can't stab someone in the eyes wearing a mask!
		user << "\red You're going to need to remove that mask/helmet/glasses first."
		return

	var/mob/living/carbon/monkey/Mo = M
	if(istype(Mo) && ( \
			(Mo.wear_mask && Mo.wear_mask.flags & MASKCOVERSEYES) \
		))
		// you can't stab someone in the eyes wearing a mask!
		user << "\red You're going to need to remove that mask/helmet/glasses first."
		return

	if(istype(M, /mob/living/carbon/alien) || istype(M, /mob/living/carbon/metroid))//Aliens don't have eyes./N     Metroids also don't have eyes!
		user << "\red You cannot locate any eyes on this creature!"
		return

	user.attack_log += "\[[time_stamp()]\]<font color='red'> Attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>"
	M.attack_log += "\[[time_stamp()]\]<font color='orange'> Attacked by [user.name] ([user.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>"

	src.add_fingerprint(user)
	//if((user.mutations & CLOWN) && prob(50))
	//	M = user
		/*
		M << "\red You stab yourself in the eye."
		M.sdisabilities |= 1
		M.weakened += 4
		M.bruteloss += 10
		*/
	if(M != user)
		for(var/mob/O in (viewers(M) - user - M))
			O.show_message("\red [M] has been stabbed in the eye with [src] by [user].", 1)
		M << "\red [user] stabs you in the eye with [src]!"
		user << "\red You stab [M] in the eye with [src]!"
	else
		user.visible_message( \
			"\red [user] has stabbed themself with [src]!", \
			"\red You stab yourself in the eyes with [src]!" \
		)
	if(istype(M, /mob/living/carbon/human))
		var/datum/organ/external/affecting = M:organs["head"]
		affecting.take_damage(7)
	else
		M.take_organ_damage(7)
	M.eye_blurry += rand(3,4)
	M.eye_stat += rand(2,4)
	if (M.eye_stat >= 10)
		M.eye_blurry += 15+(0.1*M.eye_blurry)
		M.disabilities |= 1
		if(M.stat != 2)
			M << "\red Your eyes start to bleed profusely!"
		if(prob(50))
			if(M.stat != 2)
				M << "\red You drop what you're holding and clutch at your eyes!"
				M.drop_item()
			M.eye_blurry += 10
			M.paralysis += 1
			M.weakened += 4
		if (prob(M.eye_stat - 10 + 1))
			if(M.stat != 2)
				M << "\red You go blind!"
			M.sdisabilities |= 1
	return


