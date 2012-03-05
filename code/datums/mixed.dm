/datum/data
	var
		name = "data"
		size = 1.0


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
	var
		list/cables = list()	// all cables & junctions
		list/nodes = list()		// all APCs & sources

		newload = 0
		load = 0
		newavail = 0
		avail = 0
		viewload = 0
		number = 0
		perapc = 0			// per-apc avilability
		netexcess = 0



/datum/debug
	var/list/debuglist