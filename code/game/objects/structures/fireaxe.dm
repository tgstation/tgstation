/obj/structure/fireaxecabinet
	name = "fire axe cabinet"
	desc = "There is a small label that reads \"For Emergency use only\" along with details for safe use of the axe. As if."
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "fireaxe"
	anchored = TRUE
	density = FALSE
	armor_type = /datum/armor/structure_fireaxecabinet
	max_integrity = 150
	integrity_failure = 0.33
	/// Do we need to be unlocked to be opened.
	var/locked = TRUE
	/// Are we opened, can someone take the held item out.
	var/open = FALSE
	/// The item we're holding.
	var/obj/item/held_item
	/// The path of the item we spawn and can hold.
	var/item_path = /obj/item/fireaxe
	/// Overlay we get when the item is inside us.
	var/item_overlay = "axe"
	/// Whether we should populate our own contents on Initialize()
	var/populate_contents = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/fireaxecabinet, 32)

/datum/armor/structure_fireaxecabinet
	melee = 50
	bullet = 20
	energy = 100
	bomb = 10
	fire = 90
	acid = 50

/obj/structure/fireaxecabinet/Initialize(mapload)
	. = ..()
	if(populate_contents)
		held_item = new item_path(src)
	update_appearance()
	find_and_hang_on_wall()

/obj/structure/fireaxecabinet/Destroy()
	if(held_item)
		QDEL_NULL(held_item)
	return ..()

/obj/structure/fireaxecabinet/attackby(obj/item/attacking_item, mob/living/user, params)
	if(iscyborg(user) || attacking_item.tool_behaviour == TOOL_MULTITOOL)
		toggle_lock(user)
	else if(attacking_item.tool_behaviour == TOOL_WELDER && !user.combat_mode && !broken)
		if(atom_integrity < max_integrity)
			if(!attacking_item.tool_start_check(user, amount = 2))
				return
			balloon_alert(user, "repairing...")
			if(attacking_item.use_tool(src, user, 4 SECONDS, volume= 50, amount = 2))
				repair_damage(max_integrity - get_integrity())
				update_appearance()
				balloon_alert(user, "repaired")
		else
			balloon_alert(user, "already repaired!")
		return
	else if(istype(attacking_item, /obj/item/stack/sheet/glass) && broken)
		var/obj/item/stack/sheet/glass/glass_stack = attacking_item
		if(glass_stack.get_amount() < 2)
			balloon_alert(user, "need more glass!")
			return
		balloon_alert(user, "repairing")
		if(do_after(user, 2 SECONDS, target = src) && glass_stack.use(2))
			broken = FALSE
			repair_damage(max_integrity - get_integrity())
			update_appearance()
	else if(open || broken)
		if(istype(attacking_item, item_path) && !held_item)
			if(HAS_TRAIT(attacking_item, TRAIT_WIELDED))
				balloon_alert(user, "unwield it!")
				return
			if(!user.transferItemToLoc(attacking_item, src))
				return
			held_item = attacking_item
			update_appearance()
			return
		else if(!broken)
			toggle_open()
	else
		return ..()

/obj/structure/fireaxecabinet/Exited(atom/movable/gone, direction)
	if(gone == held_item)
		held_item = null
		update_appearance()
	return ..()

/obj/structure/fireaxecabinet/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(broken)
				playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 90, TRUE)
			else
				playsound(loc, 'sound/effects/glass/glasshit.ogg', 90, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/tools/welder.ogg', 100, TRUE)

/obj/structure/fireaxecabinet/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = TRUE, attack_dir)
	if(open)
		return
	. = ..()
	if(.)
		update_appearance()

/obj/structure/fireaxecabinet/atom_break(damage_flag)
	. = ..()
	if(!broken)
		update_appearance()
		broken = TRUE
		playsound(src, 'sound/effects/glass/glassbr3.ogg', 100, TRUE)
		new /obj/item/shard(loc)
		new /obj/item/shard(loc)

/obj/structure/fireaxecabinet/atom_deconstruct(disassembled = TRUE)
	if(held_item && loc)
		held_item.forceMove(loc)
	new /obj/item/wallframe/fireaxecabinet(loc)

/obj/structure/fireaxecabinet/blob_act(obj/structure/blob/B)
	if(held_item)
		held_item.forceMove(loc)
	qdel(src)

/obj/structure/fireaxecabinet/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if((open || broken) && held_item)
		user.put_in_hands(held_item)
		add_fingerprint(user)
		update_appearance()
		return
	toggle_open(user)

/obj/structure/fireaxecabinet/attack_hand_secondary(mob/user, list/modifiers)
	toggle_open(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/fireaxecabinet/attack_paw(mob/living/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/structure/fireaxecabinet/attack_ai(mob/user)
	toggle_lock(user)
	return

/obj/structure/fireaxecabinet/attack_tk(mob/user)
	. = COMPONENT_CANCEL_ATTACK_CHAIN
	toggle_open(user)

/obj/structure/fireaxecabinet/update_overlays()
	. = ..()
	if(held_item)
		. += item_overlay
	var/hp_percent = (atom_integrity/max_integrity) * 100

	if(open)
		if(broken)
			. += "glass4_raised"
			return

		switch(hp_percent)
			if(-INFINITY to 40)
				. += "glass3_raised"
			if(40 to 60)
				. += "glass2_raised"
			if(60 to 80)
				. += "glass1_raised"
			if(80 to INFINITY)
				. += "glass_raised"
		return

	if(broken)
		. += "glass4"
	else
		switch(hp_percent)
			if(-INFINITY to 40)
				. += "glass3"
			if(40 to 60)
				. += "glass2"
			if(60 to 80)
				. += "glass1"
			if(80 to INFINITY)
				. += "glass"

	. += locked ? "locked" : "unlocked"

/obj/structure/fireaxecabinet/proc/toggle_lock(mob/user)
	to_chat(user, span_notice("Resetting circuitry..."))
	playsound(src, 'sound/machines/locktoggle.ogg', 50, TRUE)
	if(do_after(user, 2 SECONDS, target = src))
		to_chat(user, span_notice("You [locked ? "disable" : "re-enable"] the locking modules."))
		locked = !locked
		update_appearance()

/obj/structure/fireaxecabinet/proc/toggle_open(mob/user)
	if(locked)
		balloon_alert(user, "won't budge!")
		return
	else
		open = !open
		playsound(src, 'sound/machines/click.ogg', 30, TRUE)
		update_appearance()
		return

/obj/structure/fireaxecabinet/empty
	populate_contents = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/fireaxecabinet/empty, 32)

/obj/item/wallframe/fireaxecabinet
	name = "fire axe cabinet"
	desc = "Home to a window's greatest nightmare. Apply to wall to use."
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "fireaxe"
	result_path = /obj/structure/fireaxecabinet/empty
	pixel_shift = 32

/obj/structure/fireaxecabinet/mechremoval
	name = "mech removal tool cabinet"
	desc = "There is a small label that reads \"For Emergency use only\" along with details for safe use of the tool. As if."
	icon_state = "mechremoval"
	item_path = /obj/item/crowbar/mechremoval
	item_overlay = "crowbar"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/fireaxecabinet/mechremoval, 32)

/obj/structure/fireaxecabinet/mechremoval/atom_deconstruct(disassembled = TRUE)
	if(held_item && loc)
		held_item.forceMove(loc)
	new /obj/item/wallframe/fireaxecabinet/mechremoval(loc)

/obj/structure/fireaxecabinet/mechremoval/empty
	populate_contents = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/fireaxecabinet/mechremoval/empty, 32)

/obj/item/wallframe/fireaxecabinet/mechremoval
	name = "mech removal tool cabinet"
	desc = "Home to a very special crowbar. Apply to wall to use."
	icon_state = "mechremoval"
	result_path = /obj/structure/fireaxecabinet/mechremoval/empty
