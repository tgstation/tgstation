//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/datum/powernet
	var/list/cables = list()	// all cables & junctions
	var/list/nodes = list()		// all APCs & sources

	var/newload = 0
	var/load = 0
	var/newavail = 0
	var/avail = 0
	var/viewload = 0
	var/number = 0
	var/perapc = 0			// per-apc avilability
	var/netexcess = 0



/datum/debug
	var/list/debuglist
