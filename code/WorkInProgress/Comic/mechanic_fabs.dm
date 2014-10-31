#define GEN_FAB_WIDTH 		1000	//Gen fab stands for General Fabricator
#define GEN_FAB_HEIGHT		600

#define GEN_FAB_BASETIME 	100

#define GEN_FAB_BASESTORAGE 150000

/obj/machinery/r_n_d/fabricator/mechanic_fab
	name = "General Fabricator"
	desc = "A machine used to produce items from blueprint designs."
	icon = 'icons/obj/machines/mechanic.dmi'
	icon_state = "genfab"
	max_material_storage = 150000
	nano_file = "genfab.tmpl"
	var/list/design_types = list("machine" = 0, "item" = 1)

	idle_power_usage = 20
	active_power_usage = 5000

	research_flags = NANOTOUCH | TAKESMATIN | HASOUTPUT

	part_sets = list("Items" = list())

/obj/machinery/r_n_d/fabricator/mechanic_fab/New()
	..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/generalfab,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser
	)

	RefreshParts()

/obj/machinery/r_n_d/fabricator/mechanic_fab/attackby(var/obj/O, var/mob/user)
	if(..())
		return 1
	if(istype(O, /obj/item/research_blueprint))
		var/obj/item/research_blueprint/RB = O
		if(!design_types[RB.design_type])
			user <<"<span class='warning'>This isn't the right machine for that kind of blueprint!</span>"
			return 0
		else if(RB.stored_design && design_types[RB.design_type])
			var/datum/design/mechanic_design/MD = RB.stored_design
			src.AddMechanicDesign(MD)
			overlays += "[base_state]-bp"
			user <<"<span class='notice'>You successfully load \the [MD.name] design into \the [src].</span>"
			qdel(RB)
			spawn(10)
				overlays -= "[base_state]-bp"

/obj/machinery/r_n_d/fabricator/mechanic_fab/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	if(stat & (BROKEN|NOPOWER))
		return
	if((user.stat && !isobserver(user)) || user.restrained() || !allowed(user))
		return

	var/data[0]
	var/queue_list[0]

	for(var/i=1;i<=queue.len;i++)
		var/datum/design/part = queue[i]
		queue_list.Add(list(list("name" = part.name, "cost" = output_part_cost(part), "commands" = list("remove_from_queue" = i))))

	data["queue"] = queue_list
	data["screen"]=screen
	var/materials_list[0]
		//Get the material names
	for(var/matID in materials)
		var/datum/material/material = materials[matID] // get the ID of the materials
		if(material && material.stored > 0)
			materials_list.Add(list(list("name" = material.processed_name, "storage" = material.stored, "commands" = list("eject" = matID)))) // get the amount of the materials
	data["materials"] = materials_list

	var/parts_list[0] // setup a list to get all the information for parts

	for(var/set_name in part_sets)
		//message_admins("Assiging parts to [set_name]")
		var/list/parts = part_sets[set_name]
		var/list/set_name_list = list()
		var/i = 0
		for(var/datum/design/mechanic_design/part in parts)
			//message_admins("Adding the [part.name] to the list")
			i++
			set_name_list.Add(list(list("name" = part.name, "uses" = part.uses, "cost" = output_part_cost(part), "time" = get_construction_time_w_coeff(part)/10, "command1" = list("add_to_queue" = "[i][set_name]"), "command2" = list("build" = "[i][set_name]"), "command3" = list("remove_design" = "[i][set_name]"))))
		parts_list[set_name] = set_name_list
	data["parts"] = parts_list // assigning the parts data to the data sent to UI

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		ui = new(user, src, ui_key, nano_file, name, FAB_SCREEN_WIDTH, FAB_SCREEN_HEIGHT)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/r_n_d/fabricator/Topic(href, href_list)

	if(..()) // critical exploit prevention, do not remove unless you replace it -walter0o
		return 1

	if(href_list["remove_design"])
		var/datum/design/part = getTopicDesign(href_list["remove_design"])
		remove_part_from_set(copytext(href_list["remove_design"], 2), part)
		return 1

/obj/machinery/r_n_d/fabricator/mechanic_fab/proc/AddMechanicDesign(var/datum/design/mechanic_design/design)
	if(istype(design))
		Gen_Mat_Reqs(design.build_path, design) //makes the material cost for the design. Weird to have here, I know, but it's the best place
		add_part_to_set(design.category, design)

//returns the required materials for the parts of a machine design
/obj/machinery/r_n_d/fabricator/mechanic_fab/proc/Gen_Mat_Reqs(var/obj/O, var/datum/design/mechanic_design/design)
	if(!O)
		message_admins("We couldn't find something in part checking, how did this happen?")
		return

	var/datum/design/part_design = FindDesign(O)
	if(part_design)
		part_design = new part_design
		design.materials = part_design.materials
		del(part_design)

	if(!design.materials.len) //let's make something up! complain about the RNG some other time
		var/techtotal = TechTotal(design)
		design.materials["$iron"] = techtotal * round(rand(500, 1500), 100)
		design.materials["$glass"] = techtotal * round(rand(250, 1000), 50)
		if(prob(techtotal * 5)) //let's add an extra cost of some medium-rare material
			design.materials[pick("$plasma", "$uranium", "$gold", "$silver")] = techtotal * round(rand(100, 500), 10)
		if(prob(techtotal * 2)) //and another cost, because we can
			design.materials[pick("$plasma", "$uranium", "$gold", "$silver")] = techtotal * round(rand(50, 250), 10)
		if(techtotal >= 15  && prob(techtotal)) //let's add something REALLY rare
			design.materials[pick("$diamond", "$clown", "$phazon")] = techtotal * round(rand(10, 150), 10)

/obj/machinery/r_n_d/fabricator/mechanic_fab/attackby(var/obj/item/O as obj, var/mob/user as mob)
	..()
	if (O.is_open_container())
		return 0

/obj/machinery/r_n_d/fabricator/mechanic_fab/build_part(var/datum/design/mechanic_design/part)
	if(..())
		if(part.uses > 0)
			part.uses--
			if(part.uses == 0)
				remove_part_from_set(part.category, part)

/obj/machinery/r_n_d/fabricator/mechanic_fab/add_to_queue(var/datum/design/mechanic_design/part)
	. = ..()
	if(part.uses > 0)
		part.uses--
		if(part.uses == 0)
			remove_part_from_set(part.category, part)
	return .