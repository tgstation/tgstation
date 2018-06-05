/client/proc/atmosscan()
	set category = "Mapping"
	set name = "Check Plumbing"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Plumbing") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	//all plumbing - yes, some things might get stated twice, doesn't matter.
	for (var/obj/machinery/atmospherics/plumbing in GLOB.machines)
		if (plumbing.nodealert)
			to_chat(usr, "Unconnected [plumbing.name] located at [ADMIN_VERBOSEJMP(plumbing)]")

	//Manifolds
	for (var/obj/machinery/atmospherics/pipe/manifold/pipe in GLOB.machines)
		if (!pipe.nodes[1] || !pipe.nodes[2] || !pipe.nodes[3])
			to_chat(usr, "Unconnected [pipe.name] located at [ADMIN_VERBOSEJMP(pipe)]")

	//Pipes
	for (var/obj/machinery/atmospherics/pipe/simple/pipe in GLOB.machines)
		if (!pipe.nodes[1] || !pipe.nodes[2])
			to_chat(usr, "Unconnected [pipe.name] located at [ADMIN_VERBOSEJMP(pipe)]")

/client/proc/powerdebug()
	set category = "Mapping"
	set name = "Check Power"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Power") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	for (var/datum/powernet/PN in GLOB.powernets)
		if (!PN.nodes || !PN.nodes.len)
			if(PN.cables && (PN.cables.len > 1))
				var/obj/structure/cable/C = PN.cables[1]
				to_chat(usr, "Powernet with no nodes! (number [PN.number]) - example cable at [ADMIN_VERBOSEJMP(C)]")

		if (!PN.cables || (PN.cables.len < 10))
			if(PN.cables && (PN.cables.len > 1))
				var/obj/structure/cable/C = PN.cables[1]
				to_chat(usr, "Powernet with fewer than 10 cables! (number [PN.number]) - example cable at [ADMIN_VERBOSEJMP(C)]")
