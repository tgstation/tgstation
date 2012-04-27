client/verb/discon_pipes()
	set name = "Show Disconnected Pipes"
	set category = "Debug"

	for(var/obj/machinery/atmospherics/pipe/simple/P in world)
		if(!P.node1 || !P.node2)
			usr << "[P], [P.x], [P.y], [P.z], [P.loc.loc]"

	for(var/obj/machinery/atmospherics/pipe/manifold/P in world)
		if(!P.node1 || !P.node2 || !P.node3)
			usr << "[P], [P.x], [P.y], [P.z], [P.loc.loc]"

	for(var/obj/machinery/atmospherics/pipe/manifold4w/P in world)
		if(!P.node1 || !P.node2 || !P.node3 || !P.node4)
			usr << "[P], [P.x], [P.y], [P.z], [P.loc.loc]"
//With thanks to mini. Check before use, uncheck after. Do Not Use on a live server.