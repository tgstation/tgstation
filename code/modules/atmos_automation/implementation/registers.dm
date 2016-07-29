///////////////////
// Register data //
///////////////////

//Child is the register to get's id.
/datum/automation/get_register_data
	name = "Register: Get Data"
	returntype = AUTOM_RT_NUM
	valid_child_returntypes = list(AUTOM_RT_NUM)

/datum/automation/get_register_data/New(var/obj/machinery/computer/general_air_control/atmos_automation/aa)
	..(aa)
	children = list(null)

/datum/automation/get_register_data/Evaluate()
	var/datum/automation/field = children[1]
	var/registerid = Clamp(field.Evaluate(), 1, parent.register_amount)//Just in case.

	if(registerid)
		return parent.registers[registerid]
	return 0

/datum/automation/get_register_data/GetText()
	var/datum/automation/field = children[1]

	var/out = "Value from register: <a href='?src=\ref[src];setfield=1'>(Set Field)</a> ("
	if(field == null)
		out += "-----"
	else
		out += field.GetText()
	out += ")"
	return out

/datum/automation/get_register_data/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["setfield"])
		var/new_child = selectValidChildFor(usr)
		if(!new_child)
			return 1
		children[1] = new_child
		parent.updateUsrDialog()
		return 1

//Set this stuff.
//First child in the list is the register to get from's identifier.
//Second child is the value to set.
/datum/automation/set_register_data
	name = "Register: Set Data"
	valid_child_returntypes = list(AUTOM_RT_NUM)

/datum/automation/set_register_data/New(var/obj/machinery/computer/general_air_control/atmos_automation/aa)
	..(aa)
	children = list(null, null)

/datum/automation/set_register_data/process()
	if(!children[1] || !children[2])
		return
	var/datum/automation/idfield = children[1]
	var/datum/automation/valuefield = children[2]

	var/registerid = idfield.Evaluate()
	registerid = Clamp(registerid, 1, parent.register_amount)

	parent.registers[registerid] = valuefield.Evaluate()

/datum/automation/set_register_data/GetText()
	var/datum/automation/idfield = children[1]
	var/datum/automation/valuefield = children[2]

	var/out = "Set register: <a href='?src=\ref[src];setfield=1'>(Set Field)</a> ("
	if(idfield == null)
		out += "-----"
	else
		out += idfield.GetText()
	out += ") to value: <a href='?src=\ref[src];setfield=2'>(Set Field)</a> ("
	if(valuefield == null)
		out += "-----"
	else
		out += valuefield.GetText()
	out += ")"
	return out

datum/automation/set_register_data/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["setfield"])
		var/idx = text2num(href_list["setfield"])
		var/new_child = selectValidChildFor(usr)
		if(!new_child)
			return 1
		children[idx] = new_child
		parent.updateUsrDialog()
		return 1