/obj/item
	name = "item"
	icon = 'icons/obj/items.dmi'
	var/image/blood_overlay = null //this saves our blood splatter overlay, which will be processed not to go over the edges of the sprite
	var/abstract = 0
	var/item_state = null
	var/list/inhand_states = list("left_hand" = 'icons/mob/in-hand/left/items_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/items_righthand.dmi')
	var/r_speed = 1.0
	var/health = null
	var/hitsound = null
	var/w_class = 3.0
	flags = FPRINT
	var/slot_flags = 0		//This is used to determine on which slots an item can fit.
	var/obj/item/offhand/wielded = null
	pass_flags = PASSTABLE
	pressure_resistance = 5
//	causeerrorheresoifixthis
	var/obj/item/master = null

	var/heat_protection = 0 //flags which determine which body parts are protected from heat. Use the HEAD, UPPER_TORSO, LOWER_TORSO, etc. flags. See setup.dm
	var/cold_protection = 0 //flags which determine which body parts are protected from cold. Use the HEAD, UPPER_TORSO, LOWER_TORSO, etc. flags. See setup.dm
	var/max_heat_protection_temperature //Set this variable to determine up to which temperature (IN KELVIN) the item protects against heat damage. Keep at null to disable protection. Only protects areas set by heat_protection flags
	var/min_cold_protection_temperature //Set this variable to determine down to which temperature (IN KELVIN) the item protects against cold damage. 0 is NOT an acceptable number due to if(varname) tests!! Keep at null to disable protection. Only protects areas set by cold_protection flags

	//If this is set, The item will make an action button on the player's HUD when picked up.
	var/action_button_name //It is also the text which gets displayed on the action button. If not set it defaults to 'Use [name]'. If it's not set, there'll be no button.

	//Since any item can now be a piece of clothing, this has to be put here so all items share it.
	var/flags_inv //This flag is used to determine when items in someone's inventory cover others. IE helmets making it so you can't see glasses, etc.
	var/_color = null
	var/body_parts_covered = 0 //see setup.dm for appropriate bit flags
	//var/heat_transfer_coefficient = 1 //0 prevents all transfers, 1 is invisible
	var/gas_transfer_coefficient = 1 // for leaking gas from turf to mask and vice-versa (for masks right now, but at some point, i'd like to include space helmets)
	var/permeability_coefficient = 1 // for chemicals/diseases
	siemens_coefficient = 1 // for electrical admittance/conductance (electrocution checks and shit) - 0 is not conductive, 1 is conductive - this is a range, not binary
	var/slowdown = 0 // How much clothing is slowing you down. Negative values speeds you up
	var/canremove = 1 //Mostly for Ninja code at this point but basically will not allow the item to be removed if set to 0. /N
	var/armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	var/list/allowed = null //suit storage stuff.
	var/obj/item/device/uplink/hidden/hidden_uplink = null // All items can have an uplink hidden inside, just remember to add the triggers.
	var/icon_override = null  //Used to override hardcoded clothing dmis in human clothing proc.
	var/list/species_fit = null //This object has a different appearance when worn by these species
	var/surgery_speed = 1 //When this item is used as a surgery tool, multiply the delay of the surgery step by this much.
	var/nonplant_seed_type

	var/list/attack_verb // used in attack() to say how something was attacked "[x] has been [z.attack_verb] by [y] with [z]"



	var/vending_cat = null// subcategory for vending machines.
	var/list/dynamic_overlay[25] //For items which need to slightly alter their on-mob appearance while being worn.

/obj/item/Destroy()
	if(istype(src.loc, /mob))
		var/mob/H = src.loc
		H.drop_from_inventory(src) // items at the very least get unequipped from their mob before being deleted
	if(hasvar(src, "holder"))
		src:holder = null
	/*  BROKEN, FUCK BYOND
	if(hasvar(src, "my_atom"))
		src:my_atom = null*/
	..()


	/* Species-specific sprite sheets for inventory sprites
	Works similarly to worn sprite_sheets, except the alternate sprites are used when the clothing/refit_for_species() proc is called.
	*/
	//var/list/sprite_sheets_obj = null

/obj/item/device
	icon = 'icons/obj/device.dmi'

/obj/item/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				qdel(src)
				return
		else
	return

/obj/item/blob_act()
	qdel(src)

/obj/item/projectile_check()
	return PROJREACT_OBJS

//user: The mob that is suiciding
//damagetype: The type of damage the item will inflict on the user
//BRUTELOSS = 1
//FIRELOSS = 2
//TOXLOSS = 4
//OXYLOSS = 8
//Output a creative message and then return the damagetype done
/obj/item/proc/suicide_act(mob/user)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/proc/suicide_act() called tick#: [world.time]")
	return

/obj/item/verb/move_to_top()
	set name = "Move To Top"
	set category = "Object"
	set src in oview(1)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""]) \\/obj/item/verb/move_to_top()  called tick#: [world.time]")

	if(!istype(src.loc, /turf) || usr.stat || usr.restrained()  || (usr.status_flags & FAKEDEATH))
		return

	var/turf/T = src.loc

	src.loc = null

	src.loc = T

/obj/item/examine(mob/user)
	var/size
	switch(src.w_class)
		if(1.0)
			size = "tiny"
		if(2.0)
			size = "small"
		if(3.0)
			size = "normal-sized"
		if(4.0)
			size = "bulky"
		if(5.0)
			size = "huge"
		else
	//if ((M_CLUMSY in usr.mutations) && prob(50)) t = "funny-looking"
	var/pronoun
	if (src.gender == PLURAL)
		pronoun = "They are"
	else
		pronoun = "It is"
	..(user, " [pronoun] a [size] item.")


/obj/item/attack_ai(mob/user as mob)
	..()
	if(isMoMMI(user))
		var/in_range = in_range(src, user) || src.loc == user
		if(in_range)
			if(src == user:tool_state || src == user:sight_state)
				return 0
			attack_hand(user)
	else if(isrobot(user))
		if(!istype(src.loc, /obj/item/weapon/robot_module)) return
		var/mob/living/silicon/robot/R = user
		R.activate_module(src)
		R.hud_used.update_robot_modules_display()

/obj/item/attack_hand(mob/user as mob)
	if (!user) return

	if (istype(src.loc, /obj/item/weapon/storage))
		//If the item is in a storage item, take it out.
		var/obj/item/weapon/storage/S = src.loc
		S.remove_from_storage(src, user)

	src.throwing = 0
	if (src.loc == user)
		if(src == user.get_inactive_hand())
			if(src.flags & TWOHANDABLE)
				return src.wield(user)
		//canremove==0 means that object may not be removed. You can still wear it. This only applies to clothing. /N
		if(!src.canremove)
			return
		else
			user.u_equip(src,0)
	else
		if(isliving(src.loc))
			return
		//user.next_move = max(user.next_move+2,world.time + 2)
		src.pickup(user)
	add_fingerprint(user)
	user.put_in_active_hand(src)
	return

/obj/item/requires_dexterity(mob/user)
	return 1

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
			user.u_equip(src,0)
	else
		if(istype(src.loc, /mob/living))
			return
		src.pickup(user)
		//user.next_move = max(user.next_move+2,world.time + 2)

	user.put_in_active_hand(src)
	return

// Due to storage type consolidation this should get used more now.
// I have cleaned it up a little, but it could probably use more.  -Sayu
/obj/item/attackby(obj/item/weapon/W as obj, mob/user as mob)
	return

/obj/item/proc/talk_into(mob/M as mob, var/text, var/channel=null)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/proc/talk_into() called tick#: [world.time]")
	return

/obj/item/proc/moved(mob/user as mob, old_loc as turf)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/proc/moved() called tick#: [world.time]")
	return

/obj/item/proc/dropped(mob/user as mob)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/proc/dropped() called tick#: [world.time]")
	layer = initial(layer) //nothing bad can come from this right?
	if(wielded)
		unwield(user)

///called when an item is stripped off by another person, called AFTER it is on the ground
/obj/item/proc/stripped(mob/wearer as mob, mob/stripper as mob)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/proc/stripped() called tick#: [world.time]")
	return unequipped(wearer)

// called just as an item is picked up (loc is not yet changed)
/obj/item/proc/pickup(mob/user)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/proc/pickup() called tick#: [world.time]")
	return

// called when this item is removed from a storage item, which is passed on as S. The loc variable is already set to the new destination before this is called.
/obj/item/proc/on_exit_storage(obj/item/weapon/storage/S as obj)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/proc/on_exit_storage() called tick#: [world.time]")
	return

// called when this item is added into a storage item, which is passed on as S. The loc variable is already set to the storage item.
/obj/item/proc/on_enter_storage(obj/item/weapon/storage/S as obj)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/proc/on_enter_storage() called tick#: [world.time]")
	return

// called when "found" in pockets and storage items. Returns 1 if the search should end.
/obj/item/proc/on_found(mob/finder as mob)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/proc/on_found() called tick#: [world.time]")
	return

// called after an item is placed in an equipment slot
// user is mob that equipped it
// slot uses the slot_X defines found in setup.dm
// for items that can be placed in multiple slots
// note this isn't called during the initial dressing of a player
/obj/item/proc/equipped(var/mob/user, var/slot)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/proc/equipped() called tick#: [world.time]")
	return

// called after an item is unequipped or stripped
/obj/item/proc/unequipped(mob/user)
	return

//the mob M is attempting to equip this item into the slot passed through as 'slot'. Return 1 if it can do this and 0 if it can't.
//If you are making custom procs but would like to retain partial or complete functionality of this one, include a 'return ..()' to where you want this to happen.
//Set disable_warning to 1 if you wish it to not give you outputs.
/obj/item/proc/mob_can_equip(mob/M, slot, disable_warning = 0, automatic = 0)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/proc/mob_can_equip() called tick#: [world.time]")
	if(!slot) return 0
	if(!M) return 0

	if(wielded)
		if(flags & MUSTTWOHAND)
			M.show_message("\The [src] is too cumbersome to carry in anything other than your hands.")
		else
			M.show_message("You have to unwield \the [wielded.wielding] first.")
		return 0

	if(ishuman(M))
		//START HUMAN
		var/mob/living/carbon/human/H = M

		if(istype(src, /obj/item/clothing/under) || istype(src, /obj/item/clothing/suit))
			if(M_FAT in H.mutations)
				testing("[M] TOO FAT TO WEAR [src]!")
				if(!(flags & ONESIZEFITSALL))
					if(!disable_warning)
						H << "<span class='warning'>You're too fat to wear the [name].</span>"
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
				if( !(slot_flags & SLOT_MASK) )
					return 0
				if(H.wear_mask)
					if(automatic)
						if(H.check_for_open_slot(src))
							return 0
					if(H.wear_mask.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_back)
				if( !(slot_flags & SLOT_BACK) )
					return 0
				if(H.back)
					if(automatic)
						if(H.check_for_open_slot(src))
							return 0
					if(H.back.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_wear_suit)
				if( !(slot_flags & SLOT_OCLOTHING) )
					return 0
				if(H.wear_suit)
					if(automatic)
						if(H.check_for_open_slot(src))
							return 0
					if(H.wear_suit.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_gloves)
				if( !(slot_flags & SLOT_GLOVES) )
					return 0
				if(H.gloves)
					if(automatic)
						if(H.check_for_open_slot(src))
							return 0
					if(H.gloves.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_shoes)
				if( !(slot_flags & SLOT_FEET) )
					return 0
				if(H.shoes)
					if(automatic)
						if(H.check_for_open_slot(src))
							return 0
					if(H.shoes.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_belt)
				if(!H.w_uniform)
					if(!disable_warning)
						H << "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>"
					return 0
				if( !(slot_flags & SLOT_BELT) )
					return 0
				if(H.belt)
					if(automatic)
						if(H.check_for_open_slot(src))
							return 0
					if(H.belt.canremove && !istype(H.belt, /obj/item/weapon/storage/belt))
						return 2
					else
						return 0
				return 1
			if(slot_glasses)
				if( !(slot_flags & SLOT_EYES) )
					return 0
				if(H.glasses)
					if(automatic)
						if(H.check_for_open_slot(src))
							return 0
					if(H.glasses.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_head)
				if( !(slot_flags & SLOT_HEAD) )
					return 0
				if(H.head)
					if(automatic)
						if(H.check_for_open_slot(src))
							return 0
					if(H.head.canremove)
						return 2
					else
						return 0
				return 1

			if(slot_ears)
				if( !(slot_flags & SLOT_EARS) )
					return 0
				if(H.ears)
					if(automatic)
						if(H.check_for_open_slot(src))
							return 0
					if(H.ears.canremove)
						return 2
					else
						return 0
				return 1
			/* In case it's ever unfucked.
			if(slot_ears)
				if( !(slot_flags & SLOT_EARS) )
					return 0
				if( (slot_flags & SLOT_TWOEARS) && H.r_ear )
					return 0
				if(H.l_ear)
					if(automatic)
						if(H.check_for_open_slot(src))
							return 0
					if(H.l_ear.canremove)
						return 2
					else
						return 0
				if( w_class < 2	)
					return 1
				return 1
			if(slot_r_ear)
				if( !(slot_flags & SLOT_EARS) )
					return 0
				if( (slot_flags & SLOT_TWOEARS) && H.l_ear )
					return 0
				if(H.r_ear)
					if(automatic)
						if(H.check_for_open_slot(src))
							return 0
					if(H.r_ear.canremove)
						return 2
					else
						return 0
				if( w_class < 2 )
					return 1
				return 1
			*/
			if(slot_w_uniform)
				if( !(slot_flags & SLOT_ICLOTHING) )
					return 0
				if(H.w_uniform)
					if(automatic)
						if(H.check_for_open_slot(src))
							return 0
					if(H.w_uniform.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_wear_id)
				if(!H.w_uniform)
					if(!disable_warning)
						H << "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>"
					return 0
				if( !(slot_flags & SLOT_ID) )
					return 0
				if(H.wear_id)
					if(automatic)
						if(H.check_for_open_slot(src))
							return 0
					if(H.wear_id.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_l_store)
				if(!H.w_uniform)
					if(!disable_warning)
						H << "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>"
					return 0
				if(slot_flags & SLOT_DENYPOCKET)
					return
				if(automatic)
					if(H.l_store)
						return 0
					else if( w_class <= 2 || (slot_flags & SLOT_POCKET) )
						return 1
				else if( w_class <= 2 || (slot_flags & SLOT_POCKET) )
					if(H.l_store)
						return 2
					else
						return 1
			if(slot_r_store)
				if(!H.w_uniform)
					if(!disable_warning)
						H << "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>"
					return 0
				if(slot_flags & SLOT_DENYPOCKET)
					return
				if(automatic)
					if(H.r_store)
						return 0
					else if( w_class <= 2 || (slot_flags & SLOT_POCKET) )
						return 1
				else if( w_class <= 2 || (slot_flags & SLOT_POCKET) )
					if(H.r_store)
						return 2
					else
						return 1
			if(slot_s_store)
				if(!H.wear_suit)
					if(!disable_warning)
						H << "<span class='warning'>You need a suit before you can attach this [name].</span>"
					return 0
				if(!H.wear_suit.allowed)
					if(!disable_warning)
						usr << "You somehow have a suit with no defined allowed items for suit storage, stop that."
					return 0
				if(src.w_class > 3 && !H.wear_suit.allowed.len)
					if(!disable_warning)
						usr << "The [name] is too big to attach."
					return 0
				if( istype(src, /obj/item/device/pda) || istype(src, /obj/item/weapon/pen) || is_type_in_list(src, H.wear_suit.allowed) )
					if(H.s_store)
						if(automatic)
							if(H.check_for_open_slot(src))
								return 0
						if(H.s_store.canremove)
							return 2
						else
							return 0
					else
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

/obj/item/can_pickup(mob/living/user)
	if(!(user) || !isliving(user)) //BS12 EDIT
		return 0
	if(!user.canmove || user.stat || user.restrained() || !Adjacent(user))
		return 0
	if((!istype(user, /mob/living/carbon) && !isMoMMI(user)) || istype(user, /mob/living/carbon/brain)) //Is not a carbon being, MoMMI, or is a brain
		user << "You can't pick things up!"
	if( user.stat || user.restrained() )//Is not asleep/dead and is not restrained
		user << "<span class='warning'>You can't pick things up!</span>"
		return 0
	if(src.anchored) //Object isn't anchored
		user << "<span class='warning'>You can't pick that up!</span>"
		return 0
	if(!istype(src.loc, /turf)) //Object is on a turf
		user << "<span class='warning'>You can't pick that up!</span>"
		return 0
	return 1

/obj/item/verb_pickup(mob/living/user)
	//set src in oview(1)
	//set category = "Object"
	//set name = "Pick up"

	if(!can_pickup(user))
		return 0
	if(!user.hand && user.r_hand) //Right hand is not full
		user << "<span class='warning'>Your right hand is full.</span>"
		return
	if(user.hand && user.l_hand && !isMoMMI(user)) //Left hand is not full
		user << "<span class='warning'>Your left hand is full.</span>"
		return
	//All checks are done, time to pick it up!
	if(isMoMMI(user))
		// Otherwise, we get MoMMIs changing their own laws.
		if(istype(src,/obj/item/weapon/aiModule))
			src << "<span class='warning'>Your firmware prevents you from picking up [src]!</span>"
			return
		if(user.get_active_hand() == null)
			user.put_in_hands(src)
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/h_user = user
		if(h_user.can_use_hand())
			src.attack_hand(h_user)
		else
			src.attack_stump(h_user)
	if(istype(user, /mob/living/carbon/alien))
		src.attack_alien(user)
	if(istype(user, /mob/living/carbon/monkey))
		src.attack_paw(user)
	return

//This proc is executed when someone clicks the on-screen UI button. To make the UI button show, set the 'action_button_name'.
//The default action is attack_self().
//Checks before we get to here are: mob is alive, mob is not restrained, paralyzed, asleep, resting, laying, item is on the mob.
/obj/item/proc/ui_action_click()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/proc/ui_action_click() called tick#: [world.time]")
	if(src in usr)
		attack_self(usr)

//Used in twohanding
/obj/item/proc/wield(mob/user, var/inactive = 0)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/proc/wield() called tick#: [world.time]")
	if(!ishuman(user))
		user.show_message("You can't wield \the [src] as it's too heavy.")
		return
	if(!wielded)
		wielded = getFromPool(/obj/item/offhand)
		if(user.put_in_inactive_hand(wielded) || (!inactive && user.put_in_active_hand(wielded)))
			wielded.attach_to(src)
			update_wield(user)
			return 1
		unwield(user)
		return

/obj/item/proc/unwield(mob/user)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/proc/unwield() called tick#: [world.time]")
	if(flags & MUSTTWOHAND && src in user)
		user.drop_from_inventory(src)
	if(istype(wielded))
		user.u_equip(wielded,1)
		if(wielded)
			wielded.wielding = null
			returnToPool(wielded)
			wielded = null
	update_wield(user)

/obj/item/proc/update_wield(mob/user)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/proc/update_wield() called tick#: [world.time]")

/obj/item/proc/IsShield()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/proc/IsShield() called tick#: [world.time]")
	return 0

/obj/item/proc/eyestab(mob/living/carbon/M as mob, mob/living/carbon/user as mob)

	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/proc/eyestab() called tick#: [world.time]")

	var/mob/living/carbon/human/H = M
	if(istype(H))
		var/obj/item/eye_protection = H.get_body_part_coverage(EYES)
		if(eye_protection)
			user << "<span class='warning'>You're going to need to remove that [eye_protection] first.</span>"
			return

	var/mob/living/carbon/monkey/Mo = M
	if(istype(Mo) && ( \
			(Mo.wear_mask && Mo.wear_mask.body_parts_covered & EYES) \
		))
		// you can't stab someone in the eyes wearing a mask!
		user << "<span class='warning'>You're going to need to remove that mask first.</span>"
		return

	if(!M.has_eyes())
		user << "<span class='warning'>You cannot locate any eyes on [M]!</span>"
		return

	user.attack_log += "\[[time_stamp()]\]<font color='red'> Attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>"
	M.attack_log += "\[[time_stamp()]\]<font color='orange'> Attacked by [user.name] ([user.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>"
	msg_admin_attack("ATTACK: [user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])") //BS12 EDIT ALG
	log_attack("<font color='red'> [user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")
	if(!iscarbon(user))
		M.LAssailant = null
	else
		M.LAssailant = user

	src.add_fingerprint(user)
	//if((M_CLUMSY in user.mutations) && prob(50))
	//	M = user
		/*
		M << "<span class='warning'>You stab yourself in the eye.</span>"
		M.sdisabilities |= BLIND
		M.weakened += 4
		M.adjustBruteLoss(10)
		*/

	if(istype(M, /mob/living/carbon/human))

		var/datum/organ/internal/eyes/eyes = H.internal_organs_by_name["eyes"]

		if(M != user)
			for(var/mob/O in (viewers(M) - user - M))
				O.show_message("<span class='attack'>[M] has been stabbed in the eye with [src] by [user].</span>", 1)
			M << "<span class='attack'>[user] stabs you in the eye with [src]!</span>"
			user << "<span class='attack'>You stab [M] in the eye with [src]!</span>"
		else
			user.visible_message( \
				"<span class='attack'>[user] has stabbed themself with [src]!</span>", \
				"<span class='attack'>You stab yourself in the eyes with [src]!</span>" \
			)

		eyes.damage += rand(3,4)
		if(eyes.damage >= eyes.min_bruised_damage)
			if(M.stat != 2)
				if(eyes.robotic <= 1) //robot eyes bleeding might be a bit silly
					M << "<span class='warning'>Your eyes start to bleed profusely!</span>"
			if(prob(50))
				if(M.stat != 2)
					M << "<span class='warning'>You drop what you're holding and clutch at your eyes!</span>"
					M.drop_item()
				M.eye_blurry += 10
				M.Paralyse(1)
				M.Weaken(4)
			if (eyes.damage >= eyes.min_broken_damage)
				if(M.stat != 2)
					M << "<span class='warning'>You go blind!</span>"
		var/datum/organ/external/affecting = M:get_organ("head")
		if(affecting.take_damage(7))
			M:UpdateDamageIcon(1)
	else
		M.take_organ_damage(7)
	M.eye_blurry += rand(3,4)
	return

/obj/item/clean_blood()
	. = ..()
	if(blood_overlay)
		overlays.Remove(blood_overlay)
	if(istype(src, /obj/item/clothing/gloves))
		var/obj/item/clothing/gloves/G = src
		G.transfer_blood = 0


/obj/item/add_blood(mob/living/carbon/human/M as mob)
	if (!..())
		return 0
	if(istype(src, /obj/item/weapon/melee/energy))
		return

	//if we haven't made our blood_overlay already
	if(!blood_overlays[type])
		generate_blood_overlay()

	if(!blood_overlay)
		blood_overlay = blood_overlays[type]
	else
		overlays.Remove(blood_overlay)

	//apply the blood-splatter overlay if it isn't already in there, else it updates it.
	blood_overlay.color = blood_color
	overlays += blood_overlay

	//if this blood isn't already in the list, add it

	if(!M)
		return
	if(blood_DNA[M.dna.unique_enzymes])
		return 0 //already bloodied with this blood. Cannot add more.
	blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
	return 1 //we applied blood to the item

var/global/list/image/blood_overlays = list()
/obj/item/proc/generate_blood_overlay()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/proc/generate_blood_overlay() called tick#: [world.time]")
	if(blood_overlays[type])
		return

	var/icon/I = new /icon(icon, icon_state)
	I.Blend(new /icon('icons/effects/blood.dmi', rgb(255,255,255)),ICON_ADD) //fills the icon_state with white (except where it's transparent)
	I.Blend(new /icon('icons/effects/blood.dmi', "itemblood"),ICON_MULTIPLY) //adds blood and the remaining white areas become transparant

	blood_overlays[type] = image(I)


/obj/item/proc/showoff(mob/user)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/proc/showoff() called tick#: [world.time]")
	for (var/mob/M in view(user))
		M.show_message("[user] holds up [src]. <a HREF='?src=\ref[M];lookitem=\ref[src]'>Take a closer look.</a>",1)

/mob/living/carbon/verb/showoff()
	set name = "Show Held Item"
	set category = "Object"
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""]) \\/mob/living/carbon/verb/showoff()  called tick#: [world.time]")

	var/obj/item/I = get_active_hand()
	if(I && !I.abstract)
		I.showoff(src)

// /vg/ Affects wearers.
/obj/item/proc/OnMobLife(var/mob/holder)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/proc/OnMobLife() called tick#: [world.time]")
	return

/obj/item/proc/OnMobDeath(var/mob/holder)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/proc/OnMobDeath() called tick#: [world.time]")
	return

//handling the pulling of the item for singularity
/obj/item/singularity_pull(S, current_size)
	spawn(0) //this is needed or multiple items will be thrown sequentially and not simultaneously
		if(current_size >= STAGE_FOUR)
			//throw_at(S, 14, 3)
			step_towards(src,S)
			sleep(1)
			step_towards(src,S)
		else if(current_size > STAGE_ONE)
			step_towards(src,S)
		else ..()

//Gets the rating of the item, used in stuff like machine construction.
/obj/item/proc/get_rating()
	return 0