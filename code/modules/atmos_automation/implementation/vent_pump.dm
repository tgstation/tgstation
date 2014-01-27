/datum/automation/set_vent_pump_mode
	name="Vent Pump: Mode"

	var/vent_pump=null
	var/mode="stabilize"

	var/list/modes = list("stabilize","purge")

	valid_child_returntypes=list(AUTOM_RT_NUM)

	New(var/obj/machinery/computer/general_air_control/atmos_automation/aa)
		..(aa)
		children=list(null)

	process()
		if(vent_pump && children[1])
			var/datum/automation/A = children[1]
			if(A.Evaluate())
				parent.send_signal(list ("tag" = vent_pump, mode))
		return 0

	GetText()
		var/out= "Set vent pump <a href=\"?src=\ref[src];set_vent_pump=1\">[fmtString(vent_pump)]</a> mode to <a href=\"?src=\ref[src];set_mode=1\">[mode]</a> if: (<a href=\"?src=\ref[src];set_condition=1\">SET</a>): <blockquote>"
		if(children.len>0)
			var/datum/automation/C=children[1]
			out += C.GetText()
		else
			out += "\[No condition set\]"
		out += "</blockquote>"
		return out

	Topic(href,href_list)
		if(href_list["set_condition"])
			var/new_child=selectValidChildFor(usr)
			if(!new_child) return 1
			children[1] = new_child
			parent.updateUsrDialog()
			return 1
		if(href_list["set_mode"])
			mode = input("Select a mode to put this pump into.",mode) in modes
			parent.updateUsrDialog()
			return 1
		if(href_list["set_vent_pump"])
			var/list/injector_names=list()
			for(var/obj/machinery/atmospherics/unary/vent_pump/I in machines)
				if(!isnull(I.id_tag) && I.frequency == parent.frequency)
					injector_names|=I.id_tag
			vent_pump = input("Select an injector:", "Sensor Data", vent_pump) as null|anything in injector_names
			parent.updateUsrDialog()
			return 1

/datum/automation/set_vent_pump_power
	name="Vent Pump: Power"

	var/vent_pump=null
	var/state=0

	valid_child_returntypes=list(AUTOM_RT_NUM)

	New(var/obj/machinery/computer/general_air_control/atmos_automation/aa)
		..(aa)
		children=list(null)

	process()
		if(vent_pump && children[1])
			var/datum/automation/A = children[1]
			if(A.Evaluate())
				parent.send_signal(list ("tag" = vent_pump, "power"=state))
		return 0

	GetText()
		var/out= "Set vent pump <a href=\"?src=\ref[src];set_vent_pump=1\">[fmtString(vent_pump)]</a> power to <a href=\"?src=\ref[src];set_power=1\">[state ? "On" : "Off"]</a> if: (<a href=\"?src=\ref[src];set_condition=1\">SET</a>): <blockquote>"
		if(children.len>0)
			var/datum/automation/C=children[1]
			out += C.GetText()
		else
			out += "\[No condition set\]"
		out += "</blockquote>"
		return out

	Topic(href,href_list)
		if(href_list["set_condition"])
			var/new_child=selectValidChildFor(usr)
			if(!new_child) return 1
			children[1] = new_child
			parent.updateUsrDialog()
			return 1
		if(href_list["set_power"])
			state = !state
			parent.updateUsrDialog()
			return 1
		if(href_list["set_vent_pump"])
			var/list/injector_names=list()
			for(var/obj/machinery/atmospherics/unary/vent_pump/I in machines)
				if(!isnull(I.id_tag) && I.frequency == parent.frequency)
					injector_names|=I.id_tag
			vent_pump = input("Select an injector:", "Sensor Data", vent_pump) as null|anything in injector_names
			parent.updateUsrDialog()
			return 1