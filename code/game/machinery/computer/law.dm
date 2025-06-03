#define MODULE_UNSECURED 0
#define MODULE_SCREWED 1
#define MODULE_WELDED 2

/obj/machinery/ai_law_rack
	name = "Law Rack"
	desc = "A rack for storing law modules."
	icon = 'icons/obj/machines/law_rack.dmi'
	icon_state = "law_rack"
	density = TRUE
	appearance_flags = parent_type::appearance_flags | KEEP_TOGETHER
	interaction_flags_machine = parent_type::interaction_flags_machine & ~INTERACT_MACHINE_ALLOW_SILICON
	/// Assoc list of modules insalled in the rack to how secure they are
	/// First slot is always reserved for core modules
	VAR_FINAL/list/obj/item/ai_module/law_modules
	/// How many slots for laws
	var/additional_slots = 9
	/// If we are welded to the floor
	VAR_FINAL/welded = TRUE
	/// The AI or cyborg that is linked to this law rack
	VAR_FINAL/mob/living/silicon/linked_ref
	/// The name of the AI or cyborg linked to this law rack
	/// Tracked separate from linked - AIs remained linked even after deletion
	VAR_FINAL/linked

	var/datum/ai_laws/combined_lawset

/obj/machinery/ai_law_rack/Initialize(mapload)
	. = ..()
	law_modules = new /list(1 + additional_slots)
	combined_lawset = new()
	update_appearance()
	// imprint_gps("Ai Law Rack")
	if(!mapload)
		log_silicon("\A [name] was created at [loc_name(src)].")
		message_admins("\A [name] was created at [ADMIN_VERBOSEJMP(src)].")

/obj/machinery/ai_law_rack/Destroy()
	unlink_silicon()
	QDEL_NULL(combined_lawset)
	law_modules.Cut()
	return ..()

/obj/machinery/ai_law_rack/proc/update_lawset()
	combined_lawset.clear_zeroth_law()
	combined_lawset.clear_hacked_laws()
	combined_lawset.clear_inherent_laws()
	combined_lawset.clear_supplied_laws()

	for(var/obj/item/ai_module/installed in law_modules)
		installed.apply_to_combined_lawset(combined_lawset)

	if(isnull(linked_ref))
		return
	linked_ref.laws.set_zeroth_law(combined_lawset.zeroth_law)
	linked_ref.laws.hacked = combined_lawset.hacked.Copy()
	linked_ref.laws.inherent = combined_lawset.inherent.Copy()
	linked_ref.laws.supplied = combined_lawset.supplied.Copy()
	linked_ref.post_lawchange(TRUE)

/obj/machinery/ai_law_rack/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone in law_modules)
		var/index = law_modules.Find(gone)
		law_modules[index] = null
	if(!QDELING(src))
		update_appearance()
		update_lawset()

/obj/machinery/ai_law_rack/proc/can_link_to(mob/living/silicon/new_bot)
	SHOULD_CALL_PARENT(TRUE)

	if(new_bot.control_disabled)
		return FALSE
	return TRUE

/obj/machinery/ai_law_rack/proc/link_silicon(mob/living/silicon/new_bot)
	if(linked)
		return
	if(!can_link_to(new_bot))
		return

	RegisterSignal(new_bot, COMSIG_QDELETING, PROC_REF(clear_silicon_ref))
	linked_ref = new_bot
	linked = new_bot.name
	update_lawset()

/obj/machinery/ai_law_rack/proc/unlink_silicon()
	if(!linked)
		return

	if(!QDELING(linked_ref))
		linked_ref.laws.clear_hacked_laws()
		linked_ref.laws.clear_inherent_laws()
		linked_ref.laws.clear_supplied_laws()
		linked_ref.post_lawchange(TRUE)
	clear_silicon_ref()
	linked = null

/obj/machinery/ai_law_rack/proc/clear_silicon_ref()
	SIGNAL_HANDLER
	if(!linked_ref)
		return
	UnregisterSignal(linked_ref, COMSIG_QDELETING, PROC_REF(clear_silicon_ref))
	linked_ref = null

/obj/machinery/ai_law_rack/on_deconstruction(disassembled)
	if(linked)
		unlink_silicon()

/obj/machinery/ai_law_rack/dump_inventory_contents()
	. = ..()
	for(var/obj/item/ai_module/installed in law_modules)
		installed.forceMove(get_turf(src))

/obj/machinery/ai_law_rack/can_be_unfasten_wrench(mob/living/user)
	if(welded)
		balloon_alert(user, "unweld it first!")
		return FAILED_UNFASTEN
	return ..()

/obj/machinery/ai_law_rack/wrench_act(mob/living/user, obj/item/tool)
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
	if(welded)
		balloon_alert(user, "already welded!")
		return FALSE
	if(!is_anchorable_floor(loc))
		balloon_alert(user, "nothing to weld to!")
		return FALSE
	return TRUE

/obj/machinery/ai_law_rack/welder_act(mob/living/user, obj/item/tool)
	if(!can_weld_check(user))
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

/obj/machinery/ai_law_rack/multitool_act(mob/living/user, obj/item/tool)
	var/obj/item/multitool/multitool = tool
	if(!istype(multitool) || !issilicon(multitool.buffer))
		return NONE
	if(!can_link_to(multitool.buffer))
		balloon_alert(user, "can't link [multitool.buffer] to this law rack!")
		return ITEM_INTERACT_BLOCKING
	if(linked)
		balloon_alert(user, "already linked to [linked]!")
		return ITEM_INTERACT_BLOCKING
	link_silicon(multitool.buffer)
	balloon_alert(user, "linked to [linked]")
	return ITEM_INTERACT_SUCCESS

/obj/machinery/ai_law_rack/vv_edit_var(var_name, var_value)
	. = ..()
	if(var_name == NAMEOF(src, additional_slots))
		for(var/i in var_value + 1 to law_modules.len)
			var/obj/item/ai_module/installed = law_modules[i]
			installed?.forceMove(get_turf(src))

		law_modules.len = 1 + var_value

/// Range at which you can see all the modules by name
#define LAW_EXAMINE_RANGE 3

/obj/machinery/ai_law_rack/examine(mob/user)
	. = ..()
	if(isAI(user))
		if(linked_ref == user)
			. += span_notice("This is your law rack.")
		return
	if(!isobserver(user) && get_dist(user, src) > LAW_EXAMINE_RANGE)
		. += span_notice("If you got a bit closer, you could probably [EXAMINE_HINT("examine closer")] to see what law modules are installed.")
	else
		. += span_notice("[EXAMINE_HINT("Examine closer")] to see what law modules are installed.")
	var/filled = 0
	for(var/obj/item/ai_module/module in law_modules)
		filled++
	. += span_info("Otherwise, you can see that [filled] out of [length(law_modules)] slots are filled with law modules.")
	if(isnull(law_modules[1]))
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
	for(var/i in 1 to length(law_modules))
		. += get_slot_examine(i)

/obj/machinery/ai_law_rack/proc/get_slot_examine(slot)
	var/obj/item/ai_module/module = law_modules[slot]
	var/list/text = list()
	text += span_info("&bull; [slot == 1 ? "  Core" : "Slot [slot - 1]"]: [module?.name || "Empty"]")
	if(module)
		var/secure_desc = "Bugged (report this)"
		switch(law_modules[module])
			if(MODULE_UNSECURED)
				secure_desc = "Unsecured"
			if(MODULE_SCREWED)
				secure_desc = "Screwed"
			if(MODULE_WELDED)
				secure_desc = "Welded"
		text += span_notice(secure_desc)
	if(module?.ioned)
		text += span_warning("It's smoking.")
	return jointext(text, span_info(" - "))

#undef LAW_EXAMINE_RANGE
/// Beyond this we don't have support for more slots visually
#define MAX_SLOT_OVERLAYS 9

/obj/machinery/ai_law_rack/update_overlays()
	. = ..()
	// if(welded)
	// 	. += "welded"
	for(var/i in 1 to min(length(law_modules), MAX_SLOT_OVERLAYS))
		if(isnull(law_modules[i]))
			continue
		// slot 1 is offset 0 - then 1 pixel break, and 1 slot every 2 pixels
		var/image/card = image(icon = icon, icon_state = "slot_filled")
		card.pixel_z = (i == 1 ? 0 : -1) + ((i - 1) * -2)
		. += card

#undef MAX_SLOT_OVERLAYS

/obj/machinery/ai_law_rack/proc/add_law_module(obj/item/ai_module/module, slot = 1, security = MODULE_UNSECURED)
	ASSERT(istype(module))
	ASSERT(isnum(slot))
	if(slot < 1 || slot > length(law_modules))
		return FALSE
	module.on_install(linked_ref, src)
	law_modules[slot] = module
	law_modules[module] = security
	update_appearance()
	update_lawset()
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
	data["linked"] = linked

	data["slots"] = new /list(length(law_modules))
	for(var/i in 1 to length(law_modules))
		var/obj/item/ai_module/module = law_modules[i]

		data["slots"][i] = list(
			"empty" = isnull(module),
			"name" = module?.name || "Empty",
			"security" = module ? law_modules[module] : MODULE_UNSECURED,
			"ioned" = module?.ioned || FALSE,
		)

	return data

/obj/machinery/ai_law_rack/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/user = ui.user
	if(!istype(user) || issilicon(user))
		return
	switch(action)
		if("insert_module")
			var/index = clamp(text2num(params["slot"]), 1, length(law_modules))
			var/obj/item/ai_module/module = user.get_active_held_item()
			if(!istype(module))
				to_chat(user, span_warning("You need to hold an AI module to insert it!"))
				return
			if(!module.can_install_to(user, src))
				return
			if(istype(module, /obj/item/ai_module/core))
				if(index != 1)
					to_chat(user, span_warning("You can't install a core module in a non-core slot!"))
					return
			else
				if(index == 1)
					to_chat(user, span_warning("You can only install core modules in the core slot!"))
					return
			if(!user.transferItemToLoc(module, src))
				to_chat(user, span_warning("You can't seem to insert [module.name] into [src]!"))
				return
			playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
			return add_law_module(module, index)
		if("remove_module")
			var/index = clamp(text2num(params["slot"]), 1, length(law_modules))
			var/obj/item/ai_module/module = law_modules[index]
			if(isnull(module) || law_modules[module])
				// These have feedback messages in the UI, the checks are only for sanity
				return
			// calls exited which handles updating laws and such
			try_put_in_hand(module, user)
			playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
			return TRUE
		if("screw_module")
			var/index = clamp(text2num(params["slot"]), 1, length(law_modules))
			var/obj/item/ai_module/module = law_modules[index]
			if(isnull(module) || law_modules[module] == MODULE_WELDED)
				// These have feedback messages in the UI, the checks are only for sanity
				return
			var/obj/item/screwer = user.get_active_held_item()
			if(screwer.tool_behaviour != TOOL_SCREWDRIVER)
				return
			balloon_alert_to_viewers("unscrewing slot [index]...")
			if(!screwer.use_tool(src, user, 3 SECONDS, volume = 25))
				return
			module = law_modules[index]
			if(isnull(module) || law_modules[module] == MODULE_WELDED)
				return
			if(law_modules[module] == MODULE_UNSECURED)
				law_modules[module] = MODULE_SCREWED
			else if(law_modules[module] == MODULE_SCREWED)
				law_modules[module] = MODULE_UNSECURED
			return TRUE
		if("weld_module")
			var/index = clamp(text2num(params["slot"]), 1, length(law_modules))
			var/obj/item/ai_module/module = law_modules[index]
			if(isnull(module) || law_modules[module] == MODULE_SCREWED)
				// These have feedback messages in the UI, the checks are only for sanity
				return
			balloon_alert_to_viewers("unwelding slot [index]...")
			var/obj/item/welder = user.get_active_held_item()
			if(welder.tool_behaviour != TOOL_WELDER)
				return
			if(!welder.use_tool(src, user, 3 SECONDS, volume = 25, amount = 1))
				return
			module = law_modules[index]
			if(isnull(module) || law_modules[module] == MODULE_UNSECURED)
				return
			if(law_modules[module] == MODULE_SCREWED)
				law_modules[module] = MODULE_WELDED
			else if(law_modules[module] == MODULE_WELDED)
				law_modules[module] = MODULE_SCREWED
			return TRUE
		if("multitool_module")
			var/index = clamp(text2num(params["slot"]), 1, length(law_modules))
			var/obj/item/ai_module/module = law_modules[index]
			if(isnull(module))
				return
			module.multitool_act(user, user.get_inactive_hand())
			return TRUE

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
	var/obj/item/ai_module/core/core = law_modules[1]
	var/core_sub_ion = prob(sub_ion_prob)
	var/ions_added = 0
	if(istype(core))
		core.save_laws()
		// Chance the core lawset's laws are overwritten with a new lawset
		if(prob(new_lawset_prob))
			var/ion_lawset_type = pick_weighted_lawset()
			var/datum/ai_laws/ion_lawset = new ion_lawset_type()
			core.laws = ion_lawset.inherent.Copy()
			qdel(ion_lawset)
			. = TRUE
		// Chance a random law is removed from the core lawset
		if(prob(remove_law_prob))
			var/removed = rand(1, length(core.laws))
			core.laws.Cut(removed, removed + 1) // melbert todo verify
			. = TRUE
		// Chance the core lawset is shuffled entirely
		if(prob(shuffle_prob))
			core.laws = shuffle(core.laws)
			. = TRUE
		// Chance the first law in the core lawset is replaced with an ion law
		// Don't add this one if we're replacing a random law later
		if(!core_sub_ion && prob(base_ion_prob))
			core.laws.Insert(1, ion_message || generate_ion_law())
			core.set_ioned(TRUE)
			ion_message = null
			ions_added++
		. = TRUE

	// This can double dip and affect the core lawset again - that's fine
	for(var/obj/item/ai_module/law in law_modules)
		if(law != core)
			law.save_laws()
		// For core lawsets: Chance that a random law (EXCEPT the newly added ion law) is replaced with another ion law.
		// For supplied laws: Chance the entire supplied law is replaced with a new ion law.
		// If we had no core law and thus added no ion law, this is guaranteed to replace the first supplied law
		if(ions_added < ion_limit && (ion_message || (law == core && core_sub_ion) || prob(sub_ion_prob)))
			var/picked_law = length(law.laws) <= 1 ? 1 : rand(2, length(law.laws))
			law.laws[picked_law] = ion_message || generate_ion_law()
			law.set_ioned(TRUE)
			ion_message = null
			ions_added++
			. = TRUE

		/// Chance for any supplied law to be lost entirely
		else if(law != core && prob(remove_law_prob))
			law.laws.Cut()
			law.set_ioned(TRUE)
			. = TRUE

	if(.)
		update_lawset()
	return .

/obj/machinery/ai_law_rack/ai
	name = "\improper AI law rack"
	/// An AI rack is the prime rack if it is on the station at mapload
	/// Generally should only ever have one prime rack per station
	var/prime_rack = FALSE

/obj/machinery/ai_law_rack/ai/Initialize(mapload)
	. = ..()
	if(mapload)
		prime_rack = is_station_level(z)
		load_config_law()

/obj/machinery/ai_law_rack/ai/proc/load_config_law()
	var/datum/ai_laws/default_laws = get_round_default_lawset()

	for(var/obj/item/ai_module/core/full/core as anything in subtypesof(/obj/item/ai_module/core/full))
		if(core::law_id == default_laws::id)
			add_law_module(new core(src), 1, MODULE_WELDED)

/obj/machinery/ai_law_rack/ai/can_link_to(mob/living/silicon/ai/new_bot)
	if(!isAI(new_bot))
		return FALSE
	return ..()

/obj/machinery/ai_law_rack/ai/update_lawset()
	. = ..()
	var/mob/living/silicon/ai/ai = linked_ref
	for(var/mob/living/silicon/robot/bot as anything in ai?.connected_robots)
		bot.try_sync_laws()

/obj/machinery/ai_law_rack/borg
	name = "\improper cyborg law rack"

/obj/machinery/ai_law_rack/borg/can_link_to(mob/living/silicon/robot/new_bot)
	if(!iscyborg(new_bot))
		return FALSE
	if(new_bot.scrambledcodes || new_bot.emagged)
		return FALSE
	return ..()
