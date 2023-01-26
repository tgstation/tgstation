ADMIN_VERB(mapping, check_plumbing, "", R_DEBUG)
	//all plumbing - yes, some things might get stated twice, doesn't matter.
	for(var/obj/machinery/atmospherics/components/pipe in GLOB.machines)
		if(pipe.z && (!pipe.nodes || !pipe.nodes.len || (null in pipe.nodes)))
			to_chat(usr, "Unconnected [pipe.name] located at [ADMIN_VERBOSEJMP(pipe)]", confidential = TRUE)

	//Pipes
	for(var/obj/machinery/atmospherics/pipe/pipe in GLOB.machines)
		if(istype(pipe, /obj/machinery/atmospherics/pipe/smart) || istype(pipe, /obj/machinery/atmospherics/pipe/layer_manifold))
			continue
		if(pipe.z && (!pipe.nodes || !pipe.nodes.len || (null in pipe.nodes)))
			to_chat(usr, "Unconnected [pipe.name] located at [ADMIN_VERBOSEJMP(pipe)]", confidential = TRUE)

	//Nodes
	for(var/obj/machinery/atmospherics/node1 in GLOB.machines)
		for(var/obj/machinery/atmospherics/node2 in node1.nodes)
			if(!(node1 in node2.nodes))
				to_chat(usr, "One-way connection in [node1.name] located at [ADMIN_VERBOSEJMP(node1)]", confidential = TRUE)

ADMIN_VERB(mapping, check_power, "", R_DEBUG)
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
	to_chat(usr, "[results.Join("\n")]", confidential = TRUE)
