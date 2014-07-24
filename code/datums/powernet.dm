/datum/powernet
	var/list/cables = new // /obj/structure/cable
	var/list/nodes  = new // /obj/machinery/power (apcs not included)
	var/newload     = 0
	var/load        = 0
	var/newavail    = 0
	var/avail       = 0
	var/viewload    = 0
	var/number      = 0
	var/perapc      = 0   // per-apc avilability
	var/netexcess   = 0

/datum/powernet/New()
	..()
	powernets.Add(src)

/datum/powernet/Destroy()
	for(var/obj/machinery/power/node in nodes)
		node.powernet = null

	for(var/obj/structure/cable/cable in cables)
		cable.powernet = null

	powernets.Remove(src)
