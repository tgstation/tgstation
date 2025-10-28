#define MENU_OPERATION 1
#define MENU_SURGERIES 2

/obj/machinery/computer/operating
	name = "operating computer"
	desc = "Monitors patient vitals and displays surgery steps. Can be loaded with surgery disks to perform experimental procedures. Automatically syncs to operating tables within its line of sight for surgical tech advancement."
	icon_screen = "crew"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/computer/operating
	interaction_flags_machine = parent_type::interaction_flags_machine | INTERACT_MACHINE_REQUIRES_STANDING

	var/obj/structure/table/optable/table
	var/list/advanced_surgeries = list()
	var/datum/techweb/linked_techweb
	light_color = LIGHT_COLOR_BLUE

	var/target_zone = BODY_ZONE_CHEST
	var/datum/component/experiment_handler/experiment_handler
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
	if(!istype(tool, /obj/item/disk/surgery))
		return ..()
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

/obj/machinery/computer/operating/on_set_is_operational(old_value)
	update_static_data_for_all_viewers()

/obj/machinery/computer/operating/proc/find_table()
	for(var/direction in GLOB.alldirs)
		table = locate(/obj/structure/table/optable) in get_step(src, direction)
		if(table)
			table.computer = src
			break

/obj/machinery/computer/operating/ui_state(mob/user)
	return GLOB.standing_state

/obj/machinery/computer/operating/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OperatingComputer", name)
		ui.open()
		LAZYSET(zone_on_open, WEAKREF(user), user.zone_selected)

/obj/machinery/computer/operating/ui_assets(mob/user)
	. = ..()
	. += get_asset_datum(/datum/asset/simple/body_zones)

/obj/machinery/computer/operating/ui_close(mob/user)
	. = ..()
	var/zone_found = LAZYACCESS(zone_on_open, WEAKREF(user))
	if(zone_found)
		var/atom/movable/screen/zone_sel/selector = user.hud_used?.zone_select
		selector?.set_selected_zone(zone_found, user, FALSE)
		LAZYREMOVE(zone_on_open, WEAKREF(user))

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
			data["patient"]["stat"] = "Conscious"
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
	data["patient"]["bruteLoss"] = patient.getBruteLoss()
	data["patient"]["fireLoss"] = patient.getFireLoss()
	data["patient"]["toxLoss"] = patient.getToxLoss()
	data["patient"]["oxyLoss"] = patient.getOxyLoss()
	data["patient"]["blood_level"] = patient.blood_volume
	data["patient"]["standard_blood_level"] = BLOOD_VOLUME_NORMAL
	data["patient"]["has_limbs"] = patient.has_limbs // used for allowing zone selection
	data["patient"]["surgery_state"] = patient.get_surgery_state_as_list(target_zone)
	return data

/obj/machinery/computer/operating/ui_static_data(mob/user)
	var/list/data = list()

	data["surgeries"] = list()
	for(var/datum/surgery_operation/operation as anything in GLOB.operations.get_instances(advanced_surgeries))
		data["surgeries"] += list(list(
			"name" = operation.name,
			"desc" = operation.desc,
		))

	data["possible_next_operations"] = list()
	if(table?.patient && is_operational)
		// Only show basic, unlocked operations and anything we have unlocked in this computer
		for(var/datum/surgery_operation/operation as anything in GLOB.operations.get_instances(GLOB.operations.unlocked + advanced_surgeries))
			if(!operation.show_as_next_step(table.patient, target_zone))
				continue
			data["possible_next_operations"] += list(list(
				"name" = "[operation.name]",
				"desc" = operation.desc,
				"tool_rec" = operation.get_recommended_tool() || "error",
			))

		var/atom/movable/releveant = table.patient.has_limbs ? table.patient.get_bodypart(target_zone) : table.patient
		if(!length(data["possible_next_operations"]) && releveant && !HAS_TRAIT(releveant, TRAIT_READY_TO_OPERATE))
			data["possible_next_operations"] += list(list(
				"name" = "Prepare for surgery",
				"desc" = "Begin surgery by applying surgical drapes to the patient.",
				"tool_rec" = /obj/item/surgical_drapes::name,
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
			if(params["new_zone"] in GLOB.all_body_zones)
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
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum, update_static_data_for_all_viewers)), 0.1 SECONDS, TIMER_UNIQUE)

/obj/machinery/computer/operating/proc/on_techweb_unresearch(datum/source, datum/design/surgery/design)
	SIGNAL_HANDLER

	if(!istype(design))
		return

	advanced_surgeries -= design.surgery
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum, update_static_data_for_all_viewers)), 0.1 SECONDS, TIMER_UNIQUE)

#undef MENU_OPERATION
#undef MENU_SURGERIES
