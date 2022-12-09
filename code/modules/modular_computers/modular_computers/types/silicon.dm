/datum/modular_computer_host/silicon
	hardware_flag = PROGRAM_SILICON

//Integrated (Silicon) tablets don't drain power, because the tablet is required to state laws, so it being disabled WILL cause problems.
/datum/modular_computer_host/silicon/check_power_override()
	return TRUE

/datum/modular_computer_host/silicon/say(message, datum/computer_file/sender)
	silicon_push_notification(message, sender?.filename)

/datum/modular_computer_host/silicon/visible_message(message, datum/computer_file/sender, range)
	silicon_push_notification(message, sender?.filename)

///Private helper proc for silicons that displays a chat message. You should probably not call this directly.
/datum/modular_computer_host/silicon/proc/silicon_push_notification(message, sender)
	to_chat(physical, span_notice("Received push notification from [!isnull(sender) ? sender : "NtOS"]: \"[message]\""))

/datum/modular_computer_host/silicon/ui_state(mob/user)
	return GLOB.reverse_contained_state

// We don't inherit any of the signals because silicons work differently from everything else
/datum/modular_computer_host/silicon/register_signals()
	return

/datum/modular_computer_host/silicon/cyborg
	valid_on = /mob/living/silicon/robot
	hardware_flag = PROGRAM_CYBORG
	has_light = TRUE
	///Reference to our robotact program
	var/datum/computer_file/program/robotact/robotact
	///IC log that borgs can view in their personal management app
	var/list/borglog = list()
	///Our action icon, used for appearance and ui open hooks
	var/atom/movable/screen/robot/modpc/button

/datum/modular_computer_host/silicon/cyborg/New(datum/holder, cell_type, disk_type)
	. = ..()
	var/mob/living/silicon/robot/cyborg = physical
	button = cyborg.interfaceButton

/datum/modular_computer_host/silicon/cyborg/Destroy(force, ...)
	robotact = null
	button = null
	. = ..()

/datum/modular_computer_host/silicon/turn_on(mob/user, open_ui = FALSE)
	var/mob/living/silicon = physical
	if(silicon?.stat != DEAD)
		return ..()
	return FALSE

/datum/modular_computer_host/silicon/cyborg/get_ntnet_status(specific_action = 0)
	var/mob/living/silicon/robot/borg = physical
	//lockdown restricts borg networking
	if(borg.lockcharge)
		return NTNET_NO_SIGNAL
	//borg cell dying restricts borg networking
	if(!borg.cell || borg.cell.charge == 0)
		return NTNET_NO_SIGNAL

	return ..()

/**
 * Returns a ref to the RoboTact app, creating the app if need be.
 *
 * The RoboTact app is important for borgs, and so should always be available.
 * This proc will look for it in the tablet's robotact var, then check the
 * hard drive if the robotact var is unset, and finally attempt to create a new
 * copy if the hard drive does not contain the app. If the hard drive rejects
 * the new copy (such as due to lack of space), the proc will crash with an error.
 * RoboTact is supposed to be undeletable, so these will create runtime messages.
 */
/datum/modular_computer_host/silicon/cyborg/proc/get_robotact()
	if(istype(robotact) && !QDELETED(robotact))
		return robotact
	robotact = find_file_by_type(/datum/computer_file/program/robotact)
	if(istype(robotact))
		return robotact
	stack_trace("Cyborg [physical] ( [physical.type] ) was somehow missing their self-manage app in their tablet. A new copy has been created.")
	robotact = new
	if(store_file(robotact))
		return robotact
	QDEL_NULL(robotact)
	CRASH("Cyborg [physical]'s tablet hard drive rejected recieving a new copy of the self-manage app. To fix, check the hard drive's space remaining. Please make a bug report about this.")

//Makes the flashlight button affect the borg rather than the tablet
/datum/modular_computer_host/silicon/cyborg/toggle_flashlight()
	if(QDELETED(physical))
		return FALSE
	var/mob/living/silicon/robot/robo = physical
	robo.toggle_headlamp()
	return TRUE

//Makes the flashlight color setting affect the borg rather than the tablet
/datum/modular_computer_host/silicon/cyborg/set_flashlight_color(color)
	if(QDELETED(physical) || !color)
		return FALSE
	var/mob/living/silicon/robot/robo = physical
	robo.lamp_color = color
	robo.toggle_headlamp(FALSE, TRUE)
	return TRUE

//Makes the light settings reflect the borg's headlamp settings
/datum/modular_computer_host/silicon/cyborg/ui_data(mob/user)
	. = ..()
	var/mob/living/silicon/robot/robo = physical
	.["light_on"] = robo.lamp_enabled
	.["comp_light_color"] = robo.lamp_color

/datum/modular_computer_host/silicon/ai
	valid_on = /mob/living/silicon/ai
	hardware_flag = PROGRAM_AI
