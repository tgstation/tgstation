/**
 * Armament entries
 *
 * These are basic entries that are compiled into the global list of armaments.
 * It is strongly suggested that if you wish to make your own armaments station, you
 * create your own entries.
 *
 * Armament stations are capable of having a restricted list of products, which you should fill if you plan on making
 * your own station. This is the products variable. If you plan on using the premade list, you can leave this empty.
 *
 * Create your own file with all of the entries if you do wish to make your own custom armaments vendor.
 *
 * @author Gandalf2k15
 */

SUBSYSTEM_DEF(armaments)
	name = "Armaments"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_ARMAMENTS

	var/list/entries

/datum/controller/subsystem/armaments/Initialize()
	var/list/armament_dataset = list()
	for(var/datum/armament_entry/armament_entry as anything in subtypesof(/datum/armament_entry))
		// Set up our categories so we can add items to them
		if(initial(armament_entry.category))
			var/category = initial(armament_entry.category)
			if(!(category in armament_dataset))
				// We instansiate the category list so we can add items to it later
				armament_dataset[category] = list(CATEGORY_ENTRY, CATEGORY_LIMIT)
				armament_dataset[category][CATEGORY_ENTRY] = list()
		// These can be considered abstract types, thus do not need to be added.
		if(isnull(initial(armament_entry.item_type)))
			continue
		var/datum/armament_entry/spawned_armament_entry = new armament_entry()
		// Datums without a name will assume the items name
		spawned_armament_entry.name ||= initial(spawned_armament_entry.item_type.name)
		// ditto for the description
		spawned_armament_entry.description ||= initial(spawned_armament_entry.item_type.desc)
		// Make our icon cache for the UI.
		spawned_armament_entry.setup()
		// Now that we've set up our datum, we can add it to the correct category
		if(spawned_armament_entry.category)
			if(spawned_armament_entry.subcategory)
				// Check to see if we've already made the subcategory.
				if(!(spawned_armament_entry.subcategory in armament_dataset[spawned_armament_entry.category][CATEGORY_ENTRY]))
					armament_dataset[spawned_armament_entry.category][CATEGORY_ENTRY][spawned_armament_entry.subcategory] = list()
				// Finally, we add the entry into the list.
				armament_dataset[spawned_armament_entry.category][CATEGORY_ENTRY][spawned_armament_entry.subcategory] += spawned_armament_entry
			else
				// Unset subcategories default to the NONE category.
				if(!(ARMAMENT_SUBCATEGORY_NONE in armament_dataset[spawned_armament_entry.category][CATEGORY_ENTRY]))
					armament_dataset[spawned_armament_entry.category][CATEGORY_ENTRY][ARMAMENT_SUBCATEGORY_NONE] = list()
				armament_dataset[spawned_armament_entry.category][CATEGORY_ENTRY][ARMAMENT_SUBCATEGORY_NONE] += spawned_armament_entry
			// Set the category item limit.
			armament_dataset[spawned_armament_entry.category][CATEGORY_LIMIT] = spawned_armament_entry.category_item_limit
		else
			// Because of how the UI system works, categories cannot exist with nothing in them, so we
			// only set the OTHER category if something can go inside it! This seems like a copy paste job, but it needs to be here.
			if(!(ARMAMENT_CATEGORY_STANDARD in armament_dataset))
				armament_dataset[ARMAMENT_CATEGORY_STANDARD] = list(CATEGORY_ENTRY, CATEGORY_LIMIT)
				armament_dataset[ARMAMENT_CATEGORY_STANDARD][CATEGORY_LIMIT] = ARMAMENT_CATEGORY_STANDARD_LIMIT
			// We don't have home :( add us to the other category.
			if(spawned_armament_entry.subcategory)
				// Check to see if we've already made the subcategory.
				if(!(spawned_armament_entry.subcategory in armament_dataset[ARMAMENT_CATEGORY_STANDARD][CATEGORY_ENTRY]))
					armament_dataset[ARMAMENT_CATEGORY_STANDARD][CATEGORY_ENTRY][spawned_armament_entry.subcategory] = list()
				// Finally, we add the entry into the list.
				armament_dataset[ARMAMENT_CATEGORY_STANDARD][CATEGORY_ENTRY][spawned_armament_entry.subcategory] += spawned_armament_entry
			else
				// Unset subcategories default to the NONE category.
				if(!(ARMAMENT_SUBCATEGORY_NONE in armament_dataset[ARMAMENT_CATEGORY_STANDARD][CATEGORY_ENTRY]))
					armament_dataset[ARMAMENT_CATEGORY_STANDARD][CATEGORY_ENTRY][ARMAMENT_SUBCATEGORY_NONE] = list()
				armament_dataset[ARMAMENT_CATEGORY_STANDARD][CATEGORY_ENTRY][ARMAMENT_SUBCATEGORY_NONE] += spawned_armament_entry

	entries = armament_dataset
	return SS_INIT_SUCCESS

/*
*	ARMAMENT ENTRIES
*/

/datum/armament_entry
	/// The name of the equipment used in the listing, if not set, it will use the items name.
	var/name
	/// The description of the equipment used in the listing, if not set, it will use the items description.
	var/description
	/// The item path that we refer to when equipping. If left empty, it will be considered abstract.
	var/obj/item_type
	/// Category of the item. This is used to group items together in the UI.
	var/category = ARMAMENT_CATEGORY_STANDARD
	/// This is an abstract variable, only set this for base category types. It should not be overriden by subtypes. Set to 0 for infinite.
	var/category_item_limit = 0
	/// Our subcategory, where the item will be listed.
	var/subcategory = ARMAMENT_SUBCATEGORY_NONE
	/// The points cost of this item.
	var/cost = 0
	/// Defines what slot we will try to equip this item to.
	var/slot_to_equip = ITEM_SLOT_HANDS
	/// Our cached image.
	var/cached_base64
	/// The maximum amount of this item that can be equipped.
	var/max_purchase = 1
	/// Do we have magazines for purchase?
	var/magazine
	/// If we have a magazine, how much is it?
	var/magazine_cost = 1
	/// Is this restricted for purchase in some form? Requires extra code in the vendor to function, used for guncargo.
	var/restricted = FALSE

/datum/armament_entry/proc/setup()
	var/obj/item/test_item = new item_type()
	if(istype(test_item, /obj/item/gun/ballistic))
		var/obj/item/gun/ballistic/ballistic_test = test_item
		if(!ballistic_test.internal_magazine)
			magazine = ballistic_test.spawn_magazine_type
	cached_base64 = icon2base64(getFlatIcon(test_item, no_anim = TRUE))
	qdel(test_item)

/// This proc handles how the item should be equipped to the player. This needs to return either TRUE or FALSE, TRUE being that it was able to equip the item.
/datum/armament_entry/proc/equip_to_human(mob/living/carbon/human/equipping_human, obj/item/item_to_equip)
	return equipping_human.equip_to_slot_if_possible(item_to_equip, slot_to_equip)

/datum/armament_entry/proc/after_equip(turf/safe_drop_location, obj/item/item_to_equip)
	return TRUE

/datum/armament_entry/company_import
	max_purchase = 0
	category_item_limit = 0
	cost = CARGO_CRATE_VALUE
	/// Bitflag of the company
	var/company_bitflag
	/// If this requires a multitooled console to be visible
	var/contraband = FALSE
