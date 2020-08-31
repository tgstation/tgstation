/datum/computer_file/program/borgUI //generic parent that handles most of the process
	filename = "borgUI"
	filedesc = "borgUI"
	ui_header = "borg_mon.gif" //DEBUG -- new icon before PR
//	program_icon_state = "radarntos"
	requires_ntnet = FALSE
	transfer_access = null
	available_on_ntnet = FALSE
	usage_flags = PROGRAM_TABLET
	size = 5
	tgui_id = "NtosBorgUI"
	///A typed reference to the computer, specifying the borg tablet type
	var/obj/item/modular_computer/tablet/integrated/tablet

/datum/computer_file/program/borgUI/run_program(mob/living/user)
	if(!istype(computer, /obj/item/modular_computer/tablet/integrated))
		to_chat(user, "<span class='warning'>A warning flashes across /the [computer]: Device Incompatible.</span>")
		return FALSE
	if(..())
		tablet = computer
		return TRUE
	return FALSE

/datum/computer_file/program/borgUI/ui_data(mob/user)
	var/list/data = get_header_data()
	if(!iscyborg(user))
		return data
	var/mob/living/silicon/robot/borgo = tablet.borgo

	data["name"] = borgo.name
	data["designation"] = borgo.designation //Borgo module type
	data["masterAI"] = borgo.connected_ai //Master AI

	var/charge = 0
	var/maxcharge = 1
	if(borgo.cell)
		charge = borgo.cell.charge
		maxcharge = borgo.cell.maxcharge
	data["charge"] = charge //Current cell charge
	data["maxcharge"] = maxcharge //Cell max charge
	data["integrity"] = ((borgo.health + 100) / 2) //Borgo health, as percentage
	data["modDisable"] = borgo.disabled_modules //Bitflag for number of disabled modules
	data["sensors"] = borgo.sensors_on
	data["printerPictures"] = borgo.aicamera.stored.len //Number of pictures taken
	data["printerToner"] = borgo.toner //amount of toner
	data["printerTonerMax"] = borgo.tonermax //It's a variable, might as well use it
	data["thrustersInstalled"] = borgo.ionpulse
	data["thrustersStatus"] = borgo.ionpulse_on

	//DEBUG -- Cover, TRUE for locked
	data["cover"] = "[borgo.locked? "LOCKED":"UNLOCKED"]"
	//Ability to move. FAULT if lockdown wire is cut, DISABLED if borg locked, ENABLED otherwise
	data["locomotion"] = "[borgo.wires.is_cut(WIRE_LOCKDOWN)?"FAULT":"[borgo.lockcharge?"DISABLED":"ENABLED"]"]"
	//Module wire. FAULT if cut, NOMINAL otherwise
	data["wireModule"] = "[borgo.wires.is_cut(WIRE_RESET_MODULE)?"FAULT":"NOMINAL"]"
	//DEBUG -- Camera(net) wire. FAULT if cut (or no cameranet camera), DISABLED if pulse-disabled, NOMINAL otherwise
	data["wireCamera"] = "[!borgo.builtInCamera || borgo.wires.is_cut(WIRE_CAMERA)?"FAULT":"[borgo.builtInCamera.can_use()?"NOMINAL":"DISABLED"]"]"
	//AI wire. FAULT if wire is cut, CONNECTED if connected to AI, READY otherwise
	data["wireAI"] = "[borgo.wires.is_cut(WIRE_AI)?"FAULT":"[borgo.connected_ai?"CONNECTED":"READY"]"]"
	//Law sync wire. FAULT if cut, NOMINAL otherwise
	data["wireLaw"] = "[borgo.wires.is_cut(WIRE_LAWSYNC)?"FAULT":"NOMINAL"]"

	return data

/datum/computer_file/program/borgUI/ui_static_data(mob/user)
	var/list/data = list()
	if(!iscyborg(user))
		return data
	var/mob/living/silicon/robot/borgo = user

	data["Laws"] = borgo.laws.get_law_list(TRUE, TRUE, FALSE)
	data["borgLog"] = tablet.borglog
	data["borgUpgrades"] = borgo.upgrades
	return data

/datum/computer_file/program/borgUI/ui_act(action, params)
	if(..())
		return

	var/mob/living/silicon/robot/borgo = tablet.borgo

	to_chat(world, "DEBUG -- [action]")
	switch(action)
		if("coverunlock")
			if(borgo.locked)
				borgo.locked = FALSE
				borgo.update_icons()
				if(borgo.emagged)
					borgo.logevent("ChÃ¥vÃis cover lock has been [borgo.locked ? "engaged" : "released"]") //"The cover interface glitches out for a split second"
				else
					borgo.logevent("Chassis cover lock has been [borgo.locked ? "engaged" : "released"]")

		if("lawchannel")
			borgo.set_autosay()

		if("lawstate")
			borgo.checklaws()

		if("alertPower")
			if(borgo.stat == CONSCIOUS)
				if(!borgo.cell || !borgo.cell.charge)
					borgo.visible_message("<span class='notice'>The power warning light on <span class='name'>[src]</span> flashes urgently.</span>", \
						"You announce you are operating in low power mode.")
					playsound(borgo, 'sound/machines/buzz-two.ogg', 50, FALSE)

		if("toggleSensors")
			borgo.toggle_sensors()

		if("printImage")
			var/obj/item/camera/siliconcam/robot_camera/borgcam = borgo.aicamera
			borgcam?.borgprint(usr)

		if("toggleThrusters")
			borgo.toggle_ionpulse()

/**
  * Forces a full update of the UI, if currently open.
  *
  * Forces an update that includes refreshing ui_static_data. Called by
  * law changes and borg log additions.
  */
/datum/computer_file/program/borgUI/proc/force_full_update()
	if(tablet)
		SStgui.get_open_ui(tablet.borgo, src)?.send_full_update()
