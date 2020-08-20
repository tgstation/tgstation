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
	///Log for things that happen to a borg
	var/list/borglog
	var/DEBUG_VAR1 = TRUE

/datum/computer_file/program/borgUI/ui_data(mob/user)
	var/list/data = get_header_data()
	if(!iscyborg(user))
		return data
	var/mob/living/silicon/robot/borgo = user

	var/charge = 0
	var/maxcharge = 1
	if(borgo.cell)
		charge = borgo.cell.charge
		maxcharge = borgo.cell.maxcharge
	data["charge"] = charge //Current cell charge
	data["maxcharge"] = maxcharge //Cell max charge

	data["integrity"] = ((borgo.health + 100) / 2) //Borgo health, as percentage
	data["modDisable"] = borgo.disabled_modules //Bitflag for number of disabled modules

	data["cover"] = "[borgo.locked? "LOCKED":"UNLOCKED"]" //DEBUG -- Cover, TRUE for locked
	data["locomotion"] = "[borgo.wires.is_cut(WIRE_LOCKDOWN)?"FAULT":"[borgo.lockcharge?"DISABLED":"ENABLED"]"]" //FAULT if lockdown wire is cut, enabled/disabled otherwise
	data["wireModule"] = "[borgo.wires.is_cut(WIRE_RESET_MODULE)?"FAULT":"NOMINAL"]" //Module wire. NOMINAL or FAULT
	data["wireCamera"] = "[!borgo.builtInCamera || borgo.wires.is_cut(WIRE_CAMERA)?"FAULT":"NOMINAL"]" //DEBUG -- Camera wire. NOMINAL or FAULT
	data["wireAI"] = "[borgo.connected_ai?"CONNECTED":"[borgo.wires.is_cut(WIRE_AI)?"FAULT":"READY"]"]" //AI wire. Connected, Ready, or FAULT
	data["wireLaw"] = "[borgo.wires.is_cut(WIRE_LAWSYNC)?"FAULT":"NOMINAL"]" //Law sync wire. NOMINAL or FAULT

	return data

/datum/computer_file/program/borgUI/ui_static_data(mob/user)
	var/list/data = list()
	if(!iscyborg(user))
		return data
	var/mob/living/silicon/robot/borgo = user

	data["name"] = borgo.name
	data["designation"] = borgo.designation //Borgo module type
	data["masterAI"] = borgo.connected_ai //Master AI
	var/list/laws = borgo.laws.get_law_list(TRUE, TRUE, DEBUG_VAR1)
	data["Laws"] = list(laws)
	data["borgLog"] = list(borglog)
	return data

/datum/computer_file/program/borgUI/ui_act(action, params)
	if(..())
		return

	to_chat(world, "DEBUG -- [action]")

