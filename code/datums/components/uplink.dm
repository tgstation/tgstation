#define PEN_ROTATIONS 2

/**
 * Uplinks
 *
 * All /obj/item(s) have a hidden_uplink var. By default it's null. Give the item one with 'new(src') (it must be in it's contents). Then add 'uses.'
 * Use whatever conditionals you want to check that the user has an uplink, and then call interact() on their uplink.
 * You might also want the uplink menu to open if active. Check if the uplink is 'active' and then interact() with it.
**/
/datum/component/uplink
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Name of the uplink
	var/name = "syndicate uplink"
	/// Whether the uplink is currently active or not
	var/active = FALSE
	/// Whether this uplink can be locked or not
	var/lockable = TRUE
	/// Whether the uplink is locked or not.
	var/locked = TRUE
	/// Whether this uplink allows restricted items to be accessed
	var/allow_restricted = TRUE
	/// Current owner of the uplink
	var/owner = null
	/// Purchase log, listing all the purchases this uplink has made
	var/datum/uplink_purchase_log/purchase_log
	/// The current linked uplink handler.
	var/datum/uplink_handler/uplink_handler
	/// Code to unlock the uplink.
	var/unlock_code
	/// Used for pen uplink
	var/list/previous_attempts

	// Not modular variables. These variables should be removed sometime in the future

	/// The unlock text that is sent to the traitor with this uplink. This is not modular and not recommended to expand upon
	var/unlock_text
	/// The unlock note that is sent to the traitor with this uplink. This is not modular and not recommended to expand upon
	var/unlock_note
	/// The failsafe code that causes this uplink to blow up.
	var/failsafe_code

/datum/component/uplink/Initialize(owner, lockable = TRUE, enabled = FALSE, uplink_flag = UPLINK_TRAITORS, starting_tc = TELECRYSTALS_DEFAULT, has_progression = FALSE, datum/uplink_handler/uplink_handler_override)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/OnAttackBy)
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, .proc/interact)
	if(istype(parent, /obj/item/implant))
		RegisterSignal(parent, COMSIG_IMPLANT_ACTIVATED, .proc/implant_activation)
		RegisterSignal(parent, COMSIG_IMPLANT_IMPLANTING, .proc/implanting)
		RegisterSignal(parent, COMSIG_IMPLANT_OTHER, .proc/old_implant)
		RegisterSignal(parent, COMSIG_IMPLANT_EXISTING_UPLINK, .proc/new_implant)
	else if(istype(parent, /obj/item/pda))
		RegisterSignal(parent, COMSIG_PDA_CHANGE_RINGTONE, .proc/new_ringtone)
		RegisterSignal(parent, COMSIG_PDA_CHECK_DETONATE, .proc/check_detonate)
	else if(istype(parent, /obj/item/radio))
		RegisterSignal(parent, COMSIG_RADIO_NEW_FREQUENCY, .proc/new_frequency)
	else if(istype(parent, /obj/item/pen))
		RegisterSignal(parent, COMSIG_PEN_ROTATED, .proc/pen_rotation)
	if(owner)
		src.owner = owner
		LAZYINITLIST(GLOB.uplink_purchase_logs_by_key)
		if(GLOB.uplink_purchase_logs_by_key[owner])
			purchase_log = GLOB.uplink_purchase_logs_by_key[owner]
		else
			purchase_log = new(owner, src)
	src.lockable = lockable
	src.active = enabled
	if(!uplink_handler_override)
		uplink_handler = new()
		uplink_handler.has_objectives = FALSE
		uplink_handler.uplink_flag = uplink_flag
		uplink_handler.telecrystals = starting_tc
		uplink_handler.has_progression = has_progression
		uplink_handler.purchase_log = purchase_log
	else
		uplink_handler = uplink_handler_override
	RegisterSignal(uplink_handler, COMSIG_UPLINK_HANDLER_ON_UPDATE, .proc/handle_uplink_handler_update)
	if(!lockable)
		active = TRUE
		locked = FALSE

	previous_attempts = list()

/datum/component/uplink/proc/handle_uplink_handler_update()
	SIGNAL_HANDLER
	SStgui.update_uis(src)

/// Adds telecrystals to the uplink. It is bad practice to use this outside of the component itself.
/datum/component/uplink/proc/add_telecrystals(telecrystals_added)
	set_telecrystals(uplink_handler.telecrystals + telecrystals_added)

/// Sets the telecrystals of the uplink. It is bad practice to use this outside of the component itself.
/datum/component/uplink/proc/set_telecrystals(new_telecrystal_amount)
	uplink_handler.telecrystals = new_telecrystal_amount

/datum/component/uplink/InheritComponent(datum/component/uplink/uplink)
	lockable |= uplink.lockable
	active |= uplink.active
	uplink_handler.uplink_flag |= uplink.uplink_handler.uplink_flag

/datum/component/uplink/Destroy()
	purchase_log = null
	return ..()

/datum/component/uplink/proc/load_tc(mob/user, obj/item/stack/telecrystal/telecrystals, silent = FALSE)
	if(!silent)
		to_chat(user, span_notice("You slot [telecrystals] into [parent] and charge its internal uplink."))
	var/amt = telecrystals.amount
	uplink_handler.telecrystals += amt
	telecrystals.use(amt)
	log_uplink("[key_name(user)] loaded [amt] telecrystals into [parent]'s uplink")

/datum/component/uplink/proc/OnAttackBy(datum/source, obj/item/item, mob/user)
	SIGNAL_HANDLER
	if(!active)
		return //no hitting everyone/everything just to try to slot tcs in!

	if(istype(item, /obj/item/stack/telecrystal))
		load_tc(user, item)

/datum/component/uplink/proc/interact(datum/source, mob/user)
	SIGNAL_HANDLER

	if(locked)
		return
	active = TRUE
	if(user)
		INVOKE_ASYNC(src, .proc/ui_interact, user)
	// an unlocked uplink blocks also opening the PDA or headset menu
	return COMPONENT_CANCEL_ATTACK_CHAIN


/datum/component/uplink/ui_state(mob/user)
	return GLOB.inventory_state

/datum/component/uplink/ui_interact(mob/user, datum/tgui/ui)
	active = TRUE
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Uplink", name)
		// This UI is only ever opened by one person,
		// and never is updated outside of user input.
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/component/uplink/ui_data(mob/user)
	if(!user.mind)
		return
	var/list/data = list()
	data["telecrystals"] = uplink_handler.telecrystals
	data["progression_points"] = uplink_handler.progression_points
	data["current_expected_progression"] = SStraitor.current_global_progression
	data["maximum_active_objectives"] = uplink_handler.maximum_active_objectives
	data["progression_scaling_deviance"] = SStraitor.progression_scaling_deviance
	data["current_progression_scaling"] = SStraitor.current_progression_scaling

	data["maximum_potential_objectives"] = CONFIG_GET(number/maximum_potential_objectives)
	if(uplink_handler.has_objectives)
		var/list/potential_objectives = list()
		var/index = 1
		for(var/datum/traitor_objective/objective as anything in uplink_handler.potential_objectives)
			var/list/objective_data = objective.uplink_ui_data(user)
			objective_data["id"] = index
			potential_objectives += list(objective_data)
			index++
		index = 1
		var/list/active_objectives = list()
		for(var/datum/traitor_objective/objective as anything in uplink_handler.active_objectives)
			var/list/objective_data = objective.uplink_ui_data(user)
			objective_data["id"] = index
			active_objectives += list(objective_data)
			index++
		data["potential_objectives"] = potential_objectives
		data["active_objectives"] = active_objectives

	return data

/datum/component/uplink/ui_static_data(mob/user)
	var/list/data = list()
	data["uplink_flag"] = uplink_handler.uplink_flag
	data["has_progression"] = uplink_handler.has_progression
	data["has_objectives"] = uplink_handler.has_objectives
	data["lockable"] = lockable
	data["assigned_role"] = uplink_handler.assigned_role
	data["debug"] = uplink_handler.debug_mode
	return data

/datum/component/uplink/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/json/uplink)
	)

/datum/component/uplink/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!active)
		return
	switch(action)
		if("buy")
			var/datum/uplink_item/item_path = text2path(params["path"])
			if(!ispath(item_path, /datum/uplink_item))
				return

			var/datum/uplink_item/item = GLOB.uplink_items_by_type[item_path]
			uplink_handler.purchase_item(ui.user, item)
		if("lock")
			active = FALSE
			locked = TRUE
			SStgui.close_uis(src)

	if(!uplink_handler.has_objectives)
		return TRUE

	switch(action)
		if("regenerate_objectives")
			uplink_handler.generate_objectives()
			return TRUE

	var/list/objectives
	switch(action)
		if("start_objective")
			objectives = uplink_handler.potential_objectives
		if("objective_act", "finish_objective", "objective_abort")
			objectives = uplink_handler.active_objectives

	if(!objectives)
		return

	var/objective_index = text2num(params["index"])
	if(objective_index < 1 || objective_index > length(objectives))
		return TRUE
	var/datum/traitor_objective/objective = objectives[objective_index]
	// This'll practically verify for 99.99% of cases that we are targetting the correct objective
	if(round(objective.original_progression) == round(text2num(params["check"])))
		return

	// Objective actions
	switch(action)
		if("start_objective")
			uplink_handler.take_objective(ui.user, objective)
		if("objective_act")
			uplink_handler.ui_objective_act(ui.user, objective, params["objective_action"])
		if("finish_objective")
			if(!objective.finish_objective(ui.user))
				return
			uplink_handler.complete_objective(objective)
		if("objective_abort")
			uplink_handler.abort_objective(objective)
	return TRUE

// Implant signal responses
/datum/component/uplink/proc/implant_activation()
	SIGNAL_HANDLER

	var/obj/item/implant/implant = parent
	locked = FALSE
	interact(null, implant.imp_in)

/datum/component/uplink/proc/implanting(datum/source, list/arguments)
	SIGNAL_HANDLER

	var/mob/user = arguments[2]
	owner = user?.key
	if(owner && !purchase_log)
		LAZYINITLIST(GLOB.uplink_purchase_logs_by_key)
		if(GLOB.uplink_purchase_logs_by_key[owner])
			purchase_log = GLOB.uplink_purchase_logs_by_key[owner]
		else
			purchase_log = new(owner, src)

/datum/component/uplink/proc/old_implant(datum/source, list/arguments, obj/item/implant/new_implant)
	SIGNAL_HANDLER

	// It kinda has to be weird like this until implants are components
	return SEND_SIGNAL(new_implant, COMSIG_IMPLANT_EXISTING_UPLINK, src)

/datum/component/uplink/proc/new_implant(datum/source, datum/component/uplink/uplink)
	SIGNAL_HANDLER

	uplink.add_telecrystals(uplink_handler.telecrystals)
	return COMPONENT_DELETE_NEW_IMPLANT

// PDA signal responses

/datum/component/uplink/proc/new_ringtone(datum/source, mob/living/user, new_ring_text)
	SIGNAL_HANDLER

	var/obj/item/pda/master = parent
	if(trim(lowertext(new_ring_text)) != trim(lowertext(unlock_code)))
		if(trim(lowertext(new_ring_text)) == trim(lowertext(failsafe_code)))
			failsafe(user)
			return COMPONENT_STOP_RINGTONE_CHANGE
		return
	locked = FALSE
	interact(null, user)
	to_chat(user, span_hear("The PDA softly beeps."))
	user << browse(null, "window=pda")
	master.ui_mode = PDA_UI_HUB
	return COMPONENT_STOP_RINGTONE_CHANGE

/datum/component/uplink/proc/check_detonate()
	SIGNAL_HANDLER

	return COMPONENT_PDA_NO_DETONATE

// Radio signal responses

/datum/component/uplink/proc/new_frequency(datum/source, list/arguments)
	SIGNAL_HANDLER

	var/obj/item/radio/master = parent
	var/frequency = arguments[1]
	if(frequency != unlock_code)
		if(frequency == failsafe_code)
			failsafe(master.loc)
		return
	locked = FALSE
	if(ismob(master.loc))
		interact(null, master.loc)

// Pen signal responses

/datum/component/uplink/proc/pen_rotation(datum/source, degrees, mob/living/carbon/user)
	SIGNAL_HANDLER

	var/obj/item/pen/master = parent
	previous_attempts += degrees
	if(length(previous_attempts) > PEN_ROTATIONS)
		popleft(previous_attempts)

	if(compare_list(previous_attempts, unlock_code))
		locked = FALSE
		previous_attempts.Cut()
		master.degrees = 0
		interact(null, user)
		to_chat(user, span_warning("Your pen makes a clicking noise, before quickly rotating back to 0 degrees!"))

	else if(compare_list(previous_attempts, failsafe_code))
		failsafe(user)

/datum/component/uplink/proc/setup_unlock_code()
	unlock_code = generate_code()
	var/obj/item/P = parent
	if(istype(parent,/obj/item/pda))
		unlock_note = "<B>Uplink Passcode:</B> [unlock_code] ([P.name])."
	else if(istype(parent,/obj/item/radio))
		unlock_note = "<B>Radio Frequency:</B> [format_frequency(unlock_code)] ([P.name])."
	else if(istype(parent,/obj/item/pen))
		unlock_note = "<B>Uplink Degrees:</B> [english_list(unlock_code)] ([P.name])."

/datum/component/uplink/proc/generate_code()
	if(istype(parent,/obj/item/pda))
		return "[rand(100,999)] [pick(GLOB.phonetic_alphabet)]"
	else if(istype(parent,/obj/item/radio))
		return return_unused_frequency()
	else if(istype(parent,/obj/item/pen))
		var/list/L = list()
		for(var/i in 1 to PEN_ROTATIONS)
			L += rand(1, 360)
		return L

/datum/component/uplink/proc/failsafe(mob/living/carbon/user)
	if(!parent)
		return
	var/turf/T = get_turf(parent)
	if(!T)
		return
	message_admins("[ADMIN_LOOKUPFLW(user)] has triggered an uplink failsafe explosion at [AREACOORD(T)] The owner of the uplink was [ADMIN_LOOKUPFLW(owner)].")
	log_game("[key_name(user)] triggered an uplink failsafe explosion. The owner of the uplink was [key_name(owner)].")
	explosion(parent, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 3)
	qdel(parent) //Alternatively could brick the uplink.
