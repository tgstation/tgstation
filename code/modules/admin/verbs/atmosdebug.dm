/client/proc/atmosscan()
	set category = "Debug"
	set name = "Check Plumbing"
	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return

	for (var/obj/machinery/atmospherics/plumbing in world)
		if (plumbing.nodealert)
			usr << "Unconnected [plumbing.name] located at [plumbing.x],[plumbing.y],[plumbing.z] ([get_area(plumbing.loc)])"
