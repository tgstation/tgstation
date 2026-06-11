/***************************************************************
** Design Datums   **
** All the data for building stuff.   **
***************************************************************/
/*
For the materials datum, it assumes you need reagents unless specified otherwise. To designate a material that isn't a reagent,
you use one of the material IDs below. These are NOT ids in the usual sense (they aren't defined in the object or part of a datum),
they are simply references used as part of a "has materials?" type proc. They all start with a $ to denote that they aren't reagents.
The currently supporting non-reagent materials. All material amounts are set as the define SHEET_MATERIAL_AMOUNT, which defaults to 100

Don't add new keyword/IDs if they are made from an existing one (such as rods which are made from iron). Only add raw materials.

Design Guidelines
- When adding new designs, check rdreadme.dm to see what kind of things have already been made and where new stuff is needed.
- A single sheet of anything is 100 units of material. Materials besides iron/glass require help from other jobs (mining for
other types of metals and chemistry for reagents).
- Add the AUTOLATHE tag to
*/

//DESIGNS ARE GLOBAL. DO NOT CREATE OR DESTROY THEM AT RUNTIME OUTSIDE OF INIT, JUST REFERENCE THEM TO WHATEVER YOU'RE DOING! //why are you yelling?
//DO NOT REFERENCE OUTSIDE OF SSRESEARCH. USE THE PROCS IN SSRESEARCH TO OBTAIN A REFERENCE.

/datum/design //Datum for object designs, used in construction
	/// Name of the created object
	var/name = "Name"
	/// Description of the created object
	var/desc = null
	/// The ID of the design. Used for quick reference. Alphanumeric, lower-case, no symbols
	var/id = DESIGN_ID_IGNORE
	/// Bitflags indicating what machines this design is compatable with. ([IMPRINTER]|[AWAY_IMPRINTER]|[PROTOLATHE]|[AWAY_LATHE]|[AUTOLATHE]|[MECHFAB]|[BIOGENERATOR]|[LIMBGROWER]|[SMELTER])
	var/build_type = null
	/// List of materials required to create one unit of the product. Format is (typepath or requirements datum) -> amount
	var/list/materials = list()
	/// The amount of time required to create one unit of the product.
	var/construction_time = 3.2 SECONDS
	/// The typepath of the object produced by this design
	var/build_path = null
	/// Reagent produced by this design. Currently only supported by the biogenerator.
	var/make_reagent
	/// What categories this design falls under. Used for sorting in production machines.
	var/list/category = list()
	/// List of reagents required to create one unit of the product. Currently only supported by the limb grower.
	var/list/reagents_list = list()
	/// How many times faster than normal is this to build on the protolathe
	var/lathe_time_factor = 1
	/// Bitflags indicating what departmental lathes should be allowed to process this design.
	var/departmental_flags = ALL
	/// What techwebs nodes unlock this design. Constructed by SSresearch
	var/list/datum/techweb_node/unlocked_by = list()
	/// Override for the automatic icon generation used for the research console.
	var/research_icon
	/// Override for the automatic icon state generation used for the research console.
	var/research_icon_state
	/// Appears to be unused.
	var/icon_cache
	/// Optional string that interfaces can use as part of search filters. See- item/borg/upgrade/ai and the Exosuit Fabs.
	var/search_metadata
	/// For protolathe designs that don't require reagents: If they can be exported to autolathes with a design disk or not.
	var/autolathe_exportable = TRUE

	/**
	 * A variable for if and how we want the printed object to receive the materials that were used to print it.
	 *
	 * * DESIGN_INHERIT_MATS: default setting, this will also be unit tested to ensure that the object built from an unupgraded protolathe
	 * has the same materials of an object of the same type only instantiated in a generic way.
	 * * DESIGN_INHERIT_MATS_SPECIAL: get the materials, but don't perform unit test checks
	 * * DESIGN_DONT_INHERIT_MATS: The printed object won't have the materials that were used to print it.
	 *
	 * P.S. unit test checks for materials are not performed on designs that use /datum/material_requirement.
	 * The only thing we would've to check in that case would be the amounts but not the types, and that isn't worth it.
	 */
	var/inherit_materials = DESIGN_INHERIT_MATS
	// If true, the efficiency of this design won't be influenced by the tier of the stock parts of the machine printing it
	var/fixed_cost_efficiency = FALSE

	/**
	 * If set, instead of transfering the contents of the materials var to the item(s), this list will be used.
	 * This is useful for printed items that possess fewer mats than those used in the process of printing them,
	 * Or items that in turn contain more items that can be extracted and recycled singularly.
	 *
	 * Here's an example of how it's supposed to be structured:
	 *	transfered_materials = list(
	 *		/obj/item/printed = list(/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 2.5),
	 *		/obj/item/inside_printed = list(/datum/material/glass = SMALL_MATERIAL_AMOUNT * 2.5),
	 *	)
	 *
	 * A few things to consider though:
	 * 1) It shouldn't include materials not present in the 'materials' variable.
	 * 2) The sum of each material in the lists shouldn't surpass what present in the 'materials' list.
	 * 3) It's incompatible with material_slot and material_requirement datums. This might change in the future, i dunno.
	 * 4) this does nothing if 'inherit_materials' is set to DESIGN_DONT_INHERIT_MATS.
	 *
	 * I've set a few unit test checks to make sure that things don't go wrong anyway, so don't worry too much about it
	 */
	var/list/transfered_materials

/datum/design/error_design
	name = "ERROR"
	desc = "This usually means something in the database has corrupted. If this doesn't go away automatically, inform Central Command so their techs can fix this ASAP(tm)"

/datum/design/Destroy()
	SSresearch.techweb_designs -= id
	return ..()

/datum/design/proc/InitializeMaterials()
	var/list/temp_list = list()
	// Go through all of our materials, get the subsystem instance, and then replace the list.
	for(var/mat_type, amount in materials)
		if(ispath(mat_type, /datum/material_requirement) || ispath(mat_type, /datum/material_slot))
			temp_list[mat_type] = amount
			continue

		// Not a material requirement, so get the ref the normal way
		var/datum/material/mat = SSmaterials.get_material(mat_type)
		temp_list[mat] = amount

	materials = temp_list

	for(var/object, mats in transfered_materials)
		temp_list = list()
		var/list/mat_list = mats
		for(var/mat_type in mat_list)
			var/datum/material/mat = SSmaterials.get_material(mat_type)
			temp_list[mat] = mat_list[mat_type]
		transfered_materials[object] = temp_list

/datum/design/proc/icon_html(client/user)
	var/datum/asset/spritesheet_batched/sheet = get_asset_datum(/datum/asset/spritesheet_batched/research_designs)
	sheet.send(user)
	return sheet.icon_tag(id)

/// Returns the description of the design
/datum/design/proc/get_description()
	var/obj/object_build_item_path = build_path

	return isnull(desc) ? initial(object_build_item_path.desc) : desc

/// Produce the resulting item, optionally with a specfic amount if we're a stack design
/datum/design/proc/create_result(atom/drop_loc, list/custom_materials, amount)
	if (!ispath(build_path, /obj/item/stack) && amount > 1)
		CRASH("[src] create_result was passed an amount higher than 1, despite not being a stack design!")

	if (!ispath(build_path, /obj/item/stack))
		return new build_path(drop_loc)

	if (isnull(amount))
		amount = 1
	return new build_path(drop_loc, amount)

///A proc that handles transfering the materials to the target object and anything it contains that isn't abstract. You can check the doc for var/list/transfered_materials for how it works.
/datum/design/proc/transfer_materials(list/custom_materials, multiplier, atom/target_object)
	SHOULD_NOT_OVERRIDE(TRUE)

	ASSERT(islist(custom_materials), "design/transfer_materials() called with invalid 'custom_materials' arg value")
	ASSERT(multiplier, "design/transfer_materials() called with invalid 'multiplier' arg value")
	ASSERT(isatom(target_object), "design/transfer_materials() called with invalid 'target_object' arg value")

	if(!length(transfered_materials)) //most common case where the object is just one thing and 'transferred_materials' is null
		simple_transfer_materials(custom_materials, multiplier, target_object)
		return

	var/list/recursive_contents = target_object.get_all_contents_type(/obj/item)

	for(var/obj/item/object as anything in recursive_contents)
		if(object.item_flags & ABSTRACT) //skip abstract entities
			continue
		if(!(object.type in transfered_materials))
			stack_trace("[object.type] missing from the 'transfered_materials' list of the design. Edit the 'transfered_materials' var of [type], or give it the ABSTRACT item flag if appropriate.")
			continue
		simple_transfer_materials(transfered_materials[object.type], multiplier, object)

///Called by [proc/transfer_materials] in two places and it's basically the meat and bone of the function. Having it as a separate proc reduces copypaste a little.
/datum/design/proc/simple_transfer_materials(list/custom_materials, multiplier, atom/target_object)
	SHOULD_NOT_OVERRIDE(TRUE)
	PRIVATE_PROC(TRUE)

	if(isstack(target_object))
		var/obj/item/stack/stack = target_object
		stack.mats_per_unit = SSmaterials.get_material_set_cache(custom_materials, multiplier / stack.amount)
		stack.update_custom_materials()
	else
		target_object.set_custom_materials(custom_materials, multiplier)

////////////////////////////////////////
//Disks for transporting design datums//
////////////////////////////////////////

/obj/item/disk/design_disk
	name = "Component Design Disk"
	desc = "A disk for storing device design data for construction in lathes."
	icon_state = "datadisk1"
	custom_materials = list(/datum/material/iron =SMALL_MATERIAL_AMOUNT * 3, /datum/material/glass =SMALL_MATERIAL_AMOUNT)

	///List of all `/datum/design` stored on the disk.
	var/list/blueprints = list()

/obj/item/disk/design_disk/Initialize(mapload)
	. = ..()
	if(mapload)
		pixel_x = base_pixel_x + rand(-5, 5)
		pixel_y = base_pixel_y + rand(-5, 5)

/**
 * Used for special interactions with a techweb when uploading the designs.
 * Args:
 * - stored_research - The techweb that's storing us.
 */
/obj/item/disk/design_disk/proc/on_upload(datum/techweb/stored_research, atom/research_source)
	return

/obj/item/disk/design_disk/bepis
	name = "Old experimental technology disk"
	desc = "A disk containing some long-forgotten technology from a past age. You hope it still works after all these years. Upload the disk to an R&D Console to redeem the tech."
	icon_state = "rndmajordisk"

	///The bepis node we have the design id's of
	var/datum/techweb_node/bepis_node

/obj/item/disk/design_disk/bepis/Initialize(mapload)
	. = ..()
	var/bepis_id = pick(SSresearch.techweb_nodes_experimental)
	bepis_node = (SSresearch.techweb_node_by_id(bepis_id))

	for(var/entry in bepis_node.design_ids)
		var/datum/design/new_entry = SSresearch.techweb_design_by_id(entry)
		blueprints += new_entry

///Unhide and research our node so we show up in the R&D console.
/obj/item/disk/design_disk/bepis/on_upload(datum/techweb/stored_research, atom/research_source)
	stored_research.hidden_nodes -= bepis_node.id
	stored_research.research_node(bepis_node, force = TRUE, auto_adjust_cost = FALSE, research_source = research_source)

/**
 * Subtype of Bepis tech disk
 * Removes the tech disk that's held on it from the experimental node list, making them not show up in future disks.
 */
/obj/item/disk/design_disk/bepis/remove_tech
	name = "Reformatted technology disk"
	desc = "A disk containing a new, completed tech from the B.E.P.I.S. Upload the disk to an R&D Console to redeem the tech."

/obj/item/disk/design_disk/bepis/remove_tech/Initialize(mapload)
	. = ..()
	SSresearch.techweb_nodes_experimental -= bepis_node.id
	log_research("[bepis_node.display_name] has been removed from experimental nodes through the BEPIS techweb's \"remove tech\" feature.")

