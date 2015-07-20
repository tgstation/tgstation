client/verb/discon_pipes()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""]) \\client/verb/discon_pipes()  called tick#: [world.time]")
	set name = "Show Disconnected Pipes"
	set category = "Debug"

	for(var/obj/machinery/atmospherics/pipe/simple/P in atmos_machines)
		if(!P.node1 || !P.node2)
			usr << "[P], [P.x], [P.y], [P.z], [P.loc.loc]"

	for(var/obj/machinery/atmospherics/pipe/manifold/P in atmos_machines)
		if(!P.node1 || !P.node2 || !P.node3)
			usr << "[P], [P.x], [P.y], [P.z], [P.loc.loc]"

	for(var/obj/machinery/atmospherics/pipe/manifold4w/P in atmos_machines)
		if(!P.node1 || !P.node2 || !P.node3 || !P.node4)
			usr << "[P], [P.x], [P.y], [P.z], [P.loc.loc]"
//With thanks to mini. Check before use, uncheck after. Do Not Use on a live server.