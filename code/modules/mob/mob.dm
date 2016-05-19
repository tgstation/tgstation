#define MOB_SPACEDRUGS_HALLUCINATING 5
#define MOB_MINDBREAKER_HALLUCINATING 100

/obj/screen/fuckstat
	name = "Toggle Stat"
	desc = "Fuck It"
	icon = 'icons/fuckstat.dmi'
	icon_state = "fuckstat"

	Click()
		var/mob/M = usr
		if(!istype(M)) return
		M.stat_fucked = !M.stat_fucked

var/global/obj/screen/fuckstat/FUCK = new
/mob/recycle(var/datum/materials)
	return RECYK_BIOLOGICAL

/mob/burnFireFuel(var/used_fuel_ratio,var/used_reactants_ratio)

/mob/Destroy() // This makes sure that mobs with clients/keys are not just deleted from the game.
	if(on_uattack) on_uattack.holder = null
	unset_machine()
	if(mind && mind.current == src)
		mind.current = null
	spellremove(src)
	if(istype(src,/mob/living/carbon))//iscarbon is defined at the mob/living level
		var/mob/living/carbon/Ca = src
		Ca.dropBorers(1)//sanity checking for borers that haven't been qdel'd yet
	if(client)
		for(var/obj/screen/movable/spell_master/spell_master in spell_masters)
			returnToPool(spell_master)
		spell_masters = null
		spells = null
		remove_screen_objs()
		for(var/atom/movable/AM in client.screen)
			var/obj/screen/screenobj = AM
			if(istype(screenobj))
				if(!screenobj.globalscreen) //Screens taken care of in other places or used by multiple people
					returnToPool(AM)
			else
				qdel(AM)
		client.screen = list()
	mob_list.Remove(src)
	dead_mob_list.Remove(src)
	living_mob_list.Remove(src)
	ghostize(0)
	//Fuck datums amirite
	click_delayer = null
	attack_delayer = null
	special_delayer = null
	gui_icons = null
	qdel(hud_used)
	hud_used = null
	for(var/atom/movable/leftovers in src)
		qdel(leftovers)
	if(on_uattack)
		on_uattack.holder = null
		on_uattack = null
	qdel(on_logout)
	on_logout = null
	..()

/mob/projectile_check()
	return PROJREACT_MOBS

/mob/proc/remove_screen_objs()
	if(flash)
		returnToPool(flash)
		if(client) client.screen -= flash
		flash = null
	if(blind)
		returnToPool(blind)
		if(client) client.screen -= blind
		blind = null
	if(hands)
		returnToPool(hands)
		if(client) client.screen -= hands
		hands = null
	if(pullin)
		returnToPool(pullin)
		if(client) client.screen -= pullin
		pullin = null
	if(visible)
		returnToPool(visible)
		if(client) client.screen -= visible
		visible = null
	if(purged)
		returnToPool(purged)
		if(client) client.screen -= purged
		purged = null
	if(internals)
		returnToPool(internals)
		if(client) client.screen -= internals
		internals = null
	if(oxygen)
		returnToPool(oxygen)
		if(client) client.screen -= oxygen
		oxygen = null
	if(i_select)
		returnToPool(i_select)
		if(client) client.screen -= i_select
		i_select = null
	if(m_select)
		returnToPool(m_select)
		if(client) client.screen -= m_select
		m_select = null
	if(toxin)
		returnToPool(toxin)
		if(client) client.screen -= toxin
		toxin = null
	if(fire)
		returnToPool(fire)
		if(client) client.screen -= fire
		fire = null
	if(bodytemp)
		returnToPool(bodytemp)
		if(client) client.screen -= bodytemp
		bodytemp = null
	if(healths)
		returnToPool(healths)
		if(client) client.screen -= healths
		healths = null
	if(throw_icon)
		returnToPool(throw_icon)
		if(client) client.screen -= throw_icon
		throw_icon = null
	if(nutrition_icon)
		returnToPool(nutrition_icon)
		if(client) client.screen -= nutrition_icon
		nutrition_icon = null
	if(pressure)
		returnToPool(pressure)
		if(client) client.screen -= pressure
		pressure = null
	if(damageoverlay)
		returnToPool(damageoverlay)
		if(client) client.screen -= damageoverlay
		damageoverlay = null
	if(pain)
		returnToPool(pain)
		if(client) client.screen -= pain
		pain = null
	if(item_use_icon)
		returnToPool(item_use_icon)
		if(client) client.screen -= item_use_icon
		item_use_icon = null
	if(gun_move_icon)
		returnToPool(gun_move_icon)
		if(client) client.screen -= gun_move_icon
		gun_move_icon = null
	if(gun_run_icon)
		returnToPool(gun_run_icon)
		if(client) client.screen -= gun_run_icon
		gun_run_icon = null
	if(gun_setting_icon)
		returnToPool(gun_setting_icon)
		if(client) client.screen -= gun_setting_icon
		gun_setting_icon = null
	if(m_suitclothes)
		returnToPool(m_suitclothes)
		if(client) client.screen -= m_suitclothes
		m_suitclothes = null
	if(m_suitclothesbg)
		returnToPool(m_suitclothesbg)
		if(client) client.screen -= m_suitclothesbg
		m_suitclothesbg = null
	if(m_hat)
		returnToPool(m_hat)
		if(client) client.screen -= m_hat
		m_hat = null
	if(m_hatbg)
		returnToPool(m_hatbg)
		if(client) client.screen -= m_hatbg
		m_hatbg = null
	if(m_glasses)
		returnToPool(m_glasses)
		if(client) client.screen -= m_glasses
		m_glasses = null
	if(m_glassesbg)
		returnToPool(m_glassesbg)
		if(client) client.screen -= m_glassesbg
		m_glasses = null
	if(zone_sel)
		returnToPool(zone_sel)
		if(client) client.screen -= zone_sel
		zone_sel = null
	if(hud_used)
		for(var/obj/screen/item_action/actionitem in hud_used.item_action_list)
			if(client)
				client.screen -= actionitem
				client.images -= actionitem.overlay
			returnToPool(actionitem)
			hud_used.item_action_list -= actionitem

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
	on_uattack = new("owner"=src)
	on_logout = new("owner"=src)

	forceMove(loc) //Without this, area.Entered() isn't called when a mob is spawned inside area

	if(flags & HEAR_ALWAYS)
		getFromPool(/mob/virtualhearer, src)

/mob/proc/is_muzzled()
	return 0

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

	t += {"<span class='warning'> Temperature: [environment.temperature] \n</span>
<span class='notice'> Nitrogen: [environment.nitrogen] \n</span>
<span class='notice'> Oxygen: [environment.oxygen] \n</span>
<span class='notice'> Plasma : [environment.toxins] \n</span>
<span class='notice'> Carbon Dioxide: [environment.carbon_dioxide] \n</span>"}
	for(var/datum/gas/trace_gas in environment.trace_gases)
		to_chat(usr, "<span class='notice'> [trace_gas.type]: [trace_gas.moles] \n</span>")

	usr.show_message(t, 1)

/mob/proc/simple_message(var/msg, var/hallucination_msg) // Same as M << "message", but with additinal message for hallucinations.
	if(hallucinating() && hallucination_msg)
		to_chat(src, hallucination_msg)
	else
		to_chat(src, msg)

/mob/proc/show_message(msg, type, alt, alt_type)//Message, type of message (1=visible or 2=hearable), alternative message, alt message type (1=if blind or 2=if deaf)


	//Because the person who made this is a fucking idiot, let's clarify. 1 is sight-related messages (aka emotes in general), 2 is hearing-related (aka HEY DUMBFUCK I'M TALKING TO YOU)

	if(!client) //We dun goof
		return

	msg = copytext(msg, 1, MAX_MESSAGE_LEN)

	if(type)
		if((type & MESSAGE_SEE) && is_blind()) //Vision related //We can't see all those emotes no-one ever does !
			if(!(alt))
				return
			else
				msg = alt
				type = alt_type
		if((type & MESSAGE_HEAR) && is_deaf()) //Hearing related //We can't hear what the person is saying. Too bad
			if(!(alt))
				to_chat(src, "<span class='notice'>You can almost hear someone talking.</span>")//Well, not THAT deaf

				return //And that does it
			else
				msg = alt
				type = alt_type
				if((type & MESSAGE_SEE) && (sdisabilities & BLIND || blinded || paralysis)) //Since the alternative is sight-related, make sure we can see
					return
	//Added voice muffling for Issue 41.
	//This has been changed to only work with audible messages, because you can't hear a frown
	//This blocks "audible" emotes like gasping and screaming, but that's such a small loss. Who wants to hear themselves gasping to death ? I don't
	if(stat == UNCONSCIOUS || sleeping > 0) //No-one's home
		if((type & MESSAGE_SEE)) //This is an emote
			if(!(alt)) //No alternative message
				return //We can't see it, we're a bit too dying over here
			else //Hey look someone passed an alternative message
				to_chat(src, "<span class='notice'>You can almost hear someone talking.</span>")//Now we can totally not hear it!

				return //And we're good
		else //This is not an emote
			to_chat(src, "<span class='notice'>You can almost hear someone talking.</span>")//The sweet silence of death

			return //All we ever needed to hear
	else //We're fine
		to_chat(src, msg)//Send it

	return

// Show a message to all mobs in sight of this one
// This would be for visible actions by the src mob
// message is the message output to anyone who can see e.g. "[src] does something!"
// self_message (optional) is what the src mob sees  e.g. "You do something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"
// drugged_message (optional) is shown to hallucinating mobs instead of message
// self_drugged_message (optional) is shown to src mob if it's hallucinating
// blind_drugged_message (optional) is shown to blind hallucinating people

/mob/visible_message(var/message, var/self_message, var/blind_message, var/drugged_message, var/self_drugged_message, var/blind_drugged_message)
	var/list/L //Go through mobs in this list and show them the message. Unless the mob is picked up (and is in a "holder" item), this equals to viewers(src).

	if(istype(loc, /obj/item/weapon/holder))
		L = viewers(get_turf(src))
	else
		L = viewers(src)

	for(var/mob/M in L)
		if(M.see_invisible < invisibility)
			continue
		var/hallucination = M.hallucinating()
		var/msg = message
		var/msg2 = blind_message

		if(hallucination && drugged_message)
			if(drugged_message)
				msg = drugged_message
			if(blind_drugged_message)
				msg2 = blind_drugged_message

		if(M==src)
			if(self_message)
				msg = self_message
			if(hallucination && self_drugged_message)
				msg = self_drugged_message

		M.show_message( msg, 1, msg2, 2)

// Show a message to all mobs in sight of this atom
// Use for objects performing visible actions
// message is output to anyone who can see, e.g. "The [src] does something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"
/atom/proc/visible_message(var/message, var/blind_message, var/drugged_message, var/blind_drugged_message)
	if(world.time>resethearers) sethearing()
	for(var/mob/virtualhearer/hearer in viewers(src))
		if(istype(hearer.attached, /mob))
			var/mob/M = hearer.attached
			var/hallucination = M.hallucinating()
			var/msg = message
			var/msg2 = blind_message

			if(hallucination)
				if(drugged_message)
					msg = drugged_message
				if(blind_drugged_message)
					msg2 = blind_drugged_message
			M.show_message( msg, 1, msg2, 2)
		else if(istype(hearer.attached, /obj/machinery/hologram/holopad))
			var/obj/machinery/hologram/holopad/holo = hearer.attached
			if(holo.master)
				holo.master.show_message( message, 1, blind_message, 2)

/mob/proc/findname(msg)
	for(var/mob/M in mob_list)
		if (M.real_name == text("[]", msg))
			return M
	return 0

/mob/proc/movement_delay()
	return 0

/mob/proc/Life()
	if(timestopped) return 0 //under effects of time magick
	if(spell_masters && spell_masters.len)
		for(var/obj/screen/movable/spell_master/spell_master in spell_masters)
			spell_master.update_spells(0, src)
	return

/mob/proc/see_narsie(var/obj/machinery/singularity/narsie/large/N, var/dir)
	if(N.chained)
		if(narsimage)
			del(narsimage)
			del(narglow)
		return

	//No need to make an exception for mechas, as they get deleted as soon as they get in view of narnar

	if((N.z == src.z)&&(get_dist(N,src) <= (N.consume_range+10)) && !(N in view(src)))
		if(!narsimage) //Create narsimage
			narsimage = image('icons/obj/narsie.dmi',src.loc,"narsie",9,1)
			narsimage.mouse_opacity = 0
		if(!narglow) //Create narglow
			narglow = image('icons/obj/narsie.dmi',narsimage.loc,"glow-narsie", LIGHTING_LAYER + 2, 1)
			narglow.mouse_opacity = 0
/* Animating narsie works like shit thanks to fucking byond
		if(!N.old_x || !N.old_y)
			N.old_x = src.x
			N.old_y = src.y
		//Reset narsie's location to the mob
		var/old_pixel_x = 32 * (N.old_x - src.x) + N.pixel_x
		var/old_pixel_y = 32 * (N.old_y - src.y) + N.pixel_y
		narsimage.pixel_x = old_pixel_x
		narsimage.pixel_y = old_pixel_y
		narglow.pixel_x = old_pixel_x
		narglow.pixel_y = old_pixel_y
		narsimage.loc = src.loc
		narglow.loc = src.loc
		//Animate narsie based on dir
		if(dir)
			var/x_diff = 0
			var/y_diff = 0
			switch(dir) //I bet somewhere out there a proc does something like this already
				if(1)
					x_diff = 32
				if(2)
					x_diff = -32
				if(4)
					y_diff = 32
				if(8)
					y_diff = -32
				if(5)
					x_diff = 32
					y_diff = 32
				if(6)
					x_diff = 32
					y_diff = -32
				if(9)
					x_diff = -32
					y_diff = 32
				if(10)
					x_diff = -32
					y_diff = -32
			animate(narsimage, pixel_x = old_pixel_x+x_diff, pixel_y = old_pixel_y+y_diff, time = 8) //Animate the movement of narsie to narsie's new location
			animate(narglow, pixel_x = old_pixel_x+x_diff, pixel_y = old_pixel_y+y_diff, time = 8)
*/
		//Else if no dir is given, simply send them the image of narsie
		var/new_x = 32 * (N.x - src.x) + N.pixel_x
		var/new_y = 32 * (N.y - src.y) + N.pixel_y
		narsimage.pixel_x = new_x
		narsimage.pixel_y = new_y
		narglow.pixel_x = new_x
		narglow.pixel_y = new_y
		narsimage.loc = src.loc
		narglow.loc = src.loc
		//Display the new narsimage to the player
		src << narsimage
		src << narglow
	else
		if(narsimage)
			del(narsimage)
			del(narglow)

/mob/proc/see_rift(var/obj/machinery/singularity/narsie/large/exit/R)
	var/turf/T_mob = get_turf(src)
	if((R.z == T_mob.z) && (get_dist(R,T_mob) <= (R.consume_range+10)) && !(R in view(T_mob)))
		if(!riftimage)
			riftimage = image('icons/obj/rift.dmi',T_mob,"rift", LIGHTING_LAYER + 2, 1)
			riftimage.mouse_opacity = 0

		var/new_x = 32 * (R.x - T_mob.x) + R.pixel_x
		var/new_y = 32 * (R.y - T_mob.y) + R.pixel_y
		riftimage.pixel_x = new_x
		riftimage.pixel_y = new_y
		riftimage.loc = T_mob

		to_chat(src, riftimage)
	else
		if(riftimage)
			del(riftimage)

/mob/proc/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_l_hand)
			return l_hand
		if(slot_r_hand)
			return r_hand
	return null


/mob/proc/restrained()
	if(timestopped) return 1 //under effects of time magick
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
						qdel(W)
						W = null
					if(EQUIP_FAILACTION_DROP)
						W.loc=get_turf(src) // I think.
					else
						if(!disable_warning)
							to_chat(src, "<span class='warning'>You are unable to equip that.</span>")//Only print if act_on_fail is NOTHING

				return 0
			if(1)
				equip_to_slot(W, slot, redraw_mob)
			if(2)
				var/in_the_hand = (src.get_active_hand() == W || src.get_inactive_hand() == W)
				var/obj/item/wearing = get_item_by_slot(slot)
				if(wearing)
					if(!in_the_hand) //if we aren't holding it, the proc is abstract so get rid of it
						switch(act_on_fail)
							if(EQUIP_FAILACTION_DELETE)
								qdel(W)
							if(EQUIP_FAILACTION_DROP)
								W.loc=get_turf(src) // I think.
						return

					if(drop_item(W))
						if(!(put_in_active_hand(wearing)))
							equip_to_slot(wearing, slot, redraw_mob)
							switch(act_on_fail)
								if(EQUIP_FAILACTION_DELETE)
									qdel(W)
								else
									if(!disable_warning && act_on_fail != EQUIP_FAILACTION_DROP)
										to_chat(src, "<span class='warning'>You are unable to equip that.</span>")//Only print if act_on_fail is NOTHING

							return
						else
							equip_to_slot(W, slot, redraw_mob)
							u_equip(wearing,0)
							put_in_active_hand(wearing)
						if(H.s_store && !H.s_store.mob_can_equip(src, slot_s_store, 1))
							u_equip(H.s_store,1)
		return 1
	else
		if(!W.mob_can_equip(src, slot, disable_warning))
			switch(act_on_fail)
				if(EQUIP_FAILACTION_DELETE)
					qdel(W)
					W = null
				if(EQUIP_FAILACTION_DROP)
					W.loc=get_turf(src) // I think.
				else
					if(!disable_warning)
						to_chat(src, "<span class='warning'>You are unable to equip that.</span>")//Only print if act_on_fail is NOTHING

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
//				if(H.species.flags & IS_BULKY)
//					to_chat(H, "<span class='warning'>You can't get \the [src] to fasten around your thick head!</span>")
//					return 0
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
//				if(H.species.flags & IS_BULKY)
//					to_chat(H, "<span class='warning'>You can't get \the [src] to fit over your bulky exterior!</span>")
//					return 0
				if(H.wear_suit)
					if(H.wear_suit.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_gloves)
				if( !(slot_flags & SLOT_GLOVES) )
					return 0
//				if(H.species.flags & IS_BULKY)
//					to_chat(H, "<span class='warning'>You can't get \the [src] to fit over your bulky fingers!</span>")
//					return 0
				if(H.gloves)
					if(H.gloves.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_shoes)
				if( !(slot_flags & SLOT_FEET) )
					return 0
//				if(H.species.flags & IS_BULKY)
//					to_chat(H, "<span class='warning'>You can't get \the [src] to fit over your bulky feet!</span>")
//					return 0
				if(H.shoes)
					if(H.shoes.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_belt)
				if(!H.w_uniform)
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
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
				if((M_FAT in H.mutations) && (H.species && H.species.flags & CAN_BE_FAT) && !(flags & ONESIZEFITSALL))
					return 0
//				if(H.species.flags & IS_BULKY && !(flags & ONESIZEFITSALL))
//					to_chat(H, "<span class='warning'>You can't get \the [src] to fit over your bulky exterior!</span>")
//					return 0
				if(H.w_uniform)
					if(H.w_uniform.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_wear_id)
				if(!H.w_uniform)
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
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
						to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
					return 0
				if(slot_flags & SLOT_DENYPOCKET)
					return
				if( w_class <= W_CLASS_SMALL || (slot_flags & SLOT_POCKET) )
					return 1
			if(slot_r_store)
				if(H.r_store)
					return 0
				if(!H.w_uniform)
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
					return 0
				if(slot_flags & SLOT_DENYPOCKET)
					return 0
				if( w_class <= W_CLASS_SMALL || (slot_flags & SLOT_POCKET) )
					return 1
				return 0
			if(slot_s_store)
				if(!H.wear_suit)
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a suit before you can attach this [name].</span>")
					return 0
				if(!H.wear_suit.allowed)
					if(!disable_warning)
						to_chat(usr, "You somehow have a suit with no defined allowed items for suit storage, stop that.")
					return 0
				if(src.w_class > W_CLASS_MEDIUM)
					if(!disable_warning)
						to_chat(usr, "The [name] is too big to attach.")
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
					if(B.contents.len < B.storage_slots && w_class <= B.fits_max_w_class)
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

//note: ghosts can point, this is intended
//visible_message will handle invisibility properly
//overriden here and in /mob/dead/observer for different point span classes and sanity checks
/mob/verb/pointed(atom/A as turf | obj | mob in view())
	set name = "Point To"
	set category = "Object"

	if(!src || usr.isUnconscious() || !isturf(src.loc) || !(A in view(src.loc)))
		return 0

	if(istype(A, /obj/effect/decal/point))
		return 0

	var/tile = get_turf(A)

	if(!tile)
		return 0

	var/obj/point = new/obj/effect/decal/point(tile)
	point.invisibility = invisibility
	spawn(20)
		if(point)
			qdel(point)

	return 1

//this and stop_pulling really ought to be /mob/living procs
/mob/proc/start_pulling(var/atom/movable/AM)
	if ( !AM || !src || src==AM || !isturf(AM.loc) )	//if there's no person pulling OR the person is pulling themself OR the object being pulled is inside something: abort!
		return

	var/atom/movable/P = AM

	if (ismob(AM))
		var/mob/M = AM
		if (M.locked_to) //If the mob is locked_to on something, let's just try to pull the thing they're locked_to to for convenience's sake.
			P = M.locked_to

	if (!( P.anchored ))
		P.add_fingerprint(src)

		// If we're pulling something then drop what we're currently pulling and pull this instead.
		if(pulling)
			// Are we trying to pull something we are already pulling? Then just stop here, no need to continue
			var/temp_P = pulling
			stop_pulling()
			if(P == temp_P)
				return

		src.pulling = P
		P.pulledby = src
		if(ismob(P))
			var/mob/M = P
			if(!iscarbon(src))
				M.LAssailant = null
			else
				M.LAssailant = usr

/mob/verb/stop_pulling()


	set name = "Stop Pulling"
	set category = "IC"

	if(pulling)
		pulling.pulledby = null
		pulling = null



/mob/verb/mode()
	set name = "Activate Held Object"
	set category = "IC"
	set src = usr

	if(attack_delayer.blocked()) return

	if(istype(loc,/obj/mecha)) return

	if(isVentCrawling())
		to_chat(src, "<span class='danger'>Not while we're vent crawling!</span>")
		return

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
		to_chat(src, "The game appears to have misplaced your mind datum, so we can't show you your notes.")

/mob/verb/add_memory(msg as message)
	set name = "Add Note"
	set category = "IC"

	msg = copytext(msg, 1, MAX_MESSAGE_LEN)
	msg = sanitize(msg)

	if(mind)
		mind.store_memory(msg)
	else
		to_chat(src, "The game appears to have misplaced your mind datum, so we can't show you your notes.")

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

//mob verbs are faster than object verbs. See http://www.byond.com/forum/?post=1326139&page=2#comment8198716 for why this isn't atom/verb/examine()
/mob/verb/examination(atom/A as mob|obj|turf in view()) //It used to be oview(12), but I can't really say why
	set name = "Examine"
	set category = "IC"

//	if( (sdisabilities & BLIND || blinded || stat) && !istype(src,/mob/dead/observer) )
	if(is_blind(src))
		to_chat(src, "<span class='notice'>Something is there but you can't see it.</span>")
		return

	face_atom(A)
	A.examine(src)


/mob/living/verb/verb_pickup(obj/I in view(1))
	set name = "Pick up"
	set category = "Object"

	face_atom(I)
	I.verb_pickup(src)

/mob/proc/update_flavor_text()
	set src in usr

	if(usr != src)
		to_chat(usr, "No.")
	var/msg = input(usr,"Set the flavor text in your 'examine' verb. Can also be used for OOC notes about your character.","Flavor Text",html_decode(flavor_text)) as message|null

	if(msg != null)
		msg = copytext(msg, 1, MAX_MESSAGE_LEN)
		msg = html_encode(msg)

		flavor_text = msg

/mob/proc/warn_flavor_changed()
	if(flavor_text) // Don't spam people that don't use it!
		to_chat(src, "<h2 class='alert'>OOC Warning:</h2>")
		to_chat(src, "<span class='alert'>Your flavor text is likely out of date! <a href='?src=\ref[src];flavor_text=change'>Change</a></span>")

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
		to_chat(usr, "<span class='notice'> Respawn is disabled.</span>")
		return
	if ((stat != 2 || !( ticker )))
		to_chat(usr, "<span class='notice'> <B>You must be dead to use this!</B></span>")
		return
	if (ticker.mode.name == "meteor" || ticker.mode.name == "epidemic") //BS12 EDIT
		to_chat(usr, "<span class='notice'> Respawn is disabled.</span>")
		return
	else
		var/deathtime = world.time - src.timeofdeath
		if(istype(src,/mob/dead/observer))
			var/mob/dead/observer/G = src
			if(G.has_enabled_antagHUD == 1 && config.antag_hud_restricted)
				to_chat(usr, "<span class='notice'> <B>Upon using the antagHUD you forfeighted the ability to join the round.</B></span>")
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
		to_chat(usr, "You have been dead for[pluralcheck] [deathtimeseconds] seconds.")
		if (deathtime < config.respawn_delay*600)
			to_chat(usr, "You must wait [config.respawn_delay] minutes to respawn!")
			return
		else
			to_chat(usr, "You can respawn now, enjoy your new life!")

	log_game("[usr.name]/[usr.key] used abandon mob.")

	to_chat(usr, "<span class='notice'> <B>Make sure to play a different character, and please roleplay correctly!</B></span>")

	if(!client)
		log_game("[usr.key] AM failed due to disconnect.")
		return
	client.screen.len = 0
	if(!client)
		log_game("[usr.key] AM failed due to disconnect.")
		return

	var/mob/new_player/M = new /mob/new_player()
	if(!client)
		log_game("[usr.key] AM failed due to disconnect.")
		qdel(M)
		M = null
		return

	M.key = key
//	M.Login()	//wat
	return

/client/verb/issue_report()
	set name = "Github Report"
	set category = "OOC"
	var/dat = {"	<title>/vg/station Github Ingame Reporting</title>
					Revision: [return_revision()]
					<iframe src='http://ss13.moe/issues/?ckey=[ckey(key)]&address=[world.internet_address]:[world.port]' style='border:none' width='480' height='480' scroll=no></iframe>"}
	src << browse(dat, "window=github;size=480x480")

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
		to_chat(usr, "<span class='notice'>You must be observing to use this!</span>")
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
	set category = "OOC" //Why the fuck?
	unset_machine()
	reset_view(null)
	if(istype(src, /mob/living))
		var/mob/living/M = src
		if(M.cameraFollow)
			M.cameraFollow = null
		if(istype(src, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			H.handle_regular_hud_updates()

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


/mob/proc/can_use_hands()
	return

/mob/proc/is_active()
	return (0 >= usr.stat)

/mob/proc/see(message)
	if(!is_active())
		return 0
	to_chat(src, message)
	return 1

/mob/proc/show_viewers(message)
	for(var/mob/M in viewers())
		M.see(message)

/mob/Stat()
	..()

	if(client && client.holder && client.inactivity < (1200))

		if (statpanel("Status"))	//not looking at that panel
			stat(null, "Location:\t([x], [y], [z])")
			stat(null, "CPU:\t[world.cpu]")
			stat(null, "Instances:\t[world.contents.len]")
			stat(null, FUCK)
			if(!src.stat_fucked)
				if (garbageCollector)
					stat(null, "\tqdel - [garbageCollector.del_everything ? "off" : "on"]")
					stat(null, "\ton queue - [garbageCollector.queue.len]")
					stat(null, "\ttotal delete - [garbageCollector.dels_count]")
					stat(null, "\tsoft delete - [soft_dels]")
					stat(null, "\thard delete - [garbageCollector.hard_dels]")
				else
					stat(null, "Garbage Controller is not running.")

				if(processScheduler && processScheduler.getIsRunning())
					var/datum/controller/process/process

					process = processScheduler.getProcess("vote")
					stat(null, "VOT\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

					process = processScheduler.getProcess("air")
					stat(null, "AIR\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

					process = processScheduler.getProcess("sun")
					stat(null, "SUN\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

					process = processScheduler.getProcess("ticker")
					stat(null, "TIC\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

					process = processScheduler.getProcess("garbage")
					stat(null, "GAR\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

					process = processScheduler.getProcess("lighting")
					stat(null, "LIG\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

					process = processScheduler.getProcess("supply shuttle")
					stat(null, "SUP\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

					process = processScheduler.getProcess("emergency shuttle")
					stat(null, "EME\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

					process = processScheduler.getProcess("inactivity")
					stat(null, "IAC\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

					process = processScheduler.getProcess("mob")
					stat(null, "MOB([mob_list.len])\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

					process = processScheduler.getProcess("disease")
					stat(null, "DIS([active_diseases.len])\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

					process = processScheduler.getProcess("machinery")
					stat(null, "MAC([machines.len])\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

					process = processScheduler.getProcess("power")
					stat(null, "POM([power_machines.len])\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

					process = processScheduler.getProcess("obj")
					stat(null, "OBJ([processing_objects.len])\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

					process = processScheduler.getProcess("pipenet")
					stat(null, "PIP([pipe_networks.len])\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

					process = processScheduler.getProcess("nanoui")
					stat(null, "NAN([nanomanager.processing_uis.len])\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

					process = processScheduler.getProcess("event")
					stat(null, "EVE([events.len])\t - #[process.getTicks()]\t - [process.getLastRunTime()]")
				else
					stat(null, "processScheduler is not running.")
	if(client && client.inactivity < (1200))
		if(listed_turf)
			if(get_dist(listed_turf,src) > 1)
				listed_turf = null
			else if(statpanel(listed_turf.name))
				statpanel(listed_turf.name, null, listed_turf)
				for(var/atom/A in listed_turf)
					if(A.invisibility > see_invisible)
						continue
					statpanel(listed_turf.name, null, A)

		if(spell_list && spell_list.len)
			for(var/spell/S in spell_list)
				if((!S.connected_button) || !statpanel(S.panel))
					continue //Not showing the noclothes spell
				switch(S.charge_type)
					if(Sp_RECHARGE)
						statpanel(S.panel,"[S.charge_counter/10.0]/[S.charge_max/10]",S.connected_button)
					if(Sp_CHARGES)
						statpanel(S.panel,"[S.charge_counter]/[S.charge_max]",S.connected_button)
					if(Sp_HOLDVAR)
						statpanel(S.panel,"[S.holder_var_type] [S.holder_var_amount]",S.connected_button)
	sleep(world.tick_lag * 2)


// facing verbs
/mob/proc/canface()
	if(!canmove)						return 0
	if(client.moving)					return 0
	if(client.move_delayer.blocked())	return 0
	if(stat==2)							return 0
	if(anchored)						return 0
	if(monkeyizing)						return 0
	if(restrained())					return 0
	return 1

//Updates canmove, lying and icons. Could perhaps do with a rename but I can't think of anything to describe it.
/mob/proc/update_canmove()
	if (locked_to)
		var/datum/locking_category/category = locked_to.locked_atoms[src]
		if (category.flags ^ LOCKED_CAN_LIE_AND_STAND)
			canmove = 0
			lying = (category.flags & LOCKED_SHOULD_LIE) ? TRUE : FALSE //A lying value that !=1 will break this


	else if(isUnconscious() || weakened || paralysis || resting || !can_stand)
		stop_pulling()
		lying = 1
		canmove = 0
	else if(stunned)
//		lying = 0
		canmove = 0
	else if(captured)
		anchored = 1
		canmove = 0
		lying = 0
	else
		lying = 0
		canmove = has_limbs

	reset_layer() //Handles layer setting in hiding
	if(lying)
		density = 0
		drop_hands()
	else
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

/mob/proc/reset_layer()
	return

/mob/verb/eastface()
	set hidden = 1
	if(!canface())	return 0
	dir = EAST
	Facing()
	delayNextMove(movement_delay(),additive=1)
	return 1


/mob/verb/westface()
	set hidden = 1
	if(!canface())	return 0
	dir = WEST
	Facing()
	delayNextMove(movement_delay(),additive=1)
	return 1


/mob/verb/northface()
	set hidden = 1
	if(!canface())	return 0
	dir = NORTH
	Facing()
	delayNextMove(movement_delay(),additive=1)
	return 1


/mob/verb/southface()
	set hidden = 1
	if(!canface())	return 0
	dir = SOUTH
	Facing()
	delayNextMove(movement_delay(),additive=1)
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

/mob/proc/Jitter(amount)
	jitteriness = max(jitteriness,amount,0)

/mob/proc/Dizzy(amount)
	dizziness = max(dizziness,amount,0)


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

/mob/proc/yank_out_object()
	set category = "Object"
	set name = "Yank out object"
	set desc = "Remove an embedded item at the cost of bleeding and pain."
	set src in view(1)

	if(!isliving(usr) || (usr.client && usr.client.move_delayer.blocked()))
		return

	delayNextMove(20)
	delayNextAttack(20)

	if(usr.stat == 1)
		to_chat(usr, "You are unconcious and cannot do that!")
		return

	if(usr.restrained())
		to_chat(usr, "You are restrained and cannot do that!")
		return

	var/mob/S = src
	var/mob/U = usr
	var/list/valid_objects = list()
	var/self = null

	if(S == U)
		self = 1 // Removing object from yourself.

	for(var/obj/item/weapon/W in embedded)
		if(W.w_class <= W_CLASS_SMALL)
			valid_objects += W

	if(!valid_objects.len)
		if(self)
			to_chat(src, "You have nothing stuck in your body that is large enough to remove.")
		else
			to_chat(U, "[src] has nothing stuck in their wounds that is large enough to remove.")
		return

	var/obj/item/weapon/selection = input("What do you want to yank out?", "Embedded objects") in valid_objects

	if(self)
		to_chat(src, "<span class='warning'>You attempt to get a good grip on the [selection] in your body.</span></span>")
	else
		to_chat(U, "<span class='warning'>You attempt to get a good grip on the [selection] in [S]'s body.</span>")

	if(!do_after(U, src, 80))
		return
	if(!selection || !S || !U)
		return

	if(self)
		visible_message("<span class='danger'><b>[src] rips [selection] out of their body.</b></span>","<span class='warning'>You rip [selection] out of your body.</span>")
	else
		visible_message("<span class='danger'><b>[usr] rips [selection] out of [src]'s body.</b></span>","<span class='warning'>[usr] rips [selection] out of your body.</span>")

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

mob/proc/on_foot()
	return !(lying || flying || locked_to)

/mob/proc/dexterity_check()
	return 0

/mob/proc/isTeleViewing(var/client_eye)
	if(istype(client_eye,/obj/machinery/camera))
		return 1
	if(istype(client_eye,/obj/item/projectile/nikita))
		return 1
	return 0

/mob/proc/html_mob_check()
	return 0

/mob/shuttle_act()
	return

/mob/shuttle_rotate(angle)
	src.dir = turn(src.dir, -angle) //rotating pixel_x and pixel_y is bad

/mob/can_shuttle_move()
	return 1

/mob/proc/is_blind()
	if(sdisabilities & BLIND || blinded || paralysis)
		return 1
	return 0

/mob/proc/is_deaf()
	if(sdisabilities & DEAF || ear_deaf)
		return 1
	return 0

/mob/proc/hallucinating() //Return 1 if hallucinating! This doesn't affect the scary stuff from mindbreaker toxin, but it does affect other stuff (like special messages for interacting with objects)
	if(isliving(src))
		var/mob/living/M = src
		if(M.hallucination >= MOB_MINDBREAKER_HALLUCINATING)
			return 1
		if(M.druggy >= MOB_SPACEDRUGS_HALLUCINATING)
			return 1
	return 0

/mob/proc/get_subtle_message(var/msg, var/deity = null)
	if(!deity)
		deity = "a voice" //sanity
	var/pre_msg = "You hear [deity] in your head... "
	if(src.hallucinating()) //If hallucinating, make subtle messages more fun
		var/adjective = pick("an angry","a funny","a squeaky","a disappointed","your mother's","your father's","[ticker.Bible_deity_name]'s","an annoyed","a brittle","a loud","a very loud","a quiet","an evil", "an angelic")
		var/location = pick(" from above"," from below"," in your head"," from behind you"," from everywhere"," from nowhere in particular","")
		pre_msg = pick("You hear [adjective] voice[location]...")

	to_chat(src, "<b>[pre_msg] <em>[msg]</em></b>")

/mob/attack_pai(mob/user as mob)
	ShiftClick(user)

/mob/proc/handle_alpha()
	if(alphas.len < 1)
		alpha = 255
	else
		var/lowest_alpha = 255
		for(var/alpha_modification in alphas)
			lowest_alpha = min(lowest_alpha,alphas[alpha_modification])
		alpha = lowest_alpha

/mob/proc/teleport_to(var/atom/A)
	forceMove(get_turf(A))

/mob/proc/nuke_act() //Called when caught in a nuclear blast
	return

/mob/proc/remove_jitter()
	if(jitteriness)
		jitteriness = 0
		animate(src)

//High order proc to remove a mobs spell channeling, removes channeling fully
/mob/proc/remove_spell_channeling()
	if(spell_channeling)
		var/spell/thespell = on_uattack.handlers[spell_channeling][EVENT_OBJECT_INDEX]
		thespell.channel_spell(force_remove = 1)
		return 1
	return 0

#undef MOB_SPACEDRUGS_HALLUCINATING
#undef MOB_MINDBREAKER_HALLUCINATING
