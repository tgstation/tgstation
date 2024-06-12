///MOD Module - A special device installed in a MODsuit allowing the suit to do new stuff.
/obj/item/mod/module
	name = "MOD module"
	icon = 'icons/obj/clothing/modsuit/mod_modules.dmi'
	icon_state = "module"
	/// If it can be removed
	var/removable = TRUE
	/// If it's passive, togglable, usable or active
	var/module_type = MODULE_PASSIVE
	/// Is the module active
	var/active = FALSE
	/// How much space it takes up in the MOD
	var/complexity = 0
	/// Power use when idle
	var/idle_power_cost = DEFAULT_CHARGE_DRAIN * 0
	/// Power use when active
	var/active_power_cost = DEFAULT_CHARGE_DRAIN * 0
	/// Power use when used, we call it manually
	var/use_energy_cost = DEFAULT_CHARGE_DRAIN * 0
	/// ID used by their TGUI
	var/tgui_id
	/// Linked MODsuit
	var/obj/item/mod/control/mod
	/// If we're an active module, what item are we?
	var/obj/item/device
	/// Overlay given to the user when the module is inactive
	var/overlay_state_inactive
	/// Overlay given to the user when the module is active
	var/overlay_state_active
	/// Overlay given to the user when the module is used, lasts until cooldown finishes
	var/overlay_state_use
	/// Icon file for the overlay.
	var/overlay_icon_file = 'icons/mob/clothing/modsuit/mod_modules.dmi'
	/// Does the overlay use the control unit's colors?
	var/use_mod_colors = FALSE
	/// What modules are we incompatible with?
	var/list/incompatible_modules = list()
	/// Cooldown after use
	var/cooldown_time = 0
	/// The mouse button needed to use this module
	var/used_signal
	/// List of REF()s mobs we are pinned to, linked with their action buttons
	var/list/pinned_to = list()
	/// flags that let the module ability be used in odd circumstances
	var/allow_flags = NONE
	/// A list of slots required in the suit to work. Formatted like list(x|y, z, ...) where either x or y are required and z is required.
	var/list/required_slots = list()
	/// Timer for the cooldown
	COOLDOWN_DECLARE(cooldown_timer)

/obj/item/mod/module/Initialize(mapload)
	. = ..()
	if(module_type != MODULE_ACTIVE)
		return
	if(ispath(device))
		device = new device(src)
		ADD_TRAIT(device, TRAIT_NODROP, MOD_TRAIT)
		RegisterSignal(device, COMSIG_QDELETING, PROC_REF(on_device_deletion))
		RegisterSignal(src, COMSIG_ATOM_EXITED, PROC_REF(on_exit))

/obj/item/mod/module/Destroy()
	mod?.uninstall(src)
	if(device)
		UnregisterSignal(device, COMSIG_QDELETING)
		QDEL_NULL(device)
	return ..()

/obj/item/mod/module/examine(mob/user)
	. = ..()
	if(length(required_slots))
		var/list/slot_strings = list()
		for(var/slot in required_slots)
			var/list/slot_list = parse_slot_flags(slot)
			slot_strings += (length(slot_list) == 1 ? "" : "one of ") + english_list(slot_list, and_text = " or ")
		. += span_notice("Requires the MOD unit to have the following slots: [english_list(slot_strings)]")
	if(HAS_TRAIT(user, TRAIT_DIAGNOSTIC_HUD))
		. += span_notice("Complexity level: [complexity]")

/// Looks through the MODsuit's parts to see if it has the parts required to support this module
/obj/item/mod/module/proc/has_required_parts(list/parts, need_extended = FALSE)
	if(!length(required_slots))
		return TRUE
	var/total_slot_flags = NONE
	for(var/part_slot in parts)
		if(need_extended)
			var/datum/mod_part/part_datum = parts[part_slot]
			if(part_datum.part_item.loc == mod)
				continue
		total_slot_flags |= text2num(part_slot)
	var/list/needed_slots = required_slots.Copy()
	for(var/needed_slot in needed_slots)
		if(!(needed_slot & total_slot_flags))
			break
		needed_slots -= needed_slot
	return !length(needed_slots)

/// Called when the module is selected from the TGUI, radial or the action button
/obj/item/mod/module/proc/on_select()
	if(!mod.wearer)
		if(ismob(mod.loc))
			balloon_alert(mod.loc, "not equipped!")
		return
	if(((!mod.active || mod.activating) && !(allow_flags & MODULE_ALLOW_INACTIVE)) || module_type == MODULE_PASSIVE)
		if(mod.wearer)
			balloon_alert(mod.wearer, "not active!")
		return
	if(module_type != MODULE_USABLE)
		if(active)
			deactivate()
		else
			activate()
	else
		used()
	SEND_SIGNAL(mod, COMSIG_MOD_MODULE_SELECTED, src)

/// Apply a cooldown until this item can be used again
/obj/item/mod/module/proc/start_cooldown(applied_cooldown)
	if (isnull(applied_cooldown))
		applied_cooldown = cooldown_time
	COOLDOWN_START(src, cooldown_timer, applied_cooldown)
	SEND_SIGNAL(src, COMSIG_MODULE_COOLDOWN_STARTED, applied_cooldown)

/// Called when the module is activated
/obj/item/mod/module/proc/activate()
	if(!COOLDOWN_FINISHED(src, cooldown_timer))
		balloon_alert(mod.wearer, "on cooldown!")
		return FALSE
	if(!mod.active || mod.activating || !mod.get_charge())
		balloon_alert(mod.wearer, "unpowered!")
		return FALSE
	if(!(allow_flags & MODULE_ALLOW_PHASEOUT) && istype(mod.wearer.loc, /obj/effect/dummy/phased_mob))
		//specifically a to_chat because the user is phased out.
		to_chat(mod.wearer, span_warning("You cannot activate this right now."))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_MODULE_TRIGGERED, mod.wearer) & MOD_ABORT_USE)
		return FALSE
	if(module_type == MODULE_ACTIVE)
		if(mod.selected_module && !mod.selected_module.deactivate(display_message = FALSE))
			return FALSE
		mod.selected_module = src
		if(device)
			if(mod.wearer.put_in_hands(device))
				balloon_alert(mod.wearer, "[device] extended")
				RegisterSignal(mod.wearer, COMSIG_ATOM_EXITED, PROC_REF(on_exit))
				RegisterSignal(mod.wearer, COMSIG_KB_MOB_DROPITEM_DOWN, PROC_REF(dropkey))
			else
				balloon_alert(mod.wearer, "can't extend [device]!")
				mod.wearer.transferItemToLoc(device, src, force = TRUE)
				return FALSE
		else
			var/used_button = mod.wearer.client?.prefs.read_preference(/datum/preference/choiced/mod_select) || MIDDLE_CLICK
			update_signal(used_button)
			balloon_alert(mod.wearer, "[src] activated, [used_button]-click to use")
	active = TRUE
	mod.wearer.update_clothing(mod.slot_flags)
	start_cooldown()
	SEND_SIGNAL(src, COMSIG_MODULE_ACTIVATED)
	on_activation()
	return TRUE

/// Called when the module is deactivated
/obj/item/mod/module/proc/deactivate(display_message = TRUE, deleting = FALSE)
	active = FALSE
	if(module_type == MODULE_ACTIVE)
		mod.selected_module = null
		if(display_message)
			balloon_alert(mod.wearer, device ? "[device] retracted" : "[src] deactivated")
		if(device)
			mod.wearer.transferItemToLoc(device, src, force = TRUE)
			UnregisterSignal(mod.wearer, COMSIG_ATOM_EXITED)
			UnregisterSignal(mod.wearer, COMSIG_KB_MOB_DROPITEM_DOWN)
		else
			UnregisterSignal(mod.wearer, used_signal)
			used_signal = null
	mod.wearer.update_clothing(mod.slot_flags)
	SEND_SIGNAL(src, COMSIG_MODULE_DEACTIVATED, mod.wearer)
	on_deactivation(display_message = TRUE, deleting = FALSE)
	return TRUE

/// Called when the module is used
/obj/item/mod/module/proc/used()
	if(!COOLDOWN_FINISHED(src, cooldown_timer))
		balloon_alert(mod.wearer, "on cooldown!")
		return FALSE
	if(!check_power(use_energy_cost))
		balloon_alert(mod.wearer, "not enough charge!")
		return FALSE
	if(!(allow_flags & MODULE_ALLOW_PHASEOUT) && istype(mod.wearer.loc, /obj/effect/dummy/phased_mob))
		//specifically a to_chat because the user is phased out.
		to_chat(mod.wearer, span_warning("You cannot activate this right now."))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_MODULE_TRIGGERED, mod.wearer) & MOD_ABORT_USE)
		return FALSE
	start_cooldown()
	addtimer(CALLBACK(mod.wearer, TYPE_PROC_REF(/mob, update_clothing), mod.slot_flags), cooldown_time+1) //need to run it a bit after the cooldown starts to avoid conflicts
	mod.wearer.update_clothing(mod.slot_flags)
	SEND_SIGNAL(src, COMSIG_MODULE_USED)
	on_use()
	return TRUE

/// Called when an activated module without a device is used
/obj/item/mod/module/proc/on_select_use(atom/target)
	if(!(allow_flags & MODULE_ALLOW_INCAPACITATED) && mod.wearer.incapacitated(IGNORE_GRAB))
		return FALSE
	mod.wearer.face_atom(target)
	if(!used())
		return FALSE
	return TRUE

/// Called when an activated module without a device is active and the user alt/middle-clicks
/obj/item/mod/module/proc/on_special_click(mob/source, atom/target)
	SIGNAL_HANDLER
	on_select_use(target)
	return COMSIG_MOB_CANCEL_CLICKON

/// Called on the MODsuit's process
/obj/item/mod/module/proc/on_process(seconds_per_tick)
	if(active)
		if(!drain_power(active_power_cost * seconds_per_tick))
			deactivate()
			return FALSE
		on_active_process(seconds_per_tick)
	else
		drain_power(idle_power_cost * seconds_per_tick)
	return TRUE

/// Called from the module's activate()
/obj/item/mod/module/proc/on_activation()
	return

/// Called from the module's deactivate()
/obj/item/mod/module/proc/on_deactivation(display_message = TRUE, deleting = FALSE)
	return

/// Called from the module's used()
/obj/item/mod/module/proc/on_use()
	return

/// Called on the MODsuit's process if it is an active module
/obj/item/mod/module/proc/on_active_process(seconds_per_tick)
	return

/// Called from MODsuit's install() proc, so when the module is installed
/obj/item/mod/module/proc/on_install()
	return

/// Called from MODsuit's uninstall() proc, so when the module is uninstalled
/obj/item/mod/module/proc/on_uninstall(deleting = FALSE)
	return

/// Called when the MODsuit is activated
/obj/item/mod/module/proc/on_suit_activation()
	return

/// Called when the MODsuit is deactivated
/obj/item/mod/module/proc/on_suit_deactivation(deleting = FALSE)
	return

/// Called when the MODsuit is equipped
/obj/item/mod/module/proc/on_equip()
	return

/// Called when the MODsuit is unequipped
/obj/item/mod/module/proc/on_unequip()
	return

/// Drains power from the suit charge
/obj/item/mod/module/proc/drain_power(amount)
	if(!check_power(amount))
		return FALSE
	mod.subtract_charge(amount)
	return TRUE

/// Checks if there is enough power in the suit
/obj/item/mod/module/proc/check_power(amount)
	return mod.check_charge(amount)

/// Adds additional things to the MODsuit ui_data()
/obj/item/mod/module/proc/add_ui_data()
	return list()

/// Creates a list of configuring options for this module
/obj/item/mod/module/proc/get_configuration(mob/user)
	return list()

/// Generates an element of the get_configuration list with a display name, type and value
/obj/item/mod/module/proc/add_ui_configuration(display_name, type, value, list/values)
	return list("display_name" = display_name, "type" = type, "value" = value, "values" = values)

/// Receives configure edits from the TGUI and edits the vars
/obj/item/mod/module/proc/configure_edit(key, value)
	return

/// Called when the device moves to a different place on active modules
/obj/item/mod/module/proc/on_exit(datum/source, atom/movable/part, direction)
	SIGNAL_HANDLER

	if(!active)
		return
	if(part.loc == src)
		return
	if(part.loc == mod.wearer)
		return
	if(part == device)
		deactivate(display_message = FALSE)

/// Called when the device gets deleted on active modules
/obj/item/mod/module/proc/on_device_deletion(datum/source)
	SIGNAL_HANDLER

	if(source == device)
		device = null
		qdel(src)

/// Adds the worn overlays to the suit.
/obj/item/mod/module/proc/add_module_overlay(obj/item/source, list/overlays, mutable_appearance/standing, isinhands, icon_file)
	SIGNAL_HANDLER

	overlays += generate_worn_overlay(standing)

/// Generates an icon to be used for the suit's worn overlays
/obj/item/mod/module/proc/generate_worn_overlay(mutable_appearance/standing)
	. = list()
	if(!mod.active)
		return
	var/used_overlay
	if(overlay_state_use && !COOLDOWN_FINISHED(src, cooldown_timer))
		used_overlay = overlay_state_use
	else if(overlay_state_active && active)
		used_overlay = overlay_state_active
	else if(overlay_state_inactive)
		used_overlay = overlay_state_inactive
	else
		return
	var/mutable_appearance/module_icon = mutable_appearance(overlay_icon_file, used_overlay, layer = standing.layer + 0.1)
	if(!use_mod_colors)
		module_icon.appearance_flags |= RESET_COLOR
	. += module_icon

/// Updates the signal used by active modules to be activated
/obj/item/mod/module/proc/update_signal(value)
	switch(value)
		if(MIDDLE_CLICK)
			mod.selected_module.used_signal = COMSIG_MOB_MIDDLECLICKON
		if(ALT_CLICK)
			mod.selected_module.used_signal = COMSIG_MOB_ALTCLICKON
	RegisterSignal(mod.wearer, mod.selected_module.used_signal, TYPE_PROC_REF(/obj/item/mod/module, on_special_click))

/// Pins the module to the user's action buttons
/obj/item/mod/module/proc/pin(mob/user)
	if(module_type == MODULE_PASSIVE)
		return

	var/datum/action/item_action/mod/pinnable/module/existing_action = pinned_to[REF(user)]
	if(existing_action)
		mod.remove_item_action(existing_action)
		return

	var/datum/action/item_action/mod/pinnable/module/new_action = new(mod, user, src)
	mod.add_item_action(new_action)

/// On drop key, concels a device item.
/obj/item/mod/module/proc/dropkey(mob/living/user)
	SIGNAL_HANDLER

	if(user.get_active_held_item() != device)
		return
	deactivate()
	return COMSIG_KB_ACTIVATED

///Anomaly Locked - Causes the module to not function without an anomaly.
/obj/item/mod/module/anomaly_locked
	name = "MOD anomaly locked module"
	desc = "A form of a module, locked behind an anomalous core to function."
	incompatible_modules = list(/obj/item/mod/module/anomaly_locked)
	/// The core item the module runs off.
	var/obj/item/assembly/signaler/anomaly/core
	/// Accepted types of anomaly cores.
	var/list/accepted_anomalies = list(/obj/item/assembly/signaler/anomaly)
	/// If this one starts with a core in.
	var/prebuilt = FALSE
	/// If the core is removable once socketed.
	var/core_removable = TRUE

/obj/item/mod/module/anomaly_locked/Initialize(mapload)
	. = ..()
	if(!prebuilt || !length(accepted_anomalies))
		return
	var/core_path = pick(accepted_anomalies)
	core = new core_path(src)
	update_icon_state()

/obj/item/mod/module/anomaly_locked/Destroy()
	QDEL_NULL(core)
	return ..()

/obj/item/mod/module/anomaly_locked/examine(mob/user)
	. = ..()
	if(!length(accepted_anomalies))
		return
	if(core)
		. += span_notice("There is a [core.name] installed in it. [core_removable ? "You could remove it with a <b>screwdriver</b>..." : "Unfortunately, due to a design quirk, it's unremovable."]")
	else
		var/list/core_list = list()
		for(var/path in accepted_anomalies)
			var/atom/core_path = path
			core_list += initial(core_path.name)
		. += span_notice("You need to insert \a [english_list(core_list, and_text = " or ")] for this module to function.")
		if(!core_removable)
			. += span_notice("Due to some design quirk, once a core is inserted, it won't be removable.")

/obj/item/mod/module/anomaly_locked/on_select()
	if(!core)
		balloon_alert(mod.wearer, "no core!")
		return
	return ..()

/obj/item/mod/module/anomaly_locked/on_process(seconds_per_tick)
	. = ..()
	if(!core)
		return FALSE

/obj/item/mod/module/anomaly_locked/on_active_process(seconds_per_tick)
	if(!core)
		return FALSE
	return TRUE

/obj/item/mod/module/anomaly_locked/attackby(obj/item/item, mob/living/user, params)
	if(item.type in accepted_anomalies)
		if(core)
			balloon_alert(user, "core already in!")
			return
		if(!user.transferItemToLoc(item, src))
			return
		core = item
		balloon_alert(user, "core installed")
		playsound(src, 'sound/machines/click.ogg', 30, TRUE)
		update_icon_state()
	else
		return ..()

/obj/item/mod/module/anomaly_locked/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!core)
		balloon_alert(user, "no core!")
		return
	if(!core_removable)
		balloon_alert(user, "can't remove core!")
		return
	balloon_alert(user, "removing core...")
	if(!do_after(user, 3 SECONDS, target = src))
		balloon_alert(user, "interrupted!")
		return
	balloon_alert(user, "core removed")
	core.forceMove(drop_location())
	if(Adjacent(user) && !issilicon(user))
		user.put_in_hands(core)
	core = null
	update_icon_state()

/obj/item/mod/module/anomaly_locked/update_icon_state()
	icon_state = initial(icon_state) + (core ? "-core" : "")
	return ..()
