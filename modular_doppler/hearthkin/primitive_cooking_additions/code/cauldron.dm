/obj/machinery/cauldron
	name = "stone cauldron"
	desc = "Cooks and boils stuff the old fashioned way."
	icon = 'modular_doppler/hearthkin/primitive_cooking_additions/icons/stone_kitchen_machines.dmi'
	icon_state = "cauldron_back_off"
	density = TRUE
	pass_flags_self = PASSMACHINE | PASSTABLE| LETPASSTHROW // It's roughly the height of a table.
	layer = BELOW_OBJ_LAYER
	use_power = FALSE
	circuit = null
	resistance_flags = FIRE_PROOF
	/// Whether it's currently cooking
	var/operating
	/// Lid position
	var/open
	/// Cauldron max capacity
	var/max_n_of_items = 10
	/// Ingredients - may only contain /atom/movables
	var/list/ingredients = list()
	/// When this is the nth ingredient, whats its pixel_x?
	var/list/ingredient_shifts_x = list(
		-1,
		1,
		-2,
		2,
		-3,
		0,
	)
	/// When this is the nth ingredient, whats its pixel_y?
	var/list/ingredient_shifts_y = list(
		7,
		6,
		5,
	)

	/// Radial list icons
	var/static/radial_eject = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_eject")
	var/static/radial_cook = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_cook")

	/// Radial list options
	var/static/list/radial_options = list("eject" = radial_eject, "cook" = radial_cook)

/obj/machinery/cauldron/Initialize(mapload)
	. = ..()
	register_context()
	update_appearance(UPDATE_ICON)

/obj/machinery/cauldron/examine(mob/user)
	. = ..()

	. += span_notice("It can be taken apart with a <b>crowbar</b>.")

	if(!in_range(user, src) && !isobserver(user))
		. += span_warning("You're too far away to examine [src]'s contents!")
		return

	if(length(ingredients))
		. += span_notice("\The [src] contains:")
		var/list/items_counts = new
		for(var/i in ingredients)
			if(isstack(i))
				var/obj/item/stack/item_stack = i
				items_counts[item_stack.name] += item_stack.amount
			else
				var/atom/movable/single_item = i
				items_counts[single_item.name]++
		for(var/item in items_counts)
			. += span_notice("- [items_counts[item]]x [item].")
	else
		. += span_notice("\The [src] is empty.")

/obj/machinery/cauldron/Exited(atom/movable/gone, direction)
	if(gone in ingredients)
		ingredients -= gone
		if(!QDELING(gone) && ingredients.len && isitem(gone))
			var/obj/item/itemized_ingredient = gone
			if(!(itemized_ingredient.item_flags & NO_PIXEL_RANDOM_DROP))
				itemized_ingredient.pixel_x = itemized_ingredient.base_pixel_x + rand(-6, 6)
				itemized_ingredient.pixel_y = itemized_ingredient.base_pixel_y + rand(-5, 6)
	return ..()

/obj/machinery/cauldron/on_deconstruction(disassembled)
	eject()
	return ..()

/obj/machinery/cauldron/Destroy()
	QDEL_LIST(ingredients)
	return ..()

/obj/machinery/cauldron/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(held_item?.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = "[anchored ? "Unsecure" : "Secure"]"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item?.tool_behaviour == TOOL_CROWBAR)
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET

	context[SCREENTIP_CONTEXT_LMB] = "Show menu"

	if(length(ingredients) != 0)
		context[SCREENTIP_CONTEXT_RMB] = "Start cooking"

	return CONTEXTUAL_SCREENTIP_SET

#define CAULDRON_INGREDIENT_OVERLAY_SIZE 14

/obj/machinery/cauldron/update_overlays()
	. = ..()

	var/ingredient_count = 0

	for(var/atom/movable/ingredient as anything in ingredients)
		var/image/ingredient_overlay = image(ingredient, src)

		var/list/icon_dimensions = get_icon_dimensions(ingredient.icon)
		ingredient_overlay.transform = ingredient_overlay.transform.Scale(
			CAULDRON_INGREDIENT_OVERLAY_SIZE / icon_dimensions["width"],
			CAULDRON_INGREDIENT_OVERLAY_SIZE / icon_dimensions["height"],
		)

		ingredient_overlay.pixel_x = ingredient_shifts_x[(ingredient_count % ingredient_shifts_x.len) + 1]
		ingredient_overlay.pixel_y = ingredient_shifts_y[(ingredient_count % ingredient_shifts_y.len) + 1]
		ingredient_overlay.layer = FLOAT_LAYER
		ingredient_overlay.plane = FLOAT_PLANE
		ingredient_overlay.blend_mode = BLEND_INSET_OVERLAY

		ingredient_count += 1

		. += ingredient_overlay

	var/base_icon_state = "cauldron_front"
	var/lid_icon_state

	if(open)
		lid_icon_state = "cauldron_lid_open"
	else
		lid_icon_state = "cauldron_lid_closed"


	. += mutable_appearance(
		icon,
		lid_icon_state,
	)

	. += base_icon_state

#undef CAULDRON_INGREDIENT_OVERLAY_SIZE

/obj/machinery/cauldron/update_icon_state()
	if(operating)
		icon_state = "cauldron_back_cooking"
	else
		icon_state = "cauldron_back_off"

	return ..()

/obj/machinery/cauldron/wrench_act(mob/living/user, obj/item/tool)
	if(default_unfasten_wrench(user, tool))
		update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/cauldron/crowbar_act(mob/living/user, obj/item/tool)
	user.balloon_alert_to_viewers("disassembling...")
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 100))
		return
	new /obj/item/stack/sheet/mineral/stone(drop_location(), 5) // Made with stone instead of iron so that it doesn't outbalance microwaves on station
	deconstruct(TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/cauldron/attackby(obj/item/item, mob/living/user, params)
	if(operating)
		return

	if(!anchored)
		if(IS_EDIBLE(item))
			balloon_alert(user, "not secured!")
			return TRUE
		return ..()

	if(istype(item, /obj/item/storage))
		var/obj/item/storage/tray = item
		var/loaded = 0

		if(!istype(item, /obj/item/storage/bag/tray))
			// Non-tray dumping requires a do_after
			to_chat(user, span_notice("You start dumping out the contents of [item] into [src]..."))
			if(!do_after(user, 2 SECONDS, target = tray))
				return

		for(var/obj/tray_item in tray.contents)
			if(!IS_EDIBLE(tray_item))
				continue
			if(ingredients.len >= max_n_of_items)
				balloon_alert(user, "it's full!")
				return TRUE
			if(tray.atom_storage.attempt_remove(tray_item, src))
				loaded++
				ingredients += tray_item
		if(loaded)
			open()
			to_chat(user, span_notice("You insert [loaded] items into \the [src]."))
			update_appearance()
		return

	if(item.w_class <= WEIGHT_CLASS_NORMAL && !istype(item, /obj/item/storage) && !user.combat_mode)
		if(ingredients.len >= max_n_of_items)
			balloon_alert(user, "it's full!")
			return TRUE
		if(!user.transferItemToLoc(item, src))
			balloon_alert(user, "it's stuck to your hand!")
			return FALSE

		ingredients += item
		open()
		user.visible_message(span_notice("[user] adds \a [item] to \the [src]."), span_notice("You add [item] to \the [src]."))
		update_appearance()
		return

	return ..()

/obj/machinery/cauldron/attack_hand_secondary(mob/user, list/modifiers)
	if(user.can_perform_action(src))
		if(!length(ingredients))
			balloon_alert(user, "it's empty!")
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

		cook(user)

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/cauldron/ui_interact(mob/user)
	. = ..()

	if(!anchored)
		balloon_alert(user, "not secured!")
		return
	if(operating || !user.can_perform_action(src))
		return

	if(!length(ingredients))
		if(isAI(user))
			examine(user)
		else
			balloon_alert(user, "it's empty!")
		return

	var/choice = show_radial_menu(user, src, radial_options, require_near = TRUE)

	// post choice verification
	if(!anchored)
		balloon_alert(user, "not secured!")
		return
	if(operating || !user.can_perform_action(src))
		return

	switch(choice)
		if("eject")
			eject()
		if("cook")
			cook(user)
		if("examine")
			examine(user)

/**
 * Ejects all the ingredients currently stored in the cauldron.
 * Called by deconstruction, finishing cooking, or user selecting the eject option.
 */
/obj/machinery/cauldron/proc/eject()
	var/atom/drop_loc = drop_location()
	for(var/atom/movable/movable_ingredient as anything in ingredients)
		movable_ingredient.forceMove(drop_loc)
	open()

/**
 * Begins the process of cooking the included ingredients.
 *
 * * cooker - The mob that initiated the cook cycle
 */
/obj/machinery/cauldron/proc/cook(mob/cooker)
	if(operating || !anchored)
		return

	start(cooker)

/**
 * The start of the cook loop
 *
 * * cooker - The mob that initiated the cook cycle
 */
/obj/machinery/cauldron/proc/start(mob/cooker)
	visible_message(span_notice("\The [src] turns on."), null, span_hear("You hear bubbling as the cauldron ignites."))
	operating = TRUE
	update_appearance()
	cook_loop(cycles = 10, cooker = cooker)

/**
 * The actual cook loop started via [proc/start]
 * * time - how many loops are left, base case for recursion
 * * wait - deciseconds between loops
 * * cooker - The mob that initiated the cook cycle
 */
/obj/machinery/cauldron/proc/cook_loop(cycles, wait = max(12, 2), mob/cooker)
	if(cycles <= 0 || !length(ingredients))
		loop_finish(cooker)
		return
	cycles--
	addtimer(CALLBACK(src, PROC_REF(cook_loop), cycles, wait, cooker), wait)

/**
 * Called when the cook_loop is done successfully
 *
 * * cooker - The mob that initiated the cook cycle
 */
/obj/machinery/cauldron/proc/loop_finish(mob/cooker)
	operating = FALSE

	for(var/obj/item/cooked_item in ingredients)
		cooked_item.microwave_act(src, cooker, randomize_pixel_offset = ingredients.len)

	eject()

/**
 * Temporary opens the cauldron, called when ingredients are added or ejected
 *
 * autoclose - how long it stays open before calling the close() proc
 */
/obj/machinery/cauldron/proc/open(autoclose = 0.6 SECONDS)
	open = TRUE
	update_appearance()
	addtimer(CALLBACK(src, PROC_REF(close)), autoclose)

/**
 * Closes the cauldron, called by the open() proc after some delay
 */
/obj/machinery/cauldron/proc/close()
	open = FALSE
	update_appearance()
