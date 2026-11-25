/obj/structure/tipjar
	name = "tip jar"
	desc = "I can't believe tipping culture made its way to the stars."
	icon = 'icons/obj/tipjar.dmi'
	icon_state = "jar"
	density = TRUE
	anchored = FALSE
	resistance_flags = ACID_PROOF
	max_integrity = 100
	custom_materials = list(/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2)
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR
	pass_flags = PASSTABLE
	anchored_tabletop_offset = 6
	drag_slowdown = 0.5

	/// Stuff that can fit in the jar
	VAR_PRIVATE/static/list/tippable_typecache = typecacheof(list(
		/obj/item/card,
		/obj/item/cigarette,
		/obj/item/cigbutt, // jerk!
		/obj/item/coin,
		/obj/item/documents,
		/obj/item/folder,
		/obj/item/food/candy_trash,
		/obj/item/holochip,
		/obj/item/match,
		/obj/item/paper,
		/obj/item/paperwork,
		/obj/item/pen,
		/obj/item/photo,
		/obj/item/stack/spacecash,
		/obj/item/toy/crayon,
		/obj/item/trash, // jerk!
	))

	/// Where we position the items in the jar's contents visually on the sprite.
	/// Index corresponds to the order of items in the contents list.
	VAR_PRIVATE/static/list/vector/pos_map = list(
		vector(-3, -7),
		vector( 3, -7),
		vector( 0, -6),
		vector(-3, -5),
		vector( 3, -5),
		vector( 0, -4),
		vector(-3, -3),
		vector( 3, -3),
		vector( 0, -2),
	)

	/// If TRUE, we have a chance to spawn with some goodies inside
	VAR_PROTECTED/prefilled = FALSE

/obj/structure/tipjar/Initialize(mapload)
	. = ..()
	if(mapload)
		set_anchored(TRUE)
	if(prefilled)
		if(prob(10))
			for(var/i in 1 to rand(1, 4))
				new /obj/effect/spawner/random/entertainment/coin(src)
		if(prob(10))
			for(var/i in 1 to rand(1, 3))
				new /obj/effect/spawner/random/entertainment/money_small(src)
		if(prob(2))
			for(var/i in 1 to rand(1, 2))
				new /obj/effect/spawner/random/entertainment/money(src)

	AddElement(/datum/element/crackable)
	update_appearance()

/obj/structure/tipjar/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(is_type_in_typecache(tool, tippable_typecache))
		// while we only visually show the first pos_map items, we can store some extra...
		if(length(contents) >= length(pos_map) * 3)
			balloon_alert(user, "it's full!")
			return ITEM_INTERACT_BLOCKING
		if(user.transferItemToLoc(tool, src))
			balloon_alert_to_viewers("deposited \a [tool]")
			return ITEM_INTERACT_SUCCESS
		return ITEM_INTERACT_BLOCKING

	return NONE

/obj/structure/tipjar/examine(mob/user)
	. = ..()
	var/list/all_things = list()
	for(var/obj/item/thing in src)
		all_things[thing.name] += 1

	var/list/all_things_text = list()
	for(var/thing_name, thing_count in all_things)
		all_things_text += thing_count > 1 ? "[thing_count] [thing_name][plural_s(thing_name)]" : "\a [thing_name]"

	. += span_info("Inside, you can see: [english_list(all_things_text)].")

/obj/structure/tipjar/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!IsReachableBy(user))
		return

	. = TRUE
	if(!length(contents))
		user.visible_message(
			span_notice("[user] sticks [user.p_their()] hand in the empty [name], like a fool."),
			span_warning("There's nothing to fish out of [src]!"),
		)
		return

	user.visible_message(
		span_notice("[user] starts fishing around in [src]..."),
		span_notice("You start fishing around in [src]..."),
	)
	Shake(1, 1, 5 SECONDS, 0.5 SECONDS)
	if(!do_after(user, 5 SECONDS, src) || !length(contents))
		animate(src)
		pixel_x = base_pixel_x
		pixel_y = base_pixel_y
		return

	var/obj/item/fished_out = pick(contents)
	user.visible_message(
		span_notice("[user] pulls [fished_out] out of [src]!"),
		span_notice("You pull [fished_out] out of [src]."),
	)
	user.put_in_hands(fished_out)

/obj/structure/tipjar/dump_contents()
	var/atom/droploc = drop_location()
	for(var/obj/item/thing in src)
		thing.forceMove(droploc)
		thing.pixel_x += rand(-4, 4)
		thing.pixel_y += rand(-4, 4)

/obj/structure/tipjar/handle_deconstruct(disassembled)
	. = ..()
	dump_contents()

/obj/structure/tipjar/atom_deconstruct(disassembled = TRUE)
	if(disassembled)
		drop_custom_materials()
		playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	else
		drop_material_shards()
		playsound(src, /datum/sound_effect/shatter, 50, TRUE)

/obj/structure/tipjar/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)

/obj/structure/tipjar/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	update_appearance()
	RegisterSignal(arrived, COMSIG_STACK_CAN_MERGE, PROC_REF(block_merging))

/obj/structure/tipjar/Exited(atom/movable/gone, direction)
	. = ..()
	update_appearance()
	UnregisterSignal(gone, COMSIG_STACK_CAN_MERGE)

/obj/structure/tipjar/proc/block_merging(mob/living/user, atom/movable/other)
	SIGNAL_HANDLER
	return CANCEL_STACK_MERGE

/obj/structure/tipjar/wrench_act(mob/living/user, obj/item/tool)
	switch(default_unfasten_wrench(user, tool, 5 SECONDS))
		if(CANT_UNFASTEN)
			return NONE
		if(FAILED_UNFASTEN)
			return ITEM_INTERACT_BLOCKING
		if(SUCCESSFUL_UNFASTEN)
			return ITEM_INTERACT_SUCCESS
	return NONE

/obj/structure/tipjar/update_overlays()
	. = ..()
	underlays.Cut()
	for(var/i in 1 to min(length(contents), length(pos_map)))
		var/obj/item/thing = contents[i]
		var/image/content_overlay = image(thing, src)

		content_overlay.transform = content_overlay.transform.Scale(0.5)
		content_overlay.pixel_x = 0
		content_overlay.pixel_y = 0
		content_overlay.pixel_w = pos_map[i].x
		content_overlay.pixel_z = pos_map[i].y
		content_overlay.layer = FLOAT_LAYER
		content_overlay.plane = FLOAT_PLANE

		underlays += content_overlay

/obj/structure/tipjar/prefilled
	prefilled = TRUE

/obj/structure/tipjar/plasma
	max_integrity = 300
	custom_materials = list(/datum/material/alloy/plasmaglass = SHEET_MATERIAL_AMOUNT * 2)

/obj/structure/tipjar/plasma/prefilled
	prefilled = TRUE
