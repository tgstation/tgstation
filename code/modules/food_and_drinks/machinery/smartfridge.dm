// -------------------------
//  SmartFridge.  Much todo
// -------------------------
/obj/machinery/smartfridge
	name = "smartfridge"
	desc = "Keeps cold things cold and hot things cold."
	icon = 'icons/obj/machines/smartfridge.dmi'
	icon_state = "smartfridge-icon"
	base_icon_state = "smartfridge"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	circuit = /obj/item/circuitboard/machine/smartfridge
	light_power = 1
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	integrity_failure = 0.5
	can_atmos_pass = ATMOS_PASS_NO
	/// Icon state part for contents display
	var/contents_overlay_icon = "plant"
	/// What path boards used to construct it should build into when dropped. Needed so we don't accidentally have them build variants with items preloaded in them.
	var/base_build_path = /obj/machinery/smartfridge
	/// Maximum number of items that can be loaded into the machine per matter bin tier
	var/max_n_of_items = 1500
	/// List of items that the machine starts with upon spawn
	var/list/initial_contents
	/// If the machine shows an approximate number of its contents on its sprite
	var/visible_contents = TRUE
	/// Is this smartfridge going to have a glowing screen? (Drying Racks are not)
	var/has_emissive = TRUE
	/// Whether the smartfridge is welded down to the floor disabling unwrenching
	var/can_be_welded_down = TRUE
	/// Whether the smartfridge is welded down to the floor disabling unwrenching
	var/welded_down = FALSE
	/// The sound of item retrieval
	var/vend_sound = 'sound/machines/machine_vend.ogg'
	/// Whether the UI should be set to list view by default
	var/default_list_view = FALSE

/obj/machinery/smartfridge/Initialize(mapload)
	. = ..()
	create_reagents(100, NO_REACT)
	air_update_turf(TRUE, TRUE)
	register_context()
	if(mapload && can_be_welded_down)
		welded_down = TRUE

	if(islist(initial_contents))
		for(var/typekey in initial_contents)
			var/amount = initial_contents[typekey]
			if(isnull(amount))
				amount = 1
			for(var/i in 1 to amount)
				load(new typekey(src))

/obj/machinery/smartfridge/Move(atom/newloc, direct, glide_size_override, update_dir)
	var/turf/old_loc = loc
	. = ..()
	move_update_air(old_loc)

/obj/machinery/smartfridge/welder_act(mob/living/user, obj/item/tool)
	if(!can_be_welded_down)
		return ..()
	if(welded_down)
		if(!tool.tool_start_check(user, amount=2))
			return ITEM_INTERACT_BLOCKING

		user.visible_message(
			span_notice("[user.name] starts to cut \the [src] free from the floor."),
			span_notice("You start to cut [src] free from the floor..."),
			span_hear("You hear welding."),
		)

		if(!tool.use_tool(src, user, delay=100, volume=100))
			return ITEM_INTERACT_BLOCKING

		welded_down = FALSE
		to_chat(user, span_notice("You cut [src] free from the floor."))
		return ITEM_INTERACT_SUCCESS

	if(!anchored)
		balloon_alert(user, "wrench it first!")
		return ITEM_INTERACT_BLOCKING

	if(!tool.tool_start_check(user, amount=2))
		return ITEM_INTERACT_BLOCKING

	user.visible_message(
		span_notice("[user.name] starts to weld \the [src] to the floor."),
		span_notice("You start to weld [src] to the floor..."),
		span_hear("You hear welding."),
	)

	if(!tool.use_tool(src, user, delay = 100, volume = 100))
		return ITEM_INTERACT_BLOCKING

	welded_down = TRUE
	to_chat(user, span_notice("You weld [src] to the floor."))
	return ITEM_INTERACT_SUCCESS

/obj/machinery/smartfridge/welder_act_secondary(mob/living/user, obj/item/tool)
	if(!(machine_stat & BROKEN))
		balloon_alert(user, "no repair needed!")
		return ITEM_INTERACT_BLOCKING

	if(!tool.tool_start_check(user, amount=1))
		return ITEM_INTERACT_BLOCKING

	user.visible_message(
		span_notice("[user] is repairing [src]."),
		span_notice("You begin repairing [src]..."),
		span_hear("You hear welding."),
	)

	if(tool.use_tool(src, user, delay = 40, volume = 50))
		if(!(machine_stat & BROKEN))
			return ITEM_INTERACT_BLOCKING
		to_chat(user, span_notice("You repair [src]"))
		atom_integrity = max_integrity
		set_machine_stat(machine_stat & ~BROKEN)
		update_icon()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/smartfridge/screwdriver_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		if(panel_open)
			add_overlay("[base_icon_state]-panel")
		else
			cut_overlay("[base_icon_state]-panel")
		SStgui.update_uis(src)
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/machinery/smartfridge/can_be_unfasten_wrench(mob/user, silent)
	if(welded_down)
		balloon_alert(user, "unweld first!")
		return FAILED_UNFASTEN
	return ..()

/obj/machinery/smartfridge/set_anchored(anchorvalue)
	. = ..()
	if(!anchored && welded_down) //make sure they're keep in sync in case it was forcibly unanchored by badmins or by a megafauna.
		welded_down = FALSE
	can_atmos_pass = anchorvalue ? ATMOS_PASS_NO : ATMOS_PASS_YES
	air_update_turf(TRUE, anchorvalue)

/obj/machinery/smartfridge/wrench_act(mob/living/user, obj/item/tool)
	if(default_unfasten_wrench(user, tool) == SUCCESSFUL_UNFASTEN)
		power_change()
		return ITEM_INTERACT_SUCCESS

/obj/machinery/smartfridge/crowbar_act(mob/living/user, obj/item/tool)
	if(default_pry_open(tool, close_after_pry = TRUE))
		return ITEM_INTERACT_SUCCESS

	if(welded_down)
		balloon_alert(user, "unweld first!")
	else
		default_deconstruction_crowbar(tool)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/smartfridge/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(isnull(held_item))
		return NONE

	var/tool_tip_set = FALSE
	if(held_item.tool_behaviour == TOOL_WELDER)
		if(welded_down)
			context[SCREENTIP_CONTEXT_LMB] = "Unweld"
			tool_tip_set = TRUE
		else if (!welded_down && anchored && can_be_welded_down)
			context[SCREENTIP_CONTEXT_LMB] = "Weld down"
			tool_tip_set = TRUE
		if(machine_stat & BROKEN)
			context[SCREENTIP_CONTEXT_RMB] = "Repair"
			tool_tip_set = TRUE

	else if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "close" : "open"] panel"
		tool_tip_set = TRUE

	else if(held_item.tool_behaviour == TOOL_CROWBAR)
		if(panel_open)
			context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
			tool_tip_set = TRUE

	else if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = "[anchored ? "Una" : "A"]nchor"
		tool_tip_set = TRUE

	return tool_tip_set ? CONTEXTUAL_SCREENTIP_SET : NONE

/obj/machinery/smartfridge/RefreshParts()
	. = ..()
	for(var/datum/stock_part/matter_bin/matter_bin in component_parts)
		max_n_of_items = initial(max_n_of_items) * matter_bin.tier

/obj/machinery/smartfridge/examine(mob/user)
	. = ..()

	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: This unit can hold a maximum of <b>[max_n_of_items]</b> items.")

	. += structure_examine()

/// Returns details related to the fridge structure
/obj/machinery/smartfridge/proc/structure_examine()
	. = list()

	if(welded_down)
		. += span_info("It's moorings are firmly [EXAMINE_HINT("welded")] to the floor.")
	else if (can_be_welded_down)
		. += span_info("It's moorings are loose and can be [EXAMINE_HINT("welded")] down.")

	if(anchored)
		. += span_info("It is [EXAMINE_HINT("wrenched")] down on the floor.")
	else
		. += span_info("It could be [EXAMINE_HINT("wrenched")] down.")

/obj/machinery/smartfridge/update_appearance(updates=ALL)
	. = ..()

	set_light((!(machine_stat & BROKEN) && powered()) ? MINIMUM_USEFUL_LIGHT_RANGE : 0)

/obj/machinery/smartfridge/update_icon_state()
	icon_state = "[base_icon_state]"
	if(machine_stat & BROKEN)
		icon_state += "-broken"
	return ..()

/// Returns the number of items visible in the fridge. Faster than subtracting 2 lists
/obj/machinery/smartfridge/proc/visible_items()
	return contents.len - 1 // Exclude circuitboard

/obj/machinery/smartfridge/update_overlays()
	. = ..()

	var/shown_contents_length = visible_items()
	if(visible_contents && shown_contents_length)
		var/content_level = "[base_icon_state]-[contents_overlay_icon]"
		switch(shown_contents_length)
			if(1 to 25)
				content_level += "-1"
			if(26 to 50)
				content_level += "-2"
			if(31 to INFINITY)
				content_level += "-3"
		. += mutable_appearance(icon, content_level)

	. += mutable_appearance(icon, "[base_icon_state]-glass[(machine_stat & BROKEN) ? "-broken" : ""]")
	if(has_emissive && powered() && !(machine_stat & BROKEN))
		. += mutable_appearance(icon, "[base_icon_state]-powered")
		. += emissive_appearance(icon, "[base_icon_state]-light-mask", src, alpha = src.alpha)

/obj/machinery/smartfridge/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src.loc, 'sound/effects/glass/glasshit.ogg', 75, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/tools/welder.ogg', 100, TRUE)

/obj/machinery/smartfridge/atom_break(damage_flag)
	playsound(src, SFX_SHATTER, 50, TRUE)
	return ..()

/obj/machinery/smartfridge/attackby(obj/item/weapon, mob/living/user, params)
	if(!machine_stat)
		var/shown_contents_length = visible_items()
		if(shown_contents_length >= max_n_of_items)
			balloon_alert(user, "no space!")
			return FALSE

		if(!(weapon.item_flags & ABSTRACT) && \
			!(weapon.flags_1 & HOLOGRAM_1) && \
			accept_check(weapon) \
		)
			load(weapon, user)
			user.visible_message(span_notice("[user] adds \the [weapon] to \the [src]."), span_notice("You add \the [weapon] to \the [src]."))
			SStgui.update_uis(src)
			if(visible_contents)
				update_appearance()
			return TRUE

		if(istype(weapon, /obj/item/storage/bag))
			var/obj/item/storage/bag = weapon
			var/loaded = 0
			for(var/obj/item/object in bag.contents)
				if(shown_contents_length >= max_n_of_items)
					break
				if(!(object.item_flags & ABSTRACT) && \
					!(object.flags_1 & HOLOGRAM_1) && \
					accept_check(object) \
				)
					load(object, user)
					loaded++
			SStgui.update_uis(src)

			if(loaded)
				if(shown_contents_length >= max_n_of_items)
					user.visible_message(span_notice("[user] loads \the [src] with \the [weapon]."), \
						span_notice("You fill \the [src] with \the [weapon]."))
				else
					user.visible_message(span_notice("[user] loads \the [src] with \the [weapon]."), \
						span_notice("You load \the [src] with \the [weapon]."))
				if(weapon.contents.len)
					to_chat(user, span_warning("Some items are refused."))
				if (visible_contents)
					update_appearance()
				return TRUE
			else
				to_chat(user, span_warning("There is nothing in [weapon] to put in [src]!"))
				return FALSE

	if(!powered())
		to_chat(user, span_warning("\The [src]'s magnetic door won't open without power!"))
		return FALSE

	if(!user.combat_mode || (weapon.item_flags & NOBLUDGEON))
		to_chat(user, span_warning("\The [src] smartly refuses [weapon]."))
		return FALSE

	else
		return ..()

/**
 * Can this item be accepted by the smart fridge
 * Arguments
 * * [weapon][obj/item] - the item to accept
 */
/obj/machinery/smartfridge/proc/accept_check(obj/item/weapon)
	var/static/list/accepted_items = list(
		/obj/item/food/grown,
		/obj/item/seeds,
		/obj/item/grown,
		/obj/item/graft,
	)
	return is_type_in_list(weapon, accepted_items)

/**
 * Loads the item into the smart fridge
 * Arguments
 * * [weapon][obj/item] - the item to load. If the item is being held by a mo it will transfer it from hand else directly force move
 */
/obj/machinery/smartfridge/proc/load(obj/item/weapon, mob/user)
	if(ismob(weapon.loc))
		var/mob/owner = weapon.loc
		if(!owner.transferItemToLoc(weapon, src))
			to_chat(owner, span_warning("\the [weapon] is stuck to your hand, you cannot put it in \the [src]!"))
			return FALSE
		return TRUE
	else
		if(weapon.loc.atom_storage)
			return weapon.loc.atom_storage.attempt_remove(weapon, src, silent = TRUE)
		else
			weapon.forceMove(src)
			return TRUE

/obj/machinery/smartfridge/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SmartVend", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/smartfridge/ui_data(mob/user)
	. = list()

	var/listofitems = list()
	for (var/item in src)
		// We do not vend our own components.
		if(item in component_parts)
			continue

		var/atom/movable/atom = item
		if (!QDELETED(atom))
			var/key = "[atom.type]-[atom.name]"
			if (listofitems[key])
				listofitems[key]["amount"]++
			else
				listofitems[key] = list(
					"path" = key,
					"name" = full_capitalize(atom.name),
					"icon" = atom.icon,
					"icon_state" = atom.icon_state,
					"amount" = 1
					)
	.["contents"] = sort_list(listofitems)
	.["name"] = name
	.["isdryer"] = FALSE
	.["default_list_view"] = default_list_view

/obj/machinery/smartfridge/Exited(atom/movable/gone, direction) // Update the UIs in case something inside is removed
	. = ..()
	SStgui.update_uis(src)

/obj/machinery/smartfridge/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || !ui.user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return

	var/mob/living_mob = ui.user

	switch(action)
		if("Release")
			var/amount = text2num(params["amount"])
			if(isnull(amount) || !isnum(amount))
				return TRUE
			var/dispensed_amount = 0

			if(isAI(living_mob))
				to_chat(living_mob, span_warning("[src] does not respect your authority!"))
				return TRUE

			for(var/obj/item/dispensed_item in contents)
				if(amount <= 0)
					break
				var/item_name = "[dispensed_item.type]-[replacetext(replacetext(dispensed_item.name, "\proper", ""), "\improper", "")]"
				if(params["path"] != item_name)
					continue
				if(dispensed_item in component_parts)
					CRASH("Attempted removal of [dispensed_item] component_part from smartfridge via smartfridge interface.")
				//dispense the item
				if(!living_mob.put_in_hands(dispensed_item))
					dispensed_item.forceMove(drop_location())
					adjust_item_drop_location(dispensed_item)
				use_energy(active_power_usage)
				dispensed_amount++
				amount--
			if(dispensed_amount && vend_sound)
				playsound(src, vend_sound, 50, TRUE, extrarange = -3)
			if (visible_contents)
				update_appearance()
			return TRUE

	return FALSE

// ----------------------------
//  Drying 'smartfridge'
// ----------------------------
/obj/machinery/smartfridge/drying
	name = "dehydrator"
	desc = "A machine meant to remove moisture from various food."
	icon_state = "dehydrator-icon"
	base_icon_state = "dehydrator"
	contents_overlay_icon = "contents"
	circuit = /obj/item/circuitboard/machine/dehydrator
	light_power = 0.5
	base_build_path = /obj/machinery/smartfridge/drying //should really be seeing this without admin fuckery.
	has_emissive = FALSE
	can_atmos_pass = ATMOS_PASS_YES
	can_be_welded_down = FALSE
	max_n_of_items = 25
	vend_sound = null
	/// Is the rack currently drying stuff
	var/drying = FALSE
	/// The reference to the last user's mind. Needed for the chef made trait to be properly applied correctly to dried food.
	var/datum/weakref/current_user

/obj/machinery/smartfridge/drying/Destroy()
	current_user = null
	return ..()

/obj/machinery/smartfridge/drying/AllowDrop()
	return TRUE // Allow drying results to stay inside

/obj/machinery/smartfridge/drying/update_overlays()
	. = ..()
	if(visible_contents && powered() && !(machine_stat & BROKEN))
		var/suffix = drying ? "on" : "off"
		. += mutable_appearance(icon, "[base_icon_state]-[suffix]")
		. += emissive_appearance(icon, "[base_icon_state]-[suffix]", src, alpha = src.alpha)

/obj/machinery/smartfridge/drying/visible_items()
	return min(1, (contents.len - 1)) // Return one if has any, as there's only one icon for overlay

/obj/machinery/smartfridge/drying/ui_data(mob/user)
	. = ..()
	.["isdryer"] = TRUE
	.["drying"] = drying

/obj/machinery/smartfridge/drying/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		update_appearance() // This is to handle a case where the last item is taken out manually instead of through drying pop-out
		return

	var/mob/user = ui.user
	switch(action)
		if("Dry")
			toggle_drying(FALSE, user)
			return TRUE

/obj/machinery/smartfridge/drying/powered()
	return !anchored ? FALSE : ..()

/obj/machinery/smartfridge/drying/power_change()
	. = ..()
	if(!powered())
		toggle_drying(TRUE)

/obj/machinery/smartfridge/drying/load(obj/item/dried_object, mob/user) //For updating the filled overlay
	. = ..()
	if(!.)
		return
	update_appearance()
	if(drying && user?.mind)
		current_user = WEAKREF(user.mind)

/obj/machinery/smartfridge/drying/process(seconds_per_tick)
	if(drying)
		for(var/obj/item/item_iterator in src)
			if(!accept_check(item_iterator))
				continue
			SEND_SIGNAL(item_iterator, COMSIG_ITEM_DRIED, current_user, seconds_per_tick)

		SStgui.update_uis(src)
		update_appearance()
		use_energy(active_power_usage)

/obj/machinery/smartfridge/drying/accept_check(obj/item/O)
	return HAS_TRAIT(O, TRAIT_DRYABLE)

/**
 * Toggles drying on or off
 * Arguments
 * * forceoff - if TRUE will force the dryer off always
 */
/obj/machinery/smartfridge/drying/proc/toggle_drying(forceoff, mob/user)
	if(drying || forceoff)
		drying = FALSE
		current_user = null
		update_use_power(IDLE_POWER_USE)
	else
		drying = TRUE
		if(user?.mind)
			current_user = WEAKREF(user.mind)
		update_use_power(ACTIVE_POWER_USE)
	update_appearance()

/obj/machinery/smartfridge/drying/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	atmos_spawn_air("[TURF_TEMPERATURE(1000)]")

/// Wooden version
/obj/machinery/smartfridge/drying/rack
	name = "drying rack"
	desc = "A wooden contraption, used to dry plant products, food and hide."
	icon_state = "drying-rack"
	base_icon_state = "drying-rack"
	resistance_flags = FLAMMABLE
	visible_contents = FALSE
	base_build_path = /obj/machinery/smartfridge/drying/rack
	use_power = NO_POWER_USE
	idle_power_usage = 0

/obj/machinery/smartfridge/drying/rack/Initialize(mapload)
	. = ..()
	//so we don't drop any of the parent smart fridge parts upon deconstruction
	clear_components()

/obj/machinery/smartfridge/drying/rack/welder_act_secondary(mob/living/user, obj/item/tool)
	return NONE // Can't repair wood with welder

/obj/machinery/smartfridge/drying/rack/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(isnull(held_item))
		return NONE

	var/tool_tip_set = FALSE
	if(held_item.tool_behaviour == TOOL_CROWBAR)
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		tool_tip_set = TRUE
	else if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = "[anchored ? "Un" : ""]anchore"
		tool_tip_set = TRUE

	return tool_tip_set ? CONTEXTUAL_SCREENTIP_SET : NONE

/obj/machinery/smartfridge/drying/rack/structure_examine()
	. = ..()
	. += span_info("The whole rack can be [EXAMINE_HINT("pried")] apart.")

/obj/machinery/smartfridge/drying/rack/default_deconstruction_screwdriver()
	return NONE

/obj/machinery/smartfridge/drying/rack/exchange_parts()
	return

/obj/machinery/smartfridge/drying/rack/on_deconstruction(disassembled)
	new /obj/item/stack/sheet/mineral/wood(drop_location(), 10)

/obj/machinery/smartfridge/drying/rack/crowbar_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_crowbar(tool, ignore_panel = TRUE))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/smartfridge/drying/rack/update_overlays()
	. = ..()
	if(drying)
		. += "[base_icon_state]-drying"
	if(contents.len)
		. += "[base_icon_state]-filled"

// ----------------------------
//  Bar drink smartfridge
// ----------------------------
/obj/machinery/smartfridge/drinks
	name = "drink showcase"
	desc = "A refrigerated storage unit for tasty tasty alcohol."
	base_build_path = /obj/machinery/smartfridge/drinks
	contents_overlay_icon = "drink"

/obj/machinery/smartfridge/drinks/accept_check(obj/item/weapon)
	//not an item or valid container
	if(!is_reagent_container(weapon))
		return FALSE

	//an bowl or something that has no reagents
	if(istype(weapon,/obj/item/reagent_containers/cup/bowl) || !length(weapon.reagents?.reagent_list))
		return FALSE

	//list of items acceptable
	return (istype(weapon, /obj/item/reagent_containers/cup) || istype(weapon, /obj/item/reagent_containers/condiment))

// ----------------------------
//  Food smartfridge
// ----------------------------
/obj/machinery/smartfridge/food
	desc = "A refrigerated storage unit for food."
	base_build_path = /obj/machinery/smartfridge/food
	contents_overlay_icon = "food"

/obj/machinery/smartfridge/food/accept_check(obj/item/weapon)
	if(weapon.w_class >= WEIGHT_CLASS_BULKY)
		return FALSE
	if(IS_EDIBLE(weapon))
		return TRUE
	if(istype(weapon, /obj/item/reagent_containers/cup/bowl) && weapon.reagents?.total_volume > 0)
		return TRUE
	return FALSE

// -------------------------------------
// Xenobiology Slime-Extract Smartfridge
// -------------------------------------
/obj/machinery/smartfridge/extract
	name = "smart slime extract storage"
	desc = "A refrigerated storage unit for slime extracts."
	base_build_path = /obj/machinery/smartfridge/extract
	contents_overlay_icon = "slime"

/obj/machinery/smartfridge/extract/accept_check(obj/item/weapon)
	return (istype(weapon, /obj/item/slime_extract) || istype(weapon, /obj/item/slime_scanner))

/obj/machinery/smartfridge/extract/preloaded
	initial_contents = list(/obj/item/slime_scanner = 2)

// -------------------------------------
// Cytology Petri Dish Smartfridge
// -------------------------------------
/obj/machinery/smartfridge/petri
	name = "smart petri dish storage"
	desc = "A refrigerated storage unit for petri dishes."
	base_build_path = /obj/machinery/smartfridge/petri
	contents_overlay_icon = "petri"

/obj/machinery/smartfridge/petri/accept_check(obj/item/weapon)
	return istype(weapon, /obj/item/petri_dish)

/obj/machinery/smartfridge/petri/preloaded
	initial_contents = list(/obj/item/petri_dish/random = 3)

// -------------------------
// Organ Surgery Smartfridge
// -------------------------
/obj/machinery/smartfridge/organ
	name = "smart organ storage"
	desc = "A refrigerated storage unit for organ storage."
	max_n_of_items = 20 //vastly lower to prevent processing too long
	base_build_path = /obj/machinery/smartfridge/organ
	contents_overlay_icon = "organ"
	/// The rate at which this fridge will repair damaged organs
	var/repair_rate = 0

/obj/machinery/smartfridge/organ/accept_check(obj/item/O)
	return (isorgan(O) || isbodypart(O))

/obj/machinery/smartfridge/organ/load(obj/item/item, mob/user)
	. = ..()
	if(!.) //if the item loads, clear can_decompose
		return

	if(isorgan(item))
		var/obj/item/organ/organ = item
		organ.organ_flags |= ORGAN_FROZEN

	if(isbodypart(item))
		var/obj/item/bodypart/bodypart = item
		for(var/obj/item/organ/stored in bodypart.contents)
			stored.organ_flags |= ORGAN_FROZEN

/obj/machinery/smartfridge/organ/RefreshParts()
	. = ..()
	for(var/datum/stock_part/matter_bin/matter_bin in component_parts)
		max_n_of_items = 20 * matter_bin.tier
		repair_rate = max(0, STANDARD_ORGAN_HEALING * (matter_bin.tier - 1) * 0.5)

/obj/machinery/smartfridge/organ/process(seconds_per_tick)
	for(var/obj/item/organ/target_organ in contents)
		if(!target_organ.damage)
			continue

		target_organ.apply_organ_damage(-repair_rate * target_organ.maxHealth * seconds_per_tick, required_organ_flag = ORGAN_ORGANIC)

/obj/machinery/smartfridge/organ/Exited(atom/movable/gone, direction)
	. = ..()

	if(isorgan(gone))
		var/obj/item/organ/O = gone
		O.organ_flags &= ~ORGAN_FROZEN

	if(isbodypart(gone))
		var/obj/item/bodypart/bodypart = gone
		for(var/obj/item/organ/stored in bodypart.contents)
			stored.organ_flags &= ~ORGAN_FROZEN

// -----------------------------
// Chemistry Medical Smartfridge
// -----------------------------
/obj/machinery/smartfridge/chemistry
	name = "smart chemical storage"
	desc = "A refrigerated storage unit for medicine storage."
	base_build_path = /obj/machinery/smartfridge/chemistry
	contents_overlay_icon = "chem"
	default_list_view = TRUE

/obj/machinery/smartfridge/chemistry/accept_check(obj/item/weapon)
	// not an item or reagent container
	if(!is_reagent_container(weapon))
		return FALSE

	// empty pill prank ok
	if(istype(weapon, /obj/item/reagent_containers/pill))
		return TRUE

	//check each pill in the pill bottle
	if(istype(weapon, /obj/item/storage/pill_bottle))
		if(weapon.contents.len)
			for(var/obj/item/target_item in weapon)
				if(!accept_check(target_item))
					return FALSE
			return TRUE
		return FALSE

	// other empty containers not accepted
	if(!length(weapon.reagents?.reagent_list))
		return FALSE

	// the long list of other containers that can be accepted
	var/static/list/chemfridge_typecache = typecacheof(list(
					/obj/item/reagent_containers/syringe,
					/obj/item/reagent_containers/cup/tube,
					/obj/item/reagent_containers/cup/bottle,
					/obj/item/reagent_containers/cup/beaker,
					/obj/item/reagent_containers/spray,
					/obj/item/reagent_containers/medigel,
					/obj/item/reagent_containers/chem_pack
	))
	return is_type_in_typecache(weapon, chemfridge_typecache)

/obj/machinery/smartfridge/chemistry/preloaded
	initial_contents = list(
		/obj/item/reagent_containers/pill/epinephrine = 12,
		/obj/item/reagent_containers/pill/multiver = 5,
		/obj/item/reagent_containers/cup/bottle/epinephrine = 1,
		/obj/item/reagent_containers/cup/bottle/multiver = 1)

// ----------------------------
// Virology Medical Smartfridge
// ----------------------------
/obj/machinery/smartfridge/chemistry/virology
	name = "smart virus storage"
	desc = "A refrigerated storage unit for volatile sample storage."
	base_build_path = /obj/machinery/smartfridge/chemistry/virology
	contents_overlay_icon = "viro"
	default_list_view = TRUE

/obj/machinery/smartfridge/chemistry/virology/preloaded
	initial_contents = list(
		/obj/item/storage/pill_bottle/sansufentanyl = 2,
		/obj/item/reagent_containers/syringe/antiviral = 4,
		/obj/item/reagent_containers/cup/bottle/cold = 1,
		/obj/item/reagent_containers/cup/bottle/flu_virion = 1,
		/obj/item/reagent_containers/cup/bottle/mutagen = 1,
		/obj/item/reagent_containers/cup/bottle/sugar = 1,
		/obj/item/reagent_containers/cup/bottle/plasma = 1,
		/obj/item/reagent_containers/cup/bottle/synaptizine = 1,
		/obj/item/reagent_containers/cup/bottle/formaldehyde = 1)

// ----------------------------
// Disk """fridge"""
// ----------------------------
/obj/machinery/smartfridge/disks
	name = "disk compartmentalizer"
	desc = "A machine capable of storing a variety of disks. Denoted by most as the DSU (disk storage unit)."
	icon_state = "disktoaster"
	base_icon_state = "disktoaster"
	has_emissive = TRUE
	pass_flags = PASSTABLE
	can_atmos_pass = ATMOS_PASS_YES
	visible_contents = FALSE
	has_emissive = FALSE
	base_build_path = /obj/machinery/smartfridge/disks

/obj/machinery/smartfridge/disks/accept_check(obj/item/weapon)
	return istype(weapon, /obj/item/disk)
