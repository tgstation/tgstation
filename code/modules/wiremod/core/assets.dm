/datum/asset/json/circuit_components
	name = "circuit components"

/datum/asset/json/circuit_components/generate()
	var/list/circuit_data = list()

	for (var/component_type in subtypesof(/obj/item/circuit_component))
		var/obj/item/circuit_component/circuit_info = new component_type()
		var/list/component_data = list()

		var/list/input_info = list()
		for(var/datum/port/input/port as anything in circuit_info.input_ports)
			input_info += list(list(
				"name" = port.name,
				"datatype" = port.datatype,
			))
		var/list/output_info = list()
		for(var/datum/port/output/port as anything in circuit_info.output_ports)
			output_info += list(list(
				"name" = port.name,
				"datatype" = port.datatype,
			))

		component_data["name"] = circuit_info.display_name
		component_data["description"] = circuit_info.desc
		component_data["category"] = circuit_info.category
		component_data["type"] = component_type

		component_data["input_ports"] = input_info
		component_data["output_ports"] = output_info

		circuit_data += list(component_data)
		qdel(circuit_info)

	return circuit_data
