/datum/wires/robot
	random = 1
	holder_type = /mob/living/silicon/robot
	wire_count = 5

var/const/BORG_WIRE_LAWCHECK = 1
var/const/BORG_WIRE_MAIN_POWER = 2 // The power wires do nothing whyyyyyyyyyyyyy
var/const/BORG_WIRE_LOCKED_DOWN = 4
var/const/BORG_WIRE_AI_CONTROL = 8
var/const/BORG_WIRE_CAMERA = 16

/datum/wires/robot/GetInteractWindow()

	. = ..()
	var/mob/living/silicon/robot/R = holder
	. += text("<br>\n[(R.lawupdate ? "The LawSync light is on." : "The LawSync light is off.")]<br>\n[(R.connected_ai ? "The AI link light is on." : "The AI link light is off.")]")
	. += text("<br>\n[((!isnull(R.camera) && R.camera.status == 1) ? "The Camera light is on." : "The Camera light is off.")]<br>\n")
	. += text("<br>\n[(R.lockcharge ? "The lockdown light is on." : "The lockdown light is off.")]")
	return .

/datum/wires/robot/UpdateCut(var/index, var/mended)

	var/mob/living/silicon/robot/R = holder
	switch(index)
		if(BORG_WIRE_LAWCHECK) //Cut the law wire, and the borg will no longer receive law updates from its AI
			if(!mended)
				if (R.lawupdate == 1)
					R << "LawSync protocol engaged."
					R.show_laws()
			else
				if (R.lawupdate == 0 && !R.emagged)
					R.lawupdate = 1

		if (BORG_WIRE_AI_CONTROL) //Cut the AI wire to reset AI control
			if(!mended)
				if (R.connected_ai)
					R.connected_ai = null

		if (BORG_WIRE_CAMERA)
			if(!isnull(R.camera) && !R.scrambledcodes)
				R.camera.status = mended
				R.camera.deactivate(usr, 0) // Will kick anyone who is watching the Cyborg's camera.

		if(BORG_WIRE_LAWCHECK)	//Forces a law update if the borg is set to receive them. Since an update would happen when the borg checks its laws anyway, not much use, but eh
			if (R.lawupdate)
				R.lawsync()

		if(BORG_WIRE_LOCKED_DOWN)
			R.SetLockdown(!mended)


/datum/wires/robot/UpdatePulsed(var/index)

	var/mob/living/silicon/robot/R = holder
	switch(index)
		if (BORG_WIRE_AI_CONTROL) //pulse the AI wire to make the borg reselect an AI
			if(!R.emagged)
				R.connected_ai = select_active_ai()

		if (BORG_WIRE_CAMERA)
			if(!isnull(R.camera) && R.camera.can_use() && !R.scrambledcodes)
				R.camera.deactivate(usr, 0) // Kick anyone watching the Cyborg's camera, doesn't display you disconnecting the camera.
				R.visible_message("[R]'s camera lense focuses loudly.")
				R << "Your camera lense focuses loudly."

		if(BORG_WIRE_LOCKED_DOWN)
			R.SetLockdown(!R.lockcharge) // Toggle

/datum/wires/robot/CanUse(var/mob/living/L)
	var/mob/living/silicon/robot/R = holder
	if(R.wiresexposed)
		return 1
	return 0

/datum/wires/robot/proc/IsCameraCut()
	return wires_status & BORG_WIRE_CAMERA

/datum/wires/robot/proc/LockedCut()
	return wires_status & BORG_WIRE_LOCKED_DOWN