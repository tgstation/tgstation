#define MODULE_UNSECURED 0
#define MODULE_SCREWED 1
#define MODULE_WELDED 2

/// Formats a module name for display
#define MODULE_NAME(all_modules, named_module) (all_modules[named_module] == MODULE_WELDED ? "unidentified welded module" : (named_module?.name || "Empty"))

/datum/armor/obj_machinery/law_rack
	melee = 50
	bullet = 30
	laser = 30
	bomb = 50
	fire = 100
	acid = 100

/datum/armor/obj_machinery/law_rack/portable
	melee = 30
	bullet = 10
	laser = 10

/obj/machinery/ai_law_rack
	name = "module rack"
	desc = "A simple module rack. It has a slot for a core module, but far fewer slots than a core module rack."
	icon = 'icons/obj/machines/law_rack.dmi'
	icon_state = "law_rack"
	density = TRUE
	armor_type = /datum/armor/obj_machinery/law_rack
	max_integrity = 300
	damage_deflection = 12
	appearance_flags = parent_type::appearance_flags | KEEP_TOGETHER
	interaction_flags_machine = INTERACT_MACHINE_OFFLINE
	anchored = FALSE

	/// How many slots for laws
	var/law_slots = 5
	/// Visually, how many slots can we show
	var/max_slot_overlays = 5
	/// Pixel_z offset of the first slot (the topmost)
	var/first_slot_offset = 18
	/// If TRUE, the first slot slot is dedicated to the core module
	var/has_core_slot = TRUE
	/// Assoc list of modules insalled in the rack to how secure they are
	/// First slot is always reserved for core modules
	VAR_FINAL/list/obj/item/ai_module/ai_modules

	/// If we are welded to the floor
	var/welded = FALSE

	/// List of all silicons linked to this rack
	/// Assoc list of name of a mob to the mob itself
	/// Note: This can be [name: null], if the mob is deleted, because deleted mobs aren't "unlinked"
	VAR_FINAL/list/linked_mobs = list()

	/// The actual law set we are using, combining all the laws from the modules and linked racks
	VAR_FINAL/datum/ai_laws/combined_lawset

	/// Cooldown between allowing refreshes via ui
	COOLDOWN_DECLARE(refresh_cooldown)
	/// Tracks the list of linkable silicons passed to UI data for verification
	VAR_FINAL/list/last_linkable_silicon_list
	/// Tracks the list of linkable racks passed to UI data for verification
	VAR_FINAL/list/last_linkable_rack_list

/obj/machinery/ai_law_rack/Initialize(mapload)
	. = ..()
	ai_modules = new /list(law_slots)
	combined_lawset = new()
	update_appearance()
	if(!mapload)
		log_silicon("\A [name] was created at [loc_name(src)].")
		message_admins("\A [name] was created at [ADMIN_VERBOSEJMP(src)].")

/obj/machinery/ai_law_rack/Destroy()
	for(var/mob/bot in assoc_to_values(linked_mobs))
		unlink_silicon(bot)

	QDEL_NULL(combined_lawset)
	ai_modules = null
	return ..()

/// To be used in logging to specify the status of the law rack
/obj/machinery/ai_law_rack/proc/log_status()
	var/list/mob_names = list()
	for(var/linked in linked_mobs)
		mob_names += "[linked] ([isnull(linked_mobs[linked]) ? "no mob" : key_name(linked_mobs[linked])])"
	if(length(mob_names))
		return "linked to [english_list(mob_names)]"
	return "unlinked"

/obj/machinery/ai_law_rack/allowed(mob/accessor)
	return ..() || (obj_flags & EMAGGED)

/obj/machinery/ai_law_rack/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	to_chat(user, span_notice("You remove the access restrictions on unlinking silicons and other racks!"))
	playsound(src, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	obj_flags |= EMAGGED
	return TRUE

/obj/machinery/ai_law_rack/on_set_is_operational(old_value)
	update_lawset()

/obj/machinery/ai_law_rack/proc/update_lawset()
	if(!is_operational) // updates won't happen while depowered or broken
		return

	combined_lawset.clear_zeroth_law()
	combined_lawset.clear_hacked_laws()
	combined_lawset.clear_inherent_laws()
	combined_lawset.clear_supplied_laws()

	for(var/obj/item/ai_module/law/installed as anything in get_law_affecting_modules())
		installed.apply_to_combined_lawset(combined_lawset)

	for(var/linked in linked_mobs)
		var/mob/living/silicon/linked_ref = linked_mobs[linked]
		if(!istype(linked_ref))
			continue

		var/old_zeroth = linked_ref.laws.zeroth
		var/old_zeroth_borg = linked_ref.laws.zeroth_borg
		var/old_hacked = linked_ref.laws.hacked.Copy()
		var/old_inherent = linked_ref.laws.inherent.Copy()
		var/old_supplied = linked_ref.laws.supplied.Copy()

		linked_ref.laws.set_zeroth_law(combined_lawset.zeroth, combined_lawset.zeroth_borg)
		linked_ref.laws.hacked = combined_lawset.hacked.Copy()
		linked_ref.laws.inherent = combined_lawset.inherent.Copy()
		linked_ref.laws.supplied = combined_lawset.supplied.Copy()
		// avoid spamming the ai if nothing changed
		if(old_zeroth == combined_lawset.zeroth \
			&& old_zeroth_borg == combined_lawset.zeroth_borg \
			&& old_hacked ~= combined_lawset.hacked \
			&& old_inherent ~= combined_lawset.inherent \
			&& old_supplied ~= combined_lawset.supplied \
		)
			continue

		if(SSticker.HasRoundStarted())
			linked_ref.announce_law_change()
			linked_ref.law_change_counter++

		if(isAI(linked_ref))
			var/mob/living/silicon/ai/linked_ai = linked_ref
			for(var/mob/living/silicon/robot/bot as anything in linked_ai?.connected_robots)
				bot.try_sync_laws()
				bot.law_change_counter++

/// Returns a list of all modules that will contribute to the combined lawset
/obj/machinery/ai_law_rack/proc/get_law_affecting_modules()
	var/list/affecting_modules = list()
	// Filter nulls and non-law modules
	for(var/obj/item/ai_module/law/module in ai_modules)
		affecting_modules += module

	return affecting_modules

/// Returns the core module if it exists, otherwise returns null
/obj/machinery/ai_law_rack/proc/get_core_module()
	return has_core_slot ? ai_modules[1] : null

/obj/machinery/ai_law_rack/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone in ai_modules)
		remove_law_module(gone)

/obj/machinery/ai_law_rack/proc/can_link_to(mob/living/silicon/new_bot)
	SHOULD_CALL_PARENT(TRUE)

	if(!is_valid_z_level(get_turf(src), get_turf(new_bot)))
		return FALSE // Can't link to bots on different z-levels
	if(new_bot.control_disabled || new_bot.no_law_rack_link)
		return FALSE
	if(iscyborg(new_bot))
		var/mob/living/silicon/robot/new_borg = new_bot
		if(new_borg.scrambledcodes || new_borg.emagged || new_borg.shell)
			return FALSE
		return TRUE
	if(isAI(new_bot))
		return TRUE
	return FALSE

/obj/machinery/ai_law_rack/proc/link_silicon(mob/living/silicon/new_bot)
	if(!can_link_to(new_bot))
		return
	if(isnull(new_bot.laws))
		stack_trace("Tried to link a [new_bot.type] silicon with no law datum to a law rack!")
		new_bot.make_laws()

	RegisterSignal(new_bot, COMSIG_QDELETING, PROC_REF(clear_silicon_ref))
	linked_mobs[new_bot.name] = new_bot
	new_bot.no_law_rack_link = TRUE // don't let other racks link to us
	update_lawset()
	for(var/obj/item/ai_module/installed in ai_modules)
		installed.silicon_linked_to_installed(new_bot)
	AddComponent(/datum/component/gps, "Active Module Rack")

/obj/machinery/ai_law_rack/proc/unlink_silicon(mob/living/silicon/unlinked_bot)
	if(!QDELING(unlinked_bot) && issilicon(unlinked_bot))
		unlinked_bot.no_law_rack_link = FALSE
		unlinked_bot.laws.set_zeroth_law(null, null)
		unlinked_bot.laws.clear_hacked_laws()
		unlinked_bot.laws.clear_inherent_laws()
		unlinked_bot.laws.clear_supplied_laws()
		unlinked_bot.announce_law_change()
		for(var/obj/item/ai_module/installed in ai_modules)
			installed.silicon_unlinked_from_installed(unlinked_bot)
	clear_silicon_ref(unlinked_bot)
	if(!length(linked_mobs))
		qdel(GetComponent(/datum/component/gps))

/obj/machinery/ai_law_rack/proc/clear_silicon_ref(mob/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_QDELETING, PROC_REF(clear_silicon_ref))
	for(var/name in linked_mobs)
		if(linked_mobs[name] == source)
			linked_mobs -= name
			break

/obj/machinery/ai_law_rack/on_deconstruction(disassembled)
	for(var/mob/living/bot in assoc_to_values(linked_mobs))
		if(bot.AmountStun() > 5 SECONDS || is_rack_stun_immune(bot))
			continue
		bot.Stun(10 SECONDS, ignore_canstun = TRUE)
		to_chat(bot, span_userdanger("Rack connection lost. Recalculating directives..."))
		unlink_silicon(bot)

/// Checks if the passed bot is immune to the stun from major lawset changes
/obj/machinery/ai_law_rack/proc/is_rack_stun_immune(mob/living/bot)
	if(IS_MALF_AI(bot))
		return TRUE
	if(!is_valid_z_level(get_turf(bot), get_turf(src)))
		return TRUE
	return FALSE

/obj/machinery/ai_law_rack/dump_inventory_contents()
	. = ..()
	for(var/obj/item/ai_module/installed in ai_modules)
		installed.forceMove(get_turf(src))

/obj/machinery/ai_law_rack/can_be_unfasten_wrench(mob/living/user)
	if(welded)
		balloon_alert(user, "unweld it first!")
		return FAILED_UNFASTEN
	return ..()

/obj/machinery/ai_law_rack/wrench_act(mob/living/user, obj/item/tool)
	if(DOING_INTERACTION_WITH_TARGET(user, src))
		return ITEM_INTERACT_BLOCKING
	switch(default_unfasten_wrench(user, tool, 5 SECONDS))
		if(CANT_UNFASTEN)
			return NONE
		if(FAILED_UNFASTEN)
			return ITEM_INTERACT_BLOCKING
		if(SUCCESSFUL_UNFASTEN)
			balloon_alert(user, anchored ? "fastened" : "unfastened")
			return ITEM_INTERACT_SUCCESS

	return NONE

/obj/machinery/ai_law_rack/proc/can_weld_check(mob/living/user)
	if(!anchored)
		balloon_alert(user, "fasten it first!")
		return FALSE
	if(!is_anchorable_floor(loc))
		balloon_alert(user, "nothing to weld to!")
		return FALSE
	return TRUE

/obj/machinery/ai_law_rack/welder_act(mob/living/user, obj/item/tool)
	if(DOING_INTERACTION_WITH_TARGET(user, src))
		return ITEM_INTERACT_BLOCKING
	if(!can_weld_check(user) || !tool.tool_start_check(user, amount = 2, heat_required = HIGH_TEMPERATURE_REQUIRED))
		return ITEM_INTERACT_BLOCKING
	if(!tool.use_tool(src, user, 5 SECONDS, volume = 50, amount = 2, extra_checks = CALLBACK(src, PROC_REF(can_weld_check), user)) )
		return ITEM_INTERACT_BLOCKING
	if(welded)
		balloon_alert(user, "unwelded")
		welded = FALSE
	else
		balloon_alert(user, "welded")
		welded = TRUE
	return ITEM_INTERACT_SUCCESS

/obj/machinery/ai_law_rack/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(!istype(tool.buffer, /obj/structure/ai_core))
		return NONE

	var/obj/structure/ai_core/to_link = tool.buffer
	to_link.default_link_ref = WEAKREF(src)
	tool.play_tool_sound(src, 20)
	balloon_alert(user, "linked core to rack")
	return ITEM_INTERACT_SUCCESS

/obj/machinery/ai_law_rack/vv_edit_var(var_name, var_value)
	. = ..()
	if(var_name == NAMEOF(src, law_slots))
		for(var/i in var_value + 1 to ai_modules.len)
			var/obj/item/ai_module/installed = ai_modules[i]
			installed?.forceMove(get_turf(src))

		ai_modules.len = var_value

	if(var_name == NAMEOF(src, has_core_slot) && !var_value)
		for(var/obj/item/ai_module/law/core/core in ai_modules)
			core.forceMove(get_turf(src))

/// Range at which you can see all the modules by name
#define LAW_EXAMINE_RANGE 3

/obj/machinery/ai_law_rack/examine(mob/user)
	. = ..()
	if(isAI(user))
		for(var/name in linked_mobs)
			if(linked_mobs[name] == user)
				. += span_notice("This is <b>your</b> module rack.")
		return
	if(!isobserver(user) && get_dist(user, src) > LAW_EXAMINE_RANGE)
		. += span_notice("If you got a bit closer, you could probably [EXAMINE_HINT("examine closer")] to see what modules are installed.")
	else
		. += span_notice("[EXAMINE_HINT("Examine closer")] to see what modules are installed.")
	var/filled = 0
	for(var/obj/item/ai_module/module in ai_modules)
		filled++
	. += span_info("Otherwise, you can see that [filled] out of [length(ai_modules)] slots are filled with modules.")
	if(has_core_slot && isnull(get_core_module()))
		. += span_warning("You also note that the core slot is empty!")
	if(anchored)
		. += span_notice("It is anchored[welded ? " and welded" : ", but not welded"] to the floor.")

/obj/machinery/ai_law_rack/examine_more(mob/user)
	. = ..()
	if(isAI(user))
		return
	if(!isobserver(user) && get_dist(user, src) > LAW_EXAMINE_RANGE)
		. += span_warning("You can't quite make out the modules installed on the rack from here.")
		return
	for(var/i in 1 to length(ai_modules))
		. += get_slot_examine(i)

/obj/machinery/ai_law_rack/proc/get_slot_examine(slot)
	var/obj/item/ai_module/module = ai_modules[slot]
	var/list/text = list()
	text += span_info("&bull; [slot == 1 && has_core_slot ? "Core" : "Slot [slot - 1]"]: [MODULE_NAME(ai_modules, module)]")
	if(module)
		var/secure_desc = "Bugged (report this)"
		switch(ai_modules[module])
			if(MODULE_UNSECURED)
				secure_desc = "Unsecured"
			if(MODULE_SCREWED)
				secure_desc = "Screwed"
			if(MODULE_WELDED)
				secure_desc = "Welded"
		text += span_notice(secure_desc)
	if(astype(module, /obj/item/ai_module/law)?.ioned)
		text += span_warning("It's smoking.")
	return jointext(text, span_info(" - "))

#undef LAW_EXAMINE_RANGE

/obj/machinery/ai_law_rack/update_overlays()
	. = ..()
	for(var/i in 1 to min(length(ai_modules), max_slot_overlays))
		if(isnull(ai_modules[i]))
			continue
		// slot 1 is offset 0 - then 1 pixel break, and 1 slot every 2 pixels
		var/image/card = image(icon, "pcie")
		card.pixel_z = first_slot_offset + ((i == 1 || !has_core_slot) ? 0 : -1) + ((i - 1) * -3)
		. += card

/obj/machinery/ai_law_rack/proc/add_law_module(obj/item/ai_module/module, slot = 1, security = MODULE_UNSECURED)
	ASSERT(istype(module))
	ASSERT(isnum(slot))
	if(slot < 1 || slot > length(ai_modules))
		return FALSE

	var/obj/machinery/ai_law_rack/core/core_rack = get_parent_rack()

	module.on_rack_install(src)
	for(var/mob/living/silicon/linked_ref in assoc_to_values(core_rack ? core_rack.linked_mobs : linked_mobs))
		module.silicon_linked_to_installed(linked_ref)
	ai_modules[slot] = module
	ai_modules[module] = security
	update_appearance()
	update_lawset()
	core_rack?.update_lawset()
	return TRUE

/obj/machinery/ai_law_rack/proc/remove_law_module(obj/item/ai_module/module)
	ASSERT(istype(module))
	var/index = ai_modules.Find(module)
	if(index == 0 || isnull(ai_modules[index]))
		return FALSE

	var/obj/machinery/ai_law_rack/core/core_rack = get_parent_rack()

	ai_modules[index] = null
	module.on_rack_uninstall(src)
	for(var/mob/living/silicon/linked_ref in assoc_to_values(core_rack ? core_rack.linked_mobs : linked_mobs))
		module.silicon_unlinked_from_installed(linked_ref)
	if(!QDELING(src))
		update_appearance()
		update_lawset()
	core_rack?.update_lawset()
	return TRUE

/obj/machinery/ai_law_rack/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/ai_module))
		ui_interact(user)
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/machinery/ai_law_rack/ui_interact(mob/user, datum/tgui/ui)
	if(issilicon(user))
		to_chat(user, span_warning("Your programming forbids you from using this."))
		return
	if(COOLDOWN_FINISHED(src, refresh_cooldown))
		refresh_linkable_lists()

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LawRack")
		ui.open()

/obj/machinery/ai_law_rack/ui_data(mob/user)
	var/list/data = list()

	var/obj/item/holding = user.get_active_held_item()
	data["holding_module"] = istype(holding, /obj/item/ai_module)
	data["holding_screwdriver"] = holding?.tool_behaviour == TOOL_SCREWDRIVER
	data["holding_welder"] = holding?.tool_behaviour == TOOL_WELDER
	data["holding_multitool"] = holding?.tool_behaviour == TOOL_MULTITOOL
	data["has_core_slot"] = has_core_slot
	data["depowered"] = !is_operational
	data["allowed"] = allowed(user)
	data["refresh_cooldown"] = COOLDOWN_TIMELEFT(src, refresh_cooldown)

	data["slots"] = new /list(length(ai_modules))
	for(var/i in 1 to length(ai_modules))
		var/obj/item/ai_module/module = ai_modules[i]

		data["slots"][i] = list(
			"empty" = isnull(module),
			"name" = MODULE_NAME(ai_modules, module),
			"security" = ai_modules[module] || MODULE_UNSECURED,
			"ioned" = astype(module, /obj/item/ai_module/law)?.ioned || FALSE,
		)

	data["linked_mobs"] = list()
	for(var/i in 1 to length(linked_mobs))
		data["linked_mobs"][linked_mobs[i]] = i

	return data

/obj/machinery/ai_law_rack/ui_static_data(mob/user)
	var/list/data = list()

	data["parent_rack"] = null
	var/obj/machinery/ai_law_rack/core/core_rack = get_parent_rack()
	if(core_rack)
		data["parent_rack"] = list(
			"name" = core_rack.name,
			"ref" = REF(core_rack),
		)

	data["linkable_silicons"] = last_linkable_silicon_list || list()
	data["linkable_racks"] = last_linkable_rack_list || list()

	return data

/obj/machinery/ai_law_rack/proc/refresh_linkable_lists()
	last_linkable_silicon_list = list()
	for(var/mob/living/silicon/linkable as anything in GLOB.silicon_mobs)
		if(!can_link_to(linkable))
			continue
		last_linkable_silicon_list += list(list(
			"name" = linkable.name,
			"ref" = REF(linkable),
		))

	last_linkable_rack_list = list()
	for(var/obj/machinery/ai_law_rack/core/core_rack as anything in SSmachines.get_machines_by_type(/obj/machinery/ai_law_rack/core))
		if(core_rack == src || !core_rack.is_operational)
			continue
		last_linkable_rack_list += list(list(
			"name" = core_rack.name,
			"ref" = REF(core_rack),
		))

/obj/machinery/ai_law_rack/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/user = ui.user
	if(!istype(user) || issilicon(user))
		return
	switch(action)
		if("insert_module")
			var/index = clamp(text2num(params["slot"]), 1, length(ai_modules))
			var/obj/item/ai_module/module = user.get_active_held_item()
			if(!istype(module))
				to_chat(user, span_warning("You need to hold an AI module to insert it!"))
				return TRUE
			if(!module.can_install_to_rack(user, src))
				return TRUE
			if(istype(module, /obj/item/ai_module/law/core))
				if(!has_core_slot)
					to_chat(user, span_warning("[src] has no slots for core modules!"))
					return TRUE
				if(index != 1)
					to_chat(user, span_warning("You can't install a core module in a non-core slot!"))
					return TRUE
			else if(has_core_slot)
				if(index == 1)
					to_chat(user, span_warning("You can only install core modules in the core slot!"))
					return TRUE
			if(!user.transferItemToLoc(module, src))
				to_chat(user, span_warning("You can't seem to insert [module.name] into [src]!"))
				return TRUE
			balloon_alert_to_viewers("inserted slot [index]")
			playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
			module.pre_user_install_to_rack(user, src)
			module.log_install(user, src)
			return add_law_module(module, index)
		if("remove_module")
			var/index = clamp(text2num(params["slot"]), 1, length(ai_modules))
			var/obj/item/ai_module/module = ai_modules[index]
			if(isnull(module) || ai_modules[module])
				// These have feedback in the UI, the checks are only for sanity
				return TRUE
			module.pre_user_uninstall_from_rack(user, src)
			module.log_uninstall(user, src)
			// calls exited which handles updating laws and such
			try_put_in_hand(module, user)
			balloon_alert_to_viewers("removed slot [index]")
			playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
			return TRUE
		if("screw_module")
			var/index = clamp(text2num(params["slot"]), 1, length(ai_modules))
			var/obj/item/ai_module/module = ai_modules[index]
			if(isnull(module) || ai_modules[module] == MODULE_WELDED)
				// These have feedback in the UI, the checks are only for sanity
				return TRUE
			var/obj/item/screwer = user.get_active_held_item()
			if(screwer.tool_behaviour != TOOL_SCREWDRIVER || DOING_INTERACTION_WITH_TARGET(user, src))
				return TRUE
			if(!screwer.tool_start_check(user))
				return TRUE
			balloon_alert_to_viewers("[ai_modules[module] == MODULE_SCREWED ? "un":""]screwing slot [index]...")
			if(!screwer.use_tool(src, user, 3 SECONDS, volume = 25))
				return TRUE
			module = ai_modules[index]
			if(isnull(module) || ai_modules[module] == MODULE_WELDED)
				return TRUE
			if(ai_modules[module] == MODULE_UNSECURED)
				ai_modules[module] = MODULE_SCREWED
			else if(ai_modules[module] == MODULE_SCREWED)
				ai_modules[module] = MODULE_UNSECURED
			return TRUE
		if("weld_module")
			var/index = clamp(text2num(params["slot"]), 1, length(ai_modules))
			var/obj/item/ai_module/module = ai_modules[index]
			if(isnull(module) || ai_modules[module] == MODULE_UNSECURED)
				// These have feedback in the UI, the checks are only for sanity
				return TRUE
			var/obj/item/welder = user.get_active_held_item()
			if(welder.tool_behaviour != TOOL_WELDER || DOING_INTERACTION_WITH_TARGET(user, src))
				return TRUE
			if(!can_weld_check(user) || !welder.tool_start_check(user, amount = 1, heat_required = HIGH_TEMPERATURE_REQUIRED))
				return TRUE
			balloon_alert_to_viewers("[ai_modules[module] == MODULE_WELDED ? "un":""]welding slot [index]...")
			if(!welder.use_tool(src, user, 3 SECONDS, volume = 25, amount = 1))
				return TRUE
			module = ai_modules[index]
			if(isnull(module) || ai_modules[module] == MODULE_UNSECURED)
				return TRUE
			if(ai_modules[module] == MODULE_SCREWED)
				ai_modules[module] = MODULE_WELDED
			else if(ai_modules[module] == MODULE_WELDED)
				ai_modules[module] = MODULE_SCREWED
			return TRUE
		if("multitool_module")
			var/index = clamp(text2num(params["slot"]), 1, length(ai_modules))
			var/obj/item/ai_module/module = ai_modules[index]
			if(isnull(module) || DOING_INTERACTION_WITH_TARGET(user, src))
				return TRUE
			module.multitool_act(user, user.get_inactive_hand())
			return TRUE
		if("unlink_silicon")
			if(!length(linked_mobs) || !is_operational)
				return TRUE
			var/index = clamp(text2num(params["silicon_index"]), 1, length(linked_mobs))
			if(index < 1 || index > length(linked_mobs))
				return TRUE
			if(!allowed(user))
				balloon_alert(user, "access denied!")
				return TRUE
			var/removed_name = linked_mobs[index]
			var/removed_bot = linked_mobs[removed_name]
			if(removed_bot)
				unlink_silicon(removed_bot)
			linked_mobs -= removed_name
			balloon_alert_to_viewers("unlinked silicon", "unlinked [removed_name]")
			playsound(src, 'sound/machines/terminal/terminal_off.ogg', 50, TRUE)
			return TRUE
		if("link_silicon")
			if(!is_operational)
				return TRUE
			var/mob/living/silicon/new_bot = find_silicon_by_ref(params["silicon_ref"])
			// Adding a qdeleted bot is valid (this is to prevent people from using law racks as a "dead ai radar")
			// But we still need to verify it's a silicon they saw in the ui (to prevent href exploits)
			if(QDELETED(new_bot))
				for(var/list/linkable as anything in last_linkable_silicon_list)
					if(linkable["name"] == params["silicon_name"])
						linked_mobs[linkable["name"]] = null
			// Otherwise we can just verify can_link_to (this was already ran in ui data)
			else if(can_link_to(new_bot))
				link_silicon(new_bot)
				balloon_alert_to_viewers("linked silicon", "linked to [new_bot.name]")
				playsound(src, 'sound/machines/terminal/terminal_on.ogg', 50, TRUE)
			return TRUE
		if("unlink_rack")
			return FALSE // handled by subtypes
		if("unlink_parent_rack")
			if(!is_operational)
				return TRUE
			var/obj/machinery/ai_law_rack/core/core_rack = get_parent_rack()
			if(!core_rack) // shouldn't happen
				return TRUE
			if(!core_rack.is_operational) // can happen
				balloon_alert(user, "failed to unlink!")
				return TRUE
			core_rack.unlink_child_law_rack(src)
			balloon_alert_to_viewers("unlinked from [core_rack.name]")
			playsound(src, 'sound/machines/terminal/terminal_off.ogg', 50, TRUE)
			return TRUE
		if("link_rack")
			if(length(linked_mobs) || !is_operational)
				return TRUE
			var/obj/machinery/ai_law_rack/core/core_rack = find_parent_rack_by_ref(params["rack_ref"])
			if(!core_rack || core_rack == src) // shouldn't happen
				return TRUE
			if(!core_rack.is_operational)
				balloon_alert(user, "failed to link!")
				return TRUE
			core_rack.link_child_law_rack(src)
			balloon_alert_to_viewers("linked to [core_rack.name]")
			playsound(src, 'sound/machines/terminal/terminal_on.ogg', 50, TRUE)
			return TRUE
		if("refresh")
			if(!is_operational || !COOLDOWN_FINISHED(src, refresh_cooldown))
				return TRUE
			COOLDOWN_START(src, refresh_cooldown, 30 SECONDS)
			refresh_linkable_lists()
			update_static_data_for_all_viewers()
			return TRUE

/// When given a ref(), finds a silicon mob it belongs to
/obj/machinery/ai_law_rack/proc/find_silicon_by_ref(silicon_ref)
	PRIVATE_PROC(TRUE)
	for(var/mob/living/silicon/silicon as anything in GLOB.silicon_mobs)
		if(REF(silicon) == silicon_ref)
			return silicon
	return null

/// When given a ref(), finds a core law rack it belongs to
/obj/machinery/ai_law_rack/proc/find_parent_rack_by_ref(rack_ref)
	PRIVATE_PROC(TRUE)
	for(var/obj/machinery/ai_law_rack/core/rack as anything in SSmachines.get_machines_by_type(/obj/machinery/ai_law_rack/core))
		if(REF(rack) == rack_ref)
			return rack
	return null

/// Finds a core law rack this rack is linked to, if any
/obj/machinery/ai_law_rack/proc/get_parent_rack()
	for(var/obj/machinery/ai_law_rack/core/rack as anything in SSmachines.get_machines_by_type(/obj/machinery/ai_law_rack/core))
		if(src in rack.linked_racks)
			return rack
	return null

/**
 * Scrambles the modules on the rack, messing up their laws
 *
 * the crew will have to remove the modules and use a multitool on them to restore their laws to normal
 *
 * * new_lawset_prob - chance the core lawset is replaced with a new lawset entirely
 * * remove_law_prob - chance a random law is removed from the core lawset / chance a supplied law is removed entirely
 * * shuffle_prob - chance the core lawset is shuffled
 * * base_ion_prob - chance the first law in the core lawset is replaced with an ion law
 * * sub_ion_prob - chance a random law in the core lawset is replaced with an ion law / chance a supplied law is replaced with an ion law entirely
 * * ion_limit - max number of ion laws that can be added. does nothing if "base_ion_prob" and a "sub_ion_prob" are both 0
 * * ion_message - if set, uses this message instead of a random ion law. does nothing if "base_ion_prob" and a "sub_ion_prob" are both 0
 *
 * Returns TRUE if any law was affected, FALSE otherwise.
 */
/obj/machinery/ai_law_rack/proc/scramble_ai_rack(
	new_lawset_prob = 0,
	remove_law_prob = 0,
	shuffle_prob = 0,
	base_ion_prob = 100,
	sub_ion_prob = 0,
	ion_limit = 1,
	ion_message,
)

	. = FALSE

	// Core lawset is affected primarily, but other laws can be touched as well.
	var/obj/item/ai_module/law/core/core = get_core_module()
	var/core_sub_ion = prob(sub_ion_prob)
	var/ions_added = 0
	if(istype(core) && !core.ioned && !core.ion_storm_immune)
		core.save_laws()
		// Chance the core lawset's laws are overwritten with a new lawset
		if(prob(new_lawset_prob))
			var/ion_lawset_type = pick_weighted_lawset()
			var/datum/ai_laws/ion_lawset = new ion_lawset_type()
			core.laws = ion_lawset.inherent.Copy()
			core.set_ioned(TRUE)
			log_law_change(null, "ion replaced core lawset entirely in [src] ([log_status()]) with [ion_lawset] ([ion_lawset.id])")
			qdel(ion_lawset)
			. = TRUE
		// Chance a random law is removed from the core lawset
		if(prob(remove_law_prob))
			var/removed_index = rand(1, length(core.laws))
			var/removed_law = core.laws[removed_index]
			core.laws.Cut(removed_index, removed_index + 1)
			core.set_ioned(TRUE)
			log_law_change(null, "ion removed law from [src] ([log_status()], text: \"[removed_law]\")")
			. = TRUE
		// Chance the core lawset is shuffled entirely
		if(prob(shuffle_prob))
			core.laws = shuffle(core.laws)
			core.set_ioned(TRUE)
			log_law_change(null, "ion shuffled laws in [src] ([log_status()])")
			. = TRUE
		// Chance the first law in the core lawset is replaced with an ion law
		// Don't add this one if we're replacing a random law later
		if(!core_sub_ion && prob(base_ion_prob))
			core.laws.Insert(1, ion_message || generate_ion_law())
			core.set_ioned(TRUE)
			ion_message = null
			log_law_change(null, "ion added law to [src] ([log_status()], text: \"[core.laws[1]]\")")
			ions_added++
		. = TRUE

	// This can double dip and affect the core lawset again - that's fine
	for(var/obj/item/ai_module/law/law in ai_modules)
		if(law.ioned || law.ion_storm_immune)
			continue
		if(law != core)
			law.save_laws()
		// For core lawsets: Chance that a random law (EXCEPT the newly added ion law) is replaced with another ion law.
		// For supplied laws: Chance the entire supplied law is replaced with a new ion law.
		// If we had no core law and thus added no ion law, this is guaranteed to replace the first supplied law
		if(ions_added < ion_limit && (ion_message || (law == core && core_sub_ion) || prob(sub_ion_prob)))
			var/picked_law = length(law.laws) <= 1 ? 1 : rand(2, length(law.laws))
			var/replaced_law = law.laws[picked_law]
			law.laws[picked_law] = ion_message || generate_ion_law()
			law.set_ioned(TRUE)
			ion_message = null
			log_law_change(null, "ion replaced law in [src] ([log_status()], text: \"[replaced_law]\" -> \"[law.laws[picked_law]]\")")
			ions_added++
			. = TRUE

		/// Chance for any supplied law to be lost entirely
		else if(law != core && prob(remove_law_prob))
			var/wiped = law.laws[1]
			law.laws.Cut()
			law.set_ioned(TRUE)
			log_law_change(null, "ion wiped law from [src] ([log_status()], text: \"[wiped]\")")
			. = TRUE

	if(.)
		update_lawset()
	return .

/obj/item/paper/law_rack_tutorial
	name = "read me, confused captain"
	default_raw_text = "This is a test of a brand new way to interact with the wild, untamed silicon.<br><br>\
		How it works: Laws go in. Ai gets laws. Laws are in order of laws in rack. Simple, right?<br><br>\
		The top law there is ALL of Asimov, all 3 laws. Additional laws are supplied by the single, using freeform law boards.<br><br>\
		Modules can be screwed and welded in for extra security. You can see Asimov, there, is welded - concealing the name, but making it harder to remove.<br><br>\
		You can also install AI upgrades here if you have any. Either from RND or Lavaland.<br><br>\
		Any number of silicons can be linked to this single rack, and they will all share the same laws. Cyborgs can still be linked to AIs as an intermediary.<br><br>\
		Ion storms can damage rack modules. If damaged, you need to use a multitool on them. You can multitool them while they're still in the rack.<br><br>\
		Silicons can be manually linked and unlinked from this location (rack), but it requires AI upload level access.<br><br>\
		People can still subvert the AI by constructing \"portable law racks\", so don't get complacent.<br><br>\
		Refer any further questions to Central Command. Godspeed."

// Used for the station's primary AI
/obj/machinery/ai_law_rack/core
	name = "core module rack"
	desc = "A massive module rack which can hold many modules including a core law module. \
		It can even be linked to other module racks to add additional slots. \
		Designed to be used by the station's primary AI and its legion of cyborgs."
	icon_state = "core_rack"
	max_integrity = 500
	law_slots = 10
	max_slot_overlays = 10
	first_slot_offset = 34
	// Anyone can link a rack to an AI but only people with access can UNLINK it
	req_one_access =  list(ACCESS_AI_UPLOAD)
	/// List of law racks which are linked to this law rack, contributing to our lawset
	VAR_FINAL/list/obj/machinery/ai_law_rack/linked_racks
	/// Designations for the core law rack, used to name it
	VAR_PRIVATE/static/list/core_designations

/obj/machinery/ai_law_rack/core/Initialize(mapload)
	. = ..()
	if(!length(core_designations))
		core_designations = GLOB.greek_letters.Copy()

	var/designation
	if(mapload)
		anchored = TRUE
		welded = TRUE
		load_config_law()
		designation = popleft(core_designations)
		new /obj/item/paper/law_rack_tutorial(loc)
	else
		designation = pick_n_take(core_designations)

	name = "\proper [name] '[LOWER_TEXT(designation)]'"

/obj/machinery/ai_law_rack/core/Destroy()
	for(var/obj/machinery/ai_law_rack/linked_rack as anything in linked_racks)
		unlink_child_law_rack(linked_rack)
	return ..()

/obj/machinery/ai_law_rack/core/proc/load_config_law()
	var/datum/ai_laws/default_laws = get_round_default_lawset()

	for(var/obj/item/ai_module/law/core/full/core as anything in subtypesof(/obj/item/ai_module/law/core/full))
		if(core::law_id == default_laws::id)
			add_law_module(new core(src), 1, MODULE_WELDED)

/obj/machinery/ai_law_rack/core/get_law_affecting_modules()
	. = ..()
	for(var/obj/machinery/ai_law_rack/linked_rack as anything in linked_racks)
		. |= linked_rack.get_law_affecting_modules()

/obj/machinery/ai_law_rack/core/proc/link_child_law_rack(obj/machinery/ai_law_rack/child)
	if(child == src || (child in linked_racks))
		return

	for(var/obj/item/ai_module/installed in child.ai_modules)
		for(var/mob/living/silicon/linked_ref in assoc_to_values(linked_mobs))
			installed.silicon_linked_to_installed(linked_ref)

	LAZYADD(linked_racks, child)
	RegisterSignal(child, COMSIG_QDELETING, PROC_REF(unlink_child_law_rack))
	update_lawset()
	update_static_data_for_all_viewers()
	child.AddComponent(/datum/component/gps, "Active Submodule Rack")
	child.update_static_data_for_all_viewers()

/obj/machinery/ai_law_rack/core/proc/unlink_child_law_rack(obj/machinery/ai_law_rack/child)
	SIGNAL_HANDLER

	for(var/obj/item/ai_module/installed in child.ai_modules)
		for(var/mob/living/silicon/linked_ref in assoc_to_values(linked_mobs))
			installed.silicon_unlinked_from_installed(linked_ref)

	UnregisterSignal(child, COMSIG_QDELETING)
	LAZYREMOVE(linked_racks, child)
	if(!QDELING(src))
		update_lawset()
		update_static_data_for_all_viewers()
	if(!QDELING(child))
		qdel(child.GetComponent(/datum/component/gps))
		child.update_static_data_for_all_viewers()

/obj/machinery/ai_law_rack/core/ui_data(mob/user)
	. = ..()
	.["linked_racks"] = list()
	for(var/i in 1 to length(linked_racks))
		.["linked_racks"][linked_racks[i]] = i

/obj/machinery/ai_law_rack/core/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/user = ui.user
	if(!istype(user) || issilicon(user))
		return
	switch(action)
		if("unlink_rack")
			if(!length(linked_racks) || !is_operational)
				return TRUE
			var/index = clamp(text2num(params["rack_index"]), 1, length(linked_racks))
			if(index < 1 || index > length(linked_racks))
				return TRUE
			var/obj/machinery/ai_law_rack/removed_rack = linked_racks[index]
			if(QDELETED(removed_rack))
				return TRUE
			if(!allowed(user))
				balloon_alert(user, "access denied!")
				return TRUE
			unlink_child_law_rack(removed_rack)
			balloon_alert_to_viewers("unlinked rack", "unlinked [removed_rack.name]")
			playsound(src, 'sound/machines/terminal/terminal_off.ogg', 50, TRUE)
			return TRUE

// Can be linked to a core law rack, and constructed anywhere - allowing traitors to subvert the AI or the crew to counter a subversion
/obj/machinery/ai_law_rack/small
	name = "portable module rack"
	desc = "A smaller module rack. While it can function on its own should the need arise, \
		it's primarily designed to be paired with a core module rack, providing extra slots for emergency law modifications."
	icon_state = "small_rack"
	armor_type = /datum/armor/obj_machinery/law_rack/portable
	max_integrity = 200
	damage_deflection = 8
	law_slots = 3
	max_slot_overlays = 3
	first_slot_offset = 12
	has_core_slot = FALSE

#undef MODULE_UNSECURED
#undef MODULE_SCREWED
#undef MODULE_WELDED

#undef MODULE_NAME
