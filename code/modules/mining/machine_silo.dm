#define ALWAYS_ANNOUNCE (ALL)
#define BAN_ATTEMPT_FAILURE_NO_ACCESS (1<<1)
#define BAN_ATTEMPT_FAILURE_CHALLENGING_DA_CHIEF (1<<2)
#define BAN_ATTEMPT_FAILURE_SOULLESS_MACHINE (1<<3)
#define BAN_CONFIRMATION (1<<4)
#define UNBAN_CONFIRMATION (1<<5)
#define FAILED_OPERATION_SUSPICIOUS (1<<6)
#define FAILED_OPERATION_NO_BANK_ID (1<<7)
#define UNRESTRICT_FAILURE_NO_ACCESS (1<<8)
#define UNRESTRICT_FAILURE_SOULLESS_MACHINE (1<<9)
#define UNRESTRICT_CONFIRMATION (1<<10)
#define RESTRICT_CONFIRMATION (1<<11)

/obj/machinery/ore_silo
	name = "ore silo"
	desc = "An all-in-one bluespace storage and transmission system for the station's mineral distribution needs."
	icon = 'icons/obj/machines/ore_silo.dmi'
	icon_state = "silo"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/ore_silo
	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN|INTERACT_MACHINE_ALLOW_SILICON|INTERACT_MACHINE_OPEN_SILICON
	processing_flags = NONE

	/// By default, an ore silo requires you to be wearing an ID to pull materials from it.
	var/ID_required = TRUE
	/// List of all connected components that are on hold from accessing materials.
	var/list/holds = list()
	/// List of all components that are sharing ores with this silo.
	var/list/datum/component/remote_materials/ore_connected_machines = list()
	/// Material Container
	var/datum/component/material_container/materials
	/// A list of names of bank account IDs that are banned from using this ore silo.
	var/list/banned_users = list()
	///The machine's internal radio, used to broadcast alerts.
	var/obj/item/radio/radio
	///The channel we announce a siphon over.
	var/list/radio_channels = list(
		RADIO_CHANNEL_COMMON = NONE,
		RADIO_CHANNEL_COMMAND = NONE,
		RADIO_CHANNEL_SUPPLY = NONE,
		RADIO_CHANNEL_SECURITY = NONE,
	)
	var/static/alist/announcement_messages = alist(
		BAN_ATTEMPT_FAILURE_NO_ACCESS = "ACCESS ENFORCEMENT FAILURE: You lack SUPPLY_COMMAND_AUTHORITY.",
		BAN_ATTEMPT_FAILURE_CHALLENGING_DA_CHIEF = "ACCESS ENFORCEMENT FAILURE: You are challenging the authority of the Director of Administration.",
		BAN_ATTEMPT_FAILURE_SOULLESS_MACHINE = "ACCESS ENFORCEMENT FAILURE: You are a soulless machine.",
		BAN_CONFIRMATION = "ACCESS ENFORCEMENT CONFIRMATION: [banned_user_data["Name"]] banned from ore silo access.",
		UNBAN_CONFIRMATION = "ACCESS ENFORCEMENT REPRIEVE: [banned_user_data["Name"]] granted UNRESTRICTED status.",
		FAILED_OPERATION_SUSPICIOUS = "ACCESS ENFORCEMENT FAILURE: Suspicious activity detected. Please contact a banker.",
		FAILED_OPERATION_NO_BANK_ID = "ACCESS ENFORCEMENT FAILURE: No account ID found. Please contact a banker.",
		UNRESTRICT_FAILURE_NO_ACCESS = "ACCESS ENFORCEMENT FAILURE: You lack SUPPLY_COMMAND_AUTHORITY to unrestrict this ore silo.",
		UNRESTRICT_FAILURE_SOULLESS_MACHINE = "ACCESS ENFORCEMENT FAILURE: You are a soulless machine, you cannot unrestrict this ore silo.",
		RESTRICT_CONFIRMATION = "Ore Silo restricted to [banned_user_data["Name"]]'s account ID [banned_user_data["Account ID"]].",
		RESTRICT_FAILURE = "Ore Silo restriction failed, please contact a banker."
	)
	var/static/alist/feedback_sound_params = alist()



/obj/machinery/ore_silo/Initialize(mapload)
	. = ..()
	materials = AddComponent( \
		/datum/component/material_container, \
		SSmaterials.materials_by_category[MAT_CATEGORY_SILO], \
		INFINITY, \
		MATCONTAINER_EXAMINE, \
		container_signals = list( \
			COMSIG_MATCONTAINER_ITEM_CONSUMED = TYPE_PROC_REF(/obj/machinery/ore_silo, on_item_consumed), \
			COMSIG_MATCONTAINER_SHEETS_RETRIEVED = TYPE_PROC_REF(/obj/machinery/ore_silo, log_sheets_ejected), \
		), \
		allowed_items = /obj/item/stack \
	)
	if (!GLOB.ore_silo_default && mapload && is_station_level(z))
		GLOB.ore_silo_default = src
	register_context()
	radio = new(src)
	radio.subspace_transmission = TRUE
	radio.canhear_range = 0
	radio.set_listening(FALSE)
	radio.recalculateChannels()
	configure_default_announcements_policy()
	// Setting up a global list for this static list of sound parameters would be a waste
	feedback_sound_params['INITIALIZED'] || configure_feedback_sound_params()

/obj/machinery/ore_silo/proc/configure_feedback_sound_params()
	feedback_sound_params[BAN_ATTEMPT_FAILURE_NO_ACCESS] = alist(
		iterations = 3,
		intervals = 0.5 SECONDS,
		soundin = 'sound/machines/scanner/scanbuzz.ogg',
		vol = 100,
		vary = TRUE, frequency = 1.8)
	feedback_sound_params[BAN_ATTEMPT_FAILURE_CHALLENGING_DA_CHIEF] = alist(
		iterations = 3,
		intervals = 1.5 SECONDS,
		soundin = sound('sound/machines/warning-buzzer.ogg', pitch = 0.5),
		vol = 100,
		vary = TRUE, extrarange = 21, frequency = 0.2)
	feedback_sound_params[BAN_CONFIRMATION] = alist(
		iterations = 1,
		intervals = 0 SECONDS,
		soundin = sound('sound/machines/chime.ogg', pitch = 0.25),
		vol = 50,
		vary = TRUE, frequency = 1.5)
	feedback_sound_params[UNBAN_CONFIRMATION] = alist(
		iterations = 1,
		intervals = 0 SECONDS,
		soundin = 'sound/machines/chime.ogg',
		vol = 50,
		vary = TRUE)
	feedback_sound_params[UNRESTRICT_FAILURE_NO_ACCESS] = alist(
		iterations = 3,
		intervals = 0.5 SECONDS,
		soundin = 'sound/machines/scanner/scanbuzz.ogg',
		vol = 100,
		vary = TRUE, frequency = 1.8)
	feedback_sound_params[RESTRICT_CONFIRMATION]= alist(
		iterations = 1,
		intervals = 0 SECONDS,
		soundin = sound('sound/machines/chime.ogg', pitch = 2),
		vol=50,
		vary=TRUE)
	feedback_sound_params['INITIALIZED'] = TRUE

/obj/machinery/ore_silo/Destroy()
	if (GLOB.ore_silo_default == src)
		GLOB.ore_silo_default = null

	for(var/datum/component/remote_materials/mats as anything in ore_connected_machines)
		mats.disconnect_from(src)

	ore_connected_machines = null
	materials = null

	return ..()

/obj/machinery/ore_silo/examine(mob/user)
	. = ..()
	. += span_notice("It can be linked to techfabs, circuit printers and protolathes with a multitool.")
	. += span_notice("Its maintainence panel can be [EXAMINE_HINT("screwed")] [panel_open ? "closed" : "open"].")
	if(panel_open)
		. += span_notice("The whole machine can be [EXAMINE_HINT("pried")] apart.")

/obj/machinery/ore_silo/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = NONE
	if(isnull(held_item))
		return

	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Close" : "Open"] Panel"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item.tool_behaviour == TOOL_MULTITOOL)
		context[SCREENTIP_CONTEXT_LMB] = "Log Silo"
		return CONTEXTUAL_SCREENTIP_SET

	if(panel_open && held_item.tool_behaviour == TOOL_CROWBAR)
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/ore_silo/proc/on_item_consumed(datum/component/material_container/container, obj/item/item_inserted, last_inserted_id, mats_consumed, amount_inserted, atom/context, alist/user_data)
	SIGNAL_HANDLER

	silo_log(context, "DEPOSIT", amount_inserted, item_inserted.name, mats_consumed, user_data)

	SEND_SIGNAL(context, COMSIG_SILO_ITEM_CONSUMED, container, item_inserted, last_inserted_id, mats_consumed, amount_inserted)

/obj/machinery/ore_silo/proc/log_sheets_ejected(datum/component/material_container/container, obj/item/stack/sheet/sheets, atom/context, alist/user_data)
	SIGNAL_HANDLER

	silo_log(context, "EJECT", -sheets.amount * SHEET_MATERIAL_AMOUNT, "[sheets.singular_name]", sheets.custom_materials, user_data)

/obj/machinery/ore_silo/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/ore_silo/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/ore_silo/multitool_act(mob/living/user, obj/item/multitool/I)
	I.set_buffer(src)
	balloon_alert(user, "saved to multitool buffer")
	return ITEM_INTERACT_SUCCESS

/obj/machinery/ore_silo/proc/connect_receptacle(datum/component/remote_materials/receptacle, atom/movable/physical_receptacle)
	ore_connected_machines += receptacle
	receptacle.mat_container = src.materials
	receptacle.silo = src
	RegisterSignal(physical_receptacle, COMSIG_ORE_SILO_PERMISSION_CHECKED, PROC_REF(check_permitted))

/obj/machinery/ore_silo/proc/disconnect_receptacle(datum/component/remote_materials/receptacle, atom/movable/physical_receptacle)
	ore_connected_machines -= receptacle
	receptacle.mat_container = null
	receptacle.silo = null
	holds -= receptacle
	UnregisterSignal(physical_receptacle, COMSIG_ORE_SILO_PERMISSION_CHECKED)

/obj/machinery/ore_silo/proc/check_permitted(datum/source, alist/user_data, atom/movable/physical_receptacle)
	SIGNAL_HANDLER

	if(!ID_required)
		return COMPONENT_ORE_SILO_ALLOW
	if(!islist(user_data))
		// Just allow to salvage the situation
		. = COMPONENT_ORE_SILO_ALLOW
		CRASH("Invalid data passed to check_permitted")
	if(user_data[SILICON_OVERRIDE] || user_data[CHAMELEON_OVERRIDE] || astype(user_data["Accesses"], /list)?.Find(ACCESS_QM))
		return COMPONENT_ORE_SILO_ALLOW
	if(user_data[ID_READ_FAILURE])
		physical_receptacle.say("SILO ERR: ID interface failure. Please contact the Head of Personnel.")
		return COMPONENT_ORE_SILO_DENY
	if(!user_data["Account ID"] || !isnum(user_data["Account ID"]))
		if(prob(5))
			physical_receptacle.say("SILO ERR: Bank account ID not found. Initiating anti-communist silo-access policy.")
		physical_receptacle.say("SILO ERR: No account ID found. Please contact a banker.")
		return COMPONENT_ORE_SILO_DENY
	if(banned_users.Find(user_data["Account ID"]))
		physical_receptacle.say("SILO ERR: You are banned from using this ore silo.")
		return COMPONENT_ORE_SILO_DENY
	return COMPONENT_ORE_SILO_ALLOW

/obj/machinery/ore_silo/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet_batched/sheetmaterials)
	)

/obj/machinery/ore_silo/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OreSilo", "Ore Silo Control")
		ui.open()

/obj/machinery/ore_silo/ui_static_data(mob/user)
	return materials.ui_static_data()

/obj/machinery/ore_silo/ui_data(mob/user)
	var/list/data = list()

	data["materials"] =  materials.ui_data()

	data["machines"] = list()
	for(var/datum/component/remote_materials/remote as anything in ore_connected_machines)
		var/atom/parent = remote.parent
		data["machines"] += list(
			list(
				"icon" = icon2base64(icon(initial(parent.icon), initial(parent.icon_state), frame = 1)),
				"name" = parent.name,
				"onHold" = !!holds[remote],
				"location" = get_area_name(parent, TRUE),
			)
		)

	data["logs"] = list()
	for(var/datum/ore_silo_log/entry as anything in GLOB.silo_access_logs[REF(src)])
		data["logs"] += list(
			list(
				"rawMaterials" = entry.get_raw_materials(""),
				"machineName" = entry.machine_name,
				"areaName" = entry.area_name,
				"action" = entry.action,
				"amount" = entry.amount,
				"time" = entry.timestamp,
				"noun" = entry.noun,
				"user_data" = entry.user_data,
			)
		)
	data["banned_users"] = banned_users

	return data

/obj/machinery/ore_silo/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("remove")
			var/index = params["id"]
			if(isnull(index))
				return

			index = text2num(index)
			if(isnull(index))
				return

			var/datum/component/remote_materials/remote = ore_connected_machines[index]
			if(isnull(remote))
				return

			remote.disconnect_from(src)
			return TRUE

		if("hold")
			var/index = params["id"]
			if(isnull(index))
				return

			index = text2num(index)
			if(isnull(index))
				return

			var/datum/component/remote_materials/remote = ore_connected_machines[index]
			if(isnull(remote))
				return

			remote.toggle_holding()
			return TRUE

		if("eject")
			var/datum/material/ejecting = locate(params["ref"])
			if(!istype(ejecting))
				return

			var/amount = params["amount"]
			if(isnull(amount))
				return

			amount = text2num(amount)
			if(isnull(amount))
				return

			materials.retrieve_sheets(amount, ejecting, drop_location(), user_data = ID_DATA(usr))
			return TRUE

		if("toggle_ban")
			var/list/banned_user_data = params["user_data"]
			attempt_ban_toggle(usr, banned_user_data)
			return TRUE

		if("toggle_restrict")
			attempt_toggle_restrict(usr)

/obj/machinery/ore_silo/proc/attempt_ban_toggle(mob/living/user, list/target_user_data)
	if(!istype(user) || !istype(target_user_data))
		CRASH("Bad arguments passed to [callee]")
	if(!isnull(target_user_data[SILICON_OVERRIDE]) || !isnull(target_user_data[ID_READ_FAILURE]))
		// this shouldn't ever happen
		CRASH("Bad proc call to [callee] from [caller].")
	if(isAI(user) || iscyborg(user) || isdrone(user))
		if(emagged)
			var/target_bank_id = target_user_data["Account ID"]
			if(!target_bank_id || !isnum(target_bank_id))
				return
			banned_users.Find(target_bank_id) ? banned_users.Remove(target_bank_id) : banned_users.Add(target_bank_id)
			return
		to_chat(user, span_danger("A scroll of red text occludes your vision: ACCESS ENFORCEMENT _disabled_ for SILICON INTERFACE."))
		user.flash_act(intensity = 1, affect_silicon = TRUE)
		handle_access_action_feedback(
			BAN_ATTEMPT_FAILURE_SOULLESS_MACHINE,
			ID_DATA(user),
			target_user_data
		)
		return

	var/target_bank_id = target_user_data["Account ID"]
	var/target_is_banned = !!(banned_users.Find(target_bank_id))

	to_chat(user, span_warning("You press the button to [target_is_banned ? "un" : ""]ban [banned_user_data["Name"]]'s account..."))
	// No feedback if emagged
	if(emagged)
		target_is_banned ? banned_users.Remove(target_bank_id) : banned_users.Add(target_bank_id)
		return

	var/alist/silo_user_data = ID_DATA(user)
	var/list/silo_user_accesses = astype(silo_user_data["Accesses"], /list)
	var/list/target_user_accesses = astype(target_user_data["Accesses"], /list)
	// Agent card bypasses bans but we want to specially handle them anyway
	// so a bunch of random account IDs don't fill the list and do something
	// like ban people who haven't joined the round yet
	var/haxxor_card_ban_immunity = !isnull(target_user_data[CHAMELEON_OVERRIDE])


	// Even though QM bypasses the access check (or rather always pases)
	// perhaps the Captain would pre-emptively ban them right before a demotion
	if(target_user_accesses.Find(ACCESS_QM) && !silo_user_accesses.Find(ACCESS_CAPTAIN))
		handle_access_action_feedback(
			BAN_ATTEMPT_FAILURE_CHALLENGING_DA_CHIEF,
			silo_user_data,
			target_user_data
		)
		return
	if(!silo_user_accesses.Find(ACCESS_QM))
		handle_access_action_feedback(
			BAN_ATTEMPT_FAILURE_NO_ACCESS,
			silo_user_data,
			target_user_data
		)
		return
	if(haxxor_card_ban_immunity)
		handle_access_action_feedback(
			FAILED_OPERATION_SUSPICIOUS,
			silo_user_data,
			target_user_data
		)
		return
	if(!target_bank_id || !isnum(target_bank_id))
		handle_access_action_feedback(
			FAILED_OPERATION_NO_BANK_ID,
			silo_user_data,
			target_user_data
		)
		return
	if(target_is_banned)
		banned_users.Remove(target_bank_id)
		handle_access_action_feedback(
			UNBAN_CONFIRMATION,
			silo_user_data,
			target_user_data
		)
		return
	// If we got here, we are banning the user
	banned_users.Add(target_bank_id)
	handle_access_action_feedback(
		BAN_CONFIRMATION,
		silo_user_data,
		target_user_data
	)

/obj/machinery/ore_silo/proc/attempt_toggle_restrict(mob/living/user)
	if(!istype(user))
		CRASH()
	var/alist/silo_user_data = ID_DATA(user)
	if(emagged)
		ID_required = !ID_required
		return
	var/is_a_robot = !!silo_user_data[SILICON_OVERRIDE]
	if(is_a_robot)
		handle_access_action_feedback(
			UNRESTRICT_FAILURE_SOULLESS_MACHINE,
			silo_user_data,
			null
		)
		return
	var/list/user_accesses = astype(silo_user_data["Accesses"], /list)
	if(!user_accesses.Find(ACCESS_QM))
		handle_access_action_feedback(
			UNRESTRICT_FAILURE_NO_ACCESS,
			silo_user_data,
			null
		)
		return
	ID_required = !ID_required
	handle_access_action_feedback(
		ID_required ? RESTRICT_CONFIRMATION : UNRESTRICT_CONFIRMATION,
		silo_user_data,
		null)

// Forgive me for how many lines this adds but I wanted to spare them of horizontal scrolling
/obj/machinery/ore_silo/proc/configure_default_announcements_policy()

	radio_channels[RADIO_CHANNEL_COMMON] = DEFAULT_COMMON_POLICY

	radio_channels[RADIO_CHANNEL_COMMAND] = DEFAULT_COMMAND_POLICY

	radio_channels[RADIO_CHANNEL_SECURITY] = DEFAULT_SECURITY_POLICY

	radio_channels[RADIO_CHANNEL_SUPPLY] = DEFAULT_SUPPLY_POLICY

/obj/machinery/ore_silo/proc/handle_access_action_feedback(action, alist/silo_user_data, list/target_user_data = null)
	switch(action)
		if(BAN_ATTEMPT_FAILURE_NO_ACCESS)
			say("ACCESS ENFORCEMENT FAILURE: [current_user_data["Name"]] lacks SUPPLY_COMMAND_AUTHORITY.")

	playsound(source = src, soundin = 'sound/effects/adminhelp.ogg',
		vol = 50,
		vary = TRUE, frequency = 2)
	say("ACCESS ENFORCEMENT CONFIRMATION: [banned_user_data["Name"]] banned from ore silo access.")
	playsound(src, 'sound/machines/chime.ogg',
		 50, FALSE)
	say("WARNING. Possible COMMAND AUTHORITY SUBVERSIVE [silo_user_data["Name"]] present at [get_area(src)].")
	playsound(source = src, soundin = 'sound/machines/scanner/scanbuzz.ogg',
		vol = 100,
		vary = TRUE, extrarange = 21/*Three screen lengths away*/, frequency = 0.2)
	say("ACCESS ENFORCEMENT REPRIEVE: [banned_user_data["Name"]] granted UNRESTRICTED status.")
/obj/machinery/ore_silo/proc/sound_feedback(action)
	playsound(source = src, soundin = 'sound/machines/scanner/scanbuzz.ogg',
		vol = 100,
		vary = TRUE, frequency = 1.8)

/**
 * Creates a log entry for depositing/withdrawing from the silo both ingame and in text based log
 *
 * Arguments:
 * - [M][/obj/machinery]: The machine performing the action.
 * - action: Text that visually describes the action (smelted/deposited/resupplied...)
 * - amount: The amount of sheets/objects deposited/withdrawn by this action. Positive for depositing, negative for withdrawing.
 * - noun: Name of the object the action was performed with (sheet, units, ore...)
 * - [mats][list]: Assoc list in format (material datum = amount of raw materials). Wants the actual amount of raw (iron, glass...) materials involved in this action. If you have 10 metal sheets each worth 100 iron you would pass a list with the iron material datum = 1000
 */
/obj/machinery/ore_silo/proc/silo_log(obj/machinery/M, action, amount, noun, list/mats, alist/user_data)
	if (!length(mats))
		return

	var/datum/ore_silo_log/entry = new(M, action, amount, noun, mats, user_data)
	var/list/datum/ore_silo_log/logs = GLOB.silo_access_logs[REF(src)]
	if(!LAZYLEN(logs))
		GLOB.silo_access_logs[REF(src)] = logs = list(entry)
	else if(!logs[1].merge(entry))
		logs.Insert(1, entry)

	flick("silo_active", src)

///The log entry for an ore silo action
/datum/ore_silo_log
	///The time of action
	var/timestamp
	///The name of the machine that remotely acted on the ore silo
	var/machine_name
	///The area of the machine that remotely acted on the ore silo
	var/area_name
	///The actual action performed by the machine
	var/action
	///An short verb describing the action
	var/noun
	///The amount of items affected by this action e.g. print quantity, sheets ejected etc.
	var/amount
	///List of individual materials used in the action
	var/list/materials
	var/alist/user_data

/datum/ore_silo_log/New(obj/machinery/M, _action, _amount, _noun, list/mats=list(), alist/user_data)
	timestamp = station_time_timestamp()
	machine_name = M.name
	area_name = get_area_name(M, TRUE)
	action = _action
	amount = _amount
	noun = _noun
	materials = mats.Copy()
	src.user_data = user_data
	var/list/data = list(
		"machine_name" = machine_name,
		"area_name" = AREACOORD(M),
		"action" = action,
		"amount" = abs(amount),
		"noun" = noun,
		"raw_materials" = get_raw_materials(""),
		"direction" = amount < 0 ? "withdrawn" : "deposited",
		"user_data" = user_data,
	)
	logger.Log(
		LOG_CATEGORY_SILO,
		"[machine_name] in \[[AREACOORD(M)]\] [action] [abs(amount)]x [noun] | [get_raw_materials("")] | [user_data["Name"]]",
		data,
	)

/**
 * Merges a silo log entry with this one
 * Arguments
 *
 * * datum/ore_silo_log/other - the other silo entry we are trying to merge with this one
 */
/datum/ore_silo_log/proc/merge(datum/ore_silo_log/other)
	if (other == src || action != other.action || noun != other.noun)
		return FALSE
	if (machine_name != other.machine_name || area_name != other.area_name)
		return FALSE

	timestamp = other.timestamp
	amount += other.amount
	for(var/each in other.materials)
		materials[each] += other.materials[each]
	return TRUE

/**
 * Returns list/materials but with each entry joined by an seperator to create 1 string
 * Arguments
 *
 * * separator - the string used to concatenate all entries in list/materials
 */
/datum/ore_silo_log/proc/get_raw_materials(separator)
	var/list/msg = list()
	for(var/key in materials)
		var/datum/material/M = key
		var/val = round(materials[key]) / 100
		msg += separator
		separator = ", "
		msg += "[amount < 0 ? "-" : "+"][val] [M.name]"
	return msg.Join()
