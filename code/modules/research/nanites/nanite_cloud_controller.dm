/obj/machinery/computer/nanite_cloud_controller
	name = "nanite cloud controller"
	desc = "Controls the official nanite cloud copy."
	circuit = /obj/item/circuitboard/computer/nanite_cloud_controller
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "nanite_cloud_controller"
	var/obj/item/disk/nanite_program/disk
	var/datum/nanite_program/program

/obj/machinery/computer/nanite_cloud_controller/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/disk/nanite_program))
		var/obj/item/disk/nanite_program/N = I
		if(disk)
			eject()
		if(user.transferItemToLoc(N, src))
			to_chat(user, "<span class='notice'>You insert [N] into [src]</span>")
			disk = N
			program = N.program
	else
		..()

/obj/machinery/computer/nanite_cloud_controller/proc/eject()
	if(!disk)
		return
	disk.forceMove(drop_location()) //TODO: put in mob active hand
	disk = null
	program = null

/obj/machinery/computer/nanite_cloud_controller/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "nanite_cloud_control", name, 600, 800, master_ui, state)
		ui.open()

/obj/machinery/computer/nanite_cloud_controller/ui_data()
	var/list/data = list()
	if(disk)
		data["has_disk"] = TRUE
		var/list/disk_data = list()
		var/datum/nanite_program/P = disk.program
		disk_data["name"] = P.name
		disk_data["desc"] = P.desc
		disk_data["use_rate"] = P.use_rate
		disk_data["can_trigger"] = P.can_trigger
		disk_data["trigger_cost"] = P.trigger_cost
		disk_data["trigger_cooldown"] = P.trigger_cooldown / 10

		disk_data["activated"] = P.activated
		disk_data["activation_delay"] = P.activation_delay
		disk_data["timer"] = P.timer
		disk_data["activation_code"] = P.activation_code
		disk_data["deactivation_code"] = P.deactivation_code
		disk_data["kill_code"] = P.kill_code
		disk_data["trigger_code"] = P.trigger_code
		disk_data["timer_type"] = P.get_timer_type_text()

		if(istype(P, /datum/nanite_program/relay))
			var/datum/nanite_program/relay/S = P
			disk_data["is_relay"] = TRUE
			disk_data["relay_code"] = S.relay_code
		data["disk"] = disk_data

	var/datum/component/nanites/cloud_copy = SSnanites.cloud_copy
	if(cloud_copy)
		var/list/cloud_programs = list()
		for(var/datum/nanite_program/P in cloud_copy.programs)
			var/list/cloud_program = list()
			var/id = 1
			cloud_program["name"] = P.name
			cloud_program["desc"] = P.desc
			cloud_program["id"] = id
			cloud_program["use_rate"] = P.use_rate
			cloud_program["can_trigger"] = P.can_trigger
			cloud_program["trigger_cost"] = P.trigger_cost
			cloud_program["trigger_cooldown"] = P.trigger_cooldown / 10
			cloud_program["activated"] = P.activated
			cloud_program["activation_delay"] = P.activation_delay
			cloud_program["timer"] = P.timer
			cloud_program["timer_type"] = P.get_timer_type_text()
			cloud_program["activation_code"] = P.activation_code
			cloud_program["deactivation_code"] = P.deactivation_code
			cloud_program["kill_code"] = P.kill_code
			cloud_program["trigger_code"] = P.trigger_code
			if(istype(P, /datum/nanite_program/relay))
				var/datum/nanite_program/relay/S = P
				cloud_program["is_relay"] = TRUE
				cloud_program["relay_code"] = S.relay_code
			id++
			cloud_programs += cloud_program
		data["cloud_programs"] = cloud_programs
	return data

/obj/machinery/computer/nanite_cloud_controller/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("eject")
			eject()
			. = TRUE
		if("upload_program")
			if(disk && program)
				SSnanites.cloud_copy.add_program(program.copy())
			. = TRUE
		if("remove_program")
			var/datum/nanite_program/P = SSnanites.cloud_copy.programs[params["program_id"]]
			qdel(P)
			. = TRUE