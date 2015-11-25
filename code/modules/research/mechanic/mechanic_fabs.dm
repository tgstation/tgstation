#define GEN_FAB_WIDTH 		850 //Gen fab stands for General Fabricator
#define GEN_FAB_HEIGHT		500

#define GEN_FAB_BASETIME 	5

#define GEN_FAB_BASESTORAGE 225000

#define PLASTIC_FRACTION 0.1
/obj/machinery/r_n_d/fabricator/mechanic_fab
	name = "General Fabricator"
	desc = "A machine used to produce items from blueprint designs."
	icon = 'icons/obj/machines/mechanic.dmi'
	icon_state = "genfab"
	max_material_storage = GEN_FAB_BASESTORAGE
	nano_file = "genfab.tmpl"
	var/list/design_types = list("item")
	var/removable_designs = 1
	var/plastic_added = 1 //if plastic costs are added for designs - the autolathe doesn't have this

	build_time = GEN_FAB_BASETIME

	idle_power_usage = 20
	active_power_usage = 5000

	research_flags = NANOTOUCH | TAKESMATIN | HASOUTPUT | IGNORE_CHEMS //we don't need chems to make boards

	part_sets = list("Items" = list())


/obj/machinery/r_n_d/fabricator/mechanic_fab/setup_part_sets()

	for(var/name_set in part_sets)
		var/list/part_set = part_sets[name_set]
		if(!istype(part_set) || !part_set.len)
			continue
		for(var/i = 1; i <= part_set.len; i++)
			var/obj/item/I = part_set[i]
			part_set[i] = getScanDesign(I)

	for(var/name_set in part_sets)
		var/list/part_set = part_sets[name_set]
		for(var/element in part_set)
			if(!istype(element, /datum/design))
				warning("[element] was left over in setting up parts.")
				part_set.Remove(element)


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

////PLASTIC COSTS///
//We add the plastic cost to this output so people can see it
/obj/machinery/r_n_d/fabricator/mechanic_fab/output_part_cost(var/datum/design/part)
	var/output = ..()
	if(plastic_added)
		output += " | [get_resource_cost_w_coeff(part, MAT_PLASTIC)] Plastic"
	return output

/obj/machinery/r_n_d/fabricator/mechanic_fab/get_resource_cost_w_coeff(var/datum/design/part as obj,var/resource as text, var/roundto=1)
	if(resource == MAT_PLASTIC && !(MAT_PLASTIC in part.materials)) //output the extra 0.1 plastic we need
		return round(part.MatTotal() * PLASTIC_FRACTION * resource_coeff, roundto)
	return round(part.materials[resource]*resource_coeff, roundto)

/obj/machinery/r_n_d/fabricator/mechanic_fab/remove_materials(var/datum/design/part)
	if(plastic_added)
		if(!(MAT_PLASTIC in part.materials) && !(research_flags & IGNORE_MATS))
			if(materials.getAmount(MAT_PLASTIC) < get_resource_cost_w_coeff(part, MAT_PLASTIC))
				return 0

	if(..()) //we passed the tests for the parent, and took resources
		if(plastic_added)
			if(!(MAT_PLASTIC in part.materials) && !(research_flags & IGNORE_MATS))
				materials.removeAmount(MAT_PLASTIC, get_resource_cost_w_coeff(part, MAT_PLASTIC))
		return 1
	return 0
///END PLASTIC COST///

/obj/machinery/r_n_d/fabricator/mechanic_fab/attackby(var/obj/O, var/mob/user)
	if(..())
		return 1
	if(istype(O, /obj/item/research_blueprint))
		var/obj/item/research_blueprint/RB = O
		if(!(RB.design_type in design_types))
			to_chat(user, "<span class='warning'>This isn't the right machine for that kind of blueprint!</span>")
			return 0
		else if(RB.stored_design && (RB.design_type in design_types))
			if(src.AddBlueprint(RB, user))
				if(src.AddMechanicDesign(RB.stored_design, user))
					overlays += "[base_state]-bp"
					to_chat(user, "<span class='notice'>You successfully load \the [RB.name] into \the [src].</span>")
					if(RB.delete_on_use)	qdel(RB) //we delete if the thing is set to delete. Always set to 1 right now
					spawn(10)
						overlays -= "[base_state]-bp"
		return 1

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
	data["screen"] = screen
	data["hacked"] = hacked
	var/materials_list[0]
		//Get the material names
	for(var/matID in materials.storage)
		var/datum/material/material = materials.getMaterial(matID) // get the ID of the materials
		if(material && materials.storage[matID] > 0)
			materials_list.Add(list(list("name" = material.processed_name, "storage" = materials.storage[matID], "commands" = list("eject" = matID)))) // get the amount of the materials
	data["materials"] = materials_list
	data["removableDesigns"] = removable_designs

	var/parts_list[0] // setup a list to get all the information for parts

	for(var/set_name in part_sets)
		//message_admins("Assiging parts to [set_name]")
		var/list/parts = part_sets[set_name]
		var/list/set_name_list = list()
		var/i = 0
		for(var/datum/design/part in parts)
			//message_admins("Adding the [part.name] to the list")
			i++
			set_name_list.Add(list(list("name" = part.name, "cost" = output_part_cost(part), "time" = get_construction_time_w_coeff(part)/10, "command1" = list("add_to_queue" = "[i][set_name]"), "command2" = list("build" = "[i][set_name]"), "command3" = list("remove_design" = "[i][set_name]"))))
		parts_list[set_name] = set_name_list
	data["parts"] = parts_list // assigning the parts data to the data sent to UI

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		ui = new(user, src, ui_key, nano_file, name, GEN_FAB_WIDTH, GEN_FAB_HEIGHT)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/r_n_d/fabricator/mechanic_fab/Topic(href, href_list)

	if(..()) // critical exploit prevention, do not remove unless you replace it -walter0o
		return 1
	if(href_list["remove_design"] && removable_designs)
		var/datum/design/part = getTopicDesign(href_list["remove_design"])
		remove_part_from_set(copytext(href_list["remove_design"], 2), part)
		return 1

/obj/machinery/r_n_d/fabricator/mechanic_fab/proc/AddBlueprint(var/obj/item/research_blueprint/blueprint, mob/user)
	if(!istype(blueprint) || !user) //sanity, yeah
		return

	var/datum/design/mechanic_design/BPdesign = blueprint.stored_design
	for(var/list in src.part_sets)
		for(var/datum/design/mechanic_design/MD in part_sets[list])
			if(MD == BPdesign) //because they're the same design, they make exactly the same thing
				to_chat(user, "You can't add that design, as it's already loaded into the machine!")
				return 0 //can't add to an infinite design
	return 1 //let's add the new design, since we haven't found it

/obj/machinery/r_n_d/fabricator/mechanic_fab/proc/AddMechanicDesign(var/datum/design/mechanic_design/design)
	if(istype(design))
		if(!design.materials.len)
			return 0
		if(add_part_to_set(design.category, design))
			return 1
		else
			return 0
	return 0
