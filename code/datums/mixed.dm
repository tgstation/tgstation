//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/datum/data
	var/name = "data"
	var/size = 1.0


/datum/data/function
	name = "function"
	size = 2.0


/datum/data/function/data_control
	name = "data control"


/datum/data/function/id_changer
	name = "id changer"


/datum/data/record
	name = "record"
	size = 5.0
	var/list/fields = list(  )


/datum/data/text
	name = "text"
	var/data = null



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
