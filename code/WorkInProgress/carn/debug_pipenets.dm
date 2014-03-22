/client/verb/pipenets_debug()
	if(!holder)	return
	for(var/i=1,i<=pipe_networks.len,i++)
//		src << "<a href='?"\ref[holder]";adminplayervars=\ref[powernets[i]]'>[copytext("\ref[powernets[i]]",8,12)]</A>"
		src << "<A HREF='?_src_=vars;Vars=\ref[pipe_networks[i]]'>[copytext("\ref[pipe_networks[i]]",8,12)]</A>"
	src << "[pipe_networks.len] total pipenets"


/client/verb/pipenet_overlays()
	var/list/L = list()
	for(var/obj/machinery/atmospherics/AT in view(mob))
		AT.maptext = null
		L |= AT
	for(var/datum/pipe_network/Network in pipe_networks)
		for(var/obj/machinery/atmospherics/AT in Network.normal_members)
			if(!(AT in L))
				continue
			if(!AT.maptext)
				AT.maptext = "<font color='white'>[copytext("\ref[Network]",8,12)]</font>"
			else
				world << "DUPLICATE: <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[AT.x];Y=[AT.y];Z=[AT.z]'>[AT.name]</a> net#<A HREF='?_src_=vars;Vars=\ref[Network]'>[copytext("\ref[Network]",8,12)]</A>)"
		for(var/datum/pipeline/PL in Network.line_members)
			for(var/obj/machinery/atmospherics/AT in PL.members)
				if(!(AT in L))
					continue
				if(!AT.maptext)
					AT.maptext = "<font color='green'>[copytext("\ref[Network]",8,12)]</font>"
				else
					world << "DUPLICATE: <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[AT.x];Y=[AT.y];Z=[AT.z]'>[AT.name]</a> net#<A HREF='?_src_=vars;Vars=\ref[Network]'>[copytext("\ref[Network]",8,12)]</A>)"
			for(var/obj/machinery/atmospherics/ATE in PL.edges)
				if(!(ATE in L))
					continue
				if(!ATE.maptext)
					ATE.maptext = "<font color='red'>[copytext("\ref[Network]",8,12)]</font>"
				else
					world << "DUPLICATE: <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[ATE.x];Y=[ATE.y];Z=[ATE.z]'>[ATE.name]</a> net#<A HREF='?_src_=vars;Vars=\ref[Network]'>[copytext("\ref[Network]",8,12)]</A>)"

/client/verb/follow_pipenet(var/netref as null|anything in get_refs(pipe_networks))
	var/datum/pipe_network/Network = locate(netref)
	if(!Network)
		src << "Unable to locate [netref]"
		return
	for(var/obj/machinery/atmospherics/AT in world)
		if(AT)
			animate(AT, alpha = 255, time = 0)
	for(var/obj/machinery/atmospherics/AT in Network.normal_members)
		if(AT)
			animate(AT, alpha = 0, time = 1, loop = -1)
			animate(alpha = 255, time = 1)
	for(var/datum/pipeline/PL in Network.line_members)
		for(var/obj/machinery/atmospherics/AT in PL.members)
			if(AT)
				animate(AT, alpha = 0, time = 1, loop = -1)
				animate(alpha = 255, time = 1)

/proc/get_refs(var/list/L)
	. = list()
	for(var/everything in L)
		. += "\ref[everything]"