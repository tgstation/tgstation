/proc/makeStrippingButton(var/obj/item/I) //Not actually the stripping button, just what's written on it
	if(!istype(I) || I.abstract)
		return "<font color=grey>Empty</font>"
	else
		return I

/mob/living/carbon/proc/strip_time()
	return HUMAN_STRIP_DELAY

/mob/living/carbon/proc/reversestrip_time()
	return HUMAN_REVERSESTRIP_DELAY

//This proc is unsafe, it assumes that the mob is holding the item, that the item can be removed, etc.
/mob/living/carbon/proc/strip_item_from(var/mob/living/user, var/obj/item/target_item, var/slot = null, var/pickpocket = FALSE)
	var/temp_loc = target_item.loc //do_mob will make sure nobody goes anywhere, including the item to be placed, but sadly it doesn't keep track of the item to be stripped

	target_item.add_fingerprint(user) //We don't need to be successful in order to get our prints on the thing

	if(do_mob(user, src, strip_time())) //Fails if the user moves, changes held item, is incapacitated, etc.
		if(temp_loc != target_item.loc) //This will also fail if the item to strip went anywhere, necessary because do_mob() doesn't keep track of it.
			return

		if(target_item.before_stripped(src, user, slot)) //If this returns 1, then the stripping process was interrupted!
			return

		drop_from_inventory(target_item)
		target_item.stripped(src, user)
		if(pickpocket)
			user.put_in_hands(target_item)

		return TRUE

//This proc is unsafe, it assumes that the mob has the given slot free, that the item can be put there etc.
/mob/living/carbon/proc/reversestrip_into_slot(var/mob/living/user, var/slot, var/pickpocket = FALSE)
	if(slot in list(slot_handcuffed, slot_legcuffed))
		to_chat(user, "<span class='warning'>You feel stupider, suddenly.</span>")
		return

	var/obj/item/held = user.get_active_hand()

	if(do_mob(user, src, reversestrip_time())) //Fails if the user moves, changes held item, is incapacitated, etc.
		if(held.mob_can_equip(src, slot, disable_warning = 1) == CAN_EQUIP) //Do not accept CAN_EQUIP_BUT_SLOT_TAKEN as valid!
			user.drop_from_inventory(held)
			src.equip_to_slot(held, slot) //Not using equip_to_slot_if_possible() because we want to check that the guy can wear this before dropping it

			return TRUE

//This proc is unsafe, it assumes hand stuff.
/mob/living/carbon/proc/reversestrip_into_hand(var/mob/living/user, var/index, var/pickpocket = FALSE)
	var/obj/item/held = user.get_active_hand()

	if(do_mob(user, src, reversestrip_time())) //Fails if the user moves, changes held item, is incapacitated, etc.
		if(src.put_in_hand_check(held, index))
			user.drop_from_inventory(held)
			src.put_in_hand(index, held)

			return TRUE

/mob/living/carbon/proc/handle_strip_slot(var/mob/living/user, var/slot)
	if(slot in src.check_obscured_slots()) //Ideally they wouldn't even get the button to do this, but they could have an outdated menu or something
		to_chat(user, "<span class='warning'>You can't reach that, something is covering it.</span>")
		return

	var/obj/item/held = user.get_active_hand()
	var/obj/item/target_item = src.get_item_by_slot(slot)
	var/pickpocket = user.isGoodPickpocket()


	if(istype(target_item) && !target_item.abstract) //We want the player to be able to strip someone while holding an item in their hands, for convenience and because otherwise people will bitch about it.
		if(!target_item.canremove || src.is_in_modules(target_item))
			to_chat(user, "<span class='warning'>You can't seem to be able to take that off!</span>")
			return

		if(!pickpocket)
			visible_message("<span class='danger'>\The [user] is trying to remove \a [target_item] from \the [src]'s [src.slotID2slotname(slot)]!</span>")

		if(strip_item_from(user, target_item, slot, pickpocket))
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has stripped \a [target_item] from [src.name]'s [src.slotID2slotname(slot)] ([src.ckey])</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had \a [target_item] stripped from their [src.slotID2slotname(slot)] by [user.name] ([user.ckey])</font>")
			log_attack("[user.name] ([user.ckey]) has stripped \a [target_item] from [src.name]'s [src.slotID2slotname(slot)] ([src.ckey])")
			show_inv(user)
		else
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has failed to strip \a [target_item] from [src.name]'s [src.slotID2slotname(slot)] ([src.ckey])</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>[user.name] ([user.ckey]) has failed to strip \a [target_item] from this mob's [src.slotID2slotname(slot)]</font>")
			log_attack("[user.name] ([user.ckey]) has failed to strip \a [target_item] from [src.name]'s [src.slotID2slotname(slot)] ([src.ckey])")

	else if(istype(held) && !held.abstract)
		if(held.cant_drop > 0 || user.is_in_modules(held))
			to_chat(user, "<span class='warning'>You can't seem to be able to let go of \the [held].</span>")
			return
		if(!held.mob_can_equip(src, slot, disable_warning = 1)) //This also checks for the target being too fat for the clothing item and such
			to_chat(user, "<span class='warning'>You can't put that there!</span>") //Ideally we could have a more descriptive message since this can fail for a variety of reasons, but whatever
			return
		if(!src.has_organ_for_slot(slot))
			to_chat(user, "<span class='warning'>\The [src] has no [src.slotID2slotname(slot)].</span>") //blunt
			return

		if(!pickpocket)
			visible_message("<span class='danger'>\The [user] is trying to put \a [held] on \the [src]!</span>")

		if(reversestrip_into_slot(user, slot, pickpocket))
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has put \a [held] into [src.name]'s [src.slotID2slotname(slot)] ([src.ckey])</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had \a [held] put into their [src.slotID2slotname(slot)] by [user.name] ([user.ckey])</font>")
			log_attack("[user.name] ([user.ckey]) has put \a [held] into [src.name]'s [src.slotID2slotname(slot)] ([src.ckey])")
			show_inv(user)
		else
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has failed to place \a [held] into [src.name]'s [src.slotID2slotname(slot)] ([src.ckey])</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>[user.name] ([user.ckey]) has failed to place \a [held] into this mob's [src.slotID2slotname(slot)]</font>")
			log_attack("[user.name] ([user.ckey]) has failed to place \a [held] into [src.name]'s [src.slotID2slotname(slot)] ([src.ckey])")

/mob/living/carbon/proc/handle_strip_hand(var/mob/living/user, var/index)
	if(!index || !isnum(index))	return

	var/obj/item/held = user.get_active_hand()
	var/obj/item/target_item = src.held_items[index]
	var/pickpocket = user.isGoodPickpocket()

	if(istype(target_item) && !target_item.abstract)
		if(target_item.cant_drop > 0 || src.is_in_modules(target_item))
			to_chat(user, "<span class='warning'>\a [target_item] is stuck to \the [src]!</span>")
			return

		if(!pickpocket)
			visible_message("<span class='warning'>\The [user] is trying to take \a [target_item] from \the [src]'s [src.get_index_limb_name(index)]!</span>")

		if(strip_item_from(user, target_item, null, pickpocket)) //slot is null since it's a hand index
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has stripped \a [target_item] from [src.name] ([src.ckey])'s [src.get_index_limb_name(index)]</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had \a [target_item] stripped from their [src.get_index_limb_name(index)] by [user.name] ([user.ckey])</font>")
			log_attack("[user.name] ([user.ckey]) has stripped \a [target_item] from [user.name]'s ([src.ckey])'s [src.get_index_limb_name(index)]")
			show_inv(user)
		else
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has failed to strip \a [target_item] from [src.name]'s ([src.ckey]) [src.get_index_limb_name(index)]</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>[user.name] ([user.ckey]) has failed to strip \a [target_item] from this mob's [src.get_index_limb_name(index)]</font>")
			log_attack("[user.name] ([user.ckey]) has failed to strip \a [target_item] from [src.name]'s ([src.ckey]) [src.get_index_limb_name(index)]")

	else if(istype(held) && !held.abstract)
		if(held.cant_drop > 0 || user.is_in_modules(held))
			to_chat(user, "<span class='warning'>You can't seem to be able to let go of \the [held].</span>")
			return

		if(!src.put_in_hand_check(held, index))
			to_chat(user, "<span class='warning'>\The [src] cannot hold [held]!</span>")
			return

		if(!pickpocket)
			visible_message("<span class='warning'>\The [user] is trying to put \a [held] on \the [src]'s [src.get_index_limb_name(index)]!</span>")

		if(reversestrip_into_hand(user, index, pickpocket))
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has put \a [held] into [src.name]'s ([src.ckey]) [src.get_index_limb_name(index)]</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had \a [held] put into their [src.get_index_limb_name(index)] by [user.name] ([user.ckey])</font>")
			log_attack("[user.name] ([user.ckey]) has put \a [held] into [src.name]'s ([src.ckey]) [src.get_index_limb_name(index)]")
			show_inv(user)
		else
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has failed to place \a [held] into [src.name]'s ([src.ckey]) [src.get_index_limb_name(index)]</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>[user.name] ([user.ckey]) has failed to place \a [held] into this mob's [src.get_index_limb_name(index)]</font>")
			log_attack("[user.name] ([user.ckey]) has failed to place \a [held] into [src.name]'s '([src.ckey]) [src.get_index_limb_name(index)]")

/mob/living/carbon/proc/handle_strip_id(var/mob/living/user)
	var/obj/item/id_item = src.get_item_by_slot(slot_wear_id)
	var/obj/item/place_item = user.get_active_hand()
	var/pickpocket = user.isGoodPickpocket()

	if(id_item && !id_item.abstract)
		if(!id_item.canremove)
			to_chat(user, "<span class='warning'>You can't seem to be able to take that off!</span>")
			return

		to_chat(user, "<span class='notice'>You try to take [src]'s ID.</span>")

		if(strip_item_from(user, id_item, slot_wear_id, pickpocket))
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has pickpocketed \a [id_item] from [src.name]'s ([src.ckey]) ID slot.</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='red'>Has had \a [id_item] pickpocketed by [user.name] ([user.ckey]) from their ID slot.</font>")
			log_attack("[user.name] ([user.ckey]) has pickpocketed \a [id_item] from [src.name]'s ([src.ckey]) ID slot.")
			show_inv(user)
		else
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has failed to pickpocket \a [id_item] from [src.name]'s ([src.ckey]) ID slot.</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>[user.name] ([user.ckey]) has failed to pickpocket \a [id_item] from this mob's ID slot.</font>")
			log_attack("[user.name] ([user.ckey]) has failed to pickpocket \a [id_item] from [src.name]'s ([src.ckey]) ID slot.")
			if(!pickpocket) // Display a warning if the user mocks up. Unless they're just that good of a pickpocket.
				to_chat(src, "<span class='warning'>You feel your ID being fumbled with!</span>")
	else if(place_item && !place_item.abstract)
		if(place_item.cant_drop > 0 || user.is_in_modules(place_item))
			to_chat(user, "<span class='warning'>You can't seem to be able to let go of \the [place_item].</span>")
			return
		if(!place_item.mob_can_equip(src, slot_wear_id, disable_warning = 1))
			to_chat(user, "<span class='warning'>You can't put that there!</span>")
			return

		to_chat(user, "<span class='notice'>You try to place [place_item] on [src].</span>")

		if(reversestrip_into_slot(user, slot_wear_id, pickpocket))
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has reverse-pickpocketed \a [place_item] into [src.name]'s ([src.ckey]) ID slot.</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had \a [place_item] reverse-pickpocketed into their ID slot by [user.name] ([user.ckey])</font>")
			log_attack("[user.name] ([user.ckey]) has reverse-pickpocketed \a [place_item] into [src.name]'s ([src.ckey]) ID slot.")
			show_inv(user)
		else
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has failed to reverse-pickpocket \a [place_item] into [src.name]'s ([src.ckey]) ID slot.</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>[user.name] ([user.ckey]) has failed to reverse-pickpocket \a [place_item] into this mob's ID slot.</font>")
			log_attack("[user.name] ([user.ckey]) has failed to reverse-pickpocket \a [place_item] into [src.name]'s ([src.ckey]) ID slot.")

/mob/living/carbon/proc/handle_strip_pocket(var/mob/living/user, var/pocket_side)
	var/pocket_id = (pocket_side == "right" ? slot_r_store : slot_l_store)
	var/obj/item/pocket_item = get_item_by_slot(pocket_id)
	var/obj/item/place_item = user.get_active_hand()
	var/pickpocket = user.isGoodPickpocket()

	if(pocket_item && !pocket_item.abstract)
		if(!pocket_item.canremove)
			to_chat(user, "<span class='warning'>You can't seem to be able to take that off!</span>")
			return

		to_chat(user, "<span class='notice'>You try to empty [src]'s [pocket_side] pocket.</span>")

		if(strip_item_from(user, pocket_item, pocket_id, pickpocket))
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has pickpocketed \the [pocket_item] from [src.name]'s ([src.ckey]) [pocket_side] pocket.</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='red'>Has had \the [pocket_item] pickpocketed by [user.name] ([user.ckey]) from their [pocket_side] pocket.</font>")
			log_attack("[user.name] ([user.ckey]) has pickpocketed \the [pocket_item] from [src.name]'s ([src.ckey]) [pocket_side] pocket.")
			show_inv(user)
		else
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has failed to pickpocket \the [pocket_item] from [src.name]'s ([src.ckey]) [pocket_side] pocket.</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>[user.name] ([user.ckey]) has failed to pickpocket \the [pocket_item] from this mob's [pocket_side] pocket.</font>")
			log_attack("[user.name] ([user.ckey]) has failed to pickpocket \the [pocket_item] from [src.name]'s ([src.ckey]) [pocket_side] pocket.")
			if(!pickpocket) // Display a warning if the user mocks up. Unless they're just that good of a pickpocket.
				to_chat(src, "<span class='warning'>You feel your [pocket_side] pocket being fumbled with!</span>")
	else if(place_item && !place_item.abstract)
		if(place_item.cant_drop > 0 || user.is_in_modules(place_item))
			to_chat(user, "<span class='warning'>You can't seem to be able to let go of \the [place_item].</span>")
			return
		if(!place_item.mob_can_equip(src, pocket_id, disable_warning = 1))
			to_chat(user, "<span class='warning'>You can't put that there!</span>")
			return

		to_chat(user, "<span class='notice'>You try to place [place_item] on [src]'s [pocket_side] pocket.</span>")

		if(reversestrip_into_slot(user, pocket_id, pickpocket))
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has reverse-pickpocketed \a [place_item] into [src.name]'s ([src.ckey]) [pocket_side] pocket.</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had \a [place_item] reverse-pickpocketed into their [pocket_side] pocket by [user.name] ([user.ckey])</font>")
			log_attack("[user.name] ([user.ckey]) has reverse-pickpocketed \a [place_item] into [src.name]'s ([src.ckey]) [pocket_side] pocket.")
			show_inv(user)
		else
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has failed to reverse-pickpocket \a [place_item] into [src.name]'s ([src.ckey]) [pocket_side] pocket.</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>[user.name] ([user.ckey]) has failed to reverse-pickpocket \a [place_item] into this mob's [pocket_side] pocket.</font>")
			log_attack("[user.name] ([user.ckey]) has failed to reverse-pickpocket \a [place_item] into [src.name]'s ([src.ckey]) [pocket_side] pocket.")

// Modify the current target sensor level.
/mob/living/carbon/human/proc/toggle_sensors(var/mob/living/user)
	var/obj/item/clothing/under/suit = w_uniform
	if(!suit)
		to_chat(user, "<span class='warning'>\The [src] is not wearing a suit.</span>")
		return
	if(!suit.has_sensor)
		to_chat(user, "<span class='warning'>\The [src]'s suit does not have sensors.</span>")
		return
	if(suit.has_sensor >= 2)
		to_chat(user, "<span class='warning'>\The [src]'s suit sensor controls are locked.</span>")
		return
	if(!user.isGoodPickpocket())
		visible_message("<span class='warning'>\The [user] is trying to set [src]'s suit sensors.</span>", "<span class='danger'>\The [user] is trying to set your suit sensors!</span>")
	if(do_mob(user, src, HUMAN_STRIP_DELAY))
		var/newmode = suit.set_sensors(user)
		if(newmode)
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their sensors set to [newmode] by [user.name] ([user.ckey])</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Set [src.name]'s suit sensors ([src.ckey]).</font>")
			log_attack("[user.name] ([user.ckey]) has set [src.name]'s suit sensors ([src.ckey]) to [newmode].")
		else
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>[user.name] ([user.ckey]) has failed to set this mob's suit sensors.</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has failed to set [src.name]'s ([src.ckey]) suit sensors.</font>")
			log_attack("[user.name] ([user.ckey]) has failed to set [src.name]'s ([src.ckey]) suit sensors.")

// Set internals on or off.
/mob/living/carbon/proc/set_internals(var/mob/living/user)
	if(!has_breathing_mask())
		to_chat(user, "<span class='warning'>\The [src] is not wearing a breathing mask.</span>")
		return

	var/obj/item/weapon/tank/T = src.get_internals_tank()
	if(!T)
		to_chat(user, "<span class='warning'>\The [src] does not have a tank to connect to.</span>")
		return

	if(!user.isGoodPickpocket())
		visible_message("<span class='warning'>\The [user] is trying to set [src]'s internals.</span>", "<span class='danger'>\The [user] is trying to set your internals!</span>")

	if(do_mob(user, src, HUMAN_STRIP_DELAY))
		src.toggle_internals(user, T)
		show_inv(user)
