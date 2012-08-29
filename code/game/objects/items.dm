/obj/item
	name = "item"
	icon = 'icons/obj/items.dmi'
	var/icon/blood_overlay = null //this saves our blood splatter overlay, which will be processed not to go over the edges of the sprite
	var/abstract = 0
	var/force = 0
	var/item_state = null
	var/damtype = "brute"
	var/r_speed = 1.0
	var/health = null
	var/burn_point = null
	var/burning = null
	var/hitsound = null
	var/w_class = 3.0
	flags = FPRINT | TABLEPASS
	var/slot_flags = 0		//This is used to determine on which slots an item can fit.
	pass_flags = PASSTABLE
	pressure_resistance = 50
//	causeerrorheresoifixthis
	var/obj/item/master = null

	var/heat_protection = 0 //flags which determine which body parts are protected from heat. Use the HEAD, UPPER_TORSO, LOWER_TORSO, etc. flags. See setup.dm
	var/cold_protection = 0 //flags which determine which body parts are protected from cold. Use the HEAD, UPPER_TORSO, LOWER_TORSO, etc. flags. See setup.dm
	var/max_heat_protection_temperature //Set this variable to determine up to which temperature (IN KELVIN) the item protects against heat damage. Keep at null to disable protection. Only protects areas set by heat_protection flags
	var/min_cold_protection_temperature //Set this variable to determine down to which temperature (IN KELVIN) the item protects against cold damage. 0 is NOT an acceptable number due to if(varname) tests!! Keep at null to disable protection. Only protects areas set by cold_protection flags

	var/icon_action_button //If this is set, The item will make an action button on the player's HUD when picked up. The button will have the icon_action_button sprite from the screen1_action.dmi file.
	var/action_button_name //This is the text which gets displayed on the action button. If not set it defaults to 'Use [name]'. Note that icon_action_button needs to be set in order for the action button to appear.

	//Since any item can now be a piece of clothing, this has to be put here so all items share it.
	var/flags_inv //This flag is used to determine when items in someone's inventory cover others. IE helmets making it so you can't see glasses, etc.
	var/color = null
	var/body_parts_covered = 0 //see setup.dm for appropriate bit flags
	//var/heat_transfer_coefficient = 1 //0 prevents all transfers, 1 is invisible
	var/gas_transfer_coefficient = 1 // for leaking gas from turf to mask and vice-versa (for masks right now, but at some point, i'd like to include space helmets)
	var/permeability_coefficient = 1 // for chemicals/diseases
	var/siemens_coefficient = 1 // for electrical admittance/conductance (electrocution checks and shit)
	var/slowdown = 0 // How much clothing is slowing you down. Negative values speeds you up
	var/canremove = 1 //Mostly for Ninja code at this point but basically will not allow the item to be removed if set to 0. /N
	var/armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	var/list/allowed = null //suit storage stuff.
	var/obj/item/device/uplink/hidden/hidden_uplink = null // All items can have an uplink hidden inside, just remember to add the triggers.


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
	if ((CLUMSY in usr.mutations) && prob(50)) t = "funny-looking"
	usr << text("This is a []\icon[][]. It is a [] item.", !src.blood_DNA ? "" : "bloody ",src, src.name, t)
	if(src.desc)
		usr << src.desc
	return

/obj/item/attack_hand(mob/user as mob)
	if (!user) return
	if (istype(src.loc, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = src.loc
		S.remove_from_storage(src)

	src.throwing = 0
	if (src.loc == user)
		//canremove==0 means that object may not be removed. You can still wear it. This only applies to clothing. /N
		if(!src.canremove)
			return
		else
			user.u_equip(src)
	else
		if(isliving(src.loc))
			return
		src.pickup(user)
		user.lastDblClick = world.time + 2
		user.next_move = world.time + 2
	add_fingerprint(user)
	user.put_in_active_hand(src)
	return


/obj/item/attack_paw(mob/user as mob)

	if(isalien(user)) // -- TLE
		var/mob/living/carbon/alien/A = user

		if(!A.has_fine_manipulation || w_class >= 4)
			if(src in A.contents) // To stop Aliens having items stuck in their pockets
				A.drop_from_inventory(src)
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
	else
		if(istype(src.loc, /mob/living))
			return
		src.pickup(user)
		user.lastDblClick = world.time + 2
		user.next_move = world.time + 2

	user.put_in_active_hand(src)
	return

/obj/item/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(istype(W,/obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = W
		if(S.use_to_pickup)
			if(!S.can_be_inserted(src))
				return
			if(S.collection_mode) //Mode is set to collect all items on a tile and we clicked on a valid one.
				if(isturf(src.loc))
					for(var/obj/item/I in src.loc)
						if(I != src) //We'll do the one we clicked on last.
							if(!S.can_be_inserted(I))
								continue
							S.handle_item_insertion(I, 1)	//The 1 stops the "You put the [src] into [S]" insertion message from being displayed.
			S.handle_item_insertion(src)


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

	user.attack_log += "\[[time_stamp()]\]<font color='red'> Attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(src.damtype)])</font>"
	M.attack_log += "\[[time_stamp()]\]<font color='orange'> Attacked by [user.name] ([user.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(src.damtype)])</font>"
	log_attack("<font color='red'>[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(src.damtype)])</font>" )

	//spawn(1800)            // this wont work right
	//	M.lastattacker = null
	/////////////////////////

	var/power = src.force
	if((HULK in user.mutations) || (SUPRSTR in user.augmentations))
		power *= 2

	if(!istype(M, /mob/living/carbon/human))
		if(istype(M, /mob/living/carbon/metroid))
			var/mob/living/carbon/metroid/Metroid = M
			if(prob(25))
				user << "\red [src] passes right through [M]!"
				return

			if(power > 0)
				Metroid.attacked += 10

			if(Metroid.Discipline && prob(50))	// wow, buddy, why am I getting attacked??
				Metroid.Discipline = 0

			if(power >= 3)
				if(istype(Metroid, /mob/living/carbon/metroid/adult))
					if(prob(5 + round(power/2)))

						if(Metroid.Victim)
							if(prob(80) && !Metroid.client)
								Metroid.Discipline++
						Metroid.Victim = null
						Metroid.anchored = 0

						spawn()
							if(Metroid)
								Metroid.SStun = 1
								sleep(rand(5,20))
								if(Metroid)
									Metroid.SStun = 0

						spawn(0)
							if(Metroid)
								Metroid.canmove = 0
								step_away(Metroid, user)
								if(prob(25 + power))
									sleep(2)
									if(Metroid && user)
										step_away(Metroid, user)
								Metroid.canmove = 1

				else
					if(prob(10 + power*2))
						if(Metroid)
							if(Metroid.Victim)
								if(prob(80) && !Metroid.client)
									Metroid.Discipline++

									if(Metroid.Discipline == 1)
										Metroid.attacked = 0

								spawn()
									if(Metroid)
										Metroid.SStun = 1
										sleep(rand(5,20))
										if(Metroid)
											Metroid.SStun = 0

							Metroid.Victim = null
							Metroid.anchored = 0


						spawn(0)
							if(Metroid && user)
								step_away(Metroid, user)
								Metroid.canmove = 0
								if(prob(25 + power*4))
									sleep(2)
									if(Metroid && user)
										step_away(Metroid, user)
								Metroid.canmove = 1


		var/showname = "."
		if(user)
			showname = " by [user]."
		if(!(user in viewers(M, null)))
			showname = "."

		for(var/mob/O in viewers(messagesource, null))
			if(src.attack_verb.len)
				O.show_message("\red <B>[M] has been [pick(src.attack_verb)] with [src][showname] </B>", 1)
			else
				O.show_message("\red <B>[M] has been attacked with [src][showname] </B>", 1)

		if(!showname && user)
			if(user.client)
				user << "\red <B>You attack [M] with [src]. </B>"



	if(istype(M, /mob/living/carbon/human))
		M:attacked_by(src, user, def_zone)
	else
		switch(src.damtype)
			if("brute")
				if(istype(src, /mob/living/carbon/metroid))
					M.adjustBrainLoss(power)

				else

					M.take_organ_damage(power)
					if (prob(33)) // Added blood for whacking non-humans too
						var/turf/location = M.loc
						if (istype(location, /turf/simulated))
							location.add_blood_floor(M)
			if("fire")
				if (!(COLD_RESISTANCE in M.mutations))
					M.take_organ_damage(0, power)
					M << "Aargh it burns!"
		M.updatehealth()
	src.add_fingerprint(user)
	return 1

/obj/item/proc/attack_self()
	return

/obj/item/proc/afterattack()
	return

/obj/item/proc/talk_into(mob/M as mob, text)
	return

/obj/item/proc/moved(mob/user as mob, old_loc as turf)
	return

/obj/item/proc/dropped(mob/user as mob)
	..()

// called just as an item is picked up (loc is not yet changed)
/obj/item/proc/pickup(mob/user)
	return

// called when this item is removed from a storage item, which is passed on as S. The loc variable is already set to the new destination before this is called.
/obj/item/proc/on_exit_storage(obj/item/weapon/storage/S as obj)
	return

// called when this item is added into a storage item, which is passed on as S. The loc variable is already set to the storage item.
/obj/item/proc/on_enter_storage(obj/item/weapon/storage/S as obj)
	return

// called after an item is placed in an equipment slot
// user is mob that equipped it
// slot uses the slot_X defines found in setup.dm
// for items that can be placed in multiple slots
// note this isn't called during the initial dressing of a player
/obj/item/proc/equipped(var/mob/user, var/slot)
	return

//the mob M is attempting to equip this item into the slot passed through as 'slot'. Return 1 if it can do this and 0 if it can't.
//If you are making custom procs but would like to retain partial or complete functionality of this one, include a 'return ..()' to where you want this to happen.
//Set disable_warning to 1 if you wish it to not give you outputs.
/obj/item/proc/mob_can_equip(M as mob, slot, disable_warning = 0)
	if(!slot) return 0
	if(!M) return 0

	if(ishuman(M))
		//START HUMAN
		var/mob/living/carbon/human/H = M

		if(FAT in H.mutations)
			if(!(flags & ONESIZEFITSALL))
				if(!disable_warning)
					H << "\red You're too fat to wear the [name]."
				return 0

		switch(slot)
			if(slot_l_hand)
				if(H.l_hand)
					return 0
				return 1
			if(slot_r_hand)
				if(H.r_hand)
					return 0
				return 1
			if(slot_wear_mask)
				if(H.wear_mask)
					return 0
				if( !(slot_flags & SLOT_MASK) )
					return 0
				return 1
			if(slot_back)
				if(H.back)
					return 0
				if( !(slot_flags & SLOT_BACK) )
					return 0
				return 1
			if(slot_wear_suit)
				if(H.wear_suit)
					return 0
				if( !(slot_flags & SLOT_OCLOTHING) )
					return 0
				return 1
			if(slot_gloves)
				if(H.gloves)
					return 0
				if( !(slot_flags & SLOT_GLOVES) )
					return 0
				return 1
			if(slot_shoes)
				if(H.shoes)
					return 0
				if( !(slot_flags & SLOT_FEET) )
					return 0
				return 1
			if(slot_belt)
				if(H.belt)
					return 0
				if(!H.w_uniform)
					if(!disable_warning)
						H << "\red You need a jumpsuit before you can attach this [name]."
					return 0
				if( !(slot_flags & SLOT_BELT) )
					return
				return 1
			if(slot_glasses)
				if(H.glasses)
					return 0
				if( !(slot_flags & SLOT_EYES) )
					return 0
				return 1
			if(slot_head)
				if(H.head)
					return 0
				if( !(slot_flags & SLOT_HEAD) )
					return 0
				return 1
			if(slot_ears)
				if(H.ears)
					return 0
				if( !(slot_flags & SLOT_EARS) )
					return 0
				return 1
			if(slot_w_uniform)
				if(H.w_uniform)
					return 0
				if( !(slot_flags & SLOT_ICLOTHING) )
					return 0
				return 1
			if(slot_wear_id)
				if(H.wear_id)
					return 0
				if(!H.w_uniform)
					if(!disable_warning)
						H << "\red You need a jumpsuit before you can attach this [name]."
					return 0
				if( !(slot_flags & SLOT_ID) )
					return 0
				return 1
			if(slot_l_store)
				if(H.l_store)
					return 0
				if(!H.w_uniform)
					if(!disable_warning)
						H << "\red You need a jumpsuit before you can attach this [name]."
					return 0
				if(slot_flags & SLOT_DENYPOCKET)
					return
				if( w_class <= 2 || (slot_flags & SLOT_POCKET) )
					return 1
			if(slot_r_store)
				if(H.r_store)
					return 0
				if(!H.w_uniform)
					if(!disable_warning)
						H << "\red You need a jumpsuit before you can attach this [name]."
					return 0
				if(slot_flags & SLOT_DENYPOCKET)
					return 0
				if( w_class <= 2 || (slot_flags & SLOT_POCKET) )
					return 1
				return 0
			if(slot_s_store)
				if(H.s_store)
					return 0
				if(!H.wear_suit)
					if(!disable_warning)
						H << "\red You need a suit before you can attach this [name]."
					return 0
				if(!H.wear_suit.allowed)
					if(!disable_warning)
						usr << "You somehow have a suit with no defined allowed items for suit storage, stop that."
					return 0
				if( istype(src, /obj/item/device/pda) || istype(src, /obj/item/weapon/pen) || is_type_in_list(src, H.wear_suit.allowed) )
					return 1
				return 0
			if(slot_handcuffed)
				if(H.handcuffed)
					return 0
				if(!istype(src, /obj/item/weapon/handcuffs))
					return 0
				return 1
			if(slot_legcuffed)
				if(H.legcuffed)
					return 0
				if(!istype(src, /obj/item/weapon/legcuffs))
					return 0
				return 1
			if(slot_in_backpack)
				if (H.back && istype(H.back, /obj/item/weapon/storage/backpack))
					var/obj/item/weapon/storage/backpack/B = H.back
					if(B.contents.len < B.storage_slots && w_class <= B.max_w_class)
						return 1
				return 0
		return 0 //Unsupported slot
		//END HUMAN

	else if(ismonkey(M))
		//START MONKEY
		var/mob/living/carbon/monkey/MO = M
		switch(slot)
			if(slot_l_hand)
				if(MO.l_hand)
					return 0
				return 1
			if(slot_r_hand)
				if(MO.r_hand)
					return 0
				return 1
			if(slot_wear_mask)
				if(MO.wear_mask)
					return 0
				if( !(slot_flags & SLOT_MASK) )
					return 0
				return 1
			if(slot_back)
				if(MO.back)
					return 0
				if( !(slot_flags & SLOT_BACK) )
					return 0
				return 1
		return 0 //Unsupported slot

		//END MONKEY


/obj/item/verb/verb_pickup()
	set src in oview(1)
	set category = "Object"
	set name = "Pick up"

	if(!(usr)) //BS12 EDIT
		return
	if((!istype(usr, /mob/living/carbon)) || (istype(usr, /mob/living/carbon/brain)))//Is humanoid, and is not a brain
		usr << "\red You can't pick things up!"
		return
	if( usr.stat || usr.restrained() )//Is not asleep/dead and is not restrained
		usr << "\red You can't pick things up!"
		return
	if(src.anchored) //Object isn't anchored
		usr << "\red You can't pick that up!"
		return
	if(!usr.hand && usr.r_hand) //Right hand is not full
		usr << "\red Your right hand is full."
		return
	if(usr.hand && usr.l_hand) //Left hand is not full
		usr << "\red Your left hand is full."
		return
	if(!istype(src.loc, /turf)) //Object is on a turf
		usr << "\red You can't pick that up!"
		return
	//All checks are done, time to pick it up!
	if(istype(usr, /mob/living/carbon/human))
		src.attack_hand(usr)
	if(istype(usr, /mob/living/carbon/alien))
		src.attack_alien(usr)
	if(istype(usr, /mob/living/carbon/monkey))
		src.attack_paw(usr)
	return


//This proc is executed when someone clicks the on-screen UI button. To make the UI button show, set the 'icon_action_button' to the icon_state of the image of the button in screen1_action.dmi
//The default action is attack_self().
//Checks before we get to here are: mob is alive, mob is not restrained, paralyzed, asleep, resting, laying, item is on the mob.
/obj/item/proc/ui_action_click()
	if( src in usr )
		attack_self(usr)


/obj/item/proc/IsShield()
	return 0

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

	log_attack("<font color='red'> [user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")

	src.add_fingerprint(user)
	//if((CLUMSY in user.mutations) && prob(50))
	//	M = user
		/*
		M << "\red You stab yourself in the eye."
		M.sdisabilities |= BLIND
		M.weakened += 4
		M.adjustBruteLoss(10)
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
		var/datum/organ/external/affecting = M:get_organ("head")
		if(affecting.take_damage(7))
			M:UpdateDamageIcon()
	else
		M.take_organ_damage(7)
	M.eye_blurry += rand(3,4)
	M.eye_stat += rand(2,4)
	if (M.eye_stat >= 10)
		M.eye_blurry += 15+(0.1*M.eye_blurry)
		M.disabilities |= NEARSIGHTED
		if(M.stat != 2)
			M << "\red Your eyes start to bleed profusely!"
		if(prob(50))
			if(M.stat != 2)
				M << "\red You drop what you're holding and clutch at your eyes!"
				M.drop_item()
			M.eye_blurry += 10
			M.Paralyse(1)
			M.Weaken(4)
		if (prob(M.eye_stat - 10 + 1))
			if(M.stat != 2)
				M << "\red You go blind!"
			M.sdisabilities |= BLIND
	return