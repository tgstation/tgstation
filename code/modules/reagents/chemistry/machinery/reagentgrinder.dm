
/obj/machinery/reagentgrinder
	name = "\improper All-In-One Grinder"
	desc = "From BlenderTech. Will It Blend? Let's test it out!"
	icon = 'icons/obj/machines/kitchen.dmi'
	icon_state = "juicer"
	base_icon_state = "juicer"
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.0025
	circuit = /obj/item/circuitboard/machine/reagentgrinder
	pass_flags = PASSTABLE
	resistance_flags = ACID_PROOF
	interaction_flags_machine = parent_type::interaction_flags_machine | INTERACT_MACHINE_OFFLINE
	anchored_tabletop_offset = 8

	/// The maximum weight of items this grinder can hold
	var/maximum_weight = WEIGHT_CLASS_BULKY
	/// Is the grinder currently performing work
	var/operating = FALSE
	/// The beaker to hold the final products
	var/obj/item/reagent_containers/beaker = null
	/// How fast operations take place
	var/speed = 1

/obj/machinery/reagentgrinder/Initialize(mapload)
	. = ..()

	if(mapload)
		beaker = new /obj/item/reagent_containers/cup/beaker/large(src)

	register_context()
	update_appearance(UPDATE_OVERLAYS)

	RegisterSignal(src, COMSIG_STORAGE_DUMP_CONTENT, PROC_REF(on_storage_dump))

/obj/machinery/reagentgrinder/Destroy()
	QDEL_NULL(beaker)
	return ..()

/obj/machinery/reagentgrinder/contents_explosion(severity, target)
	if(!QDELETED(beaker))
		return

	switch(severity)
		if(EXPLODE_DEVASTATE)
			SSexplosions.high_mov_atom += beaker
		if(EXPLODE_HEAVY)
			SSexplosions.med_mov_atom += beaker
		if(EXPLODE_LIGHT)
			SSexplosions.low_mov_atom += beaker

/obj/machinery/reagentgrinder/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	var/result = NONE
	if(isnull(held_item))
		if(!QDELETED(beaker) && !operating)
			context[SCREENTIP_CONTEXT_RMB] = "Remove beaker"
			result = CONTEXTUAL_SCREENTIP_SET
		return result

	if(is_reagent_container(held_item) && held_item.is_open_container() && !operating)
		if(QDELETED(beaker))
			context[SCREENTIP_CONTEXT_LMB] = "Insert beaker"
		else
			context[SCREENTIP_CONTEXT_LMB] = "Replace beaker"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Close" : "Open"] panel"
		return CONTEXTUAL_SCREENTIP_SET
	else if(held_item.tool_behaviour == TOOL_CROWBAR && panel_open)
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET
	else if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = "[anchored ? "Una" : "A"]nchor"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/storage/bag))
		context[SCREENTIP_CONTEXT_LMB] = "Transfer contents"
	else
		context[SCREENTIP_CONTEXT_LMB] = "Insert item"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/reagentgrinder/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !issilicon(user) && !isobserver(user))
		. += span_warning("You're too far away to examine [src]'s contents and display!")
		return

	var/total_weight = 0
	var/list/obj/item/to_process = list()
	for(var/obj/item/target in src)
		if((target in component_parts) || target == beaker)
			continue
		to_process["[target.name]"] += 1
		total_weight += target.w_class
	if(to_process.len)
		. += span_notice("Currently holding.")
		for(var/target_name as anything in to_process)
			. += span_notice("[to_process[target_name]] [target_name]")
		. += span_notice("Filled to <b>[round((total_weight / maximum_weight) * 100)]%</b> capacity.")

	if(!QDELETED(beaker))
		. += span_notice("A beaker of <b>[beaker.reagents.maximum_volume]u</b> capacity is present. Contains:")
		if(beaker.reagents.total_volume)
			for(var/datum/reagent/reg as anything in beaker.reagents.reagent_list)
				. += span_notice("[round(reg.volume, CHEMICAL_VOLUME_ROUNDING)]u of [reg.name]")
		else
			. += span_notice("Nothing.")
		. += span_notice("[EXAMINE_HINT("Right click")] with empty hand to remove beaker.")
	else
		. += span_warning("It's missing a beaker.")

	. += span_notice("You can drag a storage item to dump its contents in the grinder.")
	if(anchored)
		. += span_notice("It can be [EXAMINE_HINT("wrenched")] loose.")
	else
		. += span_warning("Needs to be [EXAMINE_HINT("wrenched")] in place to work.")
	. += span_notice("Its maintainence panel can be [EXAMINE_HINT("screwed")] [panel_open ? "closed" : "open"].")
	if(panel_open)
		. += span_notice("It can be [EXAMINE_HINT("pried")] apart.")

/obj/machinery/reagentgrinder/update_overlays()
	. = ..()

	if(!QDELETED(beaker))
		. += "[base_icon_state]-beaker"

	if(anchored && !panel_open && is_operational)
		. += "[base_icon_state]-on"

/obj/machinery/reagentgrinder/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == beaker)
		beaker = null
		update_appearance(UPDATE_OVERLAYS)

/obj/machinery/reagentgrinder/RefreshParts()
	. = ..()

	for(var/datum/stock_part/part in component_parts)
		if(istype(part, /datum/stock_part/servo))
			speed = part.tier
		else if(istype(part, /datum/stock_part/matter_bin))
			maximum_weight = WEIGHT_CLASS_GIGANTIC * part.tier
/**
 * Inserts, removes or replaces the beaker present
 * Arguments
 *
 * * mob/living/user - the player performing the action
 * * obj/item/reagent_containers/new_beaker - the new beaker to replace the old, null to do nothing
 */
/obj/machinery/reagentgrinder/proc/replace_beaker(mob/living/user, obj/item/reagent_containers/new_beaker)
	PRIVATE_PROC(TRUE)

	if(!QDELETED(beaker))
		try_put_in_hand(beaker, user)

	if(!QDELETED(new_beaker))
		if(!user.transferItemToLoc(new_beaker, src))
			return
		beaker = new_beaker

	update_appearance(UPDATE_OVERLAYS)

/**
 * Transfer this item or items inside if its a bag into the grinder
 * Arguments
 *
 * * mob/user - the player who is inserting these items
 * * list/obj/item/to_add - list of items to add
 */
/obj/machinery/reagentgrinder/proc/load_items(mob/user, list/obj/item/to_add)
	PRIVATE_PROC(TRUE)

	//surface level checks to filter out items that can be grinded/juice
	var/list/obj/item/filtered_list = list()
	for(var/obj/item/ingredient as anything in to_add)
		//what are we trying to grind exactly?
		if((ingredient.item_flags & ABSTRACT) || (ingredient.flags_1 & HOLOGRAM_1))
			continue

		//Nothing would come from grinding or juicing
		if(!length(ingredient.grind_results) && !ingredient.reagents.total_volume)
			to_chat(user, span_warning("You cannot grind/juice [ingredient] into reagents!"))
			continue

		//Error messages should be in the objects' definitions
		if(!ingredient.blend_requirements(src))
			continue

		filtered_list += ingredient
	if(!filtered_list.len)
		return FALSE

	//find total weight of all items already in grinder
	var/total_weight
	for(var/obj/item/to_process in src)
		if((to_process in component_parts) || to_process == beaker)
			continue
		total_weight += to_process.w_class

	//Now transfer the items 1 at a time while ensuring we don't go above the maximum allowed weight
	var/items_transfered = 0
	for(var/obj/item/weapon as anything in filtered_list)
		if(weapon.w_class + total_weight > maximum_weight)
			to_chat(user, span_warning("[weapon] is too big to fit into [src]."))
			continue
		weapon.forceMove(src)
		total_weight += weapon.w_class
		items_transfered += 1
		to_chat(user, span_notice("[weapon] was loaded into [src]."))

	return items_transfered

/obj/machinery/reagentgrinder/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.combat_mode || (tool.item_flags & ABSTRACT) || (tool.flags_1 & HOLOGRAM_1) || !can_interact(user) || !user.can_perform_action(src, ALLOW_SILICON_REACH))
		return NONE

	//add the beaker
	if (is_reagent_container(tool) && tool.is_open_container())
		replace_beaker(user, tool)
		to_chat(user, span_notice("You add [tool] to [src]."))
		return ITEM_INTERACT_SUCCESS

	//add items from bag
	else if(istype(tool, /obj/item/storage/bag))
		var/list/obj/item/to_add = list()
		//list of acceptable items from the bag
		var/static/list/accepted_items = list(
			/obj/item/grown,
			/obj/item/food/grown,
			/obj/item/food/honeycomb,
		)

		//add to list of items to check for
		for(var/obj/item/ingredient in tool)
			if(!is_type_in_list(ingredient, accepted_items))
				continue
			to_add += ingredient

		//add the items
		var/items_added = load_items(user, to_add)
		if(!items_added)
			to_chat(user, span_warning("No items were added."))
			return ITEM_INTERACT_BLOCKING
		to_chat(user, span_notice("[items_added] items were added from [tool] to [src]."))
		return ITEM_INTERACT_SUCCESS

	//add item directly
	else if(length(tool.grind_results) || tool.reagents?.total_volume)
		if(tool.atom_storage) //anything that has internal storage would be too much recursion for us to handle
			to_chat(user, span_notice("Drag this item onto [src] to dump its contents."))
			return ITEM_INTERACT_BLOCKING

		//add the items
		if(!load_items(user, list(tool)))
			return ITEM_INTERACT_BLOCKING
		to_chat(user, span_notice("[tool] was added to [src]."))
		return ITEM_INTERACT_SUCCESS

	//ask player to drag stuff into grinder
	else if(tool.atom_storage)
		to_chat(user, span_warning("You must drag & dump contents of [tool] into [src]."))
		return ITEM_INTERACT_BLOCKING

	return NONE

/obj/machinery/reagentgrinder/wrench_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return NONE

	var/tool_result = ITEM_INTERACT_BLOCKING
	if(operating)
		balloon_alert(user, "still operating!")
		return tool_result

	if(default_unfasten_wrench(user, tool) == SUCCESSFUL_UNFASTEN)
		update_appearance(UPDATE_OVERLAYS)
		tool_result = ITEM_INTERACT_SUCCESS
	return tool_result

/obj/machinery/reagentgrinder/screwdriver_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return NONE

	var/tool_result = ITEM_INTERACT_BLOCKING
	if(operating)
		balloon_alert(user, "still operating!")
		return tool_result

	if(default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		update_appearance(UPDATE_OVERLAYS)
		tool_result = ITEM_INTERACT_SUCCESS
	return tool_result

/obj/machinery/reagentgrinder/crowbar_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return NONE

	var/tool_result = ITEM_INTERACT_BLOCKING
	if(operating)
		balloon_alert(user, "still operating!")
		return tool_result

	if(default_deconstruction_crowbar(tool))
		tool_result = ITEM_INTERACT_SUCCESS
	return tool_result

/obj/machinery/reagentgrinder/proc/on_storage_dump(datum/source, datum/storage/storage, mob/user)
	SIGNAL_HANDLER

	var/list/obj/item/contents_to_dump = list()
	for(var/obj/item/to_dump in storage.real_location)
		if(to_dump.atom_storage) //No recursive handling of contents please
			continue
		contents_to_dump += to_dump

	to_chat(user, span_notice("You dumped [load_items(user, contents_to_dump)] items from [storage.parent] into [src]."))

	return STORAGE_DUMP_HANDLED

/obj/machinery/reagentgrinder/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(operating || !can_interact(user) || !user.can_perform_action(src, ALLOW_SILICON_REACH | FORBID_TELEKINESIS_REACH))
		return
	replace_beaker(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/reagentgrinder/attack_robot_secondary(mob/user, list/modifiers)
	return attack_hand_secondary(user, modifiers)

/obj/machinery/reagentgrinder/attack_ai_secondary(mob/user, list/modifiers)
	return attack_hand_secondary(user, modifiers)

/obj/machinery/reagentgrinder/ui_interact(mob/user)
	. = ..()

	//some interaction sanity checks
	if(!anchored || operating || !can_interact(user) || !user.can_perform_action(src, ALLOW_SILICON_REACH | FORBID_TELEKINESIS_REACH))
		return
	var/static/radial_eject = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_eject")
	var/static/radial_mix = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_mix")

	//create list of options available
	var/list/options = list()
	//actions to be performed on the items stored inside
	for(var/obj/item/to_process in src)
		if((to_process in component_parts) || to_process == beaker)
			continue

		if(!QDELETED(beaker) && !beaker.reagents.holder_full() && is_operational && anchored)
			var/static/radial_grind = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_grind")
			options["grind"] = radial_grind

			var/static/radial_juice = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_juice")
			options["juice"] = radial_juice

		options["eject"] = radial_eject
		break
	//eject action if we have a beaker
	if(!QDELETED(beaker))
		options["eject"] = radial_eject
		//mix reagents present inside
		if(beaker?.reagents.total_volume && is_operational && anchored)
			options["mix"] = radial_mix
	//examine action if Ai is trying to see whats up
	if(HAS_AI_ACCESS(user))
		if(machine_stat & NOPOWER)
			return
		var/static/radial_examine = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_examine")
		options["examine"] = radial_examine

	//display choices & perform action
	var/choice = show_radial_menu(
		user,
		src,
		options,
		custom_check = CALLBACK(src, PROC_REF(check_interactable), user),
		require_near = !HAS_SILICON_ACCESS(user),
	)
	if(!choice)
		return
	switch(choice)
		if("eject")
			replace_beaker(user)
			dump_inventory_contents()
		if("grind", "juice")
			operate_for(60 DECISECONDS, choice == "juice", user)
		if("mix")
			mix(50 DECISECONDS, user)
		if("examine")
			to_chat(user, examine_block("<span class='infoplain'>[examine(user)]</span>"))

/**
 * Checks if the radial menu can interact with this machine
 * Arguments
 *
 * * mob/user - the player interacting with this machine
 */
/obj/machinery/reagentgrinder/proc/check_interactable(mob/user)
	PRIVATE_PROC(TRUE)

	if(!can_interact(user))
		return FALSE

	if(!anchored || operating || !user.can_perform_action(src, ALLOW_SILICON_REACH))
		return FALSE

	return TRUE

/**
 * Grinds/Juices all contents inside the grinder
 * Arguments
 *
 * * time - the duration in deciseconds to perform the operation
 * * juicing - FALSE to grind, TRUE to juice
 * * mob/user - the player who initiated this process
 */
/obj/machinery/reagentgrinder/proc/operate_for(time, juicing = FALSE, mob/user)
	PRIVATE_PROC(TRUE)

	var/duration = time / speed

	Shake(duration = duration)
	operating = TRUE
	if(!juicing)
		playsound(src, 'sound/machines/blender.ogg', 50, TRUE)
	else
		playsound(src, 'sound/machines/juicer.ogg', 20, TRUE)

	var/total_weight
	for(var/obj/item/weapon in src)
		if((weapon in component_parts) || weapon == beaker)
			continue
		if(beaker.reagents.holder_full())
			break

		//recursively process everything inside this atom
		var/item_processed = FALSE
		var/item_weight = weapon.w_class
		for(var/obj/item/ingredient as anything in weapon.get_all_contents_type(/obj/item))
			if(beaker.reagents.holder_full())
				break

			if(juicing)
				if(!ingredient.juice(beaker.reagents, user))
					to_chat(user, span_danger("[src] shorts out as it tries to juice up [ingredient], and transfers it back to storage."))
					continue
				item_processed = TRUE
			else if(length(ingredient.grind_results) || ingredient.reagents?.total_volume)
				if(!ingredient.grind(beaker.reagents, user))
					if(isstack(ingredient))
						to_chat(user, span_notice("[src] attempts to grind as many pieces of [ingredient] as possible."))
					else
						to_chat(user, span_danger("[src] shorts out as it tries to grind up [ingredient], and transfers it back to storage."))
					continue
				item_processed = TRUE

		//happens only for stacks where some of the sheets were grinded so we roughly compute the weight grinded
		if(item_weight != weapon.w_class)
			total_weight += item_weight - weapon.w_class
		else
			total_weight += item_weight

		//delete only if operation was successfull for atleast 1 item(also delete atoms for whom only some of its contents were processed as they are non functional now)
		if(item_processed)
			qdel(weapon)

	//use power according to the total weight of items grinded
	use_energy((active_power_usage * (duration / 1 SECONDS)) * (total_weight / maximum_weight))

	addtimer(CALLBACK(src, PROC_REF(stop_operating)), duration)

///Reset the operating status of the machine
/obj/machinery/reagentgrinder/proc/stop_operating()
	PRIVATE_PROC(TRUE)

	operating = FALSE

/**
 * Mixes the reagents inside the beaker
 * Arguments
 *
 * * time - the length of time in deciseconds to operate
 * * mob/user - the player who started the mixing process
 */
/obj/machinery/reagentgrinder/proc/mix(time, mob/user)
	PRIVATE_PROC(TRUE)

	var/duration = time / speed

	Shake(duration = duration)
	operating = TRUE
	playsound(src, 'sound/machines/juicer.ogg', 20, TRUE)

	addtimer(CALLBACK(src, PROC_REF(mix_complete), duration), duration)

/**
 * Mix the reagents
 * Arguments
 *
 * * duration - the time spent in mixing
 */
/obj/machinery/reagentgrinder/proc/mix_complete(duration)
	PRIVATE_PROC(TRUE)

	if(QDELETED(beaker) || beaker.reagents.total_volume <= 0)
		operating = FALSE
		return

	//Recipe to make Butter
	var/butter_amt = FLOOR(beaker.reagents.get_reagent_amount(/datum/reagent/consumable/milk) / MILK_TO_BUTTER_COEFF, 1)
	var/purity = beaker.reagents.get_reagent_purity(/datum/reagent/consumable/milk)
	beaker.reagents.remove_reagent(/datum/reagent/consumable/milk, MILK_TO_BUTTER_COEFF * butter_amt)
	for(var/i in 1 to butter_amt)
		var/obj/item/food/butter/tasty_butter = new(drop_location())
		tasty_butter.reagents.set_all_reagents_purity(purity)

	//Recipe to make Mayonnaise
	if (beaker.reagents.has_reagent(/datum/reagent/consumable/eggyolk))
		beaker.reagents.convert_reagent(/datum/reagent/consumable/eggyolk, /datum/reagent/consumable/mayonnaise)

	//Recipe to make whipped cream
	if (beaker.reagents.has_reagent(/datum/reagent/consumable/cream))
		beaker.reagents.convert_reagent(/datum/reagent/consumable/cream, /datum/reagent/consumable/whipped_cream)

	//power consumed based on the ratio of total reagents mixed
	use_energy((active_power_usage * (duration / 1 SECONDS)) * (beaker.reagents.total_volume / beaker.reagents.maximum_volume))
	operating = FALSE
