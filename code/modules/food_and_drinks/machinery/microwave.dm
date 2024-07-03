// Microwaving doesn't use recipes, instead it calls the microwave_act of the objects.
// For food, this creates something based on the food's cooked_type

/// Values based on microwave success
#define MICROWAVE_NORMAL 0
#define MICROWAVE_MUCK 1
#define MICROWAVE_PRE 2

/// Values for how broken the microwave is
#define NOT_BROKEN 0
#define KINDA_BROKEN 1
#define REALLY_BROKEN 2

/// The max amount of dirtiness a microwave can be
#define MAX_MICROWAVE_DIRTINESS 100

/// For the wireless version, and display fluff
#define TIER_1_CELL_CHARGE_RATE (0.25 * STANDARD_CELL_CHARGE)

/obj/machinery/microwave
	name = "microwave oven"
	desc = "Cooks and boils stuff."
	icon = 'icons/obj/machines/microwave.dmi'
	base_icon_state = ""
	icon_state = "mw_complete"
	appearance_flags = KEEP_TOGETHER | LONG_GLIDE | PIXEL_SCALE
	layer = BELOW_OBJ_LAYER
	density = TRUE
	circuit = /obj/item/circuitboard/machine/microwave
	pass_flags = PASSTABLE
	light_color = LIGHT_COLOR_DIM_YELLOW
	light_power = 3
	anchored_tabletop_offset = 6
	interaction_flags_click = ALLOW_SILICON_REACH
	/// Is its function wire cut?
	var/wire_disabled = FALSE
	/// Wire cut to run mode backwards
	var/wire_mode_swap = FALSE
	/// Fail due to inserted PDA
	var/pda_failure = FALSE
	var/operating = FALSE
	/// How dirty is it?
	var/dirty = 0
	var/dirty_anim_playing = FALSE
	/// How broken is it? NOT_BROKEN, KINDA_BROKEN, REALLY_BROKEN
	var/broken = NOT_BROKEN
	/// Microwave door position
	var/open = FALSE
	/// Microwave max capacity
	var/max_n_of_items = 10
	/// Microwave efficiency (power) based on the stock components
	var/efficiency = 0
	/// If we use a cell instead of powernet
	var/cell_powered = FALSE
	/// The cell we charge with
	var/obj/item/stock_parts/power_store/cell
	/// The cell we're charging
	var/obj/item/stock_parts/power_store/vampire_cell
	/// Capable of vampire charging PDAs
	var/vampire_charging_capable = FALSE
	/// Charge contents of microwave instead of cook
	var/vampire_charging_enabled = FALSE
	var/datum/looping_sound/microwave/soundloop
	/// May only contain /atom/movables
	var/list/ingredients = list()
	/// When this is the nth ingredient, whats its pixel_x?
	var/list/ingredient_shifts_x = list(
		-2,
		1,
		-5,
		2,
		-6,
		0,
		-4,
	)
	/// When this is the nth ingredient, whats its pixel_y?
	var/list/ingredient_shifts_y = list(
		-4,
		-2,
		-3,
	)
	var/static/radial_examine = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_examine")
	var/static/radial_eject = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_eject")
	var/static/radial_cook = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_cook")
	var/static/radial_charge = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_charge")

	// we show the button even if the proc will not work
	var/static/list/radial_options = list("eject" = radial_eject, "cook" = radial_cook, "charge" = radial_charge)
	var/static/list/ai_radial_options = list("eject" = radial_eject, "cook" = radial_cook, "charge" = radial_charge, "examine" = radial_examine)

/obj/machinery/microwave/Initialize(mapload)
	. = ..()
	register_context()
	set_wires(new /datum/wires/microwave(src))
	create_reagents(100)
	soundloop = new(src, FALSE)
	update_appearance(UPDATE_ICON)

/obj/machinery/microwave/Exited(atom/movable/gone, direction)
	if(gone in ingredients)
		ingredients -= gone
		if(!QDELING(gone) && ingredients.len && isitem(gone))
			var/obj/item/itemized_ingredient = gone
			if(!(itemized_ingredient.item_flags & NO_PIXEL_RANDOM_DROP))
				itemized_ingredient.pixel_x = itemized_ingredient.base_pixel_x + rand(-6, 6)
				itemized_ingredient.pixel_y = itemized_ingredient.base_pixel_y + rand(-5, 6)
	return ..()

/obj/machinery/microwave/on_deconstruction(disassembled)
	eject()
	return ..()

/obj/machinery/microwave/Destroy()
	QDEL_LIST(ingredients)
	QDEL_NULL(wires)
	QDEL_NULL(soundloop)
	QDEL_NULL(particles)
	if(!isnull(cell))
		QDEL_NULL(cell)
	return ..()

/obj/machinery/microwave/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(cell_powered)
		if(!isnull(cell))
			context[SCREENTIP_CONTEXT_CTRL_LMB] = "Remove cell"
		else if(held_item && istype(held_item, /obj/item/stock_parts/power_store/cell))
			context[SCREENTIP_CONTEXT_CTRL_LMB] = "Insert cell"

	if(held_item?.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = "[anchored ? "Unsecure" : "Install/Secure"]"
		return CONTEXTUAL_SCREENTIP_SET

	if(broken > NOT_BROKEN)
		if(broken == REALLY_BROKEN && held_item?.tool_behaviour == TOOL_WIRECUTTER)
			context[SCREENTIP_CONTEXT_LMB] = "Repair"
			return CONTEXTUAL_SCREENTIP_SET

		else if(broken == KINDA_BROKEN && held_item?.tool_behaviour == TOOL_WELDER)
			context[SCREENTIP_CONTEXT_LMB] = "Repair"
			return CONTEXTUAL_SCREENTIP_SET

	context[SCREENTIP_CONTEXT_LMB] = "Show menu"

	if(vampire_charging_capable)
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Change to [vampire_charging_enabled ? "cook" : "charge"]"

	if(length(ingredients) != 0)
		context[SCREENTIP_CONTEXT_RMB] = "Start [vampire_charging_enabled ? "charging" : "cooking"]"

	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/microwave/RefreshParts()
	. = ..()
	efficiency = 0
	vampire_charging_capable = FALSE
	for(var/datum/stock_part/micro_laser/micro_laser in component_parts)
		efficiency += micro_laser.tier
	for(var/datum/stock_part/matter_bin/matter_bin in component_parts)
		max_n_of_items = 10 * matter_bin.tier
		break
	for(var/datum/stock_part/capacitor/capacitor in component_parts)
		if(capacitor.tier >= 2)
			vampire_charging_capable = TRUE
			visible_message(span_notice("The [EXAMINE_HINT("Charge Ready")] light on \the [src] flickers to life."))
			break

/obj/machinery/microwave/examine(mob/user)
	. = ..()
	if(vampire_charging_capable)
		. += span_info("This model features Wave™: a Nanotrasen exclusive. Our latest and greatest, Wave™ allows your PDA to be charged wirelessly through microwave frequencies! You can Wave-charge your device by placing it inside and selecting the charge mode.")
		. += span_info("Because nothing says 'future' like charging your PDA while overcooking your leftovers. Nanotrasen Wave™ - Multitasking, redefined.")

	if(cell_powered)
		. += span_notice("This model is wireless, powered by portable cells. [isnull(cell) ? "The cell slot is empty." : "[EXAMINE_HINT("Ctrl-click")] to remove the power cell."]")

	if(!operating)
		if(!operating && vampire_charging_capable)
			. += span_notice("[EXAMINE_HINT("Alt-click")] to change default mode.")

		. += span_notice("[EXAMINE_HINT("Right-click")] to start [vampire_charging_enabled ? "charging" : "cooking"] cycle.")

	if(!in_range(user, src) && !issilicon(user) && !isobserver(user))
		. += span_warning("You're too far away to examine [src]'s contents and display!")
		return
	if(operating)
		. += span_notice("\The [src] is operating.")
		return

	if(length(ingredients))
		if(issilicon(user))
			. += span_notice("\The [src] camera shows:")
		else
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

	if(!(machine_stat & (NOPOWER|BROKEN)))
		. += "[span_notice("The status display reads:")]\n"+\
		"[span_notice("- Mode: <b>[vampire_charging_enabled ? "Charge" : "Cook"]</b>.")]\n"+\
		"[span_notice("- Capacity: <b>[max_n_of_items]</b> items.")]\n"+\
		span_notice("- Power: <b>[efficiency * TIER_1_CELL_CHARGE_RATE]W</b>.")

		if(cell_powered)
			. += span_notice("- Charge: <b>[isnull(cell) ? "INSERT CELL" : "[round(cell.percent())]%"]</b>.")

#define MICROWAVE_INGREDIENT_OVERLAY_SIZE 24

/obj/machinery/microwave/update_overlays()
	. = ..()

	// All of these will use a full icon state instead
	if(panel_open || dirty >= MAX_MICROWAVE_DIRTINESS || broken || dirty_anim_playing)
		return .

	var/ingredient_count = 0

	for(var/atom/movable/ingredient as anything in ingredients)
		var/image/ingredient_overlay = image(ingredient, src)

		var/list/icon_dimensions = get_icon_dimensions(ingredient.icon)
		ingredient_overlay.transform = ingredient_overlay.transform.Scale(
			MICROWAVE_INGREDIENT_OVERLAY_SIZE / icon_dimensions["width"],
			MICROWAVE_INGREDIENT_OVERLAY_SIZE / icon_dimensions["height"],
		)

		ingredient_overlay.pixel_x = ingredient_shifts_x[(ingredient_count % ingredient_shifts_x.len) + 1]
		ingredient_overlay.pixel_y = ingredient_shifts_y[(ingredient_count % ingredient_shifts_y.len) + 1]
		ingredient_overlay.layer = FLOAT_LAYER
		ingredient_overlay.plane = FLOAT_PLANE
		ingredient_overlay.blend_mode = BLEND_INSET_OVERLAY

		ingredient_count += 1

		. += ingredient_overlay

	var/border_icon_state
	var/door_icon_state

	if(open)
		door_icon_state = "[base_icon_state]door_open"
		border_icon_state = "[base_icon_state]mwo"
	else if(operating)
		if(vampire_charging_enabled)
			door_icon_state = "[base_icon_state]door_charge"
		else
			door_icon_state = "[base_icon_state]door_on"
		border_icon_state = "[base_icon_state]mw1"
	else
		door_icon_state = "[base_icon_state]door_off"
		border_icon_state = "[base_icon_state]mw"


	. += mutable_appearance(
		icon,
		door_icon_state,
	)

	. += border_icon_state

	if(!open)
		. += "[base_icon_state]door_handle"

	if(!(machine_stat & NOPOWER) || cell_powered)
		. += emissive_appearance(icon, "emissive_[border_icon_state]", src, alpha = src.alpha)

	if(cell_powered && !isnull(cell))
		switch(cell.percent())
			if(75 to 100)
				. += mutable_appearance(icon, "[base_icon_state]cell_100")
				. += emissive_appearance(icon, "[base_icon_state]cell_100", src, alpha = src.alpha)
			if(50 to 75)
				. += mutable_appearance(icon, "[base_icon_state]cell_75")
				. += emissive_appearance(icon, "[base_icon_state]cell_75", src, alpha = src.alpha)
			if(25 to 50)
				. += mutable_appearance(icon, "[base_icon_state]cell_25")
				. += emissive_appearance(icon, "[base_icon_state]cell_25", src, alpha = src.alpha)
			else
				. += mutable_appearance(icon, "[base_icon_state]cell_0")
				. += emissive_appearance(icon, "[base_icon_state]cell_0", src, alpha = src.alpha)

	return .

#undef MICROWAVE_INGREDIENT_OVERLAY_SIZE

/obj/machinery/microwave/update_icon_state()
	if(broken)
		icon_state = "[base_icon_state]mwb"
	else if(dirty_anim_playing)
		icon_state = "[base_icon_state]mwbloody1"
	else if(dirty >= MAX_MICROWAVE_DIRTINESS)
		icon_state = open ? "[base_icon_state]mwbloodyo" : "[base_icon_state]mwbloody"
	else if(operating)
		icon_state = "[base_icon_state]back_on"
	else if(open)
		icon_state = "[base_icon_state]back_open"
	else if(panel_open)
		icon_state = "[base_icon_state]mw-o"
	else
		icon_state = "[base_icon_state]back_off"

	return ..()

/obj/machinery/microwave/wrench_act(mob/living/user, obj/item/tool)
	if(default_unfasten_wrench(user, tool))
		update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/microwave/crowbar_act(mob/living/user, obj/item/tool)
	if(!default_deconstruction_crowbar(tool))
		return
	return ITEM_INTERACT_SUCCESS

/obj/machinery/microwave/screwdriver_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/microwave/wirecutter_act(mob/living/user, obj/item/tool)
	if(broken != REALLY_BROKEN)
		return NONE

	user.visible_message(
		span_notice("[user] starts to fix part of [src]."),
		span_notice("You start to fix part of [src]..."),
	)

	if(!tool.use_tool(src, user, 2 SECONDS, volume = 50))
		return ITEM_INTERACT_BLOCKING

	user.visible_message(
		span_notice("[user] fixes part of [src]."),
		span_notice("You fix part of [src]."),
	)
	broken = KINDA_BROKEN // Fix it a bit
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/microwave/welder_act(mob/living/user, obj/item/tool)
	if(broken != KINDA_BROKEN)
		return NONE

	user.visible_message(
		span_notice("[user] starts to fix part of [src]."),
		span_notice("You start to fix part of [src]..."),
	)

	if(!tool.use_tool(src, user, 2 SECONDS, amount = 1, volume = 50))
		return ITEM_INTERACT_BLOCKING

	user.visible_message(
		span_notice("[user] fixes [src]."),
		span_notice("You fix [src]."),
	)
	broken = NOT_BROKEN
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/microwave/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	if(!tool.tool_behaviour)
		return ..()
	if(operating)
		return ITEM_INTERACT_SKIP_TO_ATTACK // Don't use tools if we're operating
	if(dirty >= MAX_MICROWAVE_DIRTINESS)
		return ITEM_INTERACT_SKIP_TO_ATTACK // Don't insert items if we're dirty
	if(panel_open && is_wire_tool(tool))
		wires.interact(user)
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/machinery/microwave/item_interaction(mob/living/user, obj/item/item, list/modifiers)
	if(operating)
		return NONE

	if(broken > NOT_BROKEN)
		balloon_alert(user, "it's broken!")
		return ITEM_INTERACT_BLOCKING

	if(istype(item, /obj/item/stock_parts/power_store/cell) && cell_powered)
		var/swapped = FALSE
		if(!isnull(cell))
			cell.forceMove(drop_location())
			if(!HAS_SILICON_ACCESS(user) && Adjacent(user))
				user.put_in_hands(cell)
			cell = null
			swapped = TRUE
		if(!user.transferItemToLoc(item, src))
			update_appearance()
			return ITEM_INTERACT_BLOCKING
		cell = item
		balloon_alert(user, "[swapped ? "swapped" : "inserted"] cell")
		update_appearance()
		return ITEM_INTERACT_SUCCESS

	if(!anchored)
		balloon_alert(user, "not secured!")
		return ITEM_INTERACT_BLOCKING

	if(dirty >= MAX_MICROWAVE_DIRTINESS) // The microwave is all dirty so can't be used!
		balloon_alert(user, "it's too dirty!")
		return ITEM_INTERACT_BLOCKING

	if(vampire_charging_capable && istype(item, /obj/item/modular_computer) && ingredients.len > 0)
		balloon_alert(user, "max 1 device!")
		return ITEM_INTERACT_BLOCKING

	if(istype(item, /obj/item/storage))
		var/obj/item/storage/tray = item
		var/loaded = 0

		if(!istype(item, /obj/item/storage/bag/tray))
			// Non-tray dumping requires a do_after
			to_chat(user, span_notice("You start dumping out the contents of [item] into [src]..."))
			if(!do_after(user, 2 SECONDS, target = tray))
				return ITEM_INTERACT_BLOCKING

		for(var/obj/tray_item in tray.contents)
			if(!IS_EDIBLE(tray_item))
				continue
			if(ingredients.len >= max_n_of_items)
				balloon_alert(user, "it's full!")
				return ITEM_INTERACT_BLOCKING
			if(tray.atom_storage.attempt_remove(tray_item, src))
				loaded++
				ingredients += tray_item
		if(loaded)
			open(autoclose = 0.6 SECONDS)
			to_chat(user, span_notice("You insert [loaded] items into \the [src]."))
			update_appearance()
		return ITEM_INTERACT_SUCCESS

	if(item.w_class <= WEIGHT_CLASS_NORMAL && !user.combat_mode)
		if(ingredients.len >= max_n_of_items)
			balloon_alert(user, "it's full!")
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(item, src))
			balloon_alert(user, "it's stuck to your hand!")
			return ITEM_INTERACT_BLOCKING

		ingredients += item
		open(autoclose = 0.6 SECONDS)
		user.visible_message(span_notice("[user] adds \a [item] to \the [src]."), span_notice("You add [item] to \the [src]."))
		update_appearance()
		return ITEM_INTERACT_SUCCESS

/obj/machinery/microwave/attack_hand_secondary(mob/user, list/modifiers)
	if(user.can_perform_action(src, ALLOW_SILICON_REACH))
		if(!length(ingredients))
			balloon_alert(user, "it's empty!")
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

		start_cycle(user)

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/microwave/click_alt(mob/user, list/modifiers)
	if(!vampire_charging_capable)
		return NONE

	vampire_charging_enabled = !vampire_charging_enabled
	balloon_alert(user, "set to [vampire_charging_enabled ? "charge" : "cook"]")
	playsound(src, 'sound/machines/twobeep_high.ogg', 50, FALSE)
	if(HAS_SILICON_ACCESS(user))
		visible_message(span_notice("[user] sets \the [src] to [vampire_charging_enabled ? "charge" : "cook"]."), blind_message = span_notice("You hear \the [src] make an informative beep!"))
	return CLICK_ACTION_SUCCESS

/obj/machinery/microwave/click_ctrl(mob/user)
	if(!anchored)
		return NONE

	if(cell_powered && !isnull(cell))
		user.put_in_hands(cell)
		balloon_alert(user, "removed cell")
		cell = null
		update_appearance()
		return CLICK_ACTION_SUCCESS

	return CLICK_ACTION_BLOCKING

/obj/machinery/microwave/ui_interact(mob/user)
	. = ..()

	if(!anchored)
		balloon_alert(user, "not secured!")
		return
	if(operating || panel_open || !user.can_perform_action(src, ALLOW_SILICON_REACH))
		return
	if(HAS_AI_ACCESS(user) && (machine_stat & NOPOWER))
		return

	if(!length(ingredients))
		if(HAS_AI_ACCESS(user))
			examine(user)
		else
			balloon_alert(user, "it's empty!")
		return

	var/choice = show_radial_menu(user, src, HAS_AI_ACCESS(user) ? ai_radial_options : radial_options, require_near = !HAS_SILICON_ACCESS(user))

	// post choice verification
	if(operating || panel_open || (!vampire_charging_capable && !anchored) || !user.can_perform_action(src, ALLOW_SILICON_REACH))
		return
	if(HAS_AI_ACCESS(user) && (machine_stat & NOPOWER))
		return

	switch(choice)
		if("eject")
			eject()
		if("cook")
			vampire_charging_enabled = FALSE
			start_cycle(user)
		if("charge")
			vampire_charging_enabled = TRUE
			start_cycle(user)
		if("examine")
			examine(user)

/obj/machinery/microwave/wash(clean_types)
	. = ..()
	if(operating || !(clean_types & CLEAN_SCRUB))
		return .

	dirty = 0
	update_appearance()
	return . || TRUE

/obj/machinery/microwave/proc/eject()
	var/atom/drop_loc = drop_location()
	for(var/obj/item/item_ingredient as anything in ingredients)
		item_ingredient.forceMove(drop_loc)
		item_ingredient.dropped() //Mob holders can be on the ground if we don't do this
	open(autoclose = 1.4 SECONDS)

/obj/machinery/microwave/proc/start_cycle(mob/user)
	if(wire_mode_swap)
		spark()
		if(vampire_charging_enabled)
			cook(user)
		else
			charge(user)

	else if(vampire_charging_enabled)
		charge(user)
	else
		cook(user)

/**
 * Begins the process of cooking the included ingredients.
 *
 * * cooker - The mob that initiated the cook cycle, can be null if no apparent mob triggered it (such as via emp)
 */
/obj/machinery/microwave/proc/cook(mob/cooker)
	if(machine_stat & (NOPOWER|BROKEN))
		return

	if(operating || broken > 0 || panel_open || !anchored || dirty >= MAX_MICROWAVE_DIRTINESS)
		return

	if(wire_disabled)
		audible_message("[src] buzzes.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
		return

	if(cell_powered && cell?.charge < TIER_1_CELL_CHARGE_RATE * efficiency)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
		balloon_alert(cooker, "no power draw!")
		return

	if(cooker && HAS_TRAIT(cooker, TRAIT_CURSED) && prob(7))
		muck()
		return

	if(prob(max((5 / efficiency) - 5, dirty * 5))) //a clean unupgraded microwave has no risk of failure
		muck()
		return

	// How many items are we cooking that aren't already food items
	var/non_food_ingedients = length(ingredients)
	for(var/atom/movable/potential_fooditem as anything in ingredients)
		if(IS_EDIBLE(potential_fooditem))
			non_food_ingedients--
		if(istype(potential_fooditem, /obj/item/modular_computer) && prob(75))
			pda_failure = TRUE
			notify_ghosts(
				"[cooker] has overheated their PDA!",
				source = src,
				notify_flags = NOTIFY_CATEGORY_NOFLASH,
				header = "Hunger Games: Catching Fire",
			)

	// If we're cooking non-food items we can fail randomly
	if(length(non_food_ingedients) && prob(min(dirty * 5, 100)))
		start_can_fail(cooker)
		return

	start(cooker)

/obj/machinery/microwave/proc/wzhzhzh()
	if(cell_powered && !isnull(cell))
		if(!cell.use(TIER_1_CELL_CHARGE_RATE * efficiency))
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
			return

	visible_message(span_notice("\The [src] turns on."), null, span_hear("You hear a microwave humming."))
	operating = TRUE
	set_light(l_range = 1.5, l_power = 1.2, l_on = TRUE)
	soundloop.start()
	update_appearance()

/obj/machinery/microwave/proc/spark()
	visible_message(span_warning("Sparks fly around [src]!"))
	var/datum/effect_system/spark_spread/sparks = new
	sparks.set_up(2, 1, src)
	sparks.start()

/**
 * The start of the cook loop
 *
 * * cooker - The mob that initiated the cook cycle, can be null if no apparent mob triggered it (such as via emp)
 */
/obj/machinery/microwave/proc/start(mob/cooker)
	wzhzhzh()
	cook_loop(type = MICROWAVE_NORMAL, cycles = 10, cooker = cooker)

/**
 * The start of the cook loop, but can fail (result in a splat / dirty microwave)
 *
 * * cooker - The mob that initiated the cook cycle, can be null if no apparent mob triggered it (such as via emp)
 */
/obj/machinery/microwave/proc/start_can_fail(mob/cooker)
	wzhzhzh()
	cook_loop(type = MICROWAVE_PRE, cycles = 4, cooker = cooker)

/obj/machinery/microwave/proc/muck()
	wzhzhzh()
	playsound(loc, 'sound/effects/splat.ogg', 50, TRUE)
	dirty_anim_playing = TRUE
	update_appearance()
	cook_loop(type = MICROWAVE_MUCK, cycles = 4)

/**
 * The actual cook loop started via [proc/start] or [proc/start_can_fail]
 *
 * * type - the type of cooking, determined via how this iteration of cook_loop is called, and determines the result
 * * time - how many loops are left, base case for recursion
 * * wait - deciseconds between loops
 * * cooker - The mob that initiated the cook cycle, can be null if no apparent mob triggered it (such as via emp)
 */
/obj/machinery/microwave/proc/cook_loop(type, cycles, wait = max(12 - 2 * efficiency, 2), mob/cooker) // standard wait is 10
	if((machine_stat & BROKEN) && type == MICROWAVE_PRE)
		pre_fail()
		return

	if(cycles <= 0 || !length(ingredients))
		switch(type)
			if(MICROWAVE_NORMAL)
				loop_finish(cooker)
			if(MICROWAVE_MUCK)
				muck_finish()
			if(MICROWAVE_PRE)
				pre_success(cooker)
		return

	if(cycles == 1) //Only needs to try to shock mobs once, towards the end of the loop
		var/successful_shock
		var/list/microwave_contents = list()
		microwave_contents += get_all_contents() //Mobs are often hid inside of mob holders, which could be fried and made into a burger...
		for(var/mob/living/victim in microwave_contents)
			if(victim.electrocute_act(shock_damage = 100, source = src, siemens_coeff = 1, flags = SHOCK_NOGLOVES))
				successful_shock = TRUE
				if(victim.stat == DEAD) //This is mostly so humans that can_be_held don't get gibbed from one microwave run alone, but mice become burnt messes
					victim.gib()
					muck()
		if(successful_shock) //We only want to give feedback once, regardless of how many mobs got shocked
			var/list/cant_smell = list()
			for(var/mob/smeller in get_hearers_in_view(DEFAULT_MESSAGE_RANGE, src))
				if(HAS_TRAIT(smeller, TRAIT_ANOSMIA))
					cant_smell += smeller
			visible_message(span_danger("You smell a burnt smell coming from [src]!"), ignored_mobs = cant_smell)
			particles = new /particles/smoke()
			addtimer(CALLBACK(src, PROC_REF(remove_smoke)), 10 SECONDS)
			Shake(duration = 1 SECONDS)

	cycles--
	use_energy(active_power_usage)
	addtimer(CALLBACK(src, PROC_REF(cook_loop), type, cycles, wait, cooker), wait)

/obj/machinery/microwave/proc/remove_smoke()
	QDEL_NULL(particles)

/obj/machinery/microwave/power_change()
	. = ..()
	if(cell_powered)
		return

	if((machine_stat & NOPOWER) && operating)
		pre_fail()
		eject()

/**
 * Called when the cook_loop is done successfully, no dirty mess or whatever
 *
 * * cooker - The mob that initiated the cook cycle, can be null if no apparent mob triggered it (such as via emp)
 */
/obj/machinery/microwave/proc/loop_finish(mob/cooker)
	operating = FALSE
	if(pda_failure)
		spark()
		pda_failure = FALSE // in case they repair it after this, reset
		broken = REALLY_BROKEN
		explosion(src, heavy_impact_range = 1, light_impact_range = 2, flame_range = 1)

	var/cursed_chef = cooker && HAS_TRAIT(cooker, TRAIT_CURSED)
	var/metal_amount = 0
	for(var/obj/item/cooked_item in ingredients)
		var/sigreturn = cooked_item.microwave_act(src, cooker, randomize_pixel_offset = ingredients.len)
		if(sigreturn & COMPONENT_MICROWAVE_SUCCESS)
			if(isstack(cooked_item))
				var/obj/item/stack/cooked_stack = cooked_item
				dirty += cooked_stack.amount
			else
				dirty++

		metal_amount += (cooked_item.custom_materials?[GET_MATERIAL_REF(/datum/material/iron)] || 0)

	if(cursed_chef && (metal_amount || prob(5)))  // If we're unlucky and have metal, we're guaranteed to explode
		spark()
		broken = REALLY_BROKEN
		explosion(src, light_impact_range = 2, flame_range = 1)

	if(metal_amount)
		spark()
		broken = REALLY_BROKEN
		if(prob(max(metal_amount / 2, 33)))
			explosion(src, heavy_impact_range = 1, light_impact_range = 2)

	after_finish_loop()

/obj/machinery/microwave/proc/pre_fail()
	broken = REALLY_BROKEN
	operating = FALSE
	spark()
	after_finish_loop()

/obj/machinery/microwave/proc/pre_success(mob/cooker)
	cook_loop(type = MICROWAVE_NORMAL, cycles = 10, cooker = cooker)

/obj/machinery/microwave/proc/muck_finish()
	visible_message(span_warning("\The [src] gets covered in muck!"))

	dirty = MAX_MICROWAVE_DIRTINESS
	dirty_anim_playing = FALSE
	operating = FALSE

	after_finish_loop()

/obj/machinery/microwave/proc/after_finish_loop()
	set_light(l_on = FALSE)
	soundloop.stop()
	eject()
	open(autoclose = 2 SECONDS)

/obj/machinery/microwave/proc/open(autoclose = 2 SECONDS)
	open = TRUE
	playsound(loc, 'sound/machines/click.ogg', 15, TRUE, -3)
	update_appearance()
	addtimer(CALLBACK(src, PROC_REF(close)), autoclose)

/obj/machinery/microwave/proc/close()
	open = FALSE
	update_appearance()

/**
 * The start of the charge loop
 *
 * * cooker - The mob that initiated the cook cycle, can be null if no apparent mob triggered it (such as via emp)
 */
/obj/machinery/microwave/proc/vampire(mob/cooker)
	var/obj/item/modular_computer/vampire_pda = LAZYACCESS(ingredients, 1)
	if(isnull(vampire_pda))
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
		after_finish_loop()
		return

	vampire_cell = vampire_pda.internal_cell
	if(isnull(vampire_cell))
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
		after_finish_loop()
		return

	wzhzhzh()
	var/vampire_charge_amount = vampire_cell.maxcharge - vampire_cell.charge
	charge_loop(vampire_charge_amount, cooker = cooker)

/obj/machinery/microwave/proc/charge(mob/cooker)
	if(!vampire_charging_capable)
		balloon_alert(cooker, "needs upgrade!")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
		return

	if(operating || broken > 0 || panel_open || dirty >= MAX_MICROWAVE_DIRTINESS)
		return

	if(wire_disabled)
		audible_message("[src] buzzes.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
		return

	// We should only be charging PDAs
	for(var/atom/movable/potential_item as anything in ingredients)
		if(!istype(potential_item, /obj/item/modular_computer))
			balloon_alert(cooker, "pda only!")
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
			eject()
			return

	vampire(cooker)

/**
 * The actual cook loop started via [proc/start] or [proc/start_can_fail]
 *
 * * type - the type of charging, determined via how this iteration of cook_loop is called, and determines the result
 * * time - how many loops are left, base case for recursion
 * * wait - deciseconds between loops
 * * cooker - The mob that initiated the cook cycle, can be null if no apparent mob triggered it (such as via emp)
 */
/obj/machinery/microwave/proc/charge_loop(vampire_charge_amount, wait = max(12 - 2 * efficiency, 2), mob/cooker) // standard wait is 10
	if(machine_stat & BROKEN)
		pre_fail()
		return

	if(!vampire_charge_amount || !length(ingredients) || isnull(cell) || !cell.charge || vampire_charge_amount < 25)
		vampire_cell = null
		charge_loop_finish(cooker)
		return

	var/charge_rate = vampire_cell.chargerate * (1 + ((efficiency - 1) * 0.25))
	if(charge_rate > vampire_charge_amount)
		charge_rate = vampire_charge_amount

	if(cell_powered && !cell.use(charge_rate))
		charge_loop_finish(cooker)

	use_energy(charge_rate * (0.5 - efficiency * 0.12)) //Some of the power gets lost as heat.
	charge_cell(charge_rate * (0.5 + efficiency * 0.12), vampire_cell) //Cell gets charged, which further uses power.


	vampire_charge_amount = vampire_cell.maxcharge - vampire_cell.charge

	addtimer(CALLBACK(src, PROC_REF(charge_loop), vampire_charge_amount, wait, cooker), wait)

/obj/machinery/microwave/power_change()
	. = ..()
	if((machine_stat & NOPOWER) && operating)
		pre_fail()
		eject()

/**
 * Called when the charge_loop is done successfully, no dirty mess or whatever
 *
 * * cooker - The mob that initiated the cook cycle, can be null if no apparent mob triggered it (such as via emp)
 */
/obj/machinery/microwave/proc/charge_loop_finish(mob/cooker)
	operating = FALSE
	var/cursed_chef = cooker && HAS_TRAIT(cooker, TRAIT_CURSED)
	if(cursed_chef && prob(5))
		spark()
		broken = REALLY_BROKEN
		explosion(src, light_impact_range = 2, flame_range = 1)

	// playsound(src, 'sound/machines/chime.ogg', 50, FALSE)
	after_finish_loop()

/// Type of microwave that automatically turns it self on erratically. Probably don't use this outside of the holodeck program "Microwave Paradise".
/// You could also live your life with a microwave that will continously run in the background of everything while also not having any power draw. I think the former makes more sense.
/obj/machinery/microwave/hell
	desc = "Cooks and boils stuff. This one appears to be a bit... off."
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0

/obj/machinery/microwave/hell/Initialize(mapload)
	. = ..()
	//We want there to be some chance of them getting a working microwave (eventually).
	if(prob(95))
		//The microwave should turn off asynchronously from any other microwaves that initialize at the same time. Keep in mind this will not turn off, since there is nothing to call the proc that ends this microwave's looping
		addtimer(CALLBACK(src, PROC_REF(wzhzhzh)), rand(0.5 SECONDS, 3 SECONDS))

/obj/machinery/microwave/engineering
	name = "wireless microwave oven"
	desc = "For the hard-working tradesperson who's in the middle of nowhere and just wants to warm up their pastry-based savoury item from an overpriced vending machine."
	base_icon_state = "engi_"
	icon_state = "engi_mw_complete"
	circuit = /obj/item/circuitboard/machine/microwave/engineering
	light_color = LIGHT_COLOR_BABY_BLUE
	// We don't use area power, we always use the cell
	use_power = NO_POWER_USE
	cell_powered = TRUE
	vampire_charging_capable = TRUE
	ingredient_shifts_x = list(
		0,
		5,
		-5,
		3,
		-3,
	)
	ingredient_shifts_y = list(
		0,
		2,
		-2,
	)

/obj/machinery/microwave/engineering/Initialize(mapload)
	. = ..()
	if(mapload)
		cell = new /obj/item/stock_parts/power_store/cell/upgraded/plus
	update_appearance()

/obj/machinery/microwave/engineering/cell_included/Initialize(mapload)
	. = ..()
	cell = new /obj/item/stock_parts/power_store/cell/upgraded/plus
	update_appearance()

#undef MICROWAVE_NORMAL
#undef MICROWAVE_MUCK
#undef MICROWAVE_PRE

#undef NOT_BROKEN
#undef KINDA_BROKEN
#undef REALLY_BROKEN

#undef MAX_MICROWAVE_DIRTINESS
#undef TIER_1_CELL_CHARGE_RATE
