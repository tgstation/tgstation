/obj/machinery/nanite_program_hub
	name = "nanite program hub"
	desc = "Compiles nanite programs from the techweb servers and downloads them into disks."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "nanite_program_hub"
	circuit = /obj/item/circuitboard/machine/nanite_program_hub
	use_power = IDLE_POWER_USE
	anchored = TRUE
	density = TRUE

	var/obj/item/disk/nanite_program/disk
	var/datum/techweb/linked_techweb
	var/current_category = "Main"
	var/detail_view = FALSE
	var/categories = list(
						list(name = "Utility Nanites"),
						list(name = "Medical Nanites"),
						list(name = "Sensor Nanites"),
						list(name = "Augmentation Nanites"),
						list(name = "Suppression Nanites"),
						list(name = "Weaponized Nanites")
						)

/obj/machinery/nanite_program_hub/Initialize()
	. = ..()
	linked_techweb = SSresearch.science_tech

/obj/machinery/nanite_program_hub/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/disk/nanite_program))
		var/obj/item/disk/nanite_program/N = I
		if(disk)
			eject(user)
		if(user.transferItemToLoc(N, src))
			to_chat(user, "<span class='notice'>You insert [N] into [src]</span>")
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
			disk = N
	else
		..()

/obj/machinery/nanite_program_hub/proc/eject(mob/living/user)
	if(!disk)
		return
	if(!istype(user) || !Adjacent(user) || !user.put_in_active_hand(disk))
		disk.forceMove(drop_location())
	disk = null

/obj/machinery/nanite_program_hub/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "nanite_program_hub", name, 500, 700, master_ui, state)
		ui.set_autoupdate(FALSE) //to avoid making the whole program list every second
		ui.open()

/obj/machinery/nanite_program_hub/ui_data()
	var/list/data = list()
	if(disk)
		data["has_disk"] = TRUE
		var/list/disk_data = list()
		var/datum/nanite_program/P = disk.program
		if(P)
			data["has_program"] = TRUE
			disk_data["name"] = P.name
			disk_data["desc"] = P.desc
		data["disk"] = disk_data

	data["detail_view"] = detail_view
	data["category"] = current_category

	if(current_category != "Main")
		var/list/program_list = list()
		for(var/i in linked_techweb.researched_designs)
			var/datum/design/nanites/D = SSresearch.techweb_design_by_id(i)
			if(!istype(D))
				continue
			if(current_category in D.category)
				var/list/program_design = list()
				program_design["id"] = D.id
				program_design["name"] = D.name
				program_design["desc"] = D.desc
				program_list += list(program_design)
		data["program_list"] = program_list
	else
		data["categories"] = categories

	return data

/obj/machinery/nanite_program_hub/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("eject")
			eject(usr)
			. = TRUE
		if("download")
			if(!disk)
				return
			var/datum/design/nanites/downloaded = linked_techweb.isDesignResearchedID(params["program_id"]) //check if it's a valid design
			if(!istype(downloaded))
				return
			if(disk.program)
				qdel(disk.program)
			disk.program = new downloaded.program_type
			disk.name = "[initial(disk.name)] \[[disk.program.name]\]"
			playsound(src, 'sound/machines/terminal_prompt.ogg', 25, 0)
			. = TRUE
		if("set_category")
			var/new_category = params["category"]
			current_category = new_category
			. = TRUE
		if("toggle_details")
			detail_view = !detail_view
			. = TRUE
		if("clear")
			if(disk && disk.program)
				qdel(disk.program)
				disk.program = null
				disk.name = initial(disk.name)
			. = TRUE