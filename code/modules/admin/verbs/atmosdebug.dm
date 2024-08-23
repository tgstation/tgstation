ADMIN_VERB_VISIBILITY(atmos_debug, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(atmos_debug, R_DEBUG, "Check Plumbing", "Verifies the integrity of the plumbing network.", ADMIN_CATEGORY_MAPPING)
	BLACKBOX_LOG_ADMIN_VERB("Check Plumbing")

	//all plumbing - yes, some things might get stated twice, doesn't matter.
	for(var/obj/machinery/atmospherics/components/pipe as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/atmospherics/components))
		if(pipe.z && (!pipe.nodes || !pipe.nodes.len || (null in pipe.nodes)))
			to_chat(user, "Unconnected [pipe.name] located at [ADMIN_VERBOSEJMP(pipe)]", confidential = TRUE)

	//Pipes
	for(var/obj/machinery/atmospherics/pipe/pipe as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/atmospherics/pipe))
		if(istype(pipe, /obj/machinery/atmospherics/pipe/smart) || istype(pipe, /obj/machinery/atmospherics/pipe/layer_manifold))
			continue
		if(pipe.z && (!pipe.nodes || !pipe.nodes.len || (null in pipe.nodes)))
			to_chat(user, "Unconnected [pipe.name] located at [ADMIN_VERBOSEJMP(pipe)]", confidential = TRUE)

	//Nodes
	for(var/obj/machinery/atmospherics/node1 as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/atmospherics))
		for(var/obj/machinery/atmospherics/node2 in node1.nodes)
			if(!(node1 in node2.nodes))
				to_chat(user, "One-way connection in [node1.name] located at [ADMIN_VERBOSEJMP(node1)]", confidential = TRUE)

ADMIN_VERB_VISIBILITY(power_debug, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(power_debug, R_DEBUG, "Check Power", "Verifies the integrity of the power network.", ADMIN_CATEGORY_MAPPING)
	BLACKBOX_LOG_ADMIN_VERB("Check Power")
	var/list/results = list()

	for (var/datum/powernet/PN in SSmachines.powernets)
		if (!PN.nodes || !PN.nodes.len)
			if(PN.cables && (PN.cables.len > 1))
				var/obj/structure/cable/C = PN.cables[1]
				results += "Powernet with no nodes! (number [PN.number]) - example cable at [ADMIN_VERBOSEJMP(C)]"

		if (!PN.cables || (PN.cables.len < 10))
			if(PN.cables && (PN.cables.len > 1))
				var/obj/structure/cable/C = PN.cables[1]
				results += "Powernet with fewer than 10 cables! (number [PN.number]) - example cable at [ADMIN_VERBOSEJMP(C)]"

	for(var/turf/T in world.contents)
		var/cable_layers //cache all cable layers (which are bitflags) present
		for(var/obj/structure/cable/C in T.contents)
			if(cable_layers & C.cable_layer)
				results += "Doubled wire at [ADMIN_VERBOSEJMP(C)]"
			else
				cable_layers |= C.cable_layer
		var/obj/machinery/power/terminal/term = locate(/obj/machinery/power/terminal) in T.contents
		if(term)
			var/obj/structure/cable/C = locate(/obj/structure/cable) in T.contents
			if(!C)
				results += "Unwired terminal at [ADMIN_VERBOSEJMP(term)]"
	to_chat(user, "[results.Join("\n")]", confidential = TRUE)
