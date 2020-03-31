/obj/machinery/nanite_program_hub
	name = "nanite program hub"
	desc = "Compiles nanite programs from the techweb servers and downloads them into disks."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "nanite_program_hub"
	use_power = IDLE_POWER_USE
	anchored = TRUE
	density = TRUE
	circuit = /obj/item/circuitboard/machine/nanite_program_hub
	ui_x = 500
	ui_y = 700

	var/datum/nanite_program/data_on_disk
	var/datum/techweb/linked_techweb
	var/current_category = "Main"
	var/detail_view = TRUE
	var/categories = list(
						list(name = "Utility Nanites"),
						list(name = "Medical Nanites"),
						list(name = "Sensor Nanites"),
						list(name = "Augmentation Nanites"),
						list(name = "Suppression Nanites"),
						list(name = "Weaponized Nanites"),
						list(name = "Protocols")
						)

/obj/machinery/nanite_program_hub/Initialize()
	. = ..()
	linked_techweb = SSresearch.science_tech

/obj/machinery/nanite_program_hub/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/diskmachine, CALLBACK(src, .proc/diskcallback), /obj/item/disk/nanite_program)

/obj/machinery/nanite_program_hub/proc/diskcallback(datum/disk_data)
	data_on_disk = disk_data
	if(SEND_SIGNAL(src, COMPONENT_HAS_DISK) & COMPONENT_DISK_INSERTED)
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)

/obj/machinery/nanite_program_hub/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "nanite_program_hub", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/nanite_program_hub/ui_data()
	var/list/data = list()
	if(SEND_SIGNAL(src, COMPONENT_HAS_DISK) & COMPONENT_DISK_INSERTED)
		data["has_disk"] = TRUE
		var/list/disk_data = list()
		var/datum/nanite_program/P = data_on_disk
		if(P)
			data["has_program"] = TRUE
			disk_data["name"] = P.name
			disk_data["desc"] = P.desc
		data["disk"] = disk_data
	else
		data["has_disk"] = FALSE

	data["detail_view"] = detail_view

	return data

/obj/machinery/nanite_program_hub/ui_static_data(mob/user)
	var/list/data = list()
	data["programs"] = list()
	for(var/i in linked_techweb.researched_designs)
		var/datum/design/nanites/D = SSresearch.techweb_design_by_id(i)
		if(!istype(D))
			continue
		var/cat_name = D.category[1] //just put them in the first category fuck it
		if(isnull(data["programs"][cat_name]))
			data["programs"][cat_name] = list()
		var/list/program_design = list()
		program_design["id"] = D.id
		program_design["name"] = D.name
		program_design["desc"] = D.desc
		data["programs"][cat_name] += list(program_design)

	if(!length(data["programs"]))
		data["programs"] = null

	return data

/obj/machinery/nanite_program_hub/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("eject")
			SEND_SIGNAL(src, COMPONENT_DISK_EJECT, usr)
			. = TRUE
		if("download")
			if(!(SEND_SIGNAL(src, COMPONENT_HAS_DISK) & COMPONENT_DISK_INSERTED))
				return
			var/datum/design/nanites/downloaded = linked_techweb.isDesignResearchedID(params["program_id"]) //check if it's a valid design
			if(!istype(downloaded))
				return

			data_on_disk = new downloaded.program_type
			SEND_SIGNAL(src, COMPONENT_SAVE_DATA, data_on_disk, data_on_disk.name)
			playsound(src, 'sound/machines/terminal_prompt.ogg', 25, FALSE)
			. = TRUE
		if("refresh")
			update_static_data(usr)
			. = TRUE
		if("toggle_details")
			detail_view = !detail_view
			. = TRUE
		if("clear")
			SEND_SIGNAL(src, COMPONENT_SAVE_DATA, null, null)
			data_on_disk = null
			. = TRUE
