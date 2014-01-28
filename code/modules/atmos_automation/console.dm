/obj/machinery/computer/general_air_control/atmos_automation
	icon = 'icons/obj/computer.dmi'
	icon_state = "atmos"

	show_sensors=0

	var/on=0

	name = "Atmospherics Automations Console"

	var/list/datum/automation/automations=list()

	receive_signal(datum/signal/signal)
		if(!signal || signal.encryption) return

		var/id_tag = signal.data["tag"]
		if(!id_tag)
			return

		sensor_information[id_tag] = signal.data

	process()
		if(on)
			for(var/datum/automation/A in automations)
				A.process()

	proc/request_device_refresh(var/device)
		send_signal(list("tag"=device, "status"))

	proc/send_signal(var/list/data)
		var/datum/signal/signal = new
		signal.transmission_method = 1 //radio signal
		signal.source = src
		signal.data=data
		signal.data["sigtype"]="command"
		radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

	proc/selectValidChildFor(var/datum/automation/parent, var/mob/user, var/list/valid_returntypes)
		var/list/choices=list()
		for(var/childtype in automation_types)
			var/datum/automation/A = new childtype(src)
			if(A.returntype == null)
				continue
			if(!(A.returntype in valid_returntypes))
				continue
			choices[A.name]=A
		if (choices.len==0)
			testing("Unable to find automations with returntype in [english_list(valid_returntypes)]!")
			return 0
		var/label=input(user, "Select new automation:", "Automations", "Cancel") as null|anything in choices
		if(!label)
			return 0
		return choices[label]

	return_text()
		var/out=..()

		if(on)
			out += "<a href=\"?src=\ref[src];on=1\" style=\"font-size:large;font-weight:bold;color:red;\">RUNNING</a>"
		else
			out += "<a href=\"?src=\ref[src];on=1\" style=\"font-size:large;font-weight:bold;color:green;\">STOPPED</a>"

		out += {"
			<h2>Automations</h2>
			<p>\[
			<a href="?src=\ref[src];add=1">
				Add
			</a>
			|
			<a href="?src=\ref[src];reset=*">
				Reset All
			</a>
			|
			<a href="?src=\ref[src];remove=*">
				Clear
			</a>
			\]</p>"}
		if(automations.len==0)
			out += "<i>No automations present.</i>"
		else
			for(var/datum/automation/A in automations)
				out += {"
					<fieldset>
						<legend>
							<a href="?src=\ref[src];label=\ref[A]">[A.label]</a>
							(<a href="?src=\ref[src];reset=\ref[A]">Reset</a> |
							<a href="?src=\ref[src];remove=\ref[A]">&times;</a>)
						</legend>
						[A.GetText()]
					</fieldset>
				"}
		return out

	Topic(href,href_list)
		if(href_list["on"])
			on = !on
			updateUsrDialog()
			return 1

		if(href_list["add"])
			var/new_child=selectValidChildFor(null,usr,list(0))
			if(!new_child)
				return 1
			automations += new_child
			updateUsrDialog()
			return 1

		if(href_list["label"])
			var/datum/automation/A=locate(href_list["label"])
			if(!A) return 1
			var/nl=input(usr, "Please enter a label for this automation task.") as text|null
			if(!nl) return 1
			nl	= copytext(sanitize(nl), 1, 50)
			A.label=nl
			updateUsrDialog()
			return 1

		if(href_list["reset"])
			if(href_list["reset"]=="*")
				for(var/datum/automation/A in automations)
					if(!A) continue
					A.OnReset()
			else
				var/datum/automation/A=locate(href_list["label"])
				if(!A) return 1
				A.OnReset()
			updateUsrDialog()
			return 1

		if(href_list["remove"])
			if(href_list["remove"]=="*")
				var/confirm=input("Are you sure you want to remove ALL automations?","Automations","No") in list("Yes","No")
				if(confirm == "No") return 0
				for(var/datum/automation/A in automations)
					if(!A) continue
					A.OnRemove()
					automations.Remove(A)
			else
				var/datum/automation/A=locate(href_list["label"])
				if(!A) return 1
				A.OnRemove()
				automations.Remove()
			updateUsrDialog()
			return 1

/obj/machinery/computer/general_air_control/atmos_automation/burnchamber
	var/injector_tag="inc_in"
	var/output_tag="inc_out"
	var/sensor_tag="inc_sensor"
	frequency=1449
	var/temperature=1000
	New()
		..()

		// On State
		// Pretty much this:
		//set_injector_state(injector_tag,1,get_sensor_data(sensor_tag,"temperature") < temperature)

		var/datum/automation/get_sensor_data/sensor=new(src)
		sensor.sensor=sensor_tag
		sensor.field="temperature"

		var/datum/automation/static_value/val = new(src)
		val.value=temperature - 800

		var/datum/automation/compare/compare=new(src)
		compare.comparator = "Less Than"
		compare.children[1] = sensor
		compare.children[2] = val

		var/datum/automation/set_injector_power/inj_on=new(src)
		inj_on.injector=injector_tag
		inj_on.state=1

		var/datum/automation/set_vent_pump_power/vp_on=new(src)
		vp_on.vent_pump=output_tag
		vp_on.state=1

		var/datum/automation/set_vent_pump_power/vp_off=new(src)
		vp_off.vent_pump=output_tag
		vp_off.state=0

		var/datum/automation/if_statement/i = new (src)
		i.label = "Fuel Injector On"
		i.condition = compare
		i.children_then.Add(inj_on)
		i.children_then.Add(vp_off)
		i.children_else.Add(vp_on)

		automations += i

		// Off state
		sensor=new(src)
		sensor.sensor=sensor_tag
		sensor.field="temperature"

		val = new(src)
		val.value=temperature

		compare=new(src)
		compare.comparator = "Greater Than"
		compare.children[1] = sensor
		compare.children[2] = val

		var/datum/automation/set_injector_power/inj_off=new(src)
		inj_off.injector=injector_tag
		inj_off.state=0

		i = new (src)
		i.label = "Fuel Injector Off"
		i.condition = compare
		i.children_then.Add(inj_off)

		automations += i
