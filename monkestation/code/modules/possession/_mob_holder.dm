/mob/living/simple_animal
	///do we have access to pushin?
	var/advanced_simple = FALSE
// so basically we are a carbon mob that mimics a given item kinda like a morph but can still be used like the item, when clicked on your position is inverted with the
// stored item so it functions normally than when its dropped it reverts back to you, you have a set amount of hp that regenerates over time and when you die thats it
// you ghost and the item is dropped, its a carbon so we can have stuff like sprinting
/mob/living/simple_animal/possession_holder
	name = "TEMPORARY HOLDER"
	desc = "HONK HONK, THE CODER MONKEYS HAVE MESSED UP."
	hud_type = /datum/hud/possessed
	dextrous_hud_type = /datum/hud/possessed
	dextrous = TRUE
	maxHealth = 100
	health = 100
	held_items = list(null, null)
	pass_flags = PASSTABLE | PASSMOB
	status_flags = (CANPUSH | CANSTUN | CANKNOCKDOWN)
	set_dir_on_move = FALSE
	gender = NEUTER
	advanced_simple = TRUE
	can_be_held = TRUE
	wander = FALSE
	/// how much hp we regen per process
	var/health_regeneration = 1
	/// the item we are currently
	var/obj/item/stored_item
	///rendered overlays
	var/list/possession_overlays[2]
	/// OFFSET SECTION - This is controllable by admins if they want
	///the shifted y offset of the left hand
	var/l_y_shift = 0
	///the shifted y offset of the right hand
	var/r_y_shift = 0
	///the shifted x offset of the right hand
	var/r_x_shift = 0
	///the shifted x offset of the left hand
	var/l_x_shift = 0
	/// base amount of pixels this offsets upwards for each set of additional arms past 2
	var/base_vertical_shift = 0
	///the shifted y offset of the head
	var/head_y_shift = 0
	/// the shifted x offset of the head
	var/head_x_shift = 0
	///the held id card
	var/obj/item/id
	///the held head item
	var/obj/item/head

/mob/living/simple_animal/possession_holder/New(loc, obj/item/_stored_item, _l_y_shift = 0, _r_y_shift = 0, _r_x_shift = 0, _l_x_shift = 0, _head_y_shift = 0, _head_x_shift = 0)
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
	add_traits(list(TRAIT_ADVANCEDTOOLUSER, TRAIT_CAN_STRIP), ROUNDSTART_TRAIT)

	appearance = stored_item.appearance
	desc = stored_item.desc
	name = stored_item.name
	real_name = stored_item.name

/mob/living/simple_animal/possession_holder/death(gibbed)
	. = ..()
	stored_item.forceMove(get_turf(src))
	stored_item = null
	visible_message("You can feel the soul leaving the [stored_item], it returns back to its original self.")
	qdel(src)

/mob/living/simple_animal/possession_holder/Life(seconds_per_tick, times_fired)
	. = ..()
	if(maxHealth > health)
		heal_overall_damage(health_regeneration, health_regeneration)

/mob/living/simple_animal/possession_holder/update_held_items()
	remove_overlay(1)
	var/list/hands_overlays = list()

	for(var/obj/item/I in held_items)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			I.screen_loc = ui_hand_position(get_held_index_of_item(I))
			client.screen += I
			if(length(observers))
				for(var/mob/dead/observe as anything in observers)
					if(observe.client && observe.client.eye == src)
						observe.client.screen += I
					else
						observers -= observe
						if(!observers.len)
							observers = null
							break

		var/icon_file = I.lefthand_file
		var/x_offset = l_x_shift
		var/y_offset = l_y_shift
		var/vertical_offset = 0
		vertical_offset = CEILING(get_held_index_of_item(I) / 2, 1) - 1
		if(get_held_index_of_item(I) % 2 == 0)
			icon_file = I.righthand_file
			y_offset = r_y_shift
			x_offset = r_x_shift

		var/mutable_appearance/hand_overlay = I.build_worn_icon(default_layer = HANDS_LAYER, default_icon_file = icon_file, isinhands = TRUE)
		hand_overlay.pixel_y += y_offset  + (vertical_offset * base_vertical_shift)
		hand_overlay.pixel_x += x_offset

		hands_overlays += hand_overlay

	if(hands_overlays.len)
		possession_overlays[1] = hands_overlays
	apply_overlay(1)

/mob/living/simple_animal/possession_holder/proc/apply_overlay(cache_index)
	if((. = possession_overlays[cache_index]))
		add_overlay(.)

/mob/living/simple_animal/possession_holder/proc/remove_overlay(cache_index)
	var/I = possession_overlays[cache_index]
	if(I)
		cut_overlay(I)
		possession_overlays[cache_index] = null

/mob/living/simple_animal/possession_holder/face_atom(atom/atom_to_face)
	return

/mob/living/simple_animal/possession_holder/proc/adjust_hand_count(number = 2)
	held_items = list()
	for(var/num=1 to number)
		held_items += null
	usable_hands = number
	hud_used.build_hand_slots()


/mob/living/simple_animal/proc/disarm(mob/living/carbon/target)
	do_attack_animation(target, ATTACK_EFFECT_DISARM)
	playsound(target, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
	if (ishuman(target))
		var/mob/living/carbon/human/human_target = target
		human_target.w_uniform?.add_fingerprint(src)

	SEND_SIGNAL(target, COMSIG_HUMAN_DISARM_HIT, src, zone_selected)
	var/shove_dir = get_dir(loc, target.loc)
	var/turf/target_shove_turf = get_step(target.loc, shove_dir)
	var/shove_blocked = FALSE //Used to check if a shove is blocked so that if it is knockdown logic can be applied
	var/turf/target_old_turf = target.loc

	//Are we hitting anything? or
	if(SEND_SIGNAL(target_shove_turf, COMSIG_CARBON_DISARM_PRESHOVE) & COMSIG_CARBON_ACT_SOLID)
		shove_blocked = TRUE
	else
		target.Move(target_shove_turf, shove_dir)
		if(get_turf(target) == target_old_turf)
			shove_blocked = TRUE

	if(!shove_blocked)
		target.setGrabState(GRAB_PASSIVE)

	if(target.IsKnockdown() && !target.IsParalyzed()) //KICK HIM IN THE NUTS
		target.Paralyze(SHOVE_CHAIN_PARALYZE)
		target.visible_message(span_danger("[name] kicks [target.name] onto [target.p_their()] side!"),
						span_userdanger("You're kicked onto your side by [name]!"), span_hear("You hear aggressive shuffling followed by a loud thud!"), COMBAT_MESSAGE_RANGE, src)
		to_chat(src, span_danger("You kick [target.name] onto [target.p_their()] side!"))
		addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living, SetKnockdown), 0), SHOVE_CHAIN_PARALYZE)
		log_combat(src, target, "kicks", "onto their side (paralyzing)")

	var/directional_blocked = FALSE
	var/can_hit_something = (!target.is_shove_knockdown_blocked() && !target.buckled)

	//Directional checks to make sure that we're not shoving through a windoor or something like that
	if(shove_blocked && can_hit_something && (shove_dir in GLOB.cardinals))
		var/target_turf = get_turf(target)
		for(var/obj/obj_content in target_turf)
			if(obj_content.flags_1 & ON_BORDER_1 && obj_content.dir == shove_dir && obj_content.density)
				directional_blocked = TRUE
				break
		if(target_turf != target_shove_turf && !directional_blocked) //Make sure that we don't run the exact same check twice on the same tile
			for(var/obj/obj_content in target_shove_turf)
				if(obj_content.flags_1 & ON_BORDER_1 && obj_content.dir == turn(shove_dir, 180) && obj_content.density)
					directional_blocked = TRUE
					break

	if(can_hit_something)
		//Don't hit people through windows, ok?
		if(!directional_blocked && SEND_SIGNAL(target_shove_turf, COMSIG_CARBON_DISARM_COLLIDE, src, target, shove_blocked) & COMSIG_CARBON_SHOVE_HANDLED)
			return
		if(directional_blocked || shove_blocked)
			target.Knockdown(SHOVE_KNOCKDOWN_SOLID)
			target.visible_message(span_danger("[name] shoves [target.name], knocking [target.p_them()] down!"),
				span_userdanger("You're knocked down from a shove by [name]!"), span_hear("You hear aggressive shuffling followed by a loud thud!"), COMBAT_MESSAGE_RANGE, src)
			to_chat(src, span_danger("You shove [target.name], knocking [target.p_them()] down!"))
			log_combat(src, target, "shoved", "knocking them down")
			return

	target.visible_message(span_danger("[name] shoves [target.name]!"),
		span_userdanger("You're shoved by [name]!"), span_hear("You hear aggressive shuffling!"), COMBAT_MESSAGE_RANGE, src)
	to_chat(src, span_danger("You shove [target.name]!"))

	//Take their lunch money
	var/target_held_item = target.get_active_held_item()
	var/append_message = ""
	if(!is_type_in_typecache(target_held_item, GLOB.shove_disarming_types)) //It's too expensive we'll get caught
		target_held_item = null

	if(!target.has_movespeed_modifier(/datum/movespeed_modifier/shove))
		target.add_movespeed_modifier(/datum/movespeed_modifier/shove)
		if(target_held_item)
			append_message = "loosening [target.p_their()] grip on [target_held_item]"
			target.visible_message(span_danger("[target.name]'s grip on \the [target_held_item] loosens!"), //He's already out what are you doing
				span_warning("Your grip on \the [target_held_item] loosens!"), null, COMBAT_MESSAGE_RANGE)
		addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living/carbon, clear_shove_slowdown)), SHOVE_SLOWDOWN_LENGTH)

	else if(target_held_item)
		target.dropItemToGround(target_held_item)
		append_message = "causing [target.p_them()] to drop [target_held_item]"
		target.visible_message(span_danger("[target.name] drops \the [target_held_item]!"),
			span_warning("You drop \the [target_held_item]!"), null, COMBAT_MESSAGE_RANGE)

	log_combat(src, target, "shoved", append_message)

/mob/living/simple_animal/possession_holder/can_equip(obj/item/I, slot, disable_warning, bypass_equip_delay_self)
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

/mob/living/simple_animal/possession_holder/get_item_by_slot(slot_id)
	switch(slot_id)
		if(ITEM_SLOT_ID)
			return id
		if(ITEM_SLOT_HEAD)
			return head
	return ..()

/mob/living/simple_animal/possession_holder/get_slot_by_item(obj/item/looking_for)
	if(id == looking_for)
		return ITEM_SLOT_ID
	if(head == looking_for)
		return ITEM_SLOT_HEAD
	return ..()

/mob/living/simple_animal/possession_holder/equip_to_slot(obj/item/I, slot)
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
	I.equipped(src, slot)

/mob/living/simple_animal/possession_holder/doUnEquip(obj/item/I, force, newloc, no_move, invdrop = TRUE, silent = FALSE)
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

/mob/living/simple_animal/possession_holder/proc/update_id_inv()
	if(id && client && hud_used?.hud_shown)
		id.screen_loc = ui_id
		client.screen += id

/mob/living/simple_animal/possession_holder/regenerate_icons()
	update_id_inv()
	update_held_items()
	update_worn_head()

/mob/living/simple_animal/possession_holder/update_worn_head()
	remove_overlay(2)

	if(head)
		if(client && hud_used?.hud_shown)
			head.screen_loc = ui_head
			client.screen += head
		var/used_head_icon = 'icons/mob/clothing/head/utility.dmi'
		if(istype(head, /obj/item/clothing/mask))
			used_head_icon = 'icons/mob/clothing/mask.dmi'
		var/mutable_appearance/head_overlay = head.build_worn_icon(default_layer = 2, default_icon_file = used_head_icon)
		head_overlay.pixel_y += head_y_shift

		possession_overlays[2] = head_overlay

	apply_overlay(2)

/mob/living/simple_animal/possession_holder/mob_pickup(mob/living/L)
	stored_item.forceMove(get_turf(src))
	src.forceMove(stored_item)

	RegisterSignal(stored_item, COMSIG_ITEM_DROPPED, PROC_REF(return_control))

	L.visible_message(span_warning("[L] scoops up [src]!"))
	L.put_in_hands(stored_item)

/mob/living/simple_animal/possession_holder/proc/return_control()
	SIGNAL_HANDLER

	UnregisterSignal(stored_item, COMSIG_ITEM_DROPPED)
	src.forceMove(get_turf(stored_item))
	stored_item.forceMove(src)
