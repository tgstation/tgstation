
////////////////////////////////////////////
// Injector
////////////////////////////////////////////
/datum/automation/set_injector_power
	name = "Injector: Power"
	var/injector=null
	var/state=0

	Export()
		var/list/json = ..()
		json["injector"]=injector
		json["state"]=state
		return json

	Import(var/list/json)
		..(json)
		injector = json["injector"]
		state = text2num(json["state"])

	process()
		if(injector)
			parent.send_signal(list ("tag" = injector, "power"=state))
		return 0

	GetText()
		return "Set injector <a href=\"?src=\ref[src];set_injector=1\">[fmtString(injector)]</a> power to <a href=\"?src=\ref[src];toggle_state=1\">[state ? "on" : "off"]</a>."

	Topic(href,href_list)
		if(href_list["toggle_state"])
			state = !state
			parent.updateUsrDialog()
			return 1
		if(href_list["set_injector"])
			var/list/injector_names=list()
			for(var/obj/machinery/atmospherics/unary/outlet_injector/I in machines)
				if(!isnull(I.id_tag) && I.frequency == parent.frequency)
					injector_names|=I.id_tag
			injector = input("Select an injector:", "Sensor Data", injector) as null|anything in injector_names
			parent.updateUsrDialog()
			return 1

/datum/automation/set_injector_rate
	name = "Injector: Rate"
	var/injector=null
	var/rate=0

	Export()
		var/list/json = ..()
		json["injector"]=injector
		json["rate"]=rate
		return json

	Import(var/list/json)
		..(json)
		injector = json["injector"]
		rate = text2num(json["rate"])

	process()
		if(injector)
			parent.send_signal(list ("tag" = injector, "set_volume_rate"=rate))
		return 0

	GetText()
		return "Set injector <a href=\"?src=\ref[src];set_injector=1\">[fmtString(injector)]</a> transfer rate to <a href=\"?src=\ref[src];set_rate=1\">[rate]</a> L/s."

	Topic(href,href_list)
		if(href_list["set_rate"])
			rate = input("Set rate in L/s.", "Rate", rate) as num
			parent.updateUsrDialog()
			return 1
		if(href_list["set_injector"])
			var/list/injector_names=list()
			for(var/obj/machinery/atmospherics/unary/outlet_injector/I in machines)
				if(!isnull(I.id_tag) && I.frequency == parent.frequency)
					injector_names|=I.id_tag
			injector = input("Select an injector:", "Sensor Data", injector) as null|anything in injector_names
			parent.updateUsrDialog()
			return 1