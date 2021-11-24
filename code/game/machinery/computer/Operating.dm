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
	..()
	linked_techweb = SSresearch.science_tech
	find_table()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/operating/LateInitialize()
	. = ..()

	experiment_handler = AddComponent( \
		/datum/component/experiment_handler, \
		allowed_experiments = list(/datum/experiment/dissection), \
		config_flags = EXPERIMENT_CONFIG_ALWAYS_ACTIVE, \
		config_mode = EXPERIMENT_CONFIG_ALTCLICK, \
	)

/obj/machinery/computer/operating/Destroy()
	for(var/direction in GLOB.alldirs)
		table = locate(/obj/structure/table/optable) in get_step(src, direction)
		if(table && table.computer == src)
			table.computer = null
	QDEL_NULL(experiment_handler)
	. = ..()

/obj/machinery/computer/operating/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/disk/surgery))
		user.visible_message(span_notice("[user] begins to load \the [O] in \the [src]..."), \
			span_notice("You begin to load a surgery protocol from \the [O]..."), \
			span_hear("You hear the chatter of a floppy drive."))
		var/obj/item/disk/surgery/D = O
		if(do_after(user, 10, target = src))
			advanced_surgeries |= D.surgeries
		return TRUE
	return ..()

/obj/machinery/computer/operating/proc/sync_surgeries()
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
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OperatingComputer", name)
		ui.open()

/obj/machinery/computer/operating/ui_data(mob/user)
	var/list/data = list()
	var/list/surgeries = list()
	for(var/X in advanced_surgeries)
		var/datum/surgery/S = X
		var/list/surgery = list()
		surgery["name"] = initial(S.name)
		surgery["desc"] = initial(S.desc)
		surgeries += list(surgery)
	data["surgeries"] = surgeries

	//If there's no patient just hop to it yeah?
	if(!table)
		data["patient"] = null
		return data

	data["table"] = table
	if(!table.check_eligible_patient())
		return data
	data["patient"] = list()
	var/mob/living/carbon/human/patient = table.patient

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
	data["patient"]["blood_type"] = patient.dna.blood_type
	data["patient"]["maxHealth"] = patient.maxHealth
	data["patient"]["minHealth"] = HEALTH_THRESHOLD_DEAD
	data["patient"]["bruteLoss"] = patient.getBruteLoss()
	data["patient"]["fireLoss"] = patient.getFireLoss()
	data["patient"]["toxLoss"] = patient.getToxLoss()
	data["patient"]["oxyLoss"] = patient.getOxyLoss()
	data["procedures"] = list()
	if(patient.surgeries.len)
		for(var/datum/surgery/procedure in patient.surgeries)
			var/datum/surgery_step/surgery_step = procedure.get_surgery_step()
			var/chems_needed = surgery_step.get_chem_list()
			var/alternative_step
			var/alt_chems_needed = ""
			if(surgery_step.repeatable)
				var/datum/surgery_step/next_step = procedure.get_surgery_next_step()
				if(next_step)
					alternative_step = capitalize(next_step.name)
					alt_chems_needed = next_step.get_chem_list()
				else
					alternative_step = "Finish operation"
			data["procedures"] += list(list(
				"name" = capitalize("[parse_zone(procedure.location)] [procedure.name]"),
				"next_step" = capitalize(surgery_step.name),
				"chems_needed" = chems_needed,
				"alternative_step" = alternative_step,
				"alt_chems_needed" = alt_chems_needed
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
