#define MENU_OPERATION 1
#define MENU_SURGERIES 2

/obj/machinery/computer/operating
	name = "operating computer"
	desc = "Monitors patient vitals and displays surgery steps. Can be loaded with surgery disks to perform experimental procedures. Automatically syncs to operating tables within its line of sight for surgical tech advancement."
	icon_screen = "crew"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/computer/operating
	interaction_flags_machine = parent_type::interaction_flags_machine | INTERACT_MACHINE_REQUIRES_STANDING

	light_color = LIGHT_COLOR_GREEN

	/// Linked operating table, if any
	var/obj/structure/table/optable/table
	/// List if surgery typepaths available on this computer
	var/list/advanced_surgeries = list()
	/// Techweb linked to this operating computer
	var/datum/techweb/linked_techweb
	/// Currently selected body zone for surgery
	var/target_zone = BODY_ZONE_CHEST
	/// Experiment handler component reference
	var/datum/component/experiment_handler/experiment_handler
	/// Lazyassoclist of mob weakrefs to the zone they had selected when opening the UI
	/// When closing the UI we try to revert their zone selector to that zone
	var/list/datum/weakref/zone_on_open

/obj/machinery/computer/operating/Initialize(mapload)
	. = ..()
	find_table()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/operating/post_machine_initialize()
	. = ..()
	if(!CONFIG_GET(flag/no_default_techweb_link) && !linked_techweb)
		CONNECT_TO_RND_SERVER_ROUNDSTART(linked_techweb, src)

	if(linked_techweb)
		RegisterSignal(linked_techweb, COMSIG_TECHWEB_ADD_DESIGN, PROC_REF(on_techweb_research))
		RegisterSignal(linked_techweb, COMSIG_TECHWEB_REMOVE_DESIGN, PROC_REF(on_techweb_unresearch))
		RegisterSignal(linked_techweb, COMSIG_TECHWEB_EXPERIMENT_COMPLETED, PROC_REF(update_static_data_batched))

		for(var/datum/design/surgery/design in linked_techweb.get_researched_design_datums())
			advanced_surgeries |= design.surgery

	var/list/operating_signals = list(
		COMSIG_OPERATING_COMPUTER_AUTOPSY_COMPLETE = TYPE_PROC_REF(/datum/component/experiment_handler, try_run_autopsy_experiment),
	)
	experiment_handler = AddComponent(
		/datum/component/experiment_handler, \
		allowed_experiments = list(/datum/experiment/autopsy), \
		config_flags = EXPERIMENT_CONFIG_ALWAYS_ACTIVE, \
		config_mode = EXPERIMENT_CONFIG_ALTCLICK, \
		experiment_signals = operating_signals, \
	)

/obj/machinery/computer/operating/Destroy()
	for(var/direction in GLOB.alldirs)
		table = locate(/obj/structure/table/optable) in get_step(src, direction)
		if(table && table.computer == src)
			table.computer = null
	QDEL_NULL(experiment_handler)
	return ..()

/obj/machinery/computer/operating/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(!QDELETED(tool.buffer) && istype(tool.buffer, /datum/techweb))
		linked_techweb = tool.buffer
	return TRUE

/obj/machinery/computer/operating/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/disk/surgery))
		user.visible_message(
			span_notice("[user] begins to load [tool] in [src]..."),
			span_notice("You begin to load a surgery protocol from [tool]..."),
			span_hear("You hear the chatter of a floppy drive."),
		)
		var/obj/item/disk/surgery/disky = tool
		if(!do_after(user, 1 SECONDS, src))
			return ITEM_INTERACT_BLOCKING
		advanced_surgeries |= disky.surgeries
		update_static_data_for_all_viewers()
		playsound(src, 'sound/machines/compiler/compiler-stage2.ogg', 50, FALSE, SILENCED_SOUND_EXTRARANGE)
		balloon_alert(user, "surgeries loaded")
		return ITEM_INTERACT_SUCCESS

	if((tool.item_flags & SURGICAL_TOOL) && !user.combat_mode)
		ui_interact(user)
		return ITEM_INTERACT_SUCCESS

	return NONE

/obj/machinery/computer/operating/on_set_is_operational(old_value)
	update_static_data_for_all_viewers()

/obj/machinery/computer/operating/proc/find_table()
	for(var/direction in GLOB.alldirs)
		table = locate(/obj/structure/table/optable) in get_step(src, direction)
		if(table)
			table.computer = src
			break

/obj/machinery/computer/operating/ui_status(mob/user, datum/ui_state/state)
	. = ..()
	if(isliving(user))
		. = min(., ui_check(user))

/// Checks for special ui state conditions
/obj/machinery/computer/operating/proc/ui_check(mob/living/user)
	// lower states should be checked first

	// normally machines revert to "disabled" when non-operational,
	// but here we outright close it so people can't gleam extra info
	if(!is_operational)
		return UI_CLOSE
	// if you're knocked out, ie anesthetic... definitely a no-go
	if(user.stat >= UNCONSCIOUS || HAS_TRAIT(user, TRAIT_KNOCKEDOUT))
		return UI_CLOSE
	// the patient itself should be blocked from viewing the computer
	if(user.body_position == LYING_DOWN)
		return (user.loc == table?.loc) ? UI_CLOSE : UI_DISABLED
	// we have a tight range check so people can't spy on surgeries from across the room
	// likewise it'd be pretty lame if you could see what was going on while incapacitated
	if(get_dist(user, src) > 2 || user.incapacitated)
		return UI_DISABLED

	return UI_INTERACTIVE

/obj/machinery/computer/operating/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		return

	if(ishuman(user))
		// if you are the first human to open the ui, it changes to your active zone
		if(!LAZYLEN(zone_on_open))
			target_zone = user.zone_selected
		// then we record what you were looking at for when you close it
		LAZYSET(zone_on_open, WEAKREF(user), user.zone_selected)

	ui = new(user, src, "OperatingComputer", name)
	ui.open()

/obj/machinery/computer/operating/ui_close(mob/user)
	. = ..()
	// reverts zone to whatever you had going into it, typically chest, so you don't have to mess around with it
	var/zone_found = LAZYACCESS(zone_on_open, WEAKREF(user))
	if(!zone_found)
		return

	var/atom/movable/screen/zone_sel/selector = user.hud_used?.zone_select
	selector?.set_selected_zone(zone_found, user, FALSE)
	LAZYREMOVE(zone_on_open, WEAKREF(user))
	if(!LAZYLEN(zone_on_open))
		zone_on_open = initial(zone_on_open)

/obj/machinery/computer/operating/ui_assets(mob/user)
	. = ..()
	. += get_asset_datum(/datum/asset/simple/body_zones)

/obj/machinery/computer/operating/ui_data(mob/user)
	var/list/data = list()

	data["has_table"] = !!table
	data["target_zone"] = target_zone
	if(isnull(table?.patient))
		return data

	data["patient"] = list()
	var/mob/living/carbon/patient = table.patient

	switch(patient.stat)
		if(CONSCIOUS)
			data["patient"]["stat"] = "Conscious"
			data["patient"]["statstate"] = "good"
		if(SOFT_CRIT)
			data["patient"]["stat"] = "Critical Condition"
			data["patient"]["statstate"] = "average"
		if(UNCONSCIOUS, HARD_CRIT)
			data["patient"]["stat"] = "Unconscious"
			data["patient"]["statstate"] = "average"
		if(DEAD)
			data["patient"]["stat"] = "Dead"
			data["patient"]["statstate"] = "bad"
	data["patient"]["health"] = patient.health
	data["patient"]["blood_type"] = patient.get_bloodtype()?.name || "UNKNOWN"
	data["patient"]["maxHealth"] = patient.maxHealth
	data["patient"]["minHealth"] = HEALTH_THRESHOLD_DEAD
	data["patient"]["bruteLoss"] = patient.get_brute_loss()
	data["patient"]["fireLoss"] = patient.get_fire_loss()
	data["patient"]["toxLoss"] = patient.get_tox_loss()
	data["patient"]["oxyLoss"] = patient.get_oxy_loss()
	data["patient"]["blood_level"] = patient.blood_volume
	data["patient"]["standard_blood_level"] = BLOOD_VOLUME_NORMAL
	data["patient"]["surgery_state"] = patient.get_surgery_state_as_list(deprecise_zone(target_zone))
	return data

/obj/machinery/computer/operating/ui_static_data(mob/user)
	var/list/data = list()

	data["experiments"] = list()
	data["techwebs"] = list()
	data["surgeries"] = list()
	if(!is_operational)
		return data

	if(linked_techweb)
		data["techwebs"] += list(list(
			"web_id" = linked_techweb.id,
			"web_org" = linked_techweb.organization,
			"selected" = TRUE,
			"ref" = REF(linked_techweb),
			"all_servers" = linked_techweb.techweb_servers,
		))

		for(var/datum/experiment/experiment as anything in linked_techweb.available_experiments)
			if(istype(experiment, /datum/experiment/autopsy))
				data["experiments"] += list(experiment.to_ui_data())

	var/list/operations = GLOB.operations.get_instances_from(GLOB.operations.unlocked | advanced_surgeries)
	var/any_recommended = FALSE
	for(var/datum/surgery_operation/operation as anything in operations)
		var/recommend = FALSE
		if(table?.patient && operation.show_as_next_step(table.patient, target_zone))
			recommend = TRUE
			any_recommended = TRUE

		data["surgeries"] += list(list(
			"name" = operation.rnd_name || operation.name,
			"desc" = operation.rnd_desc || operation.desc,
			"tool_rec" = operation.get_recommended_tool() || "error",
			"requirements" = operation.get_requirements(),
			"show_as_next" = recommend,
			"show_in_list" = TRUE,
			"priority" = operation.operation_flags & OPERATION_PRIORITY_NEXT_STEP,
			"mechanic" = operation.operation_flags & OPERATION_MECHANIC,
		))

	if(!any_recommended && table?.patient)
		var/obj/item/part = table.patient.get_bodypart(deprecise_zone(target_zone))
		var/just_drapes = FALSE
		if(table.patient.has_limbs)
			if(isnull(part))
				data["surgeries"] += list(list(
					"name" = "Prepare for [/datum/surgery_operation/prosthetic_replacement::name]",
					"desc" = "Prepare the patient's chest for prosthetic limb attachment.",
					"tool_rec" = "operate on chest",
					"show_as_next" = TRUE,
					"show_in_list" = FALSE,
				))

			else if(!HAS_TRAIT(part, TRAIT_READY_TO_OPERATE))
				just_drapes = TRUE

		else if(!HAS_TRAIT(table.patient, TRAIT_READY_TO_OPERATE))
			just_drapes = TRUE

		if(just_drapes)
			data["surgeries"] += list(list(
				"name" = "Prepare for surgery",
				"desc" = "Begin surgery by applying surgical drapes to the patient.",
				"tool_rec" = /obj/item/surgical_drapes::name,
				"show_as_next" = TRUE,
				"show_in_list" = FALSE,
			))

	return data

/obj/machinery/computer/operating/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("open_experiments")
			experiment_handler.ui_interact(usr)
		if("change_zone")
			if(params["new_zone"] in (GLOB.all_body_zones + GLOB.all_precise_body_zones))
				target_zone = params["new_zone"]
				var/atom/movable/screen/zone_sel/selector = ui.user.hud_used?.zone_select
				selector?.set_selected_zone(params["new_zone"], ui.user, FALSE)
			update_static_data_for_all_viewers()
	return TRUE

/obj/machinery/computer/operating/proc/on_techweb_research(datum/source, datum/design/surgery/design)
	SIGNAL_HANDLER

	if(!istype(design))
		return

	advanced_surgeries |= design.surgery
	update_static_data_batched()

/obj/machinery/computer/operating/proc/on_techweb_unresearch(datum/source, datum/design/surgery/design)
	SIGNAL_HANDLER

	if(!istype(design))
		return

	advanced_surgeries -= design.surgery
	update_static_data_batched()

/// Updates static data for all viewers after a miniscule delay (to batch multiple updates together)
/obj/machinery/computer/operating/proc/update_static_data_batched(...)
	SIGNAL_HANDLER

	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum, update_static_data_for_all_viewers)), 0.1 SECONDS, TIMER_UNIQUE)

#undef MENU_OPERATION
#undef MENU_SURGERIES
