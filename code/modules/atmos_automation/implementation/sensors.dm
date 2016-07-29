
///////////////////////////////////////////
// sensor data
///////////////////////////////////////////

/datum/automation/get_sensor_data
	name = "Sensor: Get Data"
	var/field = "temperature"
	var/sensor = null

	returntype = AUTOM_RT_NUM

/datum/automation/get_sensor_data/Export()
	var/list/json = ..()
	json["sensor"] = sensor
	json["field"] = field
	return json

/datum/automation/get_sensor_data/Import(var/list/json)
	..(json)
	sensor = json["sensor"]
	field = json["field"]

/datum/automation/get_sensor_data/Evaluate()
	if(sensor && field && sensor in parent.sensor_information)
		return parent.sensor_information[sensor][field]
	return 0

/datum/automation/get_sensor_data/GetText()
	return "<a href=\"?src=\ref[src];set_field=1\">[fmtString(field)]</a> from sensor <a href=\"?src=\ref[src];set_sensor=1\">[fmtString(sensor)]</a>"

/datum/automation/get_sensor_data/Topic(href,href_list)
	. = ..()
	if(.)
		return

	if(href_list["set_field"])
		field = input("Select a sensor output:", "Sensor Data", field) as null | anything in list(
			"temperature",
			"pressure",
			"oxygen",
			"toxins",
			"nitrogen",
			"carbon_dioxide"
		)
		parent.updateUsrDialog()
		return 1

	if(href_list["set_sensor"])
		var/list/sensor_list = list()
		for(var/obj/machinery/air_sensor/G in machines)
			if(!isnull(G.id_tag) && G.frequency == parent.frequency)
				sensor_list |= G.id_tag
		for(var/obj/machinery/meter/M in machines)
			if(!isnull(M.id_tag) && M.frequency == parent.frequency)
				sensor_list |= M.id_tag
		sensor = input("Select a sensor:", "Sensor Data", field) as null|anything in sensor_list
		parent.updateUsrDialog()
		return 1
