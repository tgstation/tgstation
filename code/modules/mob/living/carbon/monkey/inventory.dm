/obj/effect/equip_e/monkey/process()
	if (item)
		item.add_fingerprint(source)
	if (!( item ))
		switch(place)
			if("head")
				if (!( target.wear_mask ))
					qdel(src)
					return
			if("hand")
				if (!( target.held_items[hand_index] ))
					qdel(src)
					return
			if("back")
				if (!( target.back ))
					qdel(src)
					return
			if("handcuff")
				if (!( target.handcuffed ))
					qdel(src)
					return
			if("internal")
				if ((!( (istype(target.wear_mask, /obj/item/clothing/mask) && istype(target.back, /obj/item/weapon/tank) && !( target.internal )) ) && !( target.internal )))
					qdel(src)
					return

	if (item)
		if(isrobot(source) && place != "handcuff")
			var/list/L = list( "syringe", "pill", "drink", "dnainjector", "fuel")
			if(!(L.Find(place)))
				qdel(src)
				return
		for(var/mob/O in viewers(target, null))
			if ((O.client && !( O.blinded )))
				O.show_message(text("<span class='danger'>[] is trying to put a [] on []</span>", source, item, target), 1)
	else
		var/message = null
		switch(place)
			if("mask")
				if(istype(target.wear_mask, /obj/item/clothing)&&!target.wear_mask:canremove)
					message = text("<span class='danger'>[] fails to take off \a [] from []'s body!</span>", source, target.wear_mask, target)
				else
					message = text("<span class='danger'>[] is trying to take off \a [] from []'s head!</span>", source, target.wear_mask, target)
			if("hand")
				message = text("<span class='danger'>[] is trying to take off a [] from []'s []!</span>", source, target.held_items[hand_index], target, target.get_index_limb_name(hand_index))
			if("back")
				message = text("<span class='danger'>[] is trying to take off a [] from []'s back!</span>", source, target.back, target)
			if("handcuff")
				message = text("<span class='danger'>[] is trying to unhandcuff []!</span>", source, target)
			if("internal")
				if (target.internal)
					message = text("<span class='danger'>[] is trying to remove []'s internals</span>", source, target)
				else
					message = text("<span class='danger'>[] is trying to set on []'s internals.</span>", source, target)
			else
		for(var/mob/M in viewers(target, null))
			M.show_message(message, 1)
	spawn( 30 )
		done()
		return
	return

/obj/effect/equip_e/monkey/done()
	if(!source || !target)						return
	if(source.loc != s_loc)						return
	if(target.loc != t_loc)						return
	if(!source.Adjacent(target))				return
	if(item && source.get_active_hand() != item)	return
	if ((source.restrained() || source.stat))	return
	switch(place)
		if("mask")
			if (target.wear_mask)
				if(istype(target.wear_mask, /obj/item/clothing)&& !target.wear_mask:canremove)
					return
				var/obj/item/W = target.wear_mask
				target.u_equip(W,1)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					//W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			else
				if (istype(item, /obj/item/clothing/mask))
					source.drop_item(item, force_drop = 1)
					loc = target
					item.layer = 20
					target.wear_mask = item
					item.loc = target
		if("hand")
			if (target.held_items[hand_index])
				var/obj/item/W = target.held_items[hand_index]
				target.u_equip(W,1)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.layer = initial(W.layer)
					//W.dropped(target)
				W.add_fingerprint(source)
			else
				if (istype(item, /obj/item))
					source.drop_item(item, force_drop = 1)
					target.put_in_hand(hand_index, item)
					loc = target
					item.dropped(source)
		if("back")
			if (target.back)
				var/obj/item/W = target.back
				target.u_equip(W,1)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					//W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			else
				if ((istype(item, /obj/item) && item.slot_flags & SLOT_BACK ))
					source.drop_item(item, force_drop = 1)
					loc = target
					item.layer = 20
					target.back = item
					item.loc = target
		if("handcuff")
			if (target.handcuffed)
				var/obj/item/W = target.handcuffed
				target.u_equip(W,1)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					//W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			else
				if (istype(item, /obj/item/weapon/handcuffs))
					source.drop_item(item, force_drop = 1)
					target.handcuffed = item
					item.loc = target
		if("internal")
			if (target.internal)
				target.internal.add_fingerprint(source)
				target.internal = null
			else
				if (target.internal)
					target.internal = null
				if (!( istype(target.wear_mask, /obj/item/clothing/mask) ))
					return
				else
					if (istype(target.back, /obj/item/weapon/tank))
						target.internal = target.back
						target.internal.add_fingerprint(source)
						for(var/mob/M in viewers(target, 1))
							if ((M.client && !( M.blinded )))
								M.show_message(text("[] is now running on internals.", target), 1)
		else
	source.regenerate_icons()
	target.regenerate_icons()
	qdel(src)
	return



//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible() or advanced_equip_to_slot_if_possible()
//set redraw_mob to 0 if you don't wish the hud to be updated - if you're doing it manually in your own proc.
/mob/living/carbon/monkey/equip_to_slot(obj/item/W as obj, slot, redraw_mob = 1)
	if(!slot) return
	if(!istype(W)) return

	if(W == get_active_hand())
		u_equip(W,0)

	switch(slot)
		if(slot_back)
			src.back = W
			W.equipped(src, slot)
			update_inv_back(redraw_mob)
		if(slot_wear_mask)
			src.wear_mask = W
			W.equipped(src, slot)
			update_inv_wear_mask(redraw_mob)
		if(slot_handcuffed)
			src.handcuffed = W
			update_inv_handcuffed(redraw_mob)
		if(slot_legcuffed)
			src.legcuffed = W
			W.equipped(src, slot)
			update_inv_legcuffed(redraw_mob)
		if(slot_in_backpack)
			W.loc = src.back
		else
			to_chat(usr, "<span class='warning'>You are trying to eqip this item to an unsupported inventory slot. How the heck did you manage that? Stop it...</span>")
			return

	W.layer = 20

	return