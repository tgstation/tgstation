/*##################################################################
##################### TWO HANDED WEAPONS BE HERE~ -Agouri :3 ########
####################################################################*/

///General Offhand object properties///


////////////FIREAXE!//////////////


/obj/item/weapon/fireaxe/update_icon()  //Currently only here to fuck with the on-mob icons.
	src.icon_state = text("fireaxe[]",src.wielded)
	return

/obj/item/weapon/fireaxe/pickup(mob/user)
	src.wielded = 0
	src.name = "Fire Axe (Unwielded)"


/obj/item/weapon/fireaxe/attack_self(mob/user as mob)
	if( istype(user,/mob/living/carbon/monkey) )
		user << "\red It's too heavy for you to fully wield"
		return

//welp, all is good, now to see if he's trying do twohandedly wield it or unwield it


	if(src.wielded == 0) //He's trying to wield it!!

		if( user.hand ) ///User hand appears to be 1 if you're using the Left one and 0 if you're using the right? I don't even KNOW
			if(user.r_hand != null)
				user << "\red You need your right hand to be empty"
				return
		else
			if(user.l_hand != null)
				user << "\red You need your left hand to be empty"
				return
		user << "\blue You grab the hilt of the axe and raise it to your torso, readying it for use."
		src.wielded = !src.wielded
		src.force = 30
		src.name = "Fire axe (Wielded)"
		src.update_icon()

		var/obj/item/weapon/offhand/O = new /obj/item/weapon/offhand(user) ////Let's reserve his other hand~
		O.name = text("[]-Offhand",src.name)
		O.desc = "Your second grip on the Fire axe"

		if(user.hand)
			user.r_hand = O          ///Place dat offhand in the opposite hand
		else
			user.l_hand = O
		O.layer = 20
		return


	if(src.wielded == 1) //Guy's bored of robusting and now wants to carry it
		src.wielded = !src.wielded
		src.force = 5
		src.name = "Fire axe (Unwielded)"
		src.update_icon()
		user << "\blue You are now carrying the axe with one hand."

		if(user.hand)  //Now let's free up his other hand
			var/obj/item/weapon/offhand/O = user.r_hand
			del O
		else
			var/obj/item/weapon/offhand/O = user.l_hand
			del O
		return