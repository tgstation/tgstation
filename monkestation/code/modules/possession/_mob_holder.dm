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
	/// how much hp we regen per process
	var/health_regeneration = 1
	/// the item we are currently
	var/obj/item/stored_item
	///rendered overlays
	var/list/possession_overlays[1]
	/// OFFSET SECTION - This is controllable by admins if they want
	///the shifted y offset of the left hand
	var/l_y_shift = 0
	///the shifted y offset of the right hand
	var/r_y_shift = 0
	///the shifted x offset of the right hand
	var/r_x_shift = 0
	///the shifted x offset of the left hand
	var/l_x_shift = 0

/mob/living/simple_animal/possession_holder/Initialize(mapload, obj/item/_stored_item, _l_y_shift = 0, _r_y_shift = 0, _r_x_shift = 0, _l_x_shift = 0)
	. = ..()
	if(!_stored_item)
		_stored_item = new /obj/item/toy/plush/cirno_plush/ballin(src)
		message_admins("ERROR: Possession Holder was generated without a stored item defaulting to Ballin Cirno.")

	stored_item = _stored_item
	l_y_shift = _l_y_shift
	r_y_shift = _r_y_shift
	r_x_shift = _r_x_shift
	l_x_shift = _l_x_shift

	_stored_item.forceMove(src)

	AddComponent(/datum/component/carbon_sprint)
	AddComponent(/datum/component/personal_crafting)
	add_traits(list(TRAIT_ADVANCEDTOOLUSER, TRAIT_CAN_STRIP), ROUNDSTART_TRAIT)

	appearance = stored_item.appearance
	desc = stored_item.desc
	name = stored_item.name

/mob/living/simple_animal/possession_holder/update_held_items()
	remove_overlay(1)
	var/list/hands_overlays = list()

	var/obj/item/l_hand = get_item_for_held_index(1)
	var/obj/item/r_hand = get_item_for_held_index(2)

	if(r_hand)
		var/mutable_appearance/r_hand_overlay = r_hand.build_worn_icon(default_layer = 1, default_icon_file = r_hand.righthand_file, isinhands = TRUE)
		r_hand_overlay.pixel_y += r_y_shift
		r_hand_overlay.pixel_x += r_x_shift

		hands_overlays += r_hand_overlay

		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			SET_PLANE_EXPLICIT(r_hand, ABOVE_HUD_PLANE, src)
			r_hand.screen_loc = ui_hand_position(get_held_index_of_item(r_hand))
			client.screen |= r_hand

	if(l_hand)
		var/mutable_appearance/l_hand_overlay = l_hand.build_worn_icon(default_layer = 1, default_icon_file = l_hand.lefthand_file, isinhands = TRUE)
		l_hand_overlay.pixel_y += l_y_shift
		l_hand_overlay.pixel_x += l_x_shift

		hands_overlays += l_hand_overlay

		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			SET_PLANE_EXPLICIT(l_hand, ABOVE_HUD_PLANE, src)
			l_hand.screen_loc = ui_hand_position(get_held_index_of_item(l_hand))
			client.screen |= l_hand


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
