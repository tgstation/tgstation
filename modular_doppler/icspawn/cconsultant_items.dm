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

/// An extension to the default RPED part replacement action - if you don't have the requisite parts in the RPED already, it will spawn T4 versions to use.
/obj/item/storage/part_replacer/bluespace/tier4/cconsultant/part_replace_action(obj/attacked_object, mob/living/user)
	// We start with setting up a list of the current contents of the RPED when using auto-clear.  This is used to detect new items after upgrades are applied & remove them.
	var/list/old_contents = list()
	var/list/inv_grab = atom_storage.return_inv(FALSE)
	if(auto_clear)
		old_contents = atom_storage.return_inv(FALSE)
	// Once old_contents has been initialized, if needed, we check if the target object is a machine frame.
	var/obj/structure/frame/attacked_frame = attacked_object
	if(istype(attacked_frame, /obj/structure/frame/machine))
		var/obj/structure/frame/machine/machine_frame = attacked_frame
		var/obj/item/circuitboard/machine/circuit = machine_frame.circuit
		// Prioritize using the circuit's components list first, if present, to maintain consistency.
		if(istype(circuit))
			spawn_parts_for_components(user, circuit.req_components)
		else if(machine_frame.req_components)
			spawn_parts_for_components(user, machine_frame.req_components)
	else
		// It's not a machine frame, so let's check if it's a regular machine.
		if(ismachinery(attacked_object) && !istype(attacked_object, /obj/machinery/computer))
			var/obj/machinery/attacked_machinery = attacked_object
			var/obj/item/circuitboard/machine/circuit = attacked_machinery.circuit
			// If it is, we need to use the circuit's components; there's no good way to get required components off of an already-built machine.
			if(istype(circuit))
				spawn_parts_for_components(user, circuit.req_components)
	. = ..()
	// If auto-clear is in use,
	if(auto_clear)
		inv_grab.Cut()
		inv_grab = atom_storage.return_inv(FALSE)
		for(var/obj/item/stored_item in inv_grab)
			if(!(stored_item in old_contents))
				qdel(stored_item)

/// A bespoke proc for spawning in parts
/obj/item/storage/part_replacer/bluespace/tier4/cconsultant/proc/spawn_parts_for_components(mob/living/user, list/required_components)
	// Since req_components in machineboards can list item types *OR* /datum/stock_part subtypes this gets a little complicated.
	var/list/subtypes = list()
	for(var/req_component in required_components)
		// Start off noting how many the recipe calls for, a counter for how many matching parts have been found, and generating a list of subtypes for use in later checks.
		var/parts_amount_required = required_components[req_component]
		var/found_matching = 0
		subtypes = typesof(req_component)

		if(!parts_amount_required)
			continue

		/// Then, check if the requested component is an object subtype - this means it's probably either materials (e.g, cables) or non-stock_part subtypes like beakers.
		if(ispath(req_component, /obj/item))
			// If it's a stack, it needs special treatment.
			if(ispath(req_component, /obj/item/stack))
				// Stacks generate the matching count based on how many matching stacks are in the RPED's inventory with sufficient count.
				// To find stacks inside the RPED, we search its contents for anything that's a subtype of /obj/item/stack.
				for(var/obj/stored_item in contents)
					var/obj/item/stack/stored_item_as_stack = stored_item
					if(istype(stored_item_as_stack))
						// If a stack item is found, we check if it's in the typesof list for the current requested component, and if so, mark its count.
						if(stored_item_as_stack.type in subtypes)
							found_matching += stored_item_as_stack.amount
							// If there's enough, we can return early.
							if(found_matching >= parts_amount_required)
								break
				// If there's not enough left, spawn enough of the appropriate type that there will be.  Stacks' Initialialize accepts an amount for the newly-spawned stack to have, and will auto-split as needed.
				if(found_matching < parts_amount_required)
					atom_storage.attempt_insert(new req_component(src, parts_amount_required - found_matching), user, TRUE)
					continue
			else
				// It's not a stack, which means now we have to count how many matching items are present.
				for(var/obj/stored_item in contents)
					if(stored_item.type in subtypes)
						found_matching += 1
						// If there's enough, we can break - no need to spawn extras.
						if(found_matching >= parts_amount_required)
							break
				// If there's still not enough, we're going to have to spawn enough in manually.
				if(found_matching < parts_amount_required)
					for(var/i in 1 to parts_amount_required - found_matching)
						atom_storage.attempt_insert(new req_component(src), user, TRUE)
					continue

		/// If it's not an obj, then it's a subtype of /datum/stock_part - or *should be*, anyway.
		else if(ispath(req_component, /datum/stock_part))
			var/datum/stock_part/part_type = new req_component()
			var/base_type = part_type.physical_object_base_type
			// Specific machines sometimes call for specific tiers of part; give them precisely what they ask for, just in case.
			if(part_type.tier > 1)
				base_type = part_type.physical_object_type
				// Search to see if we have enough of that exact item, and if not, we'll spawn more.
				for(var/obj/stored_item in contents)
					if(stored_item.type == base_type)
						found_matching += 1
						// If there's enough, we can return early.
						if(found_matching >= parts_amount_required)
							break
				// If there's still not enough, we're going to have to spawn enough in manually.
				if(found_matching < parts_amount_required)
					for(var/i in 1 to parts_amount_required - found_matching)
						atom_storage.attempt_insert(new base_type(src), user, TRUE)
					continue
			else
				// For everything else, just make sure we have enough valid items of the stock part's subtypes.
				subtypes = typesof(base_type)
				for(var/obj/stored_item in contents)
					if(stored_item.type in subtypes)
						found_matching += 1
						// If there's enough, we can return early.
						if(found_matching >= parts_amount_required)
							break

				// If there's still not enough, we're going to have to spawn enough in manually.
				if(found_matching < parts_amount_required)
					// Reset the subtypes list so we can pick the highest tier of part available.
					subtypes = typesof(req_component)
					var/highest_tier = 0

					// Search those subtypes for the highest.  This SHOULD only ever go up to 4, but that's on the assumption upstream doesn't change it.
					for(var/subtype_path in subtypes)
						var/datum/stock_part/sub_part = new subtype_path()
						if(sub_part.tier > highest_tier)
							highest_tier = sub_part.tier
							base_type = sub_part.physical_object_type

					// Once the best component has been found, fill in enough remaining.
					for(var/i in 1 to parts_amount_required - found_matching)
						atom_storage.attempt_insert(new base_type(src), user, TRUE)
					continue

		// If it's not a /datum/stock_part subtype either, something has gone wrong and devs should probably be alerted.
		if(found_matching < parts_amount_required)
			to_chat(user, span_notice("Something went wrong manufacturing [req_component]. Alert the devs, and let them know what machine it was!"))

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
