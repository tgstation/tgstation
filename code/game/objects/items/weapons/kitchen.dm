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

/obj/item/weapon/kitchen/utensil/fork/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return ..()

	if(user.zone_sel.selecting != "eyes" && user.zone_sel.selecting != "head")
		return ..()

	if (src.icon_state == "forkloaded") //This is a poor way of handling it, but a proper rewrite of the fork to allow for a more varied foodening can happen when I'm in the mood. --NEO
		if(M == user)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\blue [] eats a delicious forkful of omelette!", user), 1)
				M.reagents.add_reagent("nutriment", 1)
		else
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\blue [] feeds [] a delicious forkful of omelette!", user, M), 1)
				M.reagents.add_reagent("nutriment", 1)
		src.icon_state = "fork"
		return
	else
		if((user.mutations & CLOWN) && prob(50))
			M = user
		return eyestab(M,user)




// ROLLING PIN

/obj/item/weapon/kitchen/rollingpin/attack(mob/M as mob, mob/living/user as mob)
	if ((user.mutations & CLOWN) && prob(50))
		user << "\red The [src] slips out of your hand and hits your head."
		user.take_organ_damage(10)
		user.paralysis += 2
		return
	if (M.stat < 2 && M.health < 50 && prob(90))
		var/mob/H = M
		// ******* Check
		if ((istype(H, /mob/living/carbon/human) && istype(H, /obj/item/clothing/head) && H.flags & 8 && prob(80)))
			M << "\red The helmet protects you from being hit hard in the head!"
			return
		var/time = rand(2, 6)
		if (prob(75))
			if (M.paralysis < time && (!(M.mutations & HULK)) )
				M.paralysis = time
		else
			if (M.stunned < time && (!(M.mutations & HULK)) )
				M.stunned = time
		if(M.stat != 2)	M.stat = 1
		for(var/mob/O in viewers(M, null))
			O.show_message(text("\red <B>[] has been knocked unconscious!</B>", M), 1, "\red You hear someone fall.", 2)
	else
		M << text("\red [] tried to knock you unconcious!",user)
		M.eye_blurry += 3

	return





// KNIFE

/obj/item/weapon/kitchen/utensil/knife/attack(target as mob, mob/living/user as mob)
	if ((user.mutations & CLOWN) && prob(50))
		user << "\red You accidentally cut yourself with the [src]."
		user.take_organ_damage(20)
		return
	return ..()
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////// TRAY -Agouri :3   ///////////////////////////////////////////////

/obj/item/weapon/tray/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if((user.mutations & CLOWN) && prob(50))              //What if he's a clown?
		M << "\red You accidentally slam yourself with the [src]!"
		M.weakened += 1
		user.take_organ_damage(2)
		if(prob(50))
			//playsound(M, 'trayhit1.wav', 50, 1)
			return
		else
			//playsound(M, 'trayhit2.wav', 50, 1) //sound playin'
			return //it always returns, but I feel like adding an extra return just for safety's sakes. EDIT; Oh well I won't :3

	var/mob/living/carbon/human/H = M      ///////////////////////////////////// /Let's have this ready for later.


	if(!(user.zone_sel.selecting == ("eyes" || "head"))) //////////////hitting anything else other than the eyes
		if(prob(33))
			src.add_blood(H)
			var/turf/location = H.loc
			if (istype(location, /turf/simulated))
				location.add_blood(H)     ///Plik plik, the sound of blood


		if(prob(15))
			M.weakened += 3
			M.take_organ_damage(3)
		else
			M.take_organ_damage(5)
		if(prob(50))
			//playsound(M, 'trayhit1.wav', 50, 1)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red <B>[] slams [] with the tray!</B>", user, M), 1)
			return
		else
			//playsound(M, 'trayhit2.wav', 50, 1)  //we applied the damage, we played the sound, we showed the appropriate messages. Time to return and stop the proc
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
			//playsound(M, 'trayhit1.wav', 50, 1)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red <B>[] slams [] with the tray!</B>", user, M), 1)
		else
			//playsound(M, 'trayhit2.wav', 50, 1)  //sound playin'
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red <B>[] slams [] with the tray!</B>", user, M), 1)
		if(prob(10))
			M.stunned = rand(1,3)
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
		//	playsound(M, 'trayhit1.wav', 50, 1)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red <B>[] slams [] in the face with the tray!</B>", user, M), 1)
		else
			//playsound(M, 'trayhit2.wav', 50, 1)  //sound playin' again
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red <B>[] slams [] in the face with the tray!</B>", user, M), 1)
		if(prob(30))
			M.stunned = rand(2,4)
			M.take_organ_damage(4)
			return
		else
			M.take_organ_damage(8)
			if(prob(30))
				M.weakened+=2
				return
			return

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