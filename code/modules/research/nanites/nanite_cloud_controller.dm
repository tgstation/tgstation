/obj/machinery/computer/nanite_cloud_controller
	name = "nanite cloud controller"
	desc = "Stores and controls nanite cloud backups."
	circuit = /obj/item/circuitboard/computer/nanite_cloud_controller
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "nanite_cloud_controller"
	var/obj/item/disk/nanite_program/disk
	var/list/datum/nanite_cloud_backup/cloud_backups = list()
	var/current_view = 0 //0 is the main menu, any other number is the page of the backup with that ID

/obj/machinery/computer/nanite_cloud_controller/Destroy()
	QDEL_LIST(cloud_backups) //rip backups
	eject()
	return ..()

/obj/machinery/computer/nanite_cloud_controller/attackby(obj/item/I, mob/user)
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

/obj/machinery/computer/nanite_cloud_controller/proc/eject(mob/living/user)
	if(!disk)
		return
	if(!istype(user) || !Adjacent(user) ||!user.put_in_active_hand(disk))
		disk.forceMove(drop_location())
	disk = null

/obj/machinery/computer/nanite_cloud_controller/proc/get_backup(cloud_id)
	for(var/I in cloud_backups)
		var/datum/nanite_cloud_backup/backup = I
		if(backup.cloud_id == cloud_id)
			return backup

/obj/machinery/computer/nanite_cloud_controller/proc/generate_backup(cloud_id, mob/user)
	if(SSnanites.get_cloud_backup(cloud_id, TRUE))
		to_chat(user, "<span class='warning'>Cloud ID already registered.</span>")
		return

	var/datum/nanite_cloud_backup/backup = new(src)
	var/datum/component/nanites/cloud_copy = new(backup)
	backup.cloud_id = cloud_id
	backup.nanites = cloud_copy
	investigate_log("[key_name(user)] created a new nanite cloud backup with id #[cloud_id]", INVESTIGATE_NANITES)

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

			var/list/extra_settings = list()
			for(var/X in P.extra_settings)
				var/list/setting = list()
				setting["name"] = X
				setting["value"] = P.get_extra_setting(X)
				extra_settings += list(setting)
			disk_data["extra_settings"] = extra_settings
			if(LAZYLEN(extra_settings))
				disk_data["has_extra_settings"] = TRUE
		data["disk"] = disk_data

	data["current_view"] = current_view
	if(current_view)
		var/datum/nanite_cloud_backup/backup = get_backup(current_view)
		if(backup)
			var/datum/component/nanites/nanites = backup.nanites
			data["cloud_backup"] = TRUE
			var/list/cloud_programs = list()
			var/id = 1
			for(var/datum/nanite_program/P in nanites.programs)
				var/list/cloud_program = list()
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
				var/list/extra_settings = list()
				for(var/X in P.extra_settings)
					var/list/setting = list()
					setting["name"] = X
					setting["value"] = P.get_extra_setting(X)
					extra_settings += list(setting)
				cloud_program["extra_settings"] = extra_settings
				if(LAZYLEN(extra_settings))
					cloud_program["has_extra_settings"] = TRUE
				id++
				cloud_programs += list(cloud_program)
			data["cloud_programs"] = cloud_programs
	else
		var/list/backup_list = list()
		for(var/X in cloud_backups)
			var/datum/nanite_cloud_backup/backup = X
			var/list/cloud_backup = list()
			cloud_backup["cloud_id"] = backup.cloud_id
			backup_list += list(cloud_backup)
		data["cloud_backups"] = backup_list
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
				playsound(src, 'sound/machines/terminal_prompt.ogg', 50, 0)
				cloud_id = CLAMP(round(cloud_id, 1),1,100)
				generate_backup(cloud_id, usr)
			. = TRUE
		if("delete_backup")
			var/datum/nanite_cloud_backup/backup = get_backup(current_view)
			if(backup)
				playsound(src, 'sound/machines/terminal_prompt.ogg', 50, 0)
				qdel(backup)
				investigate_log("[key_name(usr)] deleted the nanite cloud backup #[current_view]", INVESTIGATE_NANITES)
			. = TRUE
		if("upload_program")
			if(disk && disk.program)
				var/datum/nanite_cloud_backup/backup = get_backup(current_view)
				if(backup)
					playsound(src, 'sound/machines/terminal_prompt.ogg', 50, 0)
					var/datum/component/nanites/nanites = backup.nanites
					nanites.add_program(null, disk.program.copy())
					investigate_log("[key_name(usr)] uploaded program [disk.program.name] to cloud #[current_view]", INVESTIGATE_NANITES)
			. = TRUE
		if("remove_program")
			var/datum/nanite_cloud_backup/backup = get_backup(current_view)
			if(backup)
				playsound(src, 'sound/machines/terminal_prompt.ogg', 50, 0)
				var/datum/component/nanites/nanites = backup.nanites
				var/datum/nanite_program/P = nanites.programs[text2num(params["program_id"])]
				investigate_log("[key_name(usr)] deleted program [P.name] from cloud #[current_view]", INVESTIGATE_NANITES)
				qdel(P)
			. = TRUE

/datum/nanite_cloud_backup
	var/cloud_id = 0
	var/datum/component/nanites/nanites
	var/obj/machinery/computer/nanite_cloud_controller/storage

/datum/nanite_cloud_backup/New(obj/machinery/computer/nanite_cloud_controller/_storage)
	storage = _storage
	storage.cloud_backups += src
	SSnanites.cloud_backups += src

/datum/nanite_cloud_backup/Destroy()
	storage.cloud_backups -= src
	SSnanites.cloud_backups -= src
	return ..()