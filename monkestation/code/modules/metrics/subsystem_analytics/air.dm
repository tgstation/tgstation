/datum/controller/subsystem/air/get_metrics()
	. = ..()
	var/list/cust = list()
	cust["active_turfs"] = length(active_turfs)
	cust["hotspots"] = length(hotspots)
	.["custom"] = cust
