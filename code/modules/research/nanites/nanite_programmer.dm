/obj/machinery/nanite_programmer
	name = "nanite programmer"
	desc = "A device that can edit nanite program disks to adjust their functionality."
	var/obj/item/disk/nanite_program/disk
	var/datum/nanite_program/program
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "nanite_programmer"
	use_power = IDLE_POWER_USE
	anchored = TRUE
	density = TRUE
	circuit = /obj/item/circuitboard/machine/nanite_programmer
	ui_x = 600
	ui_y = 800

/obj/machinery/nanite_programmer/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/disk/nanite_program))
		var/obj/item/disk/nanite_program/N = I
		if(disk)
			eject(user)
		if(user.transferItemToLoc(N, src))
			to_chat(user, "<span class='notice'>You insert [N] into [src]</span>")
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
			disk = N
			program = N.program
	else
		..()

/obj/machinery/nanite_programmer/proc/eject(mob/living/user)
	if(!disk)
		return
	if(!istype(user) || !Adjacent(user) || !user.put_in_active_hand(disk))
		disk.forceMove(drop_location())
	disk = null
	program = null

/obj/machinery/nanite_programmer/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "nanite_programmer", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/nanite_programmer/ui_data()
	var/list/data = list()
	data["has_disk"] = istype(disk)
	data["has_program"] = istype(program)
	if(program)
		data["name"] = program.name
		data["desc"] = program.desc
		data["use_rate"] = program.use_rate
		data["can_trigger"] = program.can_trigger
		data["trigger_cost"] = program.trigger_cost
		data["trigger_cooldown"] = program.trigger_cooldown / 10

		data["activated"] = program.activated
		data["activation_code"] = program.activation_code
		data["deactivation_code"] = program.deactivation_code
		data["kill_code"] = program.kill_code
		data["trigger_code"] = program.trigger_code
		data["timer_restart"] = program.timer_restart / 10
		data["timer_shutdown"] = program.timer_shutdown / 10
		data["timer_trigger"] = program.timer_trigger / 10
		data["timer_trigger_delay"] = program.timer_trigger_delay / 10

		var/list/extra_settings = list()
		for(var/X in program.extra_settings)
			var/list/setting = list()
			setting["name"] = X
			setting["value"] = program.get_extra_setting(X)
			extra_settings += list(setting)
		data["extra_settings"] = extra_settings
		if(LAZYLEN(extra_settings))
			data["has_extra_settings"] = TRUE

	return data

/obj/machinery/nanite_programmer/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("eject")
			eject(usr)
			. = TRUE
		if("toggle_active")
			playsound(src, "terminal_type", 25, FALSE)
			program.activated = !program.activated //we don't use the activation procs since we aren't in a mob
			. = TRUE
		if("set_code")
			var/new_code = input("Set code (0000-9999):", name, null) as null|num
			if(!isnull(new_code))
				playsound(src, "terminal_type", 25, FALSE)
				new_code = CLAMP(round(new_code, 1),0,9999)
			else
				return

			playsound(src, "terminal_type", 25, FALSE)
			var/target_code = params["target_code"]
			switch(target_code)
				if("activation")
					program.activation_code = CLAMP(round(new_code, 1),0,9999)
				if("deactivation")
					program.deactivation_code = CLAMP(round(new_code, 1),0,9999)
				if("kill")
					program.kill_code = CLAMP(round(new_code, 1),0,9999)
				if("trigger")
					program.trigger_code = CLAMP(round(new_code, 1),0,9999)
			. = TRUE
		if("set_extra_setting")
			program.set_extra_setting(usr, params["target_setting"])
			playsound(src, "terminal_type", 25, FALSE)
			. = TRUE
		if("set_restart_timer")
			var/timer = input("Set restart timer in seconds (0-3600):", name, program.timer_restart / 10) as null|num
			if(!isnull(timer))
				playsound(src, "terminal_type", 25, FALSE)
				timer = CLAMP(round(timer, 1), 0, 3600)
				timer *= 10 //convert to deciseconds
				program.timer_restart = timer
			. = TRUE
		if("set_shutdown_timer")
			var/timer = input("Set shutdown timer in seconds (0-3600):", name, program.timer_shutdown / 10) as null|num
			if(!isnull(timer))
				playsound(src, "terminal_type", 25, FALSE)
				timer = CLAMP(round(timer, 1), 0, 3600)
				timer *= 10 //convert to deciseconds
				program.timer_shutdown = timer
			. = TRUE
		if("set_trigger_timer")
			var/timer = input("Set trigger repeat timer in seconds (0-3600):", name, program.timer_trigger / 10) as null|num
			if(!isnull(timer))
				playsound(src, "terminal_type", 25, FALSE)
				timer = CLAMP(round(timer, 1), 0, 3600)
				timer *= 10 //convert to deciseconds
				program.timer_trigger = timer
			. = TRUE
		if("set_timer_trigger_delay")
			var/timer = input("Set trigger delay in seconds (0-3600):", name, program.timer_trigger_delay / 10) as null|num
			if(!isnull(timer))
				playsound(src, "terminal_type", 25, FALSE)
				timer = CLAMP(round(timer, 1), 0, 3600)
				timer *= 10 //convert to deciseconds
				program.timer_trigger_delay = timer
			. = TRUE
