/***************************************************************
**						Design Datums						  **
**	All the data for building stuff.						  **
***************************************************************/
/*
For the materials datum, it assumes you need reagents unless specified otherwise. To designate a material that isn't a reagent,
you use one of the material IDs below. These are NOT ids in the usual sense (they aren't defined in the object or part of a datum),
they are simply references used as part of a "has materials?" type proc. They all start with a $ to denote that they aren't reagents.
The currently supporting non-reagent materials. All material amounts are set as the define MINERAL_MATERIAL_AMOUNT, which defaults to 2000
- MAT_METAL (/obj/item/stack/metal).
- MAT_GLASS (/obj/item/stack/glass).
- MAT_PLASMA (/obj/item/stack/plasma).
- MAT_SILVER (/obj/item/stack/silver).
- MAT_GOLD (/obj/item/stack/gold).
- MAT_URANIUM (/obj/item/stack/uranium).
- MAT_DIAMOND (/obj/item/stack/diamond).
- MAT_BANANIUM (/obj/item/stack/bananium).
(Insert new ones here)

Don't add new keyword/IDs if they are made from an existing one (such as rods which are made from metal). Only add raw materials.

Design Guidelines
- When adding new designs, check rdreadme.dm to see what kind of things have already been made and where new stuff is needed.
- A single sheet of anything is 2000 units of material. Materials besides metal/glass require help from other jobs (mining for
other types of metals and chemistry for reagents).
- Add the AUTOLATHE tag to
*/

//DESIGNS ARE GLOBAL. DO NOT CREATE OR DESTROY THEM AT RUNTIME OUTSIDE OF INIT, JUST REFERENCE THEM TO WHATEVER YOU'RE DOING! //why are you yelling?

/datum/design						//Datum for object designs, used in construction
	var/name = DESIGN_NAME_IGNORE					//Name of the created object.
	var/desc = DESIGN_DESC_IGNORE					//Description of the created object.
	var/id = DESIGN_ID_IGNORE						//ID of the created object for easy refernece. Alphanumeric, lower-case, no symbols
	var/build_type = null				//Flag as to what kind machine the design is built in. See defines.
	var/list/materials = list()			//List of materials. Format: "id" = amount.
	var/construction_time				//Amount of time required for building the object
	var/build_path = null				//The file path of the object that gets created
	var/list/make_reagents = list()			//Reagents produced. Format: "id" = amount. Currently only supported by the biogenerator.
	var/list/category = null 			//Primarily used for Mech Fabricators, but can be used for anything
	var/list/reagents_list = list()			//List of reagents. Format: "id" = amount.
	var/maxstack = 1
	var/lathe_time_factor = 1			//How many times faster than normal is this to build on the protolathe
	var/dangerous_construction = FALSE	//notify and log for admin investigations if this is printed.
	var/departmental_flags = ALL			//bitflags for deplathes.
	var/list/unlocking_node_ids = list()
	var/icon_cache

/datum/design/proc/icon_html(client/user)
	var/datum/asset/spritesheet/sheet = get_asset_datum(/datum/asset/spritesheet/research_designs)
	sheet.send(user)
	return sheet.icon_tag(id)

/datum/design/Destroy()
	SSresearch.designs -= id
	return ..()

/datum/design/serialize_list(list/options)
	var/list/jsonlist = list()
	if(istext(name))
		jsonlist["name"] = name
	if(istext(desc))
		jsonlist["desc"] = desc
	if(istext(id))
		jsonlist["id"] = id
	if(isnum(build_type))
		jsonlist["build_type"] = build_type
	if(islist(materials))
		jsonlist["materials"] = materials
	if(isnum(construction_time))
		jsonlist["construction_time"] = construction_time
	if(ispath(build_path))
		jsonlist["build_path"] = build_path
	if(islist(make_reagents))
		jsonlist["make_reagents"] = make_reagents
	if(islist(category))
		jsonlist["category"] = category
	if(islist(reagents_list))
		jsonlist["reagents_list"] = reagents_list
	if(isnum(maxstack))
		jsonlist["maxstack"] = maxstack
	if(isnum(lathe_time_factor))
		jsonlist["lathe_time_factor"] = lathe_time_factor
	if(isnum(dangerous_construction))
		jsonlist["dangerous_construction"] = dangerous_construction
	if(isnum(departmental_flags))
		jsonlist["departmental_flags"] = departmental_flags
	return jsonlist

/datum/design/deserialize_list(list/jsonlist, list/options)
	if(!islist(jsonlist))
		if(!istext(jsonlist))
			CRASH("Invalid json")
			return
		jsonlist = json_decode(jsonlist)
		if(!islist(jsonlist))
			CRASH("Invalid json")
			return
	if(istext(jsonlist["name"]))
		name = jsonlist["name"]
	if(istext(jsonlist["desc"]))
		desc = jsonlist["desc"]
	if(istext(jsonlist["id"]))
		id = jsonlist["id"]
	if(isnum(jsonlist["build_type"]))
		build_type = jsonlist["build_type"]
	if(islist(jsonlist["materials"]))
		var/list/L = jsonlist["materials"]
		materials = L.Copy()
	if(isnum(jsonlist["construction_time"]))
		construction_time = jsonlist["construction_time"]
	if(jsonlist["build_path"])
		if(!ispath(jsonlist["build_path"]))
			jsonlist["build_path"] = text2path(jsonlist["build_path"])
		if(ispath(jsonlist["build_path"]))
			build_path = jsonlist["build_path"]
	if(islist(jsonlist["make_reagents"]))
		var/list/L = jsonlist["make_reagents"]
		make_reagents = L.Copy()
	if(islist(jsonlist["category"]))
		var/list/L = jsonlist["category"]
		category = L.Copy()
	if(isnum(jsonlist["maxstack"]))
		maxstack = jsonlist["maxstack"]
	if(isnum(jsonlist["lathe_time_factor"]))
		lathe_time_factor = jsonlist["lathe_time_factor"]
	if(isnum(jsonlist["dangerous_construction"]))
		dangerous_construction = jsonlist["dangerous_construction"]
	if(isnum(jsonlist["departmental_flags"]))
		departmental_flags = jsonlist["departmental_flags"]
	return src

////////////////////////////////////////
//Disks for transporting design datums//
////////////////////////////////////////

/obj/item/disk/design_disk
	name = "Component Design Disk"
	desc = "A disk for storing device design data for construction in lathes."
	icon_state = "datadisk1"
	materials = list(MAT_METAL=300, MAT_GLASS=100)
	var/list/blueprints = list()
	var/max_blueprints = 1

/obj/item/disk/design_disk/Initialize()
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)
	for(var/i in 1 to max_blueprints)
		blueprints += null

/obj/item/disk/design_disk/adv
	name = "Advanced Component Design Disk"
	desc = "A disk for storing device design data for construction in lathes. This one has extra storage space."
	materials = list(MAT_METAL=300, MAT_GLASS=100, MAT_SILVER = 50)
	max_blueprints = 5
