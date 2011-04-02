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
	if(!istype(M, /mob))
		return

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




// ROLLING PIN

/obj/item/weapon/kitchen/rollingpin/attack(mob/M as mob, mob/user as mob)
	if ((usr.mutations & 16) && prob(50))
		usr << "\red The [src] slips out of your hand and hits your head."
		usr.bruteloss += 10
		usr.paralysis += 2
		return
	if (M.stat < 2 && M.health < 50 && prob(90))
		var/mob/H = M
		// ******* Check
		if ((istype(H, /mob/living/carbon/human) && istype(H, /obj/item/clothing/head) && H.flags & 8 && prob(80)))
			M << "\red The helmet protects you from being hit hard in the head!"
			return
		var/time = rand(2, 6)
		if (prob(75))
			if (M.paralysis < time && (!(M.mutations & 8)) )
				M.paralysis = time
		else
			if (M.stunned < time && (!(M.mutations & 8)) )
				M.stunned = time
		if(M.stat != 2)	M.stat = 1
		for(var/mob/O in viewers(M, null))
			O.show_message(text("\red <B>[] has been knocked unconscious!</B>", M), 1, "\red You hear someone fall.", 2)
	else
		M << text("\red [] tried to knock you unconcious!",user)
		M.eye_blurry += 3

	return





// KNIFE

/obj/item/weapon/kitchen/utensil/knife/attack(target as mob, mob/user as mob)
	if ((usr.mutations & 16) && prob(50))
		usr << "\red You accidentally cut yourself with the [src]."
		usr.bruteloss += 20
		return

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////// TRAY -Agouri :3   ///////////////////////////////////////////////

/obj/item/weapon/tray/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if((usr.mutations & 16) && prob(50))              //What if he's a clown?
		M << "\red You accidentally slam yourself with the [src]!"
		M.weakened += 1
		M.bruteloss += 2
		if(prob(50))
			playsound(M, 'trayhit1.wav', 50, 1)
			return
		else
			playsound(M, 'trayhit2.wav', 50, 1) //sound playin'
			return //it always returns, but I feel like adding an extra return just for safety's sakes. EDIT; Oh well I won't :3


	if(!(user.zone_sel.selecting == ("eyes" || "head"))) //////////////hitting anything else other than the eyes
		if(prob(15))
			M.weakened += 3
			M.bruteloss += 3
		else
			M.bruteloss +=5
		if(prob(50))
			playsound(M, 'trayhit1.wav', 50, 1)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red [] slams [] with the tray!", user, M), 1)
			return
		else
			playsound(M, 'trayhit2.wav', 50, 1)  //we applied the damage, we played the sound, we showed the appropriate messages. Time to return and stop the proc
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red [] slams [] with the tray!", user, M), 1)
			return



	var/mob/living/carbon/human/H = M      ///////////////////////////////////// //Oh boy, guy chose to attack the eyes! Let's prepare a new variable!
	if(istype(M, /mob/living/carbon/human) && ((H.head && H.head.flags & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || (H.glasses && H.glasses.flags & GLASSESCOVERSEYES)))
		M << "\red You get slammed in the face with the tray, against your mask!"
		if(prob(50))
			playsound(M, 'trayhit1.wav', 50, 1)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red [] slams [] with the tray!", user, M), 1)
		else
			playsound(M, 'trayhit2.wav', 50, 1)  //sound playin'
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red [] slams [] with the tray!", user, M), 1)
		if(prob(10))
			M.stunned = rand(1,3)
			M.bruteloss += 3
			return
		else
			M.bruteloss +=5
			return

	else //No eye or head protection, tough luck!
		M << "\red You get slammed in the face with the tray!"
		if(prob(50))
			playsound(M, 'trayhit1.wav', 50, 1)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red [] slams [] in the face with the tray!", user, M), 1)
		else
			playsound(M, 'trayhit2.wav', 50, 1)  //sound playin' again
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red [] slams [] in the face with the tray!", user, M), 1)
		if(prob(30))
			M.stunned = rand(2,4)
			M.bruteloss +=4
			return
		else
			M.bruteloss +=8
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