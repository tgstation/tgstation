#define PEN_ROTATIONS 2

/**
 * Uplinks
 *
 * All /obj/item(s) have a hidden_uplink var. By default it's null. Give the item one with 'new(src') (it must be in its contents). Then add 'uses.'
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

/datum/component/uplink/Initialize(
	owner,
	lockable = TRUE,
	enabled = FALSE,
	uplink_flag = UPLINK_TRAITORS,
	starting_tc = TELECRYSTALS_DEFAULT,
	has_progression = FALSE,
	datum/uplink_handler/uplink_handler_override,
)

	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(OnAttackBy))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(interact))
	if(istype(parent, /obj/item/implant))
		RegisterSignal(parent, COMSIG_IMPLANT_ACTIVATED, PROC_REF(implant_activation))
		RegisterSignal(parent, COMSIG_IMPLANT_IMPLANTING, PROC_REF(implanting))
		RegisterSignal(parent, COMSIG_IMPLANT_OTHER, PROC_REF(old_implant))
		RegisterSignal(parent, COMSIG_IMPLANT_EXISTING_UPLINK, PROC_REF(new_implant))
	else if(istype(parent, /obj/item/modular_computer))
		RegisterSignal(parent, COMSIG_TABLET_CHANGE_ID, PROC_REF(new_ringtone))
		RegisterSignal(parent, COMSIG_TABLET_CHECK_DETONATE, PROC_REF(check_detonate))
	else if(istype(parent, /obj/item/radio))
		RegisterSignal(parent, COMSIG_RADIO_NEW_MESSAGE, PROC_REF(new_message))
	else if(istype(parent, /obj/item/pen))
		RegisterSignal(parent, COMSIG_PEN_ROTATED, PROC_REF(pen_rotation))
	else if(istype(parent, /obj/item/uplink/replacement))
		RegisterSignal(parent, COMSIG_MOVABLE_HEAR, PROC_REF(on_heard))

	if(owner)
		src.owner = owner
		LAZYINITLIST(GLOB.uplink_purchase_logs_by_key)
		if(GLOB.uplink_purchase_logs_by_key[owner])
			purchase_log = GLOB.uplink_purchase_logs_by_key[owner]
		else
			purchase_log = new(owner, src)
		RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
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
	RegisterSignal(uplink_handler, COMSIG_UPLINK_HANDLER_ON_UPDATE, PROC_REF(handle_uplink_handler_update))
	RegisterSignal(uplink_handler, COMSIG_UPLINK_HANDLER_REPLACEMENT_ORDERED, PROC_REF(handle_uplink_replaced))
	if(!lockable)
		active = TRUE
		locked = FALSE

	previous_attempts = list()

/datum/component/uplink/proc/handle_uplink_handler_update()
	SIGNAL_HANDLER
	SStgui.update_uis(src)

/// When a new uplink is made via the syndicate beacon it locks all lockable uplinks and destroys replacement uplinks
/datum/component/uplink/proc/handle_uplink_replaced()
	SIGNAL_HANDLER
	if(lockable)
		lock_uplink()
	if(!istype(parent, /obj/item/uplink/replacement))
		return
	var/obj/item/uplink_item = parent
	do_sparks(number = 3, cardinal_only = FALSE, source = uplink_item)
	uplink_item.visible_message(span_warning("The [uplink_item] suddenly combusts!"), vision_distance = COMBAT_MESSAGE_RANGE)
	new /obj/effect/decal/cleanable/ash(get_turf(uplink_item))
	qdel(uplink_item)

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
	uplink_handler.add_telecrystals(amt)
	telecrystals.use(amt)
	log_uplink("[key_name(user)] loaded [amt] telecrystals into [parent]'s uplink")

/datum/component/uplink/proc/OnAttackBy(datum/source, obj/item/item, mob/user)
	SIGNAL_HANDLER
	if(!active)
		return //no hitting everyone/everything just to try to slot tcs in!

	if(istype(item, /obj/item/stack/telecrystal))
		load_tc(user, item)

	if(!istype(item))
		return

	SEND_SIGNAL(item, COMSIG_ITEM_ATTEMPT_TC_REIMBURSE, user, src)

/datum/component/uplink/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(user != owner)
		return
	examine_list += span_warning("[parent] contains your hidden uplink\
		[unlock_code ? ", the code to unlock it is [span_boldwarning(unlock_code)]" : null].")

	if(failsafe_code)
		examine_list += span_warning("The failsafe code is [span_boldwarning(failsafe_code)].")

/datum/component/uplink/proc/interact(datum/source, mob/user)
	SIGNAL_HANDLER

	if(locked)
		return
	active = TRUE
	if(user)
		INVOKE_ASYNC(src, PROC_REF(ui_interact), user)
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

	data["maximum_potential_objectives"] = uplink_handler.maximum_potential_objectives
	if(uplink_handler.has_objectives)
		var/list/primary_objectives = list()
		for(var/datum/objective/task as anything in uplink_handler.primary_objectives)
			var/list/task_data = list()
			if(length(primary_objectives) > length(GLOB.phonetic_alphabet))
				task_data["task_name"] = "DIRECTIVE [length(primary_objectives) + 1]" //The english alphabet is WEAK
			else
				task_data["task_name"] = "DIRECTIVE [uppertext(GLOB.phonetic_alphabet[length(primary_objectives) + 1])]"
			task_data["task_text"] = task.explanation_text
			primary_objectives += list(task_data)

		var/list/potential_objectives = list()
		for(var/index in 1 to uplink_handler.potential_objectives.len)
			var/datum/traitor_objective/objective = uplink_handler.potential_objectives[index]
			var/list/objective_data = objective.uplink_ui_data(user)
			objective_data["id"] = index
			potential_objectives += list(objective_data)

		var/list/active_objectives = list()
		for(var/index in 1 to uplink_handler.active_objectives.len)
			var/datum/traitor_objective/objective = uplink_handler.active_objectives[index]
			var/list/objective_data = objective.uplink_ui_data(user)
			objective_data["id"] = index
			active_objectives += list(objective_data)

		data["primary_objectives"] = primary_objectives
		data["potential_objectives"] = potential_objectives
		data["active_objectives"] = active_objectives
		data["completed_final_objective"] = uplink_handler.final_objective

	var/list/stock_list = uplink_handler.item_stock.Copy()
	var/list/extra_purchasable_stock = list()
	var/list/extra_purchasable = list()
	for(var/datum/uplink_item/item as anything in uplink_handler.extra_purchasable)
		if(item.stock_key in stock_list)
			extra_purchasable_stock[REF(item)] = stock_list[item.stock_key]
		extra_purchasable += list(list(
			"id" = item.type,
			"name" = item.name,
			"cost" = item.cost,
			"desc" = item.desc,
			"category" = item.category ? initial(item.category.name) : null,
			"purchasable_from" = item.purchasable_from,
			"restricted" = item.restricted,
			"limited_stock" = item.limited_stock,
			"restricted_roles" = item.restricted_roles,
			"restricted_species" = item.restricted_species,
			"progression_minimum" = item.progression_minimum,
			"ref" = REF(item),
		))

	var/list/remaining_stock = list()
	for(var/item as anything in stock_list)
		remaining_stock[item] = stock_list[item]
	data["extra_purchasable"] = extra_purchasable
	data["extra_purchasable_stock"] = extra_purchasable_stock
	data["current_stock"] = remaining_stock
	data["shop_locked"] = uplink_handler.shop_locked
	data["purchased_items"] = length(uplink_handler.purchase_log?.purchase_log)
	data["can_renegotiate"] = user.mind == uplink_handler.owner && uplink_handler.can_replace_objectives?.Invoke() == TRUE
	return data

/datum/component/uplink/ui_static_data(mob/user)
	var/list/data = list()
	data["uplink_flag"] = uplink_handler.uplink_flag
	data["has_progression"] = uplink_handler.has_progression
	data["has_objectives"] = uplink_handler.has_objectives
	data["lockable"] = lockable
	data["assigned_role"] = uplink_handler.assigned_role
	data["assigned_species"] = uplink_handler.assigned_species
	data["debug"] = uplink_handler.debug_mode
	return data

/datum/component/uplink/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/json/uplink),
	)

/datum/component/uplink/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!active)
		return
	switch(action)
		if("buy")
			var/datum/uplink_item/item
			if(params["ref"])
				item = locate(params["ref"]) in uplink_handler.extra_purchasable
				if(!item)
					return
			else
				var/datum/uplink_item/item_path = text2path(params["path"])
				if(!ispath(item_path, /datum/uplink_item))
					return
				item = SStraitor.uplink_items_by_type[item_path]
			uplink_handler.purchase_item(ui.user, item, parent)
		if("lock")
			if(!lockable)
				return TRUE
			lock_uplink()
		if("renegotiate_objectives")
			uplink_handler.replace_objectives?.Invoke()
			SStgui.update_uis(src)

	if(!uplink_handler.has_objectives)
		return TRUE

	if(uplink_handler.owner?.current != ui.user || !uplink_handler.can_take_objectives)
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

	var/objective_index = round(text2num(params["index"]))
	if(objective_index < 1 || objective_index > length(objectives))
		return TRUE
	var/datum/traitor_objective/objective = objectives[objective_index]

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

/// Proc that locks uplinks
/datum/component/uplink/proc/lock_uplink()
	active = FALSE
	locked = TRUE
	SStgui.close_uis(src)

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

	return COMPONENT_DELETE_NEW_IMPLANT

// PDA signal responses

/datum/component/uplink/proc/new_ringtone(datum/source, mob/living/user, new_ring_text)
	SIGNAL_HANDLER

	if(trim(LOWER_TEXT(new_ring_text)) != trim(LOWER_TEXT(unlock_code)))
		if(trim(LOWER_TEXT(new_ring_text)) == trim(LOWER_TEXT(failsafe_code)))
			failsafe(user)
			return COMPONENT_STOP_RINGTONE_CHANGE
		return
	locked = FALSE
	if(ismob(user))
		interact(null, user)
		to_chat(user, span_hear("The computer softly beeps."))
	return COMPONENT_STOP_RINGTONE_CHANGE

/datum/component/uplink/proc/check_detonate()
	SIGNAL_HANDLER

	return COMPONENT_TABLET_NO_DETONATE

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

/datum/component/uplink/proc/new_message(datum/source, mob/living/user, message, channel)
	SIGNAL_HANDLER

	if(channel != RADIO_CHANNEL_UPLINK)
		return

	if(!findtext(LOWER_TEXT(message), LOWER_TEXT(unlock_code)))
		if(failsafe_code && findtext(LOWER_TEXT(message), LOWER_TEXT(failsafe_code)))
			failsafe(user)  // no point returning cannot radio, youre probably ded
		return
	locked = FALSE
	interact(null, user)
	to_chat(user, "As you whisper the code into your headset, a soft chime fills your ears.")
	return COMPONENT_CANNOT_USE_RADIO

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
	if(istype(parent,/obj/item/modular_computer))
		unlock_note = "<B>Uplink Passcode:</B> [unlock_code] ([P.name])."
	else if(istype(parent,/obj/item/radio))
		unlock_note = "<B>Radio Passcode:</B> [unlock_code] ([P.name], [RADIO_TOKEN_UPLINK] channel)."
	else if(istype(parent,/obj/item/pen))
		unlock_note = "<B>Uplink Degrees:</B> [english_list(unlock_code)] ([P.name])."

/datum/component/uplink/proc/generate_code()
	var/returnable_code = ""

	if(istype(parent, /obj/item/modular_computer))
		returnable_code = "[rand(100,999)] [pick(GLOB.phonetic_alphabet)]"

	else if(istype(parent, /obj/item/radio))
		returnable_code = pick(GLOB.phonetic_alphabet)

	else if(istype(parent, /obj/item/pen))
		returnable_code = list()
		for(var/i in 1 to PEN_ROTATIONS)
			returnable_code += rand(1, 360)

	if(!unlock_code) // assume the unlock_code is our "base" code that we don't want to duplicate, and if we don't have an unlock code, immediately return out of it since there's nothing to compare to.
		return returnable_code

	// duplicate checking, re-run the proc if we get a dupe to prevent the failsafe explodey code being the same as the unlock code.
	if(islist(returnable_code))
		if(english_list(returnable_code) == english_list(unlock_code)) // we pass english_list to the user anyways and for later processing, so we can just compare the english_list of the two lists.
			return generate_code()

	else if(unlock_code == returnable_code)
		return generate_code()

	return returnable_code

/// Proc that unlocks a locked replacement uplink when it hears the unlock code from their datum
/datum/component/uplink/proc/on_heard(datum/source, list/hearing_args)
	SIGNAL_HANDLER
	if(!locked)
		return
	if(!findtext(hearing_args[HEARING_RAW_MESSAGE], unlock_code))
		return
	var/atom/replacement_uplink = parent
	locked = FALSE
	replacement_uplink.balloon_alert_to_viewers("beep", vision_distance = COMBAT_MESSAGE_RANGE)

/datum/component/uplink/proc/failsafe(atom/source)
	if(!parent)
		return
	var/turf/T = get_turf(parent)
	if(!T)
		return
	var/user_deets = "an uplink failsafe explosion has been triggered"
	if(ismob(source))
		user_deets = "[ADMIN_LOOKUPFLW(source)] has triggered an uplink failsafe explosion"
		source.log_message("triggered an uplink failsafe explosion. Uplink owner: [key_name(owner)].", LOG_ATTACK)
	else if(istype(source, /obj/item/circuit_component))
		var/obj/item/circuit_component/circuit = source
		user_deets = "[circuit.parent.get_creator_admin()] has triggered an uplink failsafe explosion"
	else
		source?.log_message("somehow triggered an uplink failsafe explosion. Uplink owner: [key_name(owner)].", LOG_ATTACK)
	message_admins("[user_deets] at [AREACOORD(T)] The owner of the uplink was [ADMIN_LOOKUPFLW(owner)].")

	explosion(parent, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 3)
	qdel(parent) //Alternatively could brick the uplink.

#undef PEN_ROTATIONS
