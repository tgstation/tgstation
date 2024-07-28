#define MENU_OPERATION 1
#define MENU_SURGERIES 2

/obj/machinery/computer/operating
	name = "operating computer"
	desc = "Monitors patient vitals and displays surgery steps. Can be loaded with surgery disks to perform experimental procedures. Automatically syncs to operating tables within its line of sight for surgical tech advancement."
	icon_screen = "crew"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/computer/operating

	var/obj/structure/table/optable/table
	var/list/advanced_surgeries = list()
	var/datum/techweb/linked_techweb
	light_color = LIGHT_COLOR_BLUE

	var/datum/component/experiment_handler/experiment_handler

/obj/machinery/computer/operating/Initialize(mapload)
	. = ..()
	find_table()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/operating/post_machine_initialize()
	. = ..()
	if(!CONFIG_GET(flag/no_default_techweb_link) && !linked_techweb)
		CONNECT_TO_RND_SERVER_ROUNDSTART(linked_techweb, src)

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

/obj/machinery/computer/operating/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/disk/surgery))
		user.visible_message(span_notice("[user] begins to load \the [O] in \the [src]..."), \
			span_notice("You begin to load a surgery protocol from \the [O]..."), \
			span_hear("You hear the chatter of a floppy drive."))
		var/obj/item/disk/surgery/D = O
		if(do_after(user, 1 SECONDS, target = src))
			advanced_surgeries |= D.surgeries
		return TRUE
	return ..()

/obj/machinery/computer/operating/proc/sync_surgeries()
	if(!linked_techweb)
		return
	for(var/i in linked_techweb.researched_designs)
		var/datum/design/surgery/D = SSresearch.techweb_design_by_id(i)
		if(!istype(D))
			continue
		advanced_surgeries |= D.surgery

/obj/machinery/computer/operating/proc/find_table()
	for(var/direction in GLOB.alldirs)
		table = locate(/obj/structure/table/optable) in get_step(src, direction)
		if(table)
			table.computer = src
			break

/obj/machinery/computer/operating/ui_state(mob/user)
	return GLOB.not_incapacitated_state

/obj/machinery/computer/operating/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OperatingComputer", name)
		ui.open()

/obj/machinery/computer/operating/ui_data(mob/user)
	var/list/data = list()
	var/list/all_surgeries = list()
	for(var/datum/surgery/surgeries as anything in advanced_surgeries)
		var/list/surgery = list()
		surgery["name"] = initial(surgeries.name)
		surgery["desc"] = initial(surgeries.desc)
		all_surgeries += list(surgery)
	data["surgeries"] = all_surgeries

	//If there's no patient just hop to it yeah?
	if(!table)
		data["patient"] = null
		return data

	data["table"] = table
	data["patient"] = list()
	data["procedures"] = list()
	if(!table.patient)
		return data
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

	// check here to see if the patient has standard blood reagent, or special blood (like how ethereals bleed liquid electricity) to show the proper name in the computer
	var/blood_id = patient.get_blood_id()
	if(blood_id == /datum/reagent/blood)
		data["patient"]["blood_type"] = patient.dna?.blood_type
	else
		var/datum/reagent/special_blood = GLOB.chemical_reagents_list[blood_id]
		data["patient"]["blood_type"] = special_blood ? special_blood.name : blood_id

	data["patient"]["maxHealth"] = patient.maxHealth
	data["patient"]["minHealth"] = HEALTH_THRESHOLD_DEAD
	data["patient"]["bruteLoss"] = patient.getBruteLoss()
	data["patient"]["fireLoss"] = patient.getFireLoss()
	data["patient"]["toxLoss"] = patient.getToxLoss()
	data["patient"]["oxyLoss"] = patient.getOxyLoss()
	if(patient.surgeries.len)
		for(var/datum/surgery/procedure in patient.surgeries)
			var/datum/surgery_step/surgery_step = procedure.get_surgery_step()
			var/chems_needed = surgery_step.get_chem_list()
			var/alternative_step
			var/alt_chems_needed = ""
			var/alt_chems_present = FALSE
			if(surgery_step.repeatable)
				var/datum/surgery_step/next_step = procedure.get_surgery_next_step()
				if(next_step)
					alternative_step = capitalize(next_step.name)
					alt_chems_needed = next_step.get_chem_list()
					alt_chems_present = next_step.chem_check(patient)
				else
					alternative_step = "Finish operation"
			data["procedures"] += list(list(
				"name" = capitalize("[patient.parse_zone_with_bodypart(procedure.location)] [procedure.name]"),
				"next_step" = capitalize(surgery_step.name),
				"chems_needed" = chems_needed,
				"alternative_step" = alternative_step,
				"alt_chems_needed" = alt_chems_needed,
				"chems_present" = surgery_step.chem_check(patient),
				"alt_chems_present" = alt_chems_present
			))
	return data

/obj/machinery/computer/operating/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("sync")
			sync_surgeries()
		if("open_experiments")
			experiment_handler.ui_interact(usr)
	return TRUE

#undef MENU_OPERATION
#undef MENU_SURGERIES
