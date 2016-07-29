

/datum/automation/set_valve_state
	name = "Digital Valve: Set Open/Closed"
	var/valve=null
	var/state=0

	Export()
		var/list/json = ..()
		json["valve"]=valve
		json["state"]=state
		return json

	Import(var/list/json)
		..(json)
		valve = json["valve"]
		state = text2num(json["state"])

	process()
		if(valve)
			parent.send_signal(list ("tag" = valve, "command"="valve_set","state"=state))
		return 0

	GetText()
		return "Set digital valve <a href=\"?src=\ref[src];set_subject=1\">[fmtString(valve)]</a> to <a href=\"?src=\ref[src];set_state=1\">[state?"open":"closed"]</a>."

	Topic(href,href_list)
		if(href_list["set_state"])
			state=!state
			parent.updateUsrDialog()
			return 1
		if(href_list["set_subject"])
			var/list/valves=list()
			for(var/obj/machinery/atmospherics/binary/valve/digital/V in atmos_machines)
				if(!isnull(V.id_tag) && V.frequency == parent.frequency)
					valves|=V.id_tag
			if(valves.len==0)
				to_chat(usr, "<span class='warning'>Unable to find any digital valves on this frequency.</span>")
				return
			valve = input("Select a valve:", "Sensor Data", valve) as null|anything in valves
			parent.updateUsrDialog()
			return 1