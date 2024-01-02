/obj/machinery/nanite_program_hub
	name = "nanite program hub"
	desc = "Compiles nanite programs from the techweb servers and downloads them into disks."
	icon = 'voidcrew/modules/nanites/icons/research.dmi'
	icon_state = "nanite_program_hub"
	use_power = IDLE_POWER_USE
	anchored = TRUE
	density = TRUE
	circuit = /obj/item/circuitboard/machine/nanite_program_hub

	var/obj/item/disk/nanite_program/disk
	var/datum/techweb/linked_techweb
	var/detail_view = TRUE

/obj/machinery/nanite_program_hub/Destroy()
	unsync_research_servers()
	return ..()

/obj/machinery/nanite_program_hub/unsync_research_servers()
	if(linked_techweb)
		linked_techweb.connected_machines -= src
		linked_techweb = null

/obj/machinery/nanite_program_hub/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(!QDELETED(tool.buffer) && istype(tool.buffer, /datum/techweb))
		if(linked_techweb)
			if(linked_techweb == tool.buffer)
				say("Already linked!")
				return
			unsync_research_servers()

		linked_techweb = tool.buffer
		linked_techweb.connected_machines += src //connect new one
		say("Linked to Server!")
		return TRUE

/obj/machinery/nanite_program_hub/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/disk/nanite_program))
		var/obj/item/disk/nanite_program/N = I
		if(user.transferItemToLoc(N, src))
			to_chat(user, span_notice("You insert [N] into [src]."))
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
			if(disk)
				eject(user)
			disk = N
		return
	return ..()

/obj/machinery/nanite_program_hub/proc/eject(mob/living/user)
	if(!disk)
		return
	if(!istype(user) || !Adjacent(user) || !user.put_in_active_hand(disk))
		disk.forceMove(drop_location())
	disk = null

/obj/machinery/nanite_program_hub/AltClick(mob/user)
	if(disk && user.can_perform_action(src, ALLOW_SILICON_REACH))
		to_chat(user, span_notice("You take out [disk] from [src]."))
		eject(user)
	return

/obj/machinery/nanite_program_hub/ui_interact(mob/user, datum/tgui/ui)
	if(!linked_techweb)
		balloon_alert(user, "no linked server!")
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NaniteProgramHub", name)
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
	else
		data["has_disk"] = FALSE

	data["detail_view"] = detail_view

	return data

/obj/machinery/nanite_program_hub/ui_static_data(mob/user)
	var/list/data = list()

	data["programs"] = list()
	for(var/i in linked_techweb.researched_designs)
		var/datum/design/nanites/D = SSresearch.techweb_design_by_id(i)
		if(!(D.build_type & NANITE_PROGRAM))
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
	. = ..()
	if(.)
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
			playsound(src, 'sound/machines/terminal_prompt.ogg', 25, FALSE)
			. = TRUE
		if("refresh")
			update_static_data(usr)
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
