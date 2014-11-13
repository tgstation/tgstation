/datum/design/mechanic_design //used to store the details of a scanned item or machine
	name = "" //the design name
	desc = ""

	var/design_type = "" //this is "machine" or "item" (not to be confused with design, this is just an indicator of type)
	build_path = null //used to store the type of the design itself (not to be confused with design type, this is the class of the thing)

	req_tech = list() //the origin tech of either the item, or the board in the machine
	var/obj/item/weapon/circuitboard/connected_circuit //used to store the type of the circuit in a scanned machine. Empty for items
	category = ""

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
		Gen_Mach_Reqs(M.type)
		Gen_Tech_Mats(1.5)//consider using M.component_parts.len for this in the future
	else if(istype(O, /obj/item))
		var/obj/item/I = O
		var/found_design = FindDesign(I)
		category = "Items"
		design_type = "item"
		if(found_design)
			var/datum/design/D = new found_design
			//message_admins("Found the [D]")
			req_tech = D.req_tech //our tech is simply the item requirement
			materials = D.materials
			del(D)
		else
			req_tech = ConvertReqString2List(I.origin_tech)
			Gen_Tech_Mats(1)
	if(!category)
		category = "Misc"

	return src

/datum/design/mechanic_design/proc/Gen_Tech_Mats(var/modifier = 1)
	if(modifier < 0) //fuck off
		return
	var/techtotal = src.TechTotal() / 2
	materials["$iron"] = techtotal * round(rand(300, 1500), 100) * modifier
	materials["$glass"] = techtotal * round(rand(150, 300), 50) * modifier
	materials["$plastic"] = techtotal * 1000 * modifier //pretty much a sheet of plastic per two tech levels
	if(prob(techtotal * 15)) //let's add an extra cost of some medium-rare material - sure a lot of items
		materials[pick("$plasma", "$uranium", "$gold", "$silver")] = techtotal * round(rand(50, 250), 10) * modifier
	if(prob(techtotal * 5))//and another cost, because we can - can proc for some items
		materials[pick("$plasma", "$uranium", "$gold", "$silver")] = techtotal * round(rand(50, 250), 10) * modifier
	if(techtotal >= 6) //let's add something REALLY rare - bananium and phazon removed for now
		materials[/*pick(*/"$diamond"/*, "$clown", "$phazon")*/] = techtotal * round(rand(10, 150), 10) * modifier

//returns the required materials for the parts of a machine design
/datum/design/mechanic_design/proc/Gen_Mach_Reqs(var/obj/machinery/machine)
	if(!machine)
		message_admins("We couldn't find something in part checking, how did this happen?")
		return

	materials["$iron"] += 15000 //base costs, the best costs

	if(istype(machine, /obj/machinery/computer))
		var/datum/design/circuit_design = FindDesign(connected_circuit)
		if(circuit_design)
			//message_admins("Found the circuit design")
			circuit_design = new circuit_design
			for(var/matID in circuit_design.materials)
				if(copytext(matID,1,2) == "$")
					materials[matID] += circuit_design.materials[matID]
			del(circuit_design)
		else
			materials["$glass"] += 2000
			//message_admins("Couldn't find the board")
		return 1

	else

		var/obj/machinery/test_machine = new machine
		//why do we instance?
		//because components are generated in New()

		for(var/obj/item/thispart in test_machine.component_parts)
			//message_admins("We're trying to find the design for [thispart]")
			var/datum/design/part_design = FindDesign(thispart)
			if(!part_design)
				materials["$iron"] += round(rand(50, 500), 10)
				materials["$glass"] += round(rand(20, 300), 10)
				continue
			//message_admins("We found the design!")
			part_design = new part_design
			var/list/fetched_materials = part_design.materials
			for(var/matID in fetched_materials)
				if(copytext(matID,1,2) == "$")
					materials[matID] += fetched_materials[matID]
			del(part_design)

		//gets rid of the instancing
		qdel(test_machine)
		return 1

proc/ConvertReqString2List(var/list/source_list) //shamelessly ripped from the code for research machines. Shoot me - Comic
	var/list/temp_list = params2list(source_list)
	for(var/O in temp_list)
		temp_list[O] = text2num(temp_list[O])
	return temp_list