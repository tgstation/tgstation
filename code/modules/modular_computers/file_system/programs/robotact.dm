/datum/computer_file/program/robotact
	filename = "robotact"
	filedesc = "RoboTact"
	downloader_category = PROGRAM_CATEGORY_SCIENCE
	extended_desc = "A built-in app for cyborg self-management and diagnostics."
	ui_header = "robotact.gif" //DEBUG -- new icon before PR
	program_open_overlay = "command"
	program_flags = PROGRAM_HEADER
	undeletable = TRUE
	can_run_on_flags = PROGRAM_PDA
	size = 5
	tgui_id = "NtosRobotact"
	program_icon = "terminal"

/datum/computer_file/program/robotact/on_start(mob/living/user)
	if(!istype(computer, /obj/item/modular_computer/pda/silicon))
		to_chat(user, span_warning("A warning flashes across \the [computer]: Device Incompatible."))
		return FALSE
	. = ..()
	if(.)
		var/obj/item/modular_computer/pda/silicon/tablet = computer
		if(tablet.device_theme == PDA_THEME_SYNDICATE)
			program_open_overlay = "command-syndicate"
		return TRUE
	return FALSE
/**
 * Checks if we should see a specific cyborg on our "network". Arguments are our borg, and another borg
 *
 * Intended to allow borgs with the same AI to see eachother, syndicate borgs (scrambledcodes) with no AI to see eachother
 *  and not-syndicate borgs with no AI to see no one. Syndicate borgs connected to an AI will no longer see other syndicate
 *  borgs except ones also slaved to the same AI.
 */
/datum/computer_file/program/robotact/proc/evaluate_borg(mob/living/silicon/robot/this_borg, mob/living/silicon/robot/other_borg)
	if(this_borg.connected_ai != other_borg.connected_ai)
		return FALSE
	if(this_borg.scrambledcodes && other_borg.scrambledcodes)
		return TRUE
	if(this_borg.connected_ai)
		return TRUE

/datum/computer_file/program/robotact/ui_data(mob/user)
	var/list/data = list()
	if(!iscyborg(user))
		return data

	//Implied, since we can't run on non tablets
	var/obj/item/modular_computer/pda/silicon/tablet = computer

	var/mob/living/silicon/robot/cyborg = tablet.silicon_owner

	data["borgName"] = cyborg.name
	data["designation"] = cyborg.model
	data["masterAI"] = cyborg.connected_ai
	data["MasterAI_connected"] = !!cyborg.connected_ai //Need a bool for this on the other side
	data["masterAI_online"] = (cyborg.connected_ai?.stat == CONSCIOUS)

	var/charge = 0
	var/maxcharge = 1
	if(cyborg.cell)
		charge = cyborg.cell.charge
		maxcharge = cyborg.cell.maxcharge
	data["charge"] = charge //Current cell charge
	data["maxcharge"] = maxcharge //Cell max charge
	data["integrity"] = ((cyborg.health + 100) / 2) //health, as percentage
	data["lampIntensity"] = cyborg.lamp_intensity //lamp power setting
	data["lampConsumption"] = cyborg.lamp_power_consumption //Power consumption of the lamp per lamp intensity.
	data["sensors"] = "[cyborg.sensors_on?"ACTIVE":"DISABLED"]"
	data["printerPictures"] = cyborg.connected_ai? cyborg.connected_ai.aicamera.stored.len : cyborg.aicamera.stored.len //Number of pictures taken, synced to AI if available
	data["printerToner"] = cyborg.toner //amount of toner
	data["printerTonerMax"] = cyborg.tonermax //It's a variable, might as well use it
	data["thrustersInstalled"] = cyborg.ionpulse //If we have a thruster uprade
	data["thrustersStatus"] = "[cyborg.ionpulse_on?"ACTIVE":"DISABLED"]" //Feedback for thruster status
	data["selfDestructAble"] = (cyborg.emagged || istype(cyborg, /mob/living/silicon/robot/model/syndicate))

	data["cyborg_groups"] = list()
	if(data["masterAI_online"] || (!data["MasterAI_connected"] && cyborg.scrambledcodes)) //If a borg isn't connected, we can just skip this all
		var/list/borggroup = list() //temporary list for holding groups of borgs
		for(var/mob/living/silicon/robot/other_borg in GLOB.silicon_mobs)
			if(!evaluate_borg(cyborg,other_borg))
				continue

			var/shell = FALSE
			if(other_borg.shell && !other_borg.ckey)
				shell = TRUE

			var/list/cyborg_data = list(
				"otherBorgName" = other_borg.name,
				"integ" = round((other_borg.health + 100) / 2), //mob heath is -100 to 100, we want to scale that to 0 - 100
				"locked_down" = other_borg.lockcharge,
				"status" = other_borg.stat,
				"shell_discon" = shell,
				"charge" = other_borg.cell ? round(other_borg.cell.percent()) : null,
				"module" = other_borg.model ? "[other_borg.model.name]" : "None",
				"ref" = REF(other_borg)
			)
			borggroup += list(cyborg_data)
			if(length(borggroup) == 4) //grouping borgs in packs of four, since I can't do it later in js
				data["cyborg_groups"] += list(borggroup)
				borggroup = list()
		if(length(borggroup)) //and any remainders
			data["cyborg_groups"] += list(borggroup)

	//Cover, TRUE for locked
	data["cover"] = "[cyborg.locked? "LOCKED":"UNLOCKED"]"
	//Ability to move. FAULT if lockdown wire is cut, DISABLED if borg locked, ENABLED otherwise
	data["locomotion"] = "[cyborg.wires.is_cut(WIRE_LOCKDOWN)?"FAULT":"[cyborg.lockcharge?"DISABLED":"ENABLED"]"]"
	//Model wire. FAULT if cut, NOMINAL otherwise
	data["wireModule"] = "[cyborg.wires.is_cut(WIRE_RESET_MODEL)?"FAULT":"NOMINAL"]"
	//DEBUG -- Camera(net) wire. FAULT if cut (or no cameranet camera), DISABLED if pulse-disabled, NOMINAL otherwise
	data["wireCamera"] = "[!cyborg.builtInCamera || cyborg.wires.is_cut(WIRE_CAMERA)?"FAULT":"[cyborg.builtInCamera.can_use()?"NOMINAL":"DISABLED"]"]"
	//AI wire. FAULT if wire is cut, CONNECTED if connected to AI, READY otherwise
	data["wireAI"] = "[cyborg.wires.is_cut(WIRE_AI)?"FAULT":"[cyborg.connected_ai?"CONNECTED":"READY"]"]"
	//Law sync wire. FAULT if cut, NOMINAL otherwise
	data["wireLaw"] = "[cyborg.wires.is_cut(WIRE_LAWSYNC)?"FAULT":"NOMINAL"]"

	return data

/datum/computer_file/program/robotact/ui_static_data(mob/user)
	var/list/data = list()
	if(!iscyborg(user))
		return data
	var/mob/living/silicon/robot/cyborg = user
	//Implied
	var/obj/item/modular_computer/pda/silicon/tablet = computer

	data["Laws"] = cyborg.laws.get_law_list(TRUE, TRUE, FALSE)
	data["borgLog"] = tablet.borglog
	data["borgUpgrades"] = cyborg.upgrades
	return data

/datum/computer_file/program/robotact/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	//Implied type, memes
	var/obj/item/modular_computer/pda/silicon/tablet = computer
	var/mob/living/silicon/robot/cyborg = tablet.silicon_owner

	switch(action)
		if("coverunlock")
			if(cyborg.locked)
				cyborg.locked = FALSE
				cyborg.update_icons()
				if(cyborg.emagged)
					cyborg.logevent("ChÃ¥vÃis cover lock has been [cyborg.locked ? "engaged" : "released"]") //"The cover interface glitches out for a split second"
				else
					cyborg.logevent("Chassis cover lock has been [cyborg.locked ? "engaged" : "released"]")

		if("lawchannel")
			cyborg.set_autosay()

		if("lawstate")
			cyborg.checklaws()

		if("alertPower")
			if(cyborg.stat == CONSCIOUS)
				if(!cyborg.cell || !cyborg.cell.charge)
					cyborg.visible_message(span_notice("The power warning light on [span_name("[cyborg]")] flashes urgently."), \
						"You announce you are operating in low power mode.")
					playsound(cyborg, 'sound/machines/buzz/buzz-two.ogg', 50, FALSE)

		if("toggleSensors")
			cyborg.toggle_sensors()

		if("viewImage")
			if(cyborg.connected_ai)
				cyborg.connected_ai.aicamera?.viewpictures(usr)
			else
				cyborg.aicamera?.viewpictures(usr)

		if("printImage")
			var/obj/item/camera/siliconcam/robot_camera/borgcam = cyborg.aicamera
			borgcam?.borgprint(usr)

		if("toggleThrusters")
			cyborg.toggle_ionpulse()

		if("lampIntensity")
			cyborg.lamp_intensity = params["ref"]
			cyborg.toggle_headlamp(FALSE, TRUE)

		if("selfDestruct")
			if(cyborg.stat || cyborg.lockcharge) //No detonation while stunned or locked down
				return
			if(cyborg.emagged || istype(cyborg, /mob/living/silicon/robot/model/syndicate)) //This option shouldn't even be showing otherwise
				cyborg.self_destruct(cyborg)
