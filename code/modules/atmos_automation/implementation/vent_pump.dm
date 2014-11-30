/datum/automation/set_vent_pump_mode
	name="Vent Pump: Mode"

	var/vent_pump=null
	var/mode="stabilize"

	var/list/modes = list("stabilize","purge")

	Export()
		var/list/json = ..()
		json["vent_pump"]=vent_pump
		json["mode"]=mode
		return json

	Import(var/list/json)
		..(json)
		vent_pump = json["vent_pump"]
		mode = json["mode"]

	New(var/obj/machinery/computer/general_air_control/atmos_automation/aa)
		..(aa)
		children=list(null)

	process()
		if(vent_pump)
			parent.send_signal(list ("tag" = vent_pump, mode))
		return 0

	GetText()
		return "Set vent pump <a href=\"?src=\ref[src];set_vent_pump=1\">[fmtString(vent_pump)]</a> mode to <a href=\"?src=\ref[src];set_mode=1\">[mode]</a>."

	Topic(href,href_list)
		if(href_list["set_mode"])
			mode = input("Select a mode to put this pump into.",mode) in modes
			parent.updateUsrDialog()
			return 1
		if(href_list["set_vent_pump"])
			var/list/injector_names=list()
			for(var/obj/machinery/atmospherics/unary/vent_pump/I in machines)
				if(!isnull(I.id_tag) && I.frequency == parent.frequency)
					injector_names|=I.id_tag
			for(var/obj/machinery/atmospherics/binary/dp_vent_pump/I in machines)
				if(!isnull(I.id_tag) && I.frequency == parent.frequency)
					injector_names|=I.id_tag
			vent_pump = input("Select a vent:", "Vent Pumps", vent_pump) as null|anything in injector_names
			parent.updateUsrDialog()
			return 1

/datum/automation/set_vent_pump_power
	name="Vent Pump: Power"

	var/vent_pump=null
	var/state=0

	Export()
		var/list/json = ..()
		json["vent_pump"]=vent_pump
		json["state"]=state
		return json

	Import(var/list/json)
		..(json)
		vent_pump = json["vent_pump"]
		state = text2num(json["state"])

	New(var/obj/machinery/computer/general_air_control/atmos_automation/aa)
		..(aa)

	process()
		if(vent_pump)
			parent.send_signal(list ("tag" = vent_pump, "power"=state))

	GetText()
		return "Set vent pump <a href=\"?src=\ref[src];set_vent_pump=1\">[fmtString(vent_pump)]</a> power to <a href=\"?src=\ref[src];set_power=1\">[state ? "on" : "off"]</a>."

	Topic(href,href_list)
		if(href_list["set_power"])
			state = !state
			parent.updateUsrDialog()
			return 1
		if(href_list["set_vent_pump"])
			var/list/injector_names=list()
			for(var/obj/machinery/atmospherics/unary/vent_pump/I in machines)
				if(!isnull(I.id_tag) && I.frequency == parent.frequency)
					injector_names|=I.id_tag
			for(var/obj/machinery/atmospherics/binary/dp_vent_pump/I in machines)
				if(!isnull(I.id_tag) && I.frequency == parent.frequency)
					injector_names|=I.id_tag
			vent_pump = input("Select a vent:", "Vent Pumps", vent_pump) as null|anything in injector_names
			parent.updateUsrDialog()
			return 1