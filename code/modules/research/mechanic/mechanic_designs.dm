/datum/design/mechanic_design //used to store the details of a scanned item or machine
	name = "" //the design name
	desc = ""

	//var/design_type = "" //this is "machine" or "item" (not to be confused with design, this is just an indicator of type) //Comic why
	build_path = null //used to store the type of the design itself (not to be confused with design type, this is the class of the thing)

	req_tech = list() //the origin tech of either the item, or the board in the machine
	category = ""

/datum/design/mechanic_design/New(var/obj/O) //sets the name, type, design, origin_tech, and circuit, all by itself
	if(!istype(O))
		return
	name = O.name
	desc = initial(O.desc) //we use initial because some things edit the description
	build_path = O.type
	design_list += src //puts us in the design list to be found later, possibly

	if(istype(O, /obj/machinery))
		var/obj/machinery/M = O
		build_type = FLATPACKER
		materials += list(MAT_IRON = 5 * CC_PER_SHEET_METAL) //cost of the frame
		if(M.component_parts && M.component_parts.len)
			category = "Machines"
			for(var/obj/item/I in M.component_parts) //fetching the circuit by looking in the parts
				if(istype(I, /obj/item/weapon/circuitboard))
					var/obj/item/weapon/circuitboard/CB = I
					req_tech = ConvertReqString2List(CB.origin_tech) //our tech is the circuit's requirement

				var/datum/design/part_design = FindDesign(I)
				if(part_design)
					copyCost(part_design, filter_chems = 1) //copy those materials requirements

		else if(istype(M, /obj/machinery/computer))
			category = "Computers"
			var/obj/machinery/computer/C = M
			if(C.circuit)
				var/obj/item/weapon/circuitboard/CB = text2path(C.circuit)
				req_tech = ConvertReqString2List(initial(CB.origin_tech)) //have to use initial because it's a path
				var/datum/design/circuit_design = FindTypeDesign(CB)
				if(circuit_design)
					copyCost(circuit_design, filter_chems = 1)

	else if(istype(O, /obj/item))
		var/obj/item/I = O
		category = "Items"
		build_type = GENFAB
		req_tech = ConvertReqString2List(I.origin_tech)
		if(I.materials)
			for(var/matID in I.materials.storage)
				if(I.materials.storage[matID] > 0)
					materials += list("[matID]" = I.materials.storage[matID])
		else
			Gen_Tech_Mats()

	if(!category)
		category = "Misc"

	return src

//Takes the materials of a design, and adds them to this one
/datum/design/mechanic_design/proc/copyCost(var/datum/design/D, filter_mats = 0, filter_chems = 0)
	for(var/matID in D.materials)
		if(copytext(matID, 1, 2) == "$")
			if(filter_mats)
				continue
		else
			if(filter_chems)
				continue

		if(!(matID in materials))
			materials += list("[matID]" = 0)

		materials[matID] += D.materials[matID]

//Saved for use maybe some other time - used to generate random additional costs
/datum/design/mechanic_design/proc/Gen_Tech_Mats(var/modifier = 1)
	if(modifier < 0) //fuck off
		return
	var/techtotal = src.TechTotal() / 2
	materials[MAT_IRON] += techtotal * round(rand(300, 1500), 100) * modifier
	materials[MAT_GLASS] += techtotal * round(rand(150, 300), 50) * modifier
	if(src.build_type == GENFAB)
		if(prob(techtotal * 15)) //let's add an extra cost of some medium-rare material - sure a lot of items
			materials[pick(MAT_PLASMA, MAT_URANIUM, MAT_GOLD, MAT_SILVER)] += techtotal * round(rand(50, 250), 10) * modifier
		if(prob(techtotal * 8))//and another cost, because we can - can proc for some items
			materials[pick(MAT_PLASMA, MAT_URANIUM, MAT_GOLD, MAT_SILVER)] += techtotal * round(rand(50, 250), 10) * modifier
		if(techtotal >= 7) //let's add something REALLY rare - bananium and phazon removed for now
			materials[/*pick(*/MAT_DIAMOND/*, MAT_CLOWN, MAT_PHAZON)*/] += techtotal * round(rand(10, 150), 10) * modifier

	for(var/matID in materials)
		materials[matID] -= (materials[matID] % 20) //clean up the numbers

proc/ConvertReqString2List(var/list/source_list) //shamelessly ripped from the code for research machines. Shoot me - Comic
	var/list/temp_list = params2list(source_list)
	for(var/O in temp_list)
		temp_list[O] = text2num(temp_list[O])
	return temp_list
