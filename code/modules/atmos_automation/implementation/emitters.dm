/datum/automation/set_emitter_power
	name = "Emitter: Set Power"
	var/emitter = null
	var/on = 0

/datum/automation/set_emitter_power/Export()
	var/list/json = ..()
	json["emitter"] = emitter
	json["on"] = on
	return json

/datum/automation/set_emitter_power/Import(var/list/json)
	..(json)
	emitter = json["emitter"]
	on = text2num(json["on"])

/datum/automation/set_emitter_power/process()
	if(emitter)
		parent.send_signal(list ("tag" = emitter, "command"="set","state"=on))
	return 0

/datum/automation/set_emitter_power/GetText()
	return "Set emitter <a href=\"?src=\ref[src];set_subject=1\">[fmtString(emitter)]</a> to <a href=\"?src=\ref[src];set_power=1\">[on?"on":"off"]</a>."

/datum/automation/set_emitter_power/Topic(href,href_list)
	. = ..()
	if(.)
		return

	if(href_list["set_power"])
		on = !on
		parent.updateUsrDialog()
		return 1

	if(href_list["set_subject"])
		var/list/emitters = list()
		for(var/obj/machinery/power/emitter/E in power_machines)
			if(!isnull(E.id_tag) && E.frequency == parent.frequency)
				emitters |= E.id_tag

		if(emitters.len == 0)
			to_chat(usr, "<span class='warning'>Unable to find any emitters on this frequency.</span>")
			return

		emitter = input("Select an emitter:", "Emitter", emitter) as null | anything in emitters
		parent.updateUsrDialog()
		return 1
