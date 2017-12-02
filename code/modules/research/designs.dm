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

Design Guidlines
- When adding new designs, check rdreadme.dm to see what kind of things have already been made and where new stuff is needed.
- A single sheet of anything is 2000 units of material. Materials besides metal/glass require help from other jobs (mining for
other types of metals and chemistry for reagents).
- Add the AUTOLATHE tag to
*/

//DESIGNS ARE GLOBAL. DO NOT CREATE OR DESTROY THEM AT RUNTIME OUTSIDE OF INIT, JUST REFERENCE THEM TO WHATEVER YOU'RE DOING!

/datum/design						//Datum for object designs, used in construction
	var/name = "Name"					//Name of the created object.
	var/desc = "Desc"					//Description of the created object.
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
	var/departmental_flags = NONE			//bitflags for deplathes.
	var/list/datum/techweb_node/unlocked_by = list()
	var/icon_cache

/datum/design/Destroy()
	CRASH("DESIGN DATUMS SHOULD NOT EVER BE DESTROYED AS THEY ARE ONLY MEANT TO BE IN A GLOBAL LIST AND REFERENCED FOR US.")
	return ..()

/datum/design/proc/icon_html(client/user)
	if (!icon_cache)
		// construct the icon and slap it into the resource cache
		var/atom/item = build_path
		if (!ispath(item, /atom))
			// biogenerator outputs to beakers by default
			if (build_type & BIOGENERATOR)
				item = /obj/item/reagent_containers/glass/beaker/large
			else
				return  // shouldn't happen, but just in case

		// circuit boards become their resulting machines or computers
		if (ispath(item, /obj/item/circuitboard))
			var/obj/item/circuitboard/C = item
			var/machine = initial(C.build_path)
			if (machine)
				item = machine
		var/icon_file = initial(item.icon)
		var/icon/I = icon(icon_file, initial(item.icon_state), SOUTH)

		// computers (and snowflakes) get their screen and keyboard sprites
		if (ispath(item, /obj/machinery/computer) || ispath(item, /obj/machinery/power/solar_control))
			var/obj/machinery/computer/C = item
			var/screen = initial(C.icon_screen)
			var/keyboard = initial(C.icon_keyboard)
			if (screen)
				I.Blend(icon(icon_file, screen, SOUTH), ICON_OVERLAY)
			if (keyboard)
				I.Blend(icon(icon_file, keyboard, SOUTH), ICON_OVERLAY)

		// based on icon2html
		icon_cache = "[generate_asset_name(I)].png"
		register_asset(icon_cache, I)
	send_asset(user, icon_cache, FALSE)
	return "<img class='icon' src=\"[url_encode(icon_cache)]\">"

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
