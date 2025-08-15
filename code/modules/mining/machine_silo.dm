// Always announce this action
#define ALWAYS_ANNOUNCE (ALL)
// Announced when someone tries to ban someone without QM access
#define BAN_ATTEMPT_FAILURE_NO_ACCESS (1<<1)
// Announced when someone tries to ban someone with QM access without being the Captain
#define BAN_ATTEMPT_FAILURE_CHALLENGING_DA_CHIEF (1<<2)
// Announced when a silicon tries to ban someone
#define BAN_ATTEMPT_FAILURE_SOULLESS_MACHINE (1<<3)
// Announced when a user is banned from the ore silo
#define BAN_CONFIRMATION (1<<4)
// Announced when a user is unbanned from the ore silo
#define UNBAN_CONFIRMATION (1<<5)
// Announced when a suspicious(chameleon ID worn by user) log is Among the ore silo logs and someone tries to ban them
#define FAILED_OPERATION_SUSPICIOUS (1<<6)
// Announced when a user tries to ban someone without a bank account ID
#define FAILED_OPERATION_NO_BANK_ID (1<<7)
// Announced when a user tries to unrestrict the ore silo without QM access
#define UNRESTRICT_FAILURE_NO_ACCESS (1<<8)
// Announced when a silicon tries to unrestrict the ore silo
#define UNRESTRICT_FAILURE_SOULLESS_MACHINE (1<<9)
// Announced when a user removes the worn ID(with valid bank account) requirement from the ore silo
#define UNRESTRICT_CONFIRMATION (1<<10)
// Announced when a user restricts the ore silo to require a valid ID with bank account
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
	///The channels we announce over
	var/list/radio_channels = list(
		RADIO_CHANNEL_COMMON = NONE,
		RADIO_CHANNEL_COMMAND = NONE,
		RADIO_CHANNEL_SUPPLY = NONE,
		RADIO_CHANNEL_SECURITY = NONE,
	)
	var/static/alist/announcement_messages = alist(
		BAN_ATTEMPT_FAILURE_NO_ACCESS = "ACCESS ENFORCEMENT FAILURE: $SILO_USER_NAME lacks supply command authority.",
		BAN_ATTEMPT_FAILURE_CHALLENGING_DA_CHIEF = "ACCESS ENFORCEMENT FAILURE: $SILO_USER_NAME attempting subversion of supply command authority.",
		BAN_ATTEMPT_FAILURE_SOULLESS_MACHINE = "$SILO_USER_NAME INTERFACE_EXCEPTION -> BANNED_USERS+=\[$TARGET_NAME\] => NO_OP",
		BAN_CONFIRMATION = "ACCESS ENFORCEMENT CONFIRMATION\[$SILO_USER_NAME\]: $TARGET_NAME banned from ore silo access.",
		UNBAN_CONFIRMATION = "ACCESS ENFORCEMENT CONFIRMATION\[$SILO_USER_NAME\]: $TARGET_NAME unbanned from ore silo access.",
		FAILED_OPERATION_SUSPICIOUS = "NULL_ACCOUNT_RESOLVE_PTR_#?",
		FAILED_OPERATION_NO_BANK_ID = "ACCESS ENFORCEMENT FAILURE: No account ID found. Please contact a banker.",
		UNRESTRICT_FAILURE_NO_ACCESS = "ID ACCESS REQUIREMENT ENFORCED: $SILO_USER_NAME lacks supply command authority; ID ACCESS REQUIREMENT REMOVAL FAILED.",
		UNRESTRICT_FAILURE_SOULLESS_MACHINE = "$SILO_USER_NAME INTERFACE_EXCEPTION -> ID_ACCESS_REQUIREMENT = !ID_ACCESS_REQUIREMENT => NO_OP",
		RESTRICT_CONFIRMATION = "ID ACCESS REQUIREMENT ROUTINE STARTED: $SILO_USER_NAME has enforced ID read requirement for this ore silo.",
		UNRESTRICT_CONFIRMATION = "ID ACCESS REQUIREMENT ROUTINE SUSPENDED: $SILO_USER_NAME has removed ID read requirement for this ore silo.",
		RESTRICT_FAILURE = "ID ACCESS REQUIREMENT ROUTINE FAILED TO START: $SILO_USER_NAME()"
	)

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
	setup_radio()
	configure_default_announcements_policy()

/obj/machinery/ore_silo/emag_act(mob/living/user)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	return TRUE

/obj/machinery/ore_silo/proc/setup_radio()
	radio = new(src)
	radio.subspace_transmission = TRUE
	radio.canhear_range = 0
	radio.set_listening(FALSE)
	radio.keyslot = new
	radio.keyslot.channels[RADIO_CHANNEL_COMMON] = TRUE
	radio.keyslot.channels[RADIO_CHANNEL_COMMAND] = TRUE
	radio.keyslot.channels[RADIO_CHANNEL_SUPPLY] = TRUE
	radio.keyslot.channels[RADIO_CHANNEL_SECURITY] = TRUE
	radio.recalculateChannels()

/obj/machinery/ore_silo/Destroy()
	if (GLOB.ore_silo_default == src)
		GLOB.ore_silo_default = null

	for(var/datum/component/remote_materials/mats as anything in ore_connected_machines)
		mats.disconnect()

	ore_connected_machines = null
	materials = null
	QDEL_NULL(radio)

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


/**
 * The logic for disconnecting a remote receptacle (RCD, fabricator, etc.) is collected here for sanity's sake
 * rather than being on specific types. Serves to agnosticize the remote_materials component somewhat rather than
 * snowflaking code for silos into the component.
 * * receptacle - The datum/component/remote_materials component that is getting connected.
 * * physical_receptacle - the actual object in the game world that was connected to our material supply. Typed as atom/movable for
 *   future-proofing against anything that may conceivably one day have remote silo access, such as a cyborg, an implant, structures, vehicles,
 *   and so-on.
 */
/obj/machinery/ore_silo/proc/connect_receptacle(datum/component/remote_materials/receptacle, atom/movable/physical_receptacle)
	ore_connected_machines += receptacle
	receptacle.mat_container = src.materials
	receptacle.silo = src
	RegisterSignal(physical_receptacle, COMSIG_ORE_SILO_PERMISSION_CHECKED, PROC_REF(check_permitted))

/**
 * The logic for disconnecting a remote receptacle (RCD, fabricator, etc.) is collected here for sanity's sake
 * rather than being on specific types. Cleans up references to us and to the receptacle.
 * * receptacle - The datum/component/remote_materials component that is getting destroyed.
 * * physical_receptacle - the actual object in the game world that was connected to our material supply. Typed as atom/movable for
 *   future-proofing against anything that may conceivably one day have remote silo access, such as a cyborg, an implant, structures, vehicles,
 *   and so-on.
 */
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
		user_data = ID_DATA(null)
		CRASH("Invalid data passed to check_permitted")
	if(user_data[SILICON_OVERRIDE] || user_data[CHAMELEON_OVERRIDE] || astype(user_data["accesses"], /list)?.Find(ACCESS_QM))
		return COMPONENT_ORE_SILO_ALLOW
	if(user_data[ID_READ_FAILURE])
		physical_receptacle.say("SILO ERR: ID interface failure. Please contact the Head of Personnel.")
		return COMPONENT_ORE_SILO_DENY
	if(!user_data["account_id"] || !isnum(user_data["account_id"]))
		if(prob(5))
			physical_receptacle.say("SILO ERR: Bank account ID not found. Initiating anti-communist silo-access policy.")
		physical_receptacle.say("SILO ERR: No account ID found. Please contact Head of Personnel.")
		return COMPONENT_ORE_SILO_DENY
	if(banned_users.Find(user_data["account_id"]))
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
				"on_hold" = !!holds[remote],
				"location" = get_area_name(parent, TRUE),
			)
		)

	data["logs"] = list()
	for(var/datum/ore_silo_log/entry as anything in GLOB.silo_access_logs[REF(src)])
		data["logs"] += list(
			list(
				"raw_materials" = entry.get_raw_materials(""),
				"machine_name" = entry.machine_name,
				"area_name" = entry.area_name,
				"action" = entry.action,
				"amount" = entry.amount,
				"time" = entry.timestamp,
				"noun" = entry.noun,
				"user_data" = entry.user_data,
			)
		)
	data["banned_users"] = banned_users
	data["ID_required"] = ID_required

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

			remote.disconnect()
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

			materials.retrieve_sheets(amount, ejecting, drop_location(), user_data = ID_DATA(ui.user))
			return TRUE

		if("toggle_ban")
			var/list/banned_user_data = params["user_data"]
			attempt_ban_toggle(usr, banned_user_data)
			return TRUE

		if("toggle_restrict")
			attempt_toggle_restrict(usr)
/**
 * Called from the ore silo's UI, when someone attempts to (un)ban a user from using the ore silo.
 * The person doing the banning should have at least QM access. Unless this is emagged. Not modifiable by silicons unless emagged.
 * Anyone but the Captain attempting to ban someone with QM access from the ore silo gets what is essentially a glorified version
 * of the permission denied result.
 * * user - The person who clicked the ban button in the UI.
 * * target_user_data - Data in the form rendered from ID_DATA(target), passed into the ore silo logs by whatever the target did such
 * 	 as removing/adding sheets, printing items, etc
 */
/obj/machinery/ore_silo/proc/attempt_ban_toggle(mob/living/user, list/target_user_data)
	if(!istype(user) || !istype(target_user_data))
		CRASH("Bad arguments passed to [callee]")
	var/emagged = obj_flags & EMAGGED
	if((isAI(user) || iscyborg(user) || isdrone(user)) && !emagged)
		to_chat(user, span_danger("A scroll of red text occludes your vision: ACCESS ENFORCEMENT _disabled_ for SILICON INTERFACE."))
		user.flash_act(intensity = 1, affect_silicon = TRUE)
		handle_access_action_feedback(
			BAN_ATTEMPT_FAILURE_SOULLESS_MACHINE,
			ID_DATA(user),
			target_user_data
		)
		return

	var/target_bank_id = target_user_data["account_id"]
	var/target_is_banned = banned_users.Find(target_bank_id)
	// Agent card bypasses bans but we want to specially handle them anyway
	// so a bunch of random account IDs don't fill the list and do something
	// like ban people who haven't joined the round yet
	var/haxxor_card_ban_immunity = !isnull(target_user_data[CHAMELEON_OVERRIDE])

	to_chat(user, span_warning("You press the button to [target_is_banned ? "un" : ""]ban [target_user_data["name"]]'s account..."))
	// No feedback if emagged
	if(emagged)
		if(!haxxor_card_ban_immunity && isnum(target_bank_id))
			target_is_banned ? banned_users.Remove(target_bank_id) : banned_users.Add(target_bank_id)
		return

	var/alist/silo_user_data = ID_DATA(user)
	var/list/silo_user_accesses = astype(silo_user_data["accesses"], /list)
	var/list/target_user_accesses = astype(target_user_data["accesses"], /list)


	// Even though QM bypasses the access check (or rather always pases)
	// perhaps the Captain would pre-emptively ban them right before a demotion
	if(target_user_accesses?.Find(ACCESS_QM) && !silo_user_accesses?.Find(ACCESS_CAPTAIN))
		handle_access_action_feedback(
			BAN_ATTEMPT_FAILURE_CHALLENGING_DA_CHIEF,
			silo_user_data,
			target_user_data
		)
		return
	if(!silo_user_accesses?.Find(ACCESS_QM))
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
/**
 * Called from the ore silo tgui interface, for when someone attempts to restrict or unrestrict the ore silo from requiring
 * an ID with an attached bank account (or, a chameleon ID, or, being a silicon)
 * user - the person who tried to toggle the ore silo's access restriction. Needs to be someone with QM access, unless the
 * 	silo is emagged. Shouldn't allow silicons to toggle this unless the silo is emagged.
 *
 */
/obj/machinery/ore_silo/proc/attempt_toggle_restrict(mob/living/user)
	if(!istype(user))
		CRASH("No user to check toggle attempt restrictions. .ID_required is unchanged.")
	var/emagged = obj_flags & EMAGGED
	if(emagged)
		ID_required = !ID_required
		return
	var/alist/silo_user_data = ID_DATA(user)
	var/is_a_robot = silo_user_data[SILICON_OVERRIDE]
	if(is_a_robot)
		handle_access_action_feedback(
			UNRESTRICT_FAILURE_SOULLESS_MACHINE,
			silo_user_data,
			null
		)
		return
	var/list/user_accesses = astype(silo_user_data["accesses"], /list)
	if(!user_accesses?.Find(ACCESS_QM))
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

// I must sacrifice the line diff to the gods of readable code
/// Set up the default announcement policy for actions
/// radio_channels[channel_name_key] = policy_bitmask
/// where channel_name_key is one of RADIO_CHANNEL_(COMMON|COMMAND|SECURITY|SUPPLY)
/// and policy_bitmask is a bitmask of actions that will be announced on that channel
/// by default
/obj/machinery/ore_silo/proc/configure_default_announcements_policy()

	radio_channels[RADIO_CHANNEL_COMMON] = BAN_ATTEMPT_FAILURE_CHALLENGING_DA_CHIEF
	radio_channels[RADIO_CHANNEL_COMMON] |= RESTRICT_CONFIRMATION
	radio_channels[RADIO_CHANNEL_COMMON] |= UNRESTRICT_CONFIRMATION

	// start off with the common channel bitmask policy as a base
	radio_channels[RADIO_CHANNEL_COMMAND] = radio_channels[RADIO_CHANNEL_COMMON]
	radio_channels[RADIO_CHANNEL_COMMAND] |= BAN_ATTEMPT_FAILURE_NO_ACCESS
	radio_channels[RADIO_CHANNEL_COMMAND] |= BAN_ATTEMPT_FAILURE_SOULLESS_MACHINE
	radio_channels[RADIO_CHANNEL_COMMAND] |= UNRESTRICT_FAILURE_NO_ACCESS
	radio_channels[RADIO_CHANNEL_COMMAND] |= UNRESTRICT_FAILURE_SOULLESS_MACHINE
	radio_channels[RADIO_CHANNEL_COMMAND] |= FAILED_OPERATION_NO_BANK_ID
	radio_channels[RADIO_CHANNEL_COMMAND] |= BAN_CONFIRMATION
	radio_channels[RADIO_CHANNEL_COMMAND] |= UNBAN_CONFIRMATION

	// Security channel is used for security-related announcements
	// but gets less information than command to avoid over-informing them without
	// QM involvement
	radio_channels[RADIO_CHANNEL_SECURITY] = radio_channels[RADIO_CHANNEL_COMMON]
	radio_channels[RADIO_CHANNEL_SECURITY] |= BAN_ATTEMPT_FAILURE_NO_ACCESS
	radio_channels[RADIO_CHANNEL_SECURITY] |= UNRESTRICT_FAILURE_NO_ACCESS
	radio_channels[RADIO_CHANNEL_SECURITY] |= BAN_CONFIRMATION
	radio_channels[RADIO_CHANNEL_SECURITY] |= UNBAN_CONFIRMATION

	// Supply channel has the same policy by default as the command channel
	// due to their usual purview of the ore silo
	radio_channels[RADIO_CHANNEL_SUPPLY] = radio_channels[RADIO_CHANNEL_COMMAND]

/obj/machinery/ore_silo/proc/handle_access_action_feedback(action, alist/silo_user_data, list/target_user_data = null)
	var/message = announcement_messages[action]
	message = replacetext(message, "$TARGET_NAME", target_user_data?["name"])
	message = replacetext(message, "$SILO_USER_NAME", silo_user_data["name"])
	say(message)
	for(var/channel in radio_channels)
		// Key is the channel name, value is the bitmask of announced actions
		if(action & radio_channels[channel])
			var/say_cooldown_adherence_timer = 1 SECONDS * radio_channels.Find(channel) // * 1, * 2, * 3, etc.
			addtimer(CALLBACK(radio, TYPE_PROC_REF(/obj/item, talk_into), src, message, channel), say_cooldown_adherence_timer)

#undef ALWAYS_ANNOUNCE
#undef BAN_ATTEMPT_FAILURE_NO_ACCESS
#undef BAN_ATTEMPT_FAILURE_CHALLENGING_DA_CHIEF
#undef BAN_ATTEMPT_FAILURE_SOULLESS_MACHINE
#undef BAN_CONFIRMATION
#undef UNBAN_CONFIRMATION
#undef FAILED_OPERATION_SUSPICIOUS
#undef FAILED_OPERATION_NO_BANK_ID
#undef UNRESTRICT_FAILURE_NO_ACCESS
#undef UNRESTRICT_FAILURE_SOULLESS_MACHINE
#undef UNRESTRICT_CONFIRMATION
#undef RESTRICT_CONFIRMATION

/**
 * Creates a log entry for depositing/withdrawing from the silo both ingame and in text based log
 *
 * Arguments:
 * - [M][/obj/machinery]: The machine performing the action.
 * - action: Text that visually describes the action (smelted/deposited/resupplied...)
 * - amount: The amount of sheets/objects deposited/withdrawn by this action. Positive for depositing, negative for withdrawing.
 * - noun: Name of the object the action was performed with (sheet, units, ore...)
 * - [mats][list]: Assoc list in format (material datum = amount of raw materials). Wants the actual amount of raw (iron, glass...) materials involved in this action. If you have 10 metal sheets each worth 100 iron you would pass a list with the iron material datum = 1000
 * - user_data - ID_DATA(user), includes details (not currently) rendered to the player, such as bank account #, see the proc on SSid_access
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
		"[machine_name] in \[[AREACOORD(M)]\] [action] [abs(amount)]x [noun] | [get_raw_materials("")] | [user_data["name"]]",
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
		var/val = round(materials[key]) / SHEET_MATERIAL_AMOUNT
		msg += separator
		separator = ", "
		msg += "[amount < 0 ? "-" : "+"][val] [M.name]"
	return msg.Join()
