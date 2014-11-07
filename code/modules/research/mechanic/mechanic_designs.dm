/datum/design/mechanic_design //used to store the details of a scanned item or machine
	name = "" //the design name
	desc = ""

	var/design_type = "" //this is "machine" or "item" (not to be confused with design, this is just an indicator of type)
	build_path = null //used to store the type of the design itself (not to be confused with design type, this is the class of the thing)

	req_tech = list() //the origin tech of either the item, or the board in the machine
	var/obj/item/weapon/circuitboard/connected_circuit //used to store the type of the circuit in a scanned machine. Empty for items
	category = ""
	var/uses = 0 //counter of how many times you can make this design before it disappears!

/datum/design/mechanic_design/New(var/obj/O) //sets the name, type, design, origin_tech, and circuit, all by itself
	if(!istype(O))
		return
	name = O.name
	desc = initial(O.desc) //we use initial because some things edit the description
	build_path = O.type
	if(istype(O, /obj/machinery))
		var/obj/machinery/M = O
		design_type = "machine"
		if(M.component_parts && M.component_parts.len)
			category = "Machines"
			for(var/obj/item/weapon/circuitboard/CB in M.component_parts) //fetching the circuit by looking in the parts
				if(istype(CB))
					connected_circuit = CB.type
					break
		else if(istype(M, /obj/machinery/computer))
			category = "Computers"
			var/obj/machinery/computer/C = M
			if(C.circuit)
				connected_circuit = text2path(C.circuit)
		if(connected_circuit) //our tech is the circuit's requirement
			req_tech = ConvertReqString2List(initial(connected_circuit.origin_tech))
	else if(istype(O, /obj/item))
		var/obj/item/I = O
		category = "Items"
		design_type = "item"
		req_tech = ConvertReqString2List(I.origin_tech) //our tech is simply the item requirement
	if(!category)
		category = "Misc"

proc/ConvertReqString2List(var/list/source_list) //shamelessly ripped from the code for research machines. Shoot me - Comic
	var/list/temp_list = params2list(source_list)
	for(var/O in temp_list)
		temp_list[O] = text2num(temp_list[O])
	return temp_list