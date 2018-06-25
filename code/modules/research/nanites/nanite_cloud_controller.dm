/obj/machinery/computer/nanite_cloud_controller
	name = "nanite cloud controller"
	desc = "Stores and controls nanite cloud backups."
	circuit = /obj/item/circuitboard/computer/nanite_cloud_controller
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "nanite_cloud_controller"
	var/obj/item/disk/nanite_program/disk
	var/current_view = 0 //0 is the main menu, any other number is the page of the backup with that ID

/obj/machinery/computer/nanite_cloud_controller/Initialize()
	. = ..()
	SSnanites.cloud_storage |= src

/obj/machinery/computer/nanite_cloud_controller/Destroy()
	SSnanites.cloud_storage -= src
	SSnanites.check_hardware() //in case this is the last storage left
	eject()
	. = ..()

/obj/machinery/computer/nanite_cloud_controller/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/disk/nanite_program))
		var/obj/item/disk/nanite_program/N = I
		if(disk)
			eject(user)
		if(user.transferItemToLoc(N, src))
			to_chat(user, "<span class='notice'>You insert [N] into [src]</span>")
			disk = N
	else
		..()

/obj/machinery/computer/nanite_cloud_controller/proc/eject(mob/living/user)
	if(!disk)
		return
	if(!istype(user) || !Adjacent(user) ||!user.put_in_active_hand(disk))
		disk.forceMove(drop_location())
	disk = null

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
		if(P)
			data["has_program"] = TRUE
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

			disk_data["has_extra_code"] = P.has_extra_code
			disk_data["extra_code"] = P.extra_code
			disk_data["extra_code_name"] = P.extra_code_name
		data["disk"] = disk_data

	data["current_view"] = current_view
	if(current_view)
		var/datum/component/nanites/cloud/cloud_backup = SSnanites.get_cloud_backup(current_view)
		if(cloud_backup)
			data["cloud_backup"] = TRUE
			var/list/cloud_programs = list()
			for(var/datum/nanite_program/P in cloud_backup.programs)
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
				cloud_program["has_extra_code"] = P.has_extra_code
				cloud_program["extra_code"] = P.extra_code
				cloud_program["extra_code_name"] = P.extra_code_name
				id++
				cloud_programs += list(cloud_program)
			data["cloud_programs"] = cloud_programs
	else
		var/list/cloud_backups = list()
		for(var/X in SSnanites.cloud_backups)
			var/datum/component/nanites/cloud/backup = X
			var/list/cloud_backup = list()
			cloud_backup["cloud_id"] = backup.cloud_id
			cloud_backups += list(cloud_backup)
		data["cloud_backups"] = cloud_backups
	return data

/obj/machinery/computer/nanite_cloud_controller/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("eject")
			eject(usr)
			. = TRUE
		if("set_view")
			current_view = text2num(params["view"])
			. = TRUE
		if("create_backup")
			var/cloud_id = input("Choose a cloud ID (1-100):", name, null) as null|num
			if(!isnull(cloud_id))
				cloud_id = CLAMP(round(cloud_id, 1),1,100)
				SSnanites.generate_cloud_backup(cloud_id)
				investigate_log("[key_name(usr)] created a new nanite cloud backup with id #[cloud_id]", INVESTIGATE_NANITES)
			. = TRUE
		if("delete_backup")
			SSnanites.delete_cloud_backup(current_view)
			investigate_log("[key_name(usr)] deleted the nanite cloud backup #[current_view]", INVESTIGATE_NANITES)
			. = TRUE
		if("upload_program")
			if(disk && disk.program)
				var/datum/component/nanites/cloud/backup = SSnanites.get_cloud_backup(current_view)
				if(backup)
					backup.add_program(disk.program.copy())
					investigate_log("[key_name(usr)] uploaded program [disk.program.name] to cloud #[current_view]", INVESTIGATE_NANITES)
			. = TRUE
		if("remove_program")
			var/datum/component/nanites/cloud/backup = SSnanites.get_cloud_backup(current_view)
			if(backup)
				var/datum/nanite_program/P = backup.programs[text2num(params["program_id"])]
				investigate_log("[key_name(usr)] deleted program [P.name] from cloud #[current_view]", INVESTIGATE_NANITES)
				qdel(P)
			. = TRUE