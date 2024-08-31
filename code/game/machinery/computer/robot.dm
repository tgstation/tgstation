/obj/machinery/computer/robotics
	name = "robotics control console"
	desc = "Used to remotely lockdown linked Cyborgs and Drones."
	icon_screen = "robot"
	icon_keyboard = "rd_key"
	req_access = list(ACCESS_ROBOTICS)
	circuit = /obj/item/circuitboard/computer/robotics
	light_color = LIGHT_COLOR_PINK
	var/mob/living/silicon/robot/locked_down_borg = null
	active_power_usage = 10000 //no idea how much is it


/obj/machinery/computer/robotics/proc/can_control(mob/user, mob/living/silicon/robot/R)
	. = FALSE
	if(!istype(R))
		return
	if(isAI(user))
		if(R.connected_ai != user)
			return
	if(iscyborg(user))
		if(R != user)
			return
	if(R.scrambledcodes)
		return
	return TRUE

/obj/machinery/computer/robotics/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RoboticsControlConsole", name)
		ui.open()

/obj/machinery/computer/robotics/ui_data(mob/user)
	var/list/data = list()

	data["can_hack"] = FALSE
	if(issilicon(user))
		var/mob/living/silicon/S = user
		if(S.hack_software)
			data["can_hack"] = TRUE
	else if(isAdminGhostAI(user))
		data["can_hack"] = TRUE

	data["can_detonate"] = FALSE
	if(isAI(user))
		var/mob/living/silicon/ai/ai = user
		data["can_detonate"] = !isnull(ai.malf_picker)

	var/turf/current_turf = get_turf(src)
	data["cyborgs"] = list()
	for(var/mob/living/silicon/robot/R in GLOB.silicon_mobs)
		if(!can_control(user, R))
			continue
		if(!is_valid_z_level(current_turf, get_turf(R)))
			continue
		var/list/cyborg_data = list(
			name = R.name,
			locked_down = R.lockcharge,
			status = R.stat,
			charge = R.cell ? round(R.cell.percent()) : null,
			module = R.model ? "[R.model.name] Model" : "No Model Detected",
			synchronization = R.connected_ai,
			emagged = R.emagged,
			ref = REF(R)
		)
		data["cyborgs"] += list(cyborg_data)

	data["drones"] = list()
	for(var/mob/living/basic/drone/drone in GLOB.drones_list)
		if(drone.hacked)
			continue
		if(!is_valid_z_level(current_turf, get_turf(drone)))
			continue
		var/list/drone_data = list(
			name = drone.name,
			status = drone.stat,
			ref = REF(drone)
		)
		data["drones"] += list(drone_data)

	return data

/obj/machinery/computer/robotics/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("stopbot")
			if(allowed(usr))
				var/mob/living/silicon/robot/R = locate(params["ref"]) in GLOB.silicon_mobs
				if(can_control(usr, R) && !..())
					if(isAI(usr))
						if(R.lockcharge)
							if(R.ai_lockdown)
								R.ai_lockdown = FALSE
								lock_unlock_borg(R)
							else
								to_chat(usr, span_danger("Cyborg locked by an user with superior permissions."))
						else
							R.ai_lockdown = TRUE
							lock_unlock_borg(R)
					else
						if(isnull(locked_down_borg) && !R.lockcharge) //If there is no borg locked down by the console yet
							lock_unlock_borg(R, src.loc.loc.name)
							R.ai_lockdown = FALSE //Just in case I'm stupid
							locked_down_borg = R
							RegisterSignal(R, COMSIG_QDELETING, PROC_REF(borg_destroyed))
						else if(locked_down_borg == R) //If the borg locked down by the console is the same as the one we're trying to unlock
							lock_unlock_borg(R)
						else if(R.lockcharge&&R.ai_lockdown)
							R.ai_lockdown = FALSE
							lock_unlock_borg(R)
						else if(R.lockcharge&&locked_down_borg!=R)
							to_chat(usr, span_danger("The cyborg was locked by a different console."))
						else
							to_chat(usr, span_danger("You can lock down only one cyborg at a time."))
			else
				to_chat(usr, span_danger("Access Denied."))
			if(!isnull(locked_down_borg))
				use_power = ACTIVE_POWER_USE
			else
				use_power = IDLE_POWER_USE

		if("killbot") //Malf AIs, and AIs with a combat upgrade, can detonate their cyborgs remotely.
			if(!isAI(usr))
				return
			var/mob/living/silicon/ai/ai = usr
			if(!ai.malf_picker)
				return
			var/mob/living/silicon/robot/target = locate(params["ref"]) in GLOB.silicon_mobs
			if(!istype(target))
				return
			if(target.connected_ai != ai)
				return
			target.self_destruct(usr)

		if("magbot")
			var/mob/living/silicon/S = usr
			if((istype(S) && S.hack_software) || isAdminGhostAI(usr))
				var/mob/living/silicon/robot/R = locate(params["ref"]) in GLOB.silicon_mobs
				if(istype(R) && !R.emagged && (R.connected_ai == usr || isAdminGhostAI(usr)) && !R.scrambledcodes && can_control(usr, R))
					log_silicon("[key_name(usr)] emagged [key_name(R)] using robotic console!")
					message_admins("[ADMIN_LOOKUPFLW(usr)] emagged cyborg [key_name_admin(R)] using robotic console!")
					R.SetEmagged(TRUE)
					R.logevent("WARN: root privleges granted to PID [num2hex(rand(1,65535), -1)][num2hex(rand(1,65535), -1)].") //random eight digit hex value. Two are used because rand(1,4294967295) throws an error

		if("killdrone")
			if(allowed(usr))
				var/mob/living/basic/drone/drone = locate(params["ref"]) in GLOB.mob_list
				if(drone.hacked)
					to_chat(usr, span_danger("ERROR: [drone] is not responding to external commands."))
				else
					var/turf/T = get_turf(drone)
					message_admins("[ADMIN_LOOKUPFLW(usr)] detonated [key_name_admin(drone)] at [ADMIN_VERBOSEJMP(T)]!")
					log_silicon("[key_name(usr)] detonated [key_name(drone)]!")
					var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
					s.set_up(3, TRUE, drone)
					s.start()
					drone.visible_message(span_danger("\the [drone] self-destructs!"))
					drone.investigate_log("has been gibbed by a robotics console.", INVESTIGATE_DEATHS)
					drone.gib()


// I feel like this should be changed, but I have no idea in what way exactly, so I just extracted it to make the code less of a mess
/obj/machinery/computer/robotics/proc/lock_unlock_borg(mob/living/silicon/robot/R, console_location = null)
	if(R.lockcharge && locked_down_borg == R)
		UnregisterSignal(locked_down_borg, COMSIG_QDELETING)
		locked_down_borg = null
	message_admins(span_notice("[ADMIN_LOOKUPFLW(usr)] [!R.lockcharge ? "locked down" : "released"] [ADMIN_LOOKUPFLW(R)]!"))
	log_silicon("[key_name(usr)] [!R.lockcharge ? "locked down" : "released"] [key_name(R)]!")
	log_combat(usr, R, "[!R.lockcharge ? "locked down" : "released"] cyborg")
	R.SetLockdown(!R.lockcharge)
	to_chat(R, !R.lockcharge ? span_notice("Your lockdown has been lifted!") : span_alert("You have been locked down!"))
	if(!isnull(console_location))
		to_chat(R, span_alert("The approximate location of the console that is keeping you locked down is [console_location]"))
	if(R.connected_ai)
		to_chat(R.connected_ai, "[!R.lockcharge ? span_notice("NOTICE - Cyborg lockdown lifted") : span_alert("ALERT - Cyborg lockdown detected")]: <a href='?src=[REF(R.connected_ai)];track=[html_encode(R.name)]'>[R.name]</a><br>")

/obj/machinery/computer/robotics/proc/borg_destroyed()
	SIGNAL_HANDLER
	locked_down_borg = null

/obj/machinery/computer/robotics/on_set_machine_stat(old_value)  //depowering the console unlocks the borg
	if(!isnull(locked_down_borg))
		if(machine_stat & (NOPOWER|BROKEN|MAINT) && locked_down_borg.lockcharge)
			src.lock_unlock_borg(locked_down_borg)
	return ..()

/obj/machinery/computer/robotics/atom_break() // This shouldnt be needed, but hitting console doesnt trigger destroy apparently
	if(!isnull(locked_down_borg))
		lock_unlock_borg(locked_down_borg)
	return ..()

/obj/machinery/computer/robotics/Destroy()
	if(!isnull(locked_down_borg))
		lock_unlock_borg(locked_down_borg)
	return ..()





