/mob/recycle(var/datum/materials)
	return RECYK_BIOLOGICAL

/mob/burnFireFuel(var/used_fuel_ratio,var/used_reactants_ratio)

/mob/Destroy() // This makes sure that mobs with clients/keys are not just deleted from the game.
	unset_machine()
	mob_list.Remove(src)
	dead_mob_list.Remove(src)
	living_mob_list.Remove(src)
	ghostize()
	..()

/mob/proc/cultify()
	return

/mob/New()
	. = ..()
	mob_list += src

	if(DEAD == stat)
		dead_mob_list += src
	else
		living_mob_list += src

	store_position()

/mob/proc/store_position()
	origin_x = x
	origin_y = y
	origin_z = z

/mob/proc/send_back()
	x = origin_x
	y = origin_y
	z = origin_z

/mob/proc/generate_name()
	return name

/**
 * Player panel controls for this mob.
 */
/mob/proc/player_panel_controls(var/mob/user)
	return ""

/mob/proc/Cell()
	set category = "Admin"
	set hidden = 1

	if(!loc) return 0

	var/datum/gas_mixture/environment = loc.return_air()

	var/t = "<span class='notice'> Coordinates: [x],[y] \n</span>"

	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\mob\mob.dm:25: t+= "<span class='warning'> Temperature: [environment.temperature] \n"
	t += {"<span class='warning'> Temperature: [environment.temperature] \n</span>
<span class='notice'> Nitrogen: [environment.nitrogen] \n</span>
<span class='notice'> Oxygen: [environment.oxygen] \n</span>
<span class='notice'> Plasma : [environment.toxins] \n</span>
<span class='notice'> Carbon Dioxide: [environment.carbon_dioxide] \n</span>"}
	// END AUTOFIX
	for(var/datum/gas/trace_gas in environment.trace_gases)
		usr << "<span class='notice'> [trace_gas.type]: [trace_gas.moles] \n</span>"

	usr.show_message(t, 1)

/mob/proc/show_message(msg, type, alt, alt_type)//Message, type of message (1 or 2), alternative message, alt message type (1 or 2)

	if(!client)	return

	msg = copytext(msg, 1, MAX_MESSAGE_LEN)

	if (type)
		if(type & 1 && (sdisabilities & BLIND || blinded || paralysis) )//Vision related
			if (!( alt ))
				return
			else
				msg = alt
				type = alt_type
		if (type & 2 && (sdisabilities & DEAF || ear_deaf))//Hearing related
			if (!( alt ))
				return
			else
				msg = alt
				type = alt_type
				if ((type & 1 && sdisabilities & BLIND))
					return
	// Added voice muffling for Issue 41.
	if(stat == UNCONSCIOUS || sleeping > 0)
		src << "<I>... You can almost hear someone talking ...</I>"
	else
		src << msg
	return

// Show a message to all mobs in sight of this one
// This would be for visible actions by the src mob
// message is the message output to anyone who can see e.g. "[src] does something!"
// self_message (optional) is what the src mob sees  e.g. "You do something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"

/mob/visible_message(var/message, var/self_message, var/blind_message)
	for(var/mob/M in viewers(src))
		var/msg = message
		if(self_message && M==src)
			msg = self_message
		M.show_message( msg, 1, blind_message, 2)

// Show a message to all mobs in sight of this atom
// Use for objects performing visible actions
// message is output to anyone who can see, e.g. "The [src] does something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"
/atom/proc/visible_message(var/message, var/blind_message)
	for(var/mob/M in viewers(src))
		M.show_message( message, 1, blind_message, 2)


/mob/proc/findname(msg)
	for(var/mob/M in mob_list)
		if (M.real_name == text("[]", msg))
			return M
	return 0

/mob/proc/movement_delay()
	return 0

/mob/proc/Life()
	return

/mob/proc/see_narsie(var/obj/machinery/singularity/narsie/large/N)
	if(N.bus_captured)
		if(narsimage)
			del(narsimage)
			del(narglow)
		return
	if((N.z == src.z)&&(get_dist(N,src) <= (N.consume_range+10)))
		if(!narsimage)
			narsimage = image('icons/obj/narsie.dmi',src.loc,"narsie",9,1)
		narsimage.pixel_x = 32 * (N.x - src.x) + N.pixel_x
		narsimage.pixel_y = 32 * (N.y - src.y) + N.pixel_y
		narsimage.loc = src.loc
		narsimage.mouse_opacity = 0
		if(!narglow)
			narglow = image('icons/obj/narsie.dmi',narsimage.loc,"glow-narsie",LIGHTING_LAYER+2,1)
		narglow.pixel_x = narsimage.pixel_x
		narglow.pixel_y = narsimage.pixel_y
		narglow.loc = narsimage.loc
		narglow.mouse_opacity = 0
		src << narsimage
		src << narglow
	else
		if(narsimage)
			del(narsimage)
			del(narglow)

/mob/proc/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_l_hand)
			return l_hand
		if(slot_r_hand)
			return r_hand
	return null


/mob/proc/restrained()
	return

//This proc is called whenever someone clicks an inventory ui slot.
/mob/proc/attack_ui(slot)
	var/obj/item/W = get_active_hand()
	if(istype(W))
		equip_to_slot_if_possible(W, slot)
	if(ishuman(src) && W == src:head)
		src:update_hair()

/mob/proc/put_in_any_hand_if_possible(obj/item/W as obj, act_on_fail = 0, disable_warning = 1, redraw_mob = 1)
	if(equip_to_slot_if_possible(W, slot_l_hand, act_on_fail, disable_warning, redraw_mob))
		update_inv_l_hand()
		return 1
	else if(equip_to_slot_if_possible(W, slot_r_hand, act_on_fail, disable_warning, redraw_mob))
		update_inv_r_hand()
		return 1
	return 0

//This is a SAFE proc. Use this instead of equip_to_splot()!
//set del_on_fail to have it delete W if it fails to equip
//set disable_warning to disable the 'you are unable to equip that' warning.
//unset redraw_mob to prevent the mob from being redrawn at the end.
/mob/proc/equip_to_slot_if_possible(obj/item/W as obj, slot, act_on_fail = 0, disable_warning = 0, redraw_mob = 1, automatic = 0)
	if(!istype(W)) return 0
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		switch(W.mob_can_equip(src, slot, disable_warning, automatic))
			if(0)
				switch(act_on_fail)
					if(EQUIP_FAILACTION_DELETE)
						del(W)
					if(EQUIP_FAILACTION_DROP)
						W.loc=get_turf(src) // I think.
					else
						if(!disable_warning)
							src << "<span class='warning'> You are unable to equip that.</span>" //Only print if act_on_fail is NOTHING
				return 0
			if(1)
				equip_to_slot(W, slot, redraw_mob)
			if(2)
				var/obj/item/wearing = null
				var/hand
				if(W == l_hand)
					hand = 0
				else if(W == r_hand)
					hand = 1
				switch(slot)
					if(slot_wear_mask)
						wearing = wear_mask
						equip_to_slot(W, slot, redraw_mob)
						if(wearing)
							if(hand)
								r_hand = wearing
								update_inv_r_hand()
							else if(hand == 0)
								l_hand = wearing
								update_inv_l_hand()
							else
								u_equip(W)
								del(W)
								equip_to_slot(wearing, slot, redraw_mob)
					if(slot_back)
						wearing = back
						equip_to_slot(W, slot, redraw_mob)
						if(wearing)
							if(hand)
								r_hand = wearing
								update_inv_r_hand()
							else if(hand == 0)
								l_hand = wearing
								update_inv_l_hand()
							else
								u_equip(W)
								del(W)
								equip_to_slot(wearing, slot, redraw_mob)
					if(slot_wear_suit)
						wearing = H.wear_suit
						equip_to_slot(W, slot, redraw_mob)
						if(wearing)
							if(hand)
								r_hand = wearing
								update_inv_r_hand()
							else if(hand == 0)
								l_hand = wearing
								update_inv_l_hand()
							else
								u_equip(W)
								del(W)
								equip_to_slot(wearing, slot, redraw_mob)
						if(H.s_store)
							if(!H.s_store.mob_can_equip(src, slot_s_store, 1))
								u_equip(H.s_store)
					if(slot_gloves)
						wearing = H.gloves
						equip_to_slot(W, slot, redraw_mob)
						if(wearing)
							if(hand)
								r_hand = wearing
								update_inv_r_hand()
							else if(hand == 0)
								l_hand = wearing
								update_inv_l_hand()
							else
								u_equip(W)
								del(W)
								equip_to_slot(wearing, slot, redraw_mob)
					if(slot_shoes)
						wearing = H.shoes
						equip_to_slot(W, slot, redraw_mob)
						if(wearing)
							if(hand)
								r_hand = wearing
								update_inv_r_hand()
							else if(hand == 0)
								l_hand = wearing
								update_inv_l_hand()
							else
								u_equip(W)
								del(W)
								equip_to_slot(wearing, slot, redraw_mob)
					if(slot_belt)
						wearing = H.belt
						equip_to_slot(W, slot, redraw_mob)
						if(wearing)
							if(hand)
								r_hand = wearing
								update_inv_r_hand()
							else if(hand == 0)
								l_hand = wearing
								update_inv_l_hand()
							else
								u_equip(W)
								del(W)
								equip_to_slot(wearing, slot, redraw_mob)
					if(slot_glasses)
						wearing = H.glasses
						equip_to_slot(W, slot, redraw_mob)
						if(wearing)
							if(hand)
								r_hand = wearing
								update_inv_r_hand()
							else if(hand == 0)
								l_hand = wearing
								update_inv_l_hand()
							else
								u_equip(W)
								del(W)
								equip_to_slot(wearing, slot, redraw_mob)
					if(slot_head)
						wearing = H.head
						equip_to_slot(W, slot, redraw_mob)
						if(wearing)
							if(hand)
								r_hand = wearing
								update_inv_r_hand()
							else if(hand == 0)
								l_hand = wearing
								update_inv_l_hand()
							else
								u_equip(W)
								del(W)
								equip_to_slot(wearing, slot, redraw_mob)
					// oh god what am I doing - N3X
					if(slot_ears)
						wearing = H.ears
						equip_to_slot(W, slot, redraw_mob)
						if(wearing)
							if(hand)
								r_hand = wearing
								update_inv_r_hand()
							else if(hand == 0)
								l_hand = wearing
								update_inv_l_hand()
							else
								u_equip(W)
								del(W)
								equip_to_slot(wearing, slot, redraw_mob)
					if(slot_w_uniform)
						wearing = H.w_uniform
						equip_to_slot(W, slot, redraw_mob)
						if(wearing)
							if(hand)
								r_hand = wearing
								update_inv_r_hand()
							else if(hand == 0)
								l_hand = wearing
								update_inv_l_hand()
							else
								u_equip(W)
								del(W)
								equip_to_slot(wearing, slot, redraw_mob)
/*
						if(H.wear_id)
							if(!H.wear_id.mob_can_equip(src, slot_wear_id, 1))
								u_equip(H.wear_id)
						if(H.l_store)
							if(!H.l_store.mob_can_equip(src, slot_l_store, 1))
								u_equip(H.l_store)
						if(H.r_store)
							if(!H.r_store.mob_can_equip(src, slot_r_store, 1))
								u_equip(H.r_store)
						if(H.belt)
							if(!H.belt.mob_can_equip(src, slot_belt, 1))
								u_equip(H.belt)*/
					if(slot_wear_id)
						wearing = H.wear_id
						equip_to_slot(W, slot, redraw_mob)
						if(wearing)
							if(hand)
								r_hand = wearing
								update_inv_r_hand()
							else if(hand == 0)
								l_hand = wearing
								update_inv_l_hand()
							else
								u_equip(W)
								del(W)
								equip_to_slot(wearing, slot, redraw_mob)
					if(slot_s_store)
						wearing = H.s_store
						equip_to_slot(W, slot, redraw_mob)
						if(wearing)
							if(hand)
								r_hand = wearing
								update_inv_r_hand()
							else if(hand == 0)
								l_hand = wearing
								update_inv_l_hand()
							else
								u_equip(W)
								del(W)
								equip_to_slot(wearing, slot, redraw_mob)
					if(slot_l_store)
						wearing = H.l_store
						equip_to_slot(W, slot, redraw_mob)
						if(wearing)
							if(hand)
								r_hand = wearing
								update_inv_r_hand()
							else if(hand == 0)
								l_hand = wearing
								update_inv_l_hand()
							else
								u_equip(W)
								del(W)
								equip_to_slot(wearing, slot, redraw_mob)
					if(slot_r_store)
						wearing = H.r_store
						equip_to_slot(W, slot, redraw_mob)
						if(wearing)
							if(hand)
								r_hand = wearing
								update_inv_r_hand()
							else if(hand == 0)
								l_hand = wearing
								update_inv_l_hand()
							else
								u_equip(W)
								del(W)
								equip_to_slot(wearing, slot, redraw_mob)
		return 1
	else
		if(!W.mob_can_equip(src, slot, disable_warning))
			switch(act_on_fail)
				if(EQUIP_FAILACTION_DELETE)
					del(W)
				if(EQUIP_FAILACTION_DROP)
					W.loc=get_turf(src) // I think.
				else
					if(!disable_warning)
						src << "<span class='warning'> You are unable to equip that.</span>" //Only print if act_on_fail is NOTHING
			return 0

		equip_to_slot(W, slot, redraw_mob) //This proc should not ever fail.
		return 1

//This is an UNSAFE proc. It merely handles the actual job of equipping. All the checks on whether you can or can't eqip need to be done before! Use mob_can_equip() for that task.
//In most cases you will want to use equip_to_slot_if_possible()
/mob/proc/equip_to_slot(obj/item/W as obj, slot)
	return

//This is just a commonly used configuration for the equip_to_slot_if_possible() proc, used to equip people when the rounds tarts and when events happen and such.
/mob/proc/equip_to_slot_or_del(obj/item/W as obj, slot)
	return equip_to_slot_if_possible(W, slot, EQUIP_FAILACTION_DELETE, 1, 0)

//This is just a commonly used configuration for the equip_to_slot_if_possible() proc, used to equip people when the rounds tarts and when events happen and such.
/mob/proc/equip_to_slot_or_drop(obj/item/W as obj, slot)
	return equip_to_slot_if_possible(W, slot, EQUIP_FAILACTION_DROP, 1, 0)

// Convinience proc.  Collects crap that fails to equip either onto the mob's back, or drops it.
// Used in job equipping so shit doesn't pile up at the start loc.
/mob/living/carbon/human/proc/equip_or_collect(var/obj/item/W, var/slot)
	if(!equip_to_slot_or_drop(W, slot))
		// Do I have a backpack?
		var/obj/item/weapon/storage/B = back

		// Do I have a plastic bag?
		if(!B)
			B=is_in_hands(/obj/item/weapon/storage/bag/plasticbag)

		if(!B)
			// Gimme one.
			B=new /obj/item/weapon/storage/bag/plasticbag(null) // Null in case of failed equip.
			if(!put_in_hands(B,slot_back))
				return // Fuck it
		B.handle_item_insertion(W,1)

//The list of slots by priority. equip_to_appropriate_slot() uses this list. Doesn't matter if a mob type doesn't have a slot.
var/list/slot_equipment_priority = list( \
		slot_back,\
		slot_wear_id,\
		slot_w_uniform,\
		slot_wear_suit,\
		slot_wear_mask,\
		slot_head,\
		slot_shoes,\
		slot_gloves,\
		slot_ears,\
		slot_glasses,\
		slot_belt,\
		slot_s_store,\
		slot_l_store,\
		slot_r_store\
	)

//puts the item "W" into an appropriate slot in a human's inventory
//returns 0 if it cannot, 1 if successful
/mob/proc/equip_to_appropriate_slot(obj/item/W)
	if(!istype(W)) return 0

	for(var/slot in slot_equipment_priority)
		if(equip_to_slot_if_possible(W, slot, 0, 1, 1, 1)) //act_on_fail = 0; disable_warning = 0; redraw_mob = 1
			return 1

	return 0

/mob/proc/check_for_open_slot(obj/item/W)
	if(!istype(W)) return 0
	var/openslot = 0
	for(var/slot in slot_equipment_priority)
		if(W.mob_check_equip(src, slot, 1) == 1)
			openslot = 1
			break
	return openslot

/obj/item/proc/mob_check_equip(M as mob, slot, disable_warning = 0)
	if(!M) return 0
	if(!slot) return 0
	if(ishuman(M))
		//START HUMAN
		var/mob/living/carbon/human/H = M

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
					return 0
				return 1
			if(slot_back)
				if( !(slot_flags & SLOT_BACK) )
					return 0
				if(H.back)
					if(H.back.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_wear_suit)
				if( !(slot_flags & SLOT_OCLOTHING) )
					return 0
				if(H.wear_suit)
					if(H.wear_suit.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_gloves)
				if( !(slot_flags & SLOT_GLOVES) )
					return 0
				if(H.gloves)
					if(H.gloves.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_shoes)
				if( !(slot_flags & SLOT_FEET) )
					return 0
				if(H.shoes)
					if(H.shoes.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_belt)
				if(!H.w_uniform)
					if(!disable_warning)
						H << "<span class='warning'> You need a jumpsuit before you can attach this [name].</span>"
					return 0
				if( !(slot_flags & SLOT_BELT) )
					return 0
				if(H.belt)
					if(H.belt.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_glasses)
				if( !(slot_flags & SLOT_EYES) )
					return 0
				if(H.glasses)
					if(H.glasses.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_head)
				if( !(slot_flags & SLOT_HEAD) )
					return 0
				if(H.head)
					if(H.head.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_ears)
				if( !(slot_flags & slot_ears) )
					return 0
				if(H.ears)
					if(H.ears.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_w_uniform)
				if( !(slot_flags & SLOT_ICLOTHING) )
					return 0
				if((M_FAT in H.mutations) && !(flags & ONESIZEFITSALL))
					return 0
				if(H.w_uniform)
					if(H.w_uniform.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_wear_id)
				if(!H.w_uniform)
					if(!disable_warning)
						H << "<span class='warning'> You need a jumpsuit before you can attach this [name].</span>"
					return 0
				if( !(slot_flags & SLOT_ID) )
					return 0
				if(H.wear_id)
					if(H.wear_id.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_l_store)
				if(H.l_store)
					return 0
				if(!H.w_uniform)
					if(!disable_warning)
						H << "<span class='warning'> You need a jumpsuit before you can attach this [name].</span>"
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
						H << "<span class='warning'> You need a jumpsuit before you can attach this [name].</span>"
					return 0
				if(slot_flags & SLOT_DENYPOCKET)
					return 0
				if( w_class <= 2 || (slot_flags & SLOT_POCKET) )
					return 1
				return 0
			if(slot_s_store)
				if(!H.wear_suit)
					if(!disable_warning)
						H << "<span class='warning'> You need a suit before you can attach this [name].</span>"
					return 0
				if(!H.wear_suit.allowed)
					if(!disable_warning)
						usr << "You somehow have a suit with no defined allowed items for suit storage, stop that."
					return 0
				if(src.w_class > 3)
					if(!disable_warning)
						usr << "The [name] is too big to attach."
					return 0
				if( istype(src, /obj/item/device/pda) || istype(src, /obj/item/weapon/pen) || is_type_in_list(src, H.wear_suit.allowed) )
					if(H.s_store)
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
/mob/proc/reset_view(atom/A)
	if (client)
		if (istype(A, /atom/movable))
			client.perspective = EYE_PERSPECTIVE
			client.eye = A
		else
			if (isturf(loc))
				client.eye = client.mob
				client.perspective = MOB_PERSPECTIVE
			else
				client.perspective = EYE_PERSPECTIVE
				client.eye = loc
	return


/mob/proc/show_inv(mob/user as mob)
	user.set_machine(src)
	var/dat = {"
	<B><HR><FONT size=3>[name]</FONT></B>
	<BR><HR>
	<BR><B>Head(Mask):</B> <A href='?src=\ref[src];item=mask'>[(wear_mask ? wear_mask : "Nothing")]</A>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=l_hand'>[(l_hand ? l_hand  : "Nothing")]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=r_hand'>[(r_hand ? r_hand : "Nothing")]</A>
	<BR><B>Back:</B> <A href='?src=\ref[src];item=back'>[(back ? back : "Nothing")]</A> [((istype(wear_mask, /obj/item/clothing/mask) && istype(back, /obj/item/weapon/tank) && !( internal )) ? text(" <A href='?src=\ref[];item=internal'>Set Internal</A>", src) : "")]
	<BR>[(internal ? text("<A href='?src=\ref[src];item=internal'>Remove Internal</A>") : "")]
	<BR><A href='?src=\ref[src];item=pockets'>Empty Pockets</A>
	<BR><A href='?src=\ref[user];refresh=1'>Refresh</A>
	<BR><A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A>
	<BR>"}
	user << browse(dat, text("window=mob[];size=325x500", name))
	onclose(user, "mob\ref[src]")
	return

/mob/proc/ret_grab(obj/effect/list_container/mobl/L as obj, flag)
	if ((!( istype(l_hand, /obj/item/weapon/grab) ) && !( istype(r_hand, /obj/item/weapon/grab) )))
		if (!( L ))
			return null
		else
			return L.container
	else
		if (!( L ))
			L = new /obj/effect/list_container/mobl( null )
			L.container += src
			L.master = src
		if (istype(l_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = l_hand
			if (!( L.container.Find(G.affecting) ))
				L.container += G.affecting
				if (G.affecting)
					G.affecting.ret_grab(L, 1)
		if (istype(r_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = r_hand
			if (!( L.container.Find(G.affecting) ))
				L.container += G.affecting
				if (G.affecting)
					G.affecting.ret_grab(L, 1)
		if (!( flag ))
			if (L.master == src)
				var/list/temp = list(  )
				temp += L.container
				L.loc = null
				return temp
			else
				return L.container
	return

/mob/verb/pointed(atom/A as turf | obj | mob in view())
	set name = "Point To"
	set category = "Object"

	if(!src || !isturf(src.loc))
		return

	if(src.stat != CONSCIOUS || src.restrained())
		return

	if(src.status_flags & FAKEDEATH)
		return

	if(!(A in view(src.loc)))
		return

	if(istype(A, /obj/effect/decal/point))
		return

	var/tile = get_turf(A)

	if(isnull(tile))
		return

	var/obj/point = new/obj/effect/decal/point(tile)

	spawn(20)
		if(point)
			qdel(point)

	usr.visible_message("<b>[src]</b> points to [A]")

/mob/verb/mode()
	set name = "Activate Held Object"
	set category = "IC"
	set src = usr

	if(istype(loc,/obj/mecha)) return

	if(hand)
		var/obj/item/W = l_hand
		if (W)
			W.attack_self(src)
			update_inv_l_hand()
	else
		var/obj/item/W = r_hand
		if (W)
			W.attack_self(src)
			update_inv_r_hand()
	//if(next_move < world.time)
	//	next_move = world.time + 2
	return

/*
/mob/verb/dump_source()

	var/master = "<PRE>"
	for(var/t in typesof(/area))
		master += text("[]\n", t)
		//Foreach goto(26)
	src << browse(master)
	return
*/

/mob/verb/memory()
	set name = "Notes"
	set category = "IC"
	if(mind)
		mind.show_memory(src)
	else
		src << "The game appears to have misplaced your mind datum, so we can't show you your notes."

/mob/verb/add_memory(msg as message)
	set name = "Add Note"
	set category = "IC"

	msg = copytext(msg, 1, MAX_MESSAGE_LEN)
	msg = sanitize(msg)

	if(mind)
		mind.store_memory(msg)
	else
		src << "The game appears to have misplaced your mind datum, so we can't show you your notes."

/mob/proc/store_memory(msg as message, popup, sane = 1)
	msg = copytext(msg, 1, MAX_MESSAGE_LEN)

	if (sane)
		msg = sanitize(msg)

	if (length(memory) == 0)
		memory += msg
	else
		memory += "<BR>[msg]"

	if (popup)
		memory()

/mob/proc/update_flavor_text()
	set src in usr
	if(usr != src)
		usr << "No."
	var/msg = input(usr,"Set the flavor text in your 'examine' verb. Can also be used for OOC notes about your character.","Flavor Text",html_decode(flavor_text)) as message|null

	if(msg != null)
		msg = copytext(msg, 1, MAX_MESSAGE_LEN)
		msg = html_encode(msg)

		flavor_text = msg

/mob/proc/warn_flavor_changed()
	if(flavor_text) // Don't spam people that don't use it!
		src << "<h2 class='alert'>OOC Warning:</h2>"
		src << "<span class='alert'>Your flavor text is likely out of date! <a href='?src=\ref[src];flavor_text=change'>Change</a></span>"

/mob/proc/print_flavor_text()
	if(flavor_text)
		var/msg = replacetext(flavor_text, "\n", "<br />")

		if(length(msg) <= 32)
			return "<font color='#ffa000'><b>[msg]</b></font>"
		else
			return "<font color='#ffa000'><b>[copytext(msg, 1, 32)]...<a href='?src=\ref[src];flavor_text=more'>More</a></b></font>"

/*
/mob/verb/help()
	set name = "Help"
	src << browse('html/help.html', "window=help")
	return
*/

/mob/verb/abandon_mob()
	set name = "Respawn"
	set category = "OOC"

	if (!( abandon_allowed ))
		usr << "<span class='notice'> Respawn is disabled.</span>"
		return
	if ((stat != 2 || !( ticker )))
		usr << "<span class='notice'> <B>You must be dead to use this!</B></span>"
		return
	if (ticker.mode.name == "meteor" || ticker.mode.name == "epidemic") //BS12 EDIT
		usr << "<span class='notice'> Respawn is disabled.</span>"
		return
	else
		var/deathtime = world.time - src.timeofdeath
		if(istype(src,/mob/dead/observer))
			var/mob/dead/observer/G = src
			if(G.has_enabled_antagHUD == 1 && config.antag_hud_restricted)
				usr << "<span class='notice'> <B>Upon using the antagHUD you forfeighted the ability to join the round.</B></span>"
				return
		var/deathtimeminutes = round(deathtime / 600)
		var/pluralcheck = "minute"
		if(deathtimeminutes == 0)
			pluralcheck = ""
		else if(deathtimeminutes == 1)
			pluralcheck = " [deathtimeminutes] minute and"
		else if(deathtimeminutes > 1)
			pluralcheck = " [deathtimeminutes] minutes and"
		var/deathtimeseconds = round((deathtime - deathtimeminutes * 600) / 10,1)
		usr << "You have been dead for[pluralcheck] [deathtimeseconds] seconds."
		if (deathtime < config.respawn_delay*600)
			usr << "You must wait [config.respawn_delay] minutes to respawn!"
			return
		else
			usr << "You can respawn now, enjoy your new life!"

	log_game("[usr.name]/[usr.key] used abandon mob.")

	usr << "<span class='notice'> <B>Make sure to play a different character, and please roleplay correctly!</B></span>"

	if(!client)
		log_game("[usr.key] AM failed due to disconnect.")
		return
	client.screen.Cut()
	if(!client)
		log_game("[usr.key] AM failed due to disconnect.")
		return

	var/mob/new_player/M = new /mob/new_player()
	if(!client)
		log_game("[usr.key] AM failed due to disconnect.")
		del(M)
		return

	M.key = key
//	M.Login()	//wat
	return

/client/verb/changes()
	set name = "Changelog"
	set category = "OOC"
	getFiles(
		'html/postcardsmall.jpg',
		'html/somerights20.png',
		'html/88x31.png',
		'html/bug-minus.png',
		'html/cross-circle.png',
		'html/hard-hat-exclamation.png',
		'html/image-minus.png',
		'html/image-plus.png',
		'html/music-minus.png',
		'html/music-plus.png',
		'html/tick-circle.png',
		'html/wrench-screwdriver.png',
		'html/spell-check.png',
		'html/burn-exclamation.png',
		'html/chevron.png',
		'html/chevron-expand.png',
		'html/changelog.css',
		'html/changelog.js',
		'html/changelog.html'
		)
	src << browse('html/changelog.html', "window=changes;size=675x650")
	if(prefs.lastchangelog != changelog_hash)
		prefs.lastchangelog = changelog_hash
		prefs.save_preferences()
		winset(src, "rpane.changelog", "background-color=none;font-style=;")

/mob/verb/observe()
	set name = "Observe"
	set category = "OOC"
	var/is_admin = 0

	if(client.holder && (client.holder.rights & R_ADMIN))
		is_admin = 1
	else if(stat != DEAD || istype(src, /mob/new_player))
		usr << "<span class='notice'> You must be observing to use this!</span>"
		return

	if(is_admin && stat == DEAD)
		is_admin = 0

	var/list/names = list()
	var/list/namecounts = list()
	var/list/creatures = list()

	for(var/obj/O in world)				//EWWWWWWWWWWWWWWWWWWWWWWWW ~needs to be optimised
		if(!O.loc)
			continue
		if(istype(O, /obj/item/weapon/disk/nuclear))
			var/name = "Nuclear Disk"
			if (names.Find(name))
				namecounts[name]++
				name = "[name] ([namecounts[name]])"
			else
				names.Add(name)
				namecounts[name] = 1
			creatures[name] = O

		if(istype(O, /obj/machinery/singularity))
			var/name = "Singularity"
			if (names.Find(name))
				namecounts[name]++
				name = "[name] ([namecounts[name]])"
			else
				names.Add(name)
				namecounts[name] = 1
			creatures[name] = O

		if(istype(O, /obj/machinery/bot))
			var/name = "BOT: [O.name]"
			if (names.Find(name))
				namecounts[name]++
				name = "[name] ([namecounts[name]])"
			else
				names.Add(name)
				namecounts[name] = 1
			creatures[name] = O


	for(var/mob/M in sortNames(mob_list))
		var/name = M.name
		if (names.Find(name))
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1

		creatures[name] = M


	client.perspective = EYE_PERSPECTIVE

	var/eye_name = null

	var/ok = "[is_admin ? "Admin Observe" : "Observe"]"
	eye_name = input("Please, select a player!", ok, null, null) as null|anything in creatures

	if (!eye_name)
		return

	var/mob/mob_eye = creatures[eye_name]

	if(client && mob_eye)
		client.eye = mob_eye
		if (is_admin)
			client.adminobs = 1
			if(mob_eye == client.mob || client.eye == client.mob)
				client.adminobs = 0

/mob/verb/cancel_camera()
	set name = "Cancel Camera View"
	set category = "OOC"
	reset_view(null)
	unset_machine()
	if(istype(src, /mob/living))
		if(src:cameraFollow)
			src:cameraFollow = null

/mob/Topic(href,href_list[])
	if(href_list["mach_close"])
		var/t1 = text("window=[href_list["mach_close"]]")
		unset_machine()
		src << browse(null, t1)

	switch(href_list["flavor_text"])
		if("more")
			usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", name, replacetext(flavor_text, "\n", "<BR>")), text("window=[];size=500x200", name))
			onclose(usr, "[name]")
		if("change")
			update_flavor_text()

/mob/proc/pull_damage()
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.health - H.halloss <= config.health_threshold_softcrit)
			for(var/name in H.organs_by_name)
				var/datum/organ/external/e = H.organs_by_name[name]
				if(H.lying)
					if(((e.status & ORGAN_BROKEN && !(e.status & ORGAN_SPLINTED)) || e.status & ORGAN_BLEEDING) && (H.getBruteLoss() + H.getFireLoss() >= 100))
						return 1
						break
		return 0

/mob/MouseDrop(mob/M as mob)
	..()
	if(M != usr) return
	if(usr == src) return
	if(!Adjacent(usr)) return
	if(istype(M,/mob/living/silicon/ai)) return
	show_inv(usr)


/mob/verb/stop_pulling()

	set name = "Stop Pulling"
	set category = "IC"

	if(pulling)
		pulling.pulledby = null
		pulling = null

/mob/proc/start_pulling(var/atom/movable/AM)

	if ( !AM || !usr || src==AM || !isturf(src.loc) )	//if there's no person pulling OR the person is pulling themself OR the object being pulled is inside something: abort!
		return

	if (AM.anchored)
		return

	var/mob/M = AM
	if(ismob(AM))
		if(!iscarbon(src))
			M.LAssailant = null
		else
			M.LAssailant = usr

	if(pulling)
		var/pulling_old = pulling
		stop_pulling()
		// Are we pulling the same thing twice? Just stop pulling.
		if(pulling_old == AM)
			return

	src.pulling = AM
	AM.pulledby = src

	if(ismob(AM))
		M.attack_log += text("\[[time_stamp()]\] <span class='warning'>Has been pulled by [src.name] ([src.ckey])</span>")
		src.attack_log += text("\[[time_stamp()]\] <span class='warning'>Pulled [M.name] ([M.ckey])</span>")

		if(ishuman(AM))
			var/mob/living/carbon/human/H = AM
			if(H.pull_damage())
				src << "<span class='warning'> <B>Pulling \the [H] in their current condition would probably be a bad idea.</B></span>"

	//Attempted fix for people flying away through space when cuffed and dragged.
	if(ismob(AM))
		var/mob/pulled = AM
		pulled.inertia_dir = 0

/mob/proc/can_use_hands()
	return

/mob/proc/is_active()
	return (0 >= usr.stat)

/mob/proc/see(message)
	if(!is_active())
		return 0
	src << message
	return 1

/mob/proc/show_viewers(message)
	for(var/mob/M in viewers())
		M.see(message)

/*
adds a dizziness amount to a mob
use this rather than directly changing var/dizziness
since this ensures that the dizzy_process proc is started
currently only humans get dizzy

value of dizziness ranges from 0 to 1000
below 100 is not dizzy
*/
/mob/proc/make_dizzy(var/amount)
	if(!istype(src, /mob/living/carbon/human)) // for the moment, only humans get dizzy
		return

	dizziness = min(1000, dizziness + amount)	// store what will be new value
													// clamped to max 1000
	if(dizziness > 100 && !is_dizzy)
		spawn(0)
			dizzy_process()


/*
dizzy process - wiggles the client's pixel offset over time
spawned from make_dizzy(), will terminate automatically when dizziness gets <100
note dizziness decrements automatically in the mob's Life() proc.
*/
/mob/proc/dizzy_process()
	is_dizzy = 1
	while(dizziness > 100)
		if(client)
			var/amplitude = dizziness*(sin(dizziness * 0.044 * world.time) + 1) / 70
			client.pixel_x = amplitude * sin(0.008 * dizziness * world.time)
			client.pixel_y = amplitude * cos(0.008 * dizziness * world.time)

		sleep(1)
	//endwhile - reset the pixel offsets to zero
	is_dizzy = 0
	if(client)
		client.pixel_x = 0
		client.pixel_y = 0

// jitteriness - copy+paste of dizziness

/mob/proc/make_jittery(var/amount)
	if(!istype(src, /mob/living/carbon/human)) // for the moment, only humans get dizzy
		return

	jitteriness = min(1000, jitteriness + amount)	// store what will be new value
													// clamped to max 1000
	if(jitteriness > 100 && !is_jittery)
		spawn(0)
			jittery_process()


// Typo from the oriignal coder here, below lies the jitteriness process. So make of his code what you will, the previous comment here was just a copypaste of the above.
/mob/proc/jittery_process()
	var/old_x = pixel_x
	var/old_y = pixel_y
	is_jittery = 1
	while((jitteriness > 100) && !isolated)
//		var/amplitude = jitteriness*(sin(jitteriness * 0.044 * world.time) + 1) / 70
//		pixel_x = amplitude * sin(0.008 * jitteriness * world.time)
//		pixel_y = amplitude * cos(0.008 * jitteriness * world.time)

		var/amplitude = min(4, jitteriness / 100)
		pixel_x = rand(-amplitude, amplitude)
		pixel_y = rand(-amplitude/3, amplitude/3)

		sleep(1)
	//endwhile - reset the pixel offsets to zero
	is_jittery = 0
	pixel_x = old_x
	pixel_y = old_y

/mob/Stat()
	..()

	if(client && client.holder)

		if (statpanel("Status"))	//not looking at that panel
			stat(null, "Location:\t([x], [y], [z])")
			stat(null, "CPU:\t[world.cpu]")
			stat(null, "Instances:\t[world.contents.len]")

			if (master_controller)
				stat(null, "MasterController-[last_tick_duration] ([master_controller.processing?"On":"Off"]-[master_controller.iteration])")
				stat(null, "Air-[master_controller.air_cost]")
				stat(null, "Sun-[master_controller.sun_cost]")
				stat(null, "Mob-[master_controller.mobs_cost]\t#[mob_list.len]")
				stat(null, "Dis-[master_controller.diseases_cost]\t#[active_diseases.len]")
				stat(null, "Mch-[master_controller.machines_cost]\t#[machines.len]")
				stat(null, "Obj-[master_controller.objects_cost]\t#[processing_objects.len]")
				stat(null, "PiNet-[master_controller.networks_cost]\t#[pipe_networks.len]")
				stat(null, "Ponet-[master_controller.powernets_cost]\t#[powernets.len]")
				stat(null, "NanoUI-[master_controller.nano_cost]\t#[nanomanager.processing_uis.len]")
				stat(null, "Tick-[master_controller.ticker_cost]")
				stat(null, "garbage collector - [master_controller.garbageCollectorCost]")
				stat(null, "\tqdel - [garbageCollector.del_everything ? "off" : "on"]")
				stat(null, "\ton queue - [garbageCollector.queue.len]")
				stat(null, "\ttotal delete - [garbageCollector.dels_count]")
				stat(null, "\tsoft delete - [garbageCollector.dels_count - garbageCollector.hard_dels]")
				stat(null, "\thard delete - [garbageCollector.hard_dels]")
				stat(null, "ALL - [master_controller.total_cost]")
			else
				stat(null, "master controller - ERROR")

	if(listed_turf && client)
		if(get_dist(listed_turf,src) > 1)
			listed_turf = null
		else
			statpanel(listed_turf.name, null, listed_turf)
			for(var/atom/A in listed_turf)
				if(A.invisibility > see_invisible)
					continue
				statpanel(listed_turf.name, null, A)

	if(spell_list && spell_list.len)
		for(var/obj/effect/proc_holder/spell/S in spell_list)
			if(istype(S, /obj/effect/proc_holder/spell/noclothes))
				continue //Not showing the noclothes spell
			switch(S.charge_type)
				if("recharge")
					statpanel(S.panel,"[S.charge_counter/10.0]/[S.charge_max/10]",S)
				if("charges")
					statpanel(S.panel,"[S.charge_counter]/[S.charge_max]",S)
				if("holdervar")
					statpanel(S.panel,"[S.holder_var_type] [S.holder_var_amount]",S)



// facing verbs
/mob/proc/canface()
	if(!canmove)						return 0
	if(client.moving)					return 0
	if(world.time < client.move_delay)	return 0
	if(stat==2)							return 0
	if(anchored)						return 0
	if(monkeyizing)						return 0
	if(restrained())					return 0
	return 1

//Updates canmove, lying and icons. Could perhaps do with a rename but I can't think of anything to describe it.
/mob/proc/update_canmove()
	if(buckled)
		anchored = 1
		canmove = 0
		if( istype(buckled,/obj/structure/stool/bed/chair) )
			lying = 0
		else
			lying = 1
	else if( stat || weakened || paralysis || resting || sleeping || (status_flags & FAKEDEATH))
		lying = 1
		canmove = 0
	else if( stunned )
//		lying = 0
		canmove = 0
	else if(captured)
		anchored = 1
		canmove = 0
		lying = 0
	else
		lying = !can_stand
		canmove = has_limbs

	if(lying)
		if(ishuman(src))
			layer = 3.9
		density = 0
		drop_l_hand()
		drop_r_hand()
	else
		if(ishuman(src))
			layer = 4
		density = 1

	//Temporarily moved here from the various life() procs
	//I'm fixing stuff incrementally so this will likely find a better home.
	//It just makes sense for now. ~Carn
	if( update_icon )	//forces a full overlay update
		update_icon = 0
		regenerate_icons()
	else if( lying != lying_prev )
		update_icons()

	return canmove


/mob/verb/eastface()
	set hidden = 1
	if(!canface())	return 0
	dir = EAST
	Facing()
	client.move_delay += movement_delay()
	return 1


/mob/verb/westface()
	set hidden = 1
	if(!canface())	return 0
	dir = WEST
	Facing()
	client.move_delay += movement_delay()
	return 1


/mob/verb/northface()
	set hidden = 1
	if(!canface())	return 0
	dir = NORTH
	Facing()
	client.move_delay += movement_delay()
	return 1


/mob/verb/southface()
	set hidden = 1
	if(!canface())	return 0
	dir = SOUTH
	Facing()
	client.move_delay += movement_delay()
	return 1


/mob/proc/Facing()
    var/datum/listener
    for(. in src.callOnFace)
        listener = locate(.)
        if(listener) call(listener,src.callOnFace[.])(src)
        else src.callOnFace -= .


/mob/proc/IsAdvancedToolUser()//This might need a rename but it should replace the can this mob use things check
	return 0


/mob/proc/Stun(amount)
	if(status_flags & CANSTUN)
		stunned = max(max(stunned,amount),0) //can't go below 0, getting a low amount of stun doesn't lower your current stun
	return

/mob/proc/SetStunned(amount) //if you REALLY need to set stun to a set amount without the whole "can't go below current stunned"
	if(status_flags & CANSTUN)
		stunned = max(amount,0)
	return

/mob/proc/AdjustStunned(amount)
	if(status_flags & CANSTUN)
		stunned = max(stunned + amount,0)
	return

/mob/proc/Weaken(amount)
	if(status_flags & CANWEAKEN)
		weakened = max(max(weakened,amount),0)
		update_canmove()	//updates lying, canmove and icons
	return

/mob/proc/SetWeakened(amount)
	if(status_flags & CANWEAKEN)
		weakened = max(amount,0)
		update_canmove()	//updates lying, canmove and icons
	return

/mob/proc/AdjustWeakened(amount)
	if(status_flags & CANWEAKEN)
		weakened = max(weakened + amount,0)
		update_canmove()	//updates lying, canmove and icons
	return

/mob/proc/Paralyse(amount)
	if(status_flags & CANPARALYSE)
		paralysis = max(max(paralysis,amount),0)
	return

/mob/proc/SetParalysis(amount)
	if(status_flags & CANPARALYSE)
		paralysis = max(amount,0)
	return

/mob/proc/AdjustParalysis(amount)
	if(status_flags & CANPARALYSE)
		paralysis = max(paralysis + amount,0)
	return

/mob/proc/Sleeping(amount)
	sleeping = max(max(sleeping,amount),0)
	return

/mob/proc/SetSleeping(amount)
	sleeping = max(amount,0)
	return

/mob/proc/AdjustSleeping(amount)
	sleeping = max(sleeping + amount,0)
	return

/mob/proc/Resting(amount)
	resting = max(max(resting,amount),0)
	return

/mob/proc/SetResting(amount)
	resting = max(amount,0)
	return

/mob/proc/AdjustResting(amount)
	resting = max(resting + amount,0)
	return

/mob/proc/get_species()
	return ""

/mob/proc/flash_weak_pain()
	flick("weak_pain",pain)

mob/proc/yank_out_object()
	set category = "Object"
	set name = "Yank out object"
	set desc = "Remove an embedded item at the cost of bleeding and pain."
	set src in view(1)

	if(!isliving(usr) || usr.next_move > world.time)
		return
	usr.next_move = world.time + 20

	if(usr.stat == 1)
		usr << "You are unconcious and cannot do that!"
		return

	if(usr.restrained())
		usr << "You are restrained and cannot do that!"
		return

	var/mob/S = src
	var/mob/U = usr
	var/list/valid_objects = list()
	var/self = null

	if(S == U)
		self = 1 // Removing object from yourself.

	for(var/obj/item/weapon/W in embedded)
		if(W.w_class >= 2)
			valid_objects += W

	if(!valid_objects.len)
		if(self)
			src << "You have nothing stuck in your body that is large enough to remove."
		else
			U << "[src] has nothing stuck in their wounds that is large enough to remove."
		return

	var/obj/item/weapon/selection = input("What do you want to yank out?", "Embedded objects") in valid_objects

	if(self)
		src << "<span class='warning'>You attempt to get a good grip on the [selection] in your body.</span></span>"
	else
		U << "<span class='warning'>You attempt to get a good grip on the [selection] in [S]'s body.</span>"

	if(!do_after(U, 80))
		return
	if(!selection || !S || !U)
		return

	if(self)
		visible_message("<span class='warning'><b>[src] rips [selection] out of their body.</b></span>","<span class='warning'><b>You rip [selection] out of your body.</b></span>")
	else
		visible_message("<span class='warning'><b>[usr] rips [selection] out of [src]'s body.</b></span>","<span class='warning'><b>[usr] rips [selection] out of your body.</b></span>")

	selection.loc = get_turf(src)

	for(var/obj/item/weapon/O in pinned)
		if(O == selection)
			pinned -= O
		if(!pinned.len)
			anchored = 0
	return 1

// Mobs tell access what access levels it has.
/mob/proc/GetAccess()
	return list()

// Skip over all the complex list checks.
/mob/proc/hasFullAccess()
	return 0

mob/proc/assess_threat()
	return 0
