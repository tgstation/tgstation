/datum/wires/robot
	holder_type = /mob/living/silicon/robot
	proper_name = "Cyborg"
	randomize = TRUE

/datum/wires/robot/New(atom/holder)
	wires = list(
		WIRE_AI, WIRE_CAMERA,
		WIRE_LAWSYNC, WIRE_LOCKDOWN,
		WIRE_RESET_MODEL
	)
	add_duds(2)
	..()

/datum/wires/robot/interactable(mob/user)
	if(!..())
		return FALSE
	var/mob/living/silicon/robot/R = holder
	if(R.wiresexposed)
		return TRUE

/datum/wires/robot/get_status()
	var/mob/living/silicon/robot/R = holder
	var/list/status = list()
	status += "The law sync module is [R.lawupdate ? "on" : "off"]."
	status += "The intelligence link display shows [R.connected_ai ? R.connected_ai.name : "NULL"]."
	status += "The camera light is [!isnull(R.builtInCamera) && R.builtInCamera.status ? "on" : "off"]."
	status += "The lockdown indicator is [R.lockcharge ? "on" : "off"]."
	status += "There is a star symbol above the [get_color_of_wire(WIRE_RESET_MODEL)] wire."
	return status

/datum/wires/robot/on_pulse(wire, user)
	var/mob/living/silicon/robot/R = holder
	switch(wire)
		if(WIRE_AI) // Pulse to pick a new AI.
			if(!R.emagged)
				var/new_ai
				if(user)
					new_ai = select_active_ai(user, R.z)
				else
					new_ai = select_active_ai(R, R.z)
				R.notify_ai(AI_NOTIFICATION_CYBORG_DISCONNECTED)
				if(new_ai && (new_ai != R.connected_ai))
					R.set_connected_ai(new_ai)
					log_combat(usr, R, "synced cyborg [R.connected_ai ? "from [ADMIN_LOOKUP(R.connected_ai)]": ""] to [ADMIN_LOOKUP(new_ai)]")
					if(R.shell)
						R.undeploy() //If this borg is an AI shell, disconnect the controlling AI and assign ti to a new AI
						R.notify_ai(AI_NOTIFICATION_AI_SHELL)
					else
						R.notify_ai(TRUE)
		if(WIRE_CAMERA) // Pulse to disable the camera.
			if(!QDELETED(R.builtInCamera) && !R.scrambledcodes)
				R.builtInCamera.toggle_cam(usr, FALSE)
				R.visible_message(span_notice("[R]'s camera lens focuses loudly."), span_notice("Your camera lens focuses loudly."))
				log_combat(usr, R, "toggled cyborg camera to [R.builtInCamera.status ? "on" : "off"] via pulse")
		if(WIRE_LAWSYNC) // Forces a law update if possible.
			if(R.lawupdate)
				R.visible_message(span_notice("[R] gently chimes."), span_notice("LawSync protocol engaged."))
				log_combat(usr, R, "forcibly synced cyborg laws via pulse")
				// TODO, log the laws they gained here
				R.lawsync()
				R.show_laws()
		if(WIRE_LOCKDOWN)
			R.SetLockdown(!R.lockcharge) // Toggle
			log_combat(usr, R, "[!R.lockcharge ? "locked down" : "released"] via pulse")

		if(WIRE_RESET_MODEL)
			if(R.has_model())
				R.visible_message(span_notice("[R]'s model servos twitch."), span_notice("Your model display flickers."))

/datum/wires/robot/on_cut(wire, mend)
	var/mob/living/silicon/robot/R = holder
	switch(wire)
		if(WIRE_AI) // Cut the AI wire to reset AI control.
			if(!mend)
				R.notify_ai(AI_NOTIFICATION_CYBORG_DISCONNECTED)
				log_combat(usr, R, "cut AI wire on cyborg[R.connected_ai ? " and disconnected from [ADMIN_LOOKUP(R.connected_ai)]": ""]")
				if(R.shell)
					R.undeploy()
				R.set_connected_ai(null)
			R.logevent("AI connection fault [mend?"cleared":"detected"]")
		if(WIRE_LAWSYNC) // Cut the law wire, and the borg will no longer receive law updates from its AI. Repair and it will re-sync.
			if(mend)
				if(!R.emagged)
					R.lawupdate = TRUE
					log_combat(usr, R, "enabled lawsync via wire")
			else if(!R.deployed) //AI shells must always have the same laws as the AI
				R.lawupdate = FALSE
				log_combat(usr, R, "disabled lawsync via wire")
			R.logevent("Lawsync Module fault [mend?"cleared":"detected"]")
		if (WIRE_CAMERA) // Disable the camera.
			if(!QDELETED(R.builtInCamera) && !R.scrambledcodes)
				R.builtInCamera.status = mend
				R.builtInCamera.toggle_cam(usr, 0)
				R.visible_message(span_notice("[R]'s camera lens focuses loudly."), span_notice("Your camera lens focuses loudly."))
				R.logevent("Camera Module fault [mend?"cleared":"detected"]")
				log_combat(usr, R, "[mend ? "enabled" : "disabled"] cyborg camera via wire")
		if(WIRE_LOCKDOWN) // Simple lockdown.
			R.SetLockdown(!mend)
			R.logevent("Motor Controller fault [mend?"cleared":"detected"]")
			log_combat(usr, R, "[!R.lockcharge ? "locked down" : "released"] via wire")
		if(WIRE_RESET_MODEL)
			if(R.has_model() && !mend)
				R.ResetModel()
				log_combat(usr, R, "reset the cyborg module via wire")

/datum/wires/robot/can_reveal_wires(mob/user)
	if(HAS_TRAIT(user, TRAIT_KNOW_CYBORG_WIRES))
		return TRUE

	return ..()

/datum/wires/robot/always_reveal_wire(color)
	// Always reveal the reset model wire.
	if(color == get_color_of_wire(WIRE_RESET_MODEL))
		return TRUE

	return ..()
