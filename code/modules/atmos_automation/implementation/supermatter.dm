///////////////////////////////////////////
// Supermatter sensor data
///////////////////////////////////////////

/datum/automation/get_sm_sensor_data
	name = "Supermatter: Get Monitor Data"
	var/field = "instability"
	var/sensor = null

	returntype = AUTOM_RT_NUM

/datum/automation/get_sm_sensor_data/Export()
	var/list/json = ..()
	json["sensor"] = sensor
	json["field"] = field
	return json

/datum/automation/get_sm_sensor_data/Import(var/list/json)
	..(json)
	sensor = json["sensor"]
	field = json["field"]

/datum/automation/get_sm_sensor_data/Evaluate()
	if(sensor && field && sensor in parent.sensor_information)
		return parent.sensor_information[sensor][field]
	return 0

/datum/automation/get_sm_sensor_data/GetText()
	return "<a href=\"?src=\ref[src];set_field=1\">[fmtString(field)]</a> from supermatter monitor <a href=\"?src=\ref[src];set_sensor=1\">[fmtString(sensor)]</a>"

/datum/automation/get_sm_sensor_data/Topic(href,href_list)
	. = ..()
	if(.)
		return

	if(href_list["set_field"])
		field = input("Select a supermatter monitor output:", "Monitor Data", field) as null | anything in list(
			"damage",
			"instability",
			"power",
		)
		parent.updateUsrDialog()
		return 1
	if(href_list["set_sensor"])
		var/list/sensor_list = list()
		for(var/obj/machinery/power/supermatter/M in power_machines)
			if(!isnull(M.id_tag) && M.frequency == parent.frequency)
				sensor_list |= M.id_tag
		sensor = input("Select a sensor:", "Sensor Data", field) as null | anything in sensor_list
		parent.updateUsrDialog()
		return 1
