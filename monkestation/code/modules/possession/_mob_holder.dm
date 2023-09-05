/mob/living
	///do we have access to pushin?
	var/advanced_simple = FALSE

// so basically we are a carbon mob that mimics a given item kinda like a morph but can still be used like the item, when clicked on your position is inverted with the
// stored item so it functions normally than when its dropped it reverts back to you, you have a set amount of hp that regenerates over time and when you die thats it
// you ghost and the item is dropped, its a carbon so we can have stuff like sprinting
/mob/living/basic/possession_holder
	name = "TEMPORARY HOLDER"
	desc = "HONK HONK, THE CODER MONKEYS HAVE MESSED UP."
	hud_type = /datum/hud/possessed
	dexterous = TRUE
	maxHealth = 100
	health = 100
	held_items = list(null, null)
	pass_flags = PASSTABLE | PASSMOB
	status_flags = (CANPUSH | CANSTUN | CANKNOCKDOWN)
	set_dir_on_move = FALSE
	gender = NEUTER
	advanced_simple = TRUE
	can_be_held = TRUE
	uses_directional_offsets = FALSE
	melee_damage_lower = 3
	melee_damage_upper = 3
	/// how much hp we regen per process
	var/health_regeneration = 1
	/// the item we are currently
	var/obj/item/stored_item
	///the held id card
	var/obj/item/id
	///the held head item
	var/obj/item/head

/mob/living/basic/possession_holder/Destroy()
	. = ..()
	stored_item = null
	if(id)
		id.forceMove(get_turf(src))
	if(head)
		head.forceMove(get_turf(src))

/mob/living/basic/possession_holder/New(loc, obj/item/_stored_item, _l_y_shift = list(0, 0, 0, 0), _r_y_shift = list(0, 0, 0, 0), _r_x_shift = list(0, 0, 0, 0), _l_x_shift = list(0, 0, 0, 0), _head_y_shift = list(0, 0, 0, 0), _head_x_shift = list(0, 0, 0, 0))
	. = ..()
	if(!_stored_item)
		_stored_item = new /obj/item/toy/plush/cirno_plush/ballin(src)
		message_admins("ERROR: Possession Holder was generated without a stored item defaulting to Ballin Cirno.")

	stored_item = _stored_item
	l_y_shift = _l_y_shift
	r_y_shift = _r_y_shift
	r_x_shift = _r_x_shift
	l_x_shift = _l_x_shift
	head_x_shift = _head_x_shift
	head_y_shift = _head_y_shift

	_stored_item.forceMove(src)

	AddComponent(/datum/component/carbon_sprint)
	AddComponent(/datum/component/personal_crafting)
	add_traits(list(TRAIT_ADVANCEDTOOLUSER, TRAIT_CAN_STRIP, TRAIT_LITERATE), ROUNDSTART_TRAIT)

	appearance = stored_item.appearance
	desc = stored_item.desc
	name = stored_item.name
	real_name = stored_item.name

/mob/living/basic/possession_holder/create_overlay_index()
	var/list/new_overlays[2]
	possession_overlays = new_overlays

/mob/living/basic/possession_holder/death(gibbed)
	. = ..()
	if(stored_item)
		stored_item.forceMove(get_turf(src))
		stored_item = null
		visible_message("You can feel the soul leaving the [stored_item], it returns back to its original self.")
	qdel(src)

/mob/living/basic/possession_holder/Life(seconds_per_tick, times_fired)
	. = ..()
	if(maxHealth > health)
		heal_overall_damage(health_regeneration, health_regeneration)

/mob/living/basic/possession_holder/face_atom(atom/atom_to_face)
	return

/mob/living/basic/possession_holder/setDir(newdir)
	. = ..()
	dir = SOUTH


/mob/living/basic/possession_holder/can_equip(obj/item/I, slot, disable_warning, bypass_equip_delay_self)
	switch(slot)
		if(ITEM_SLOT_ID)
			if(id)
				return FALSE
			if(!((I.slot_flags & ITEM_SLOT_ID)))
				return FALSE
			return TRUE
		if(ITEM_SLOT_HEAD)
			if(head)
				return FALSE
			if(!((I.slot_flags & ITEM_SLOT_HEAD) || (I.slot_flags & ITEM_SLOT_MASK)))
				return FALSE
			return TRUE
	..()

/mob/living/basic/possession_holder/get_item_by_slot(slot_id)
	switch(slot_id)
		if(ITEM_SLOT_ID)
			return id
		if(ITEM_SLOT_HEAD)
			return head
	return ..()

/mob/living/basic/possession_holder/get_slot_by_item(obj/item/looking_for)
	if(id == looking_for)
		return ITEM_SLOT_ID
	if(head == looking_for)
		return ITEM_SLOT_HEAD
	return ..()

/mob/living/basic/possession_holder/equip_to_slot(obj/item/I, slot)
	if(!slot)
		return
	if(!istype(I))
		return

	var/index = get_held_index_of_item(I)
	if(index)
		held_items[index] = null
	update_held_items()

	if(I.pulledby)
		I.pulledby.stop_pulling()

	I.screen_loc = null // will get moved if inventory is visible
	I.forceMove(src)
	SET_PLANE_EXPLICIT(I, ABOVE_HUD_PLANE, src)

	switch(slot)
		if(ITEM_SLOT_ID)
			id = I
			update_id_inv()
		if(ITEM_SLOT_HEAD)
			head = I
			update_worn_head()
		else
			to_chat(src, span_danger("You are trying to equip this item to an unsupported inventory slot. Report this to a coder!"))
			return

	//Call back for item being equipped to drone
	I.on_equipped(src, slot)

/mob/living/basic/possession_holder/doUnEquip(obj/item/I, force, newloc, no_move, invdrop = TRUE, silent = FALSE)
	if(..())
		update_held_items()
		if(I == id)
			id = null
			update_id_inv()
		if(I == head)
			head = null
			update_worn_head()
		return TRUE
	return FALSE

/mob/living/basic/possession_holder/proc/update_id_inv()
	if(id && client && hud_used?.hud_shown)
		id.screen_loc = ui_id
		client.screen += id

/mob/living/basic/possession_holder/regenerate_icons()
	update_id_inv()
	update_held_items()
	update_worn_head()

/mob/living/basic/possession_holder/update_worn_head()
	remove_overlay(2)

	if(head)
		if(client && hud_used?.hud_shown)
			head.screen_loc = ui_head
			client.screen += head
		var/used_head_icon = 'icons/mob/clothing/head/utility.dmi'
		if(istype(head, /obj/item/clothing/mask))
			used_head_icon = 'icons/mob/clothing/mask.dmi'
		var/mutable_appearance/head_overlay = head.build_worn_icon(default_layer = 2, default_icon_file = used_head_icon)

		var/used_list_index = dir
		if(dir == WEST)
			used_list_index = 4
		if(dir == EAST)
			used_list_index = 3

		head_overlay.pixel_y += head_y_shift[used_list_index]
		head_overlay.pixel_x += head_x_shift[used_list_index]

		possession_overlays[2] = head_overlay

	apply_overlay(2)

/mob/living/basic/possession_holder/mob_pickup(mob/living/L)
	stored_item.forceMove(get_turf(src))
	src.forceMove(stored_item)

	RegisterSignal(stored_item, COMSIG_ITEM_DROPPED, PROC_REF(return_control))

	L.visible_message(span_warning("[L] scoops up [src]!"))
	L.put_in_hands(stored_item)

/mob/living/basic/possession_holder/proc/return_control()
	SIGNAL_HANDLER

	UnregisterSignal(stored_item, COMSIG_ITEM_DROPPED)
	src.forceMove(get_turf(stored_item))
	stored_item.forceMove(src)
