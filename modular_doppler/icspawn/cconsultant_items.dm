//////////
//datums//
//////////

/datum/id_trim/admin/ccid
	assignment = "Continuity Consultant"
	trim_state = "trim_stationengineer"
	department_color = COLOR_VOID_PURPLE
	subdepartment_color = COLOR_ENGINEERING_ORANGE

/datum/armor/vest_debug
	melee = 95
	melee = 95
	laser = 95
	energy = 95
	bomb = 95
	bio = 95
	fire = 98
	acid = 98

/datum/outfit/debug/cconsultant
	name = "Continuity Consultant"
	uniform = /obj/item/clothing/under/syndicate/combat
	belt = /obj/item/storage/belt/utility/chief/full/debug
	shoes = /obj/item/clothing/shoes/combat/debug
	id = /obj/item/card/id/advanced/debug/ccid
	box = /obj/item/storage/box/debugtools
	backpack_contents = list(
		/obj/item/storage/part_replacer/bluespace/tier4/cconsultant = 1,
		/obj/item/gun/magic/wand/resurrection/debug = 1,
		/obj/item/gun/magic/wand/death/debug = 1,
		/obj/item/debug/human_spawner = 1,
		/obj/item/debug/omnitool = 1,
		/obj/item/storage/box/stabilized = 1,
	)

/datum/outfit/admin/cconsultant
	name = "Continuity Consultant (MODsuit)"
	uniform = /obj/item/clothing/under/syndicate/combat
	belt = /obj/item/storage/belt/utility/chief/full/debug
	shoes = /obj/item/clothing/shoes/combat/debug
	id = /obj/item/card/id/advanced/debug/ccid
	box = /obj/item/storage/box/debugtools
	backpack_contents = list(
		/obj/item/storage/part_replacer/bluespace/tier4/cconsultant = 1,
		/obj/item/gun/magic/wand/resurrection/debug = 1,
		/obj/item/gun/magic/wand/death/debug = 1,
		/obj/item/debug/human_spawner = 1,
		/obj/item/debug/omnitool = 1,
		/obj/item/storage/box/stabilized = 1,
	)

/////////
//items//
/////////

/obj/item/card/id/advanced/debug/ccid
	name = "\improper Continuity Consultant ID"
	desc = "An obscure ID card. In your peripheral vision the plasticene surface swims with flowing color."
	icon_state = "card_centcom"
	assigned_icon_state = "assigned_centcom"
	trim = /datum/id_trim/admin/ccid
	wildcard_slots = WILDCARD_LIMIT_ADMIN

/obj/item/clothing/suit/armor/vest/debug
	name = "Continuity Consultant vest"
	desc = "A sleek piece of armour designed for Bluespace agents."
	armor_type = /datum/armor/vest_debug
	w_class = WEIGHT_CLASS_TINY

/obj/item/clothing/shoes/combat/debug
	w_class = WEIGHT_CLASS_TINY

/obj/item/storage/belt/utility/chief/full/debug
	name = "\improper Continuity Consultant's belt"
	w_class = WEIGHT_CLASS_TINY

/obj/item/storage/part_replacer/bluespace/tier4/cconsultant
	name = "\improper Continuity Consultant RPED"
	desc = "A specialized bluespace RPED that can manufacture stock parts on the fly. Alt-Right-Click to manufacture parts, change settings, or clear its internal storage."
	/// Whether or not auto-clear is enabled
	var/auto_clear = TRUE
	/// List of valid types for pick_stock_part().
	var/static/list/valid_stock_part_types = list(
		/obj/item/circuitboard/machine,
		/obj/item/stock_parts,
		/obj/item/reagent_containers/cup/beaker,
	)

/obj/item/storage/part_replacer/bluespace/tier4/cconsultant/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 1000
	atom_storage.max_total_storage = 20000

/// cconsultants' special Bluespace RPED can manufacture parts on Alt-RMB, either cables, glass, machine boards, or stock parts.
/obj/item/storage/part_replacer/bluespace/tier4/cconsultant/click_alt_secondary(mob/user)
	// Ask the user what they want to make, or if they want to clear the storage.
	var/spawn_selection = tgui_input_list(user, "Pick a part, or clear storage", "RPED Manufacture", list("Clear All Items", "Toggle Auto-Clear", "Cables", "Glass", "Spare T4s", "Machine Board", "Stock Part", "Beaker"))
	// If they didn't cancel out of the list selection, we do things.  Clear-all removes all items, auto-clear destroys left-overs after upgrades, and everything else is pretty self-explanatory.
	// Machine boards and stock parts use a recursive subtype selector.
	if(isnull(spawn_selection))
		return
	else if(spawn_selection == "Clear All Items")
		var/list/inv_grab = atom_storage.return_inv(FALSE)
		for(var/obj/item/stored_item in inv_grab)
			qdel(stored_item)
	else if(spawn_selection == "Toggle Auto-Clear")
		auto_clear = !auto_clear
		to_chat(user, span_notice("The RPED will now [(auto_clear ? "destroy" : "keep")] items left-over after upgrades."))
	else if(spawn_selection == "Cables")
		atom_storage.attempt_insert(new /obj/item/stack/cable_coil(src), user, TRUE)
	else if(spawn_selection == "Glass")
		atom_storage.attempt_insert(new /obj/item/stack/sheet/glass/fifty(src), user, TRUE)
	else if(spawn_selection == "Spare T4s")
		for(var/i in 1 to 10)
			atom_storage.attempt_insert(new /obj/item/stock_parts/capacitor/quadratic(src), user, TRUE)
			atom_storage.attempt_insert(new /obj/item/stock_parts/scanning_module/triphasic(src), user, TRUE)
			atom_storage.attempt_insert(new /obj/item/stock_parts/servo/femto(src), user, TRUE)
			atom_storage.attempt_insert(new /obj/item/stock_parts/micro_laser/quadultra(src), user, TRUE)
			atom_storage.attempt_insert(new /obj/item/stock_parts/matter_bin/bluespace(src), user, TRUE)
			atom_storage.attempt_insert(new /obj/item/stock_parts/power_store/cell/bluespace(src), user, TRUE)
	else
		var/subtype
		if(spawn_selection == "Machine Board")
			subtype = /obj/item/circuitboard/machine
		else if(spawn_selection == "Stock Part")
			subtype = /obj/item/stock_parts
		else if(spawn_selection == "Beaker")
			subtype = /obj/item/reagent_containers/cup/beaker
		if(subtype)
			pick_stock_part(user, FALSE, subtype)

/// A bespoke proc for picking a subtype to spawn in a relatively user-friendly way.
/obj/item/storage/part_replacer/bluespace/tier4/cconsultant/proc/pick_stock_part(mob/user, recurse, subtype)
	// Sanity check: make sure it's actually an item, and not an atom, machine, or whatever else someone might try to feed it down the line.
	if(!is_path_in_list(subtype, valid_stock_part_types))
		return
	// Stores a list of pretty type names : actual paths.
	var/list/items_temp = list()
	// Grab the initial list of paths, NOT INCLUDING this specific path.
	var/list/paths = subtypesof(subtype)

	// Simplistic check to only list top-level subtypes.
	var/list/top_level_subtypes_only = list()
	for(var/datum/subtype_path as anything in paths)
		if(initial(subtype_path.parent_type) != subtype)
			continue
		top_level_subtypes_only += subtype_path
	paths = top_level_subtypes_only

	// With all sub-subtypes removed, initialize the list of valid, spawnable items & their pretty names - and if this is a recursion, include the original subtype.
	if(recurse)
		paths += subtype
	for(var/path in paths)
		var/obj/path_as_obj = path
		// Generates a pretty list of item names & paths, including notes for those with subtypes.  When browsing subtypes, the parent won't have the (# more) note added.
		if(length(subtypesof(path)))
			if(path == subtype)
				items_temp["[initial(path_as_obj.name)]: [path]"] = path
			else
				items_temp["[initial(path_as_obj.name)] (+[length(subtypesof(path))] more): [path]"] = path
		else
			items_temp["[initial(path_as_obj.name)]: [path]"] = path

	// Finally, once the listed is generated, ask the user what they want to spawn.
	var/target_item = tgui_input_list(user, "Select Subtype", "RPED Manufacture", sort_list(items_temp))
	if(target_item)
		// If they select something, and the name:path binding is valid, then either spawn it, OR, if it has subtypes, and isn't the parent type, recurse to let them pick a subtype.
		if(items_temp[target_item])
			var/the_item = items_temp[target_item]
			if(length(subtypesof(the_item)) && the_item != subtype)
				pick_stock_part(user, TRUE, the_item)
			else
				for(var/i in 1 to 25)
					atom_storage.attempt_insert(new the_item(src), user, TRUE)
