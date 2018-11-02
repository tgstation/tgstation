////////////////////////////////////////////
// POWERNET DATUM
// each contiguous network of cables & nodes
/////////////////////////////////////
/datum/cablenet
	var/number					// unique id
	var/list/cables = list()	// all cables & junctions

/datum/cablenet/proc/is_empty()
	return !cables.len

//remove a cable from the current cablenet
//Warning : this proc DON'T check if the cable exists
/datum/cablenet/proc/remove_cable(obj/structure/cable/C)
	cables -= C
	C.network = null
	if(is_empty())//the powernet is now empty...
		qdel(src)///... delete it

//add a cable to the current cablenet
//Warning : this proc DON'T check if the cable exists
/datum/power/proc/add_cable(obj/structure/cable/C)
	if(C.network)// if C already has a powernet...
		if(C.network == src)
			return
		else
			C.network.remove_cable(C) //..remove it
	C.network = src
	cables += C
