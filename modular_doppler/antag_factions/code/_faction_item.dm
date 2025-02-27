/* This datum describes items unique to one or more antagonistic factions.
   When making new ones, place them inside the .dm file for a given faction to make everything
   easier to keep track of at a glance.*/

/datum/antag_faction_item
	/// The name of the extra item linked to a given faction.
	var/name
	/// The in-game modified item name of the item, if applicable. Useful for reskinning existing items.
	var/item_name
	/// The description of the extra item as seen in the uplink/applicable redemption place.
	var/description
	/// The in-game modified description of the item, if applicable. Useful for reskinning existing items.
	var/item_description
	/// The typepath of the item to spawn. If you want to make bespoke items with changes, make new subtypes of those items.
	var/item = null
	/// The cost of the item in appropriate currency (usually TC).
	var/cost = 0
	/// The typepath of the faction we're linked to.
	var/datum/antag_faction/faction

/// Returns a /datum/uplink item populated with our contents.
/datum/antag_faction_item/proc/get_uplink_item()
	var/datum/uplink_item/item_to_add = new /datum/uplink_item
	item_to_add.name = name
	item_to_add.desc = description
	item_to_add.cost = cost
	item_to_add.item = item
	item_to_add.faction_given = src
	if (faction.faction_category)
		item_to_add.category = faction.faction_category

	return item_to_add

// do we want to add stuff like force/throwforce changes for novice coders to easily make changes?

/datum/uplink_item
	/// A linkback to the `antag_faction_item` datum we might've been added/spawned with, for renaming/var adjustments
	var/datum/antag_faction_item/faction_given

/datum/uplink_item/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	. = ..()
	// problem: the messaging for spawn_item happens before the return in uplink_items.dm L:161 so we're gonna have to do something
	if (. && faction_given)
		var/obj/item/cast_item = .
		// perform bespoke renames//other changes
		if (faction_given.item_name)
			cast_item.name = faction_given.item_name
		if (faction_given.item_description)
			cast_item.desc = faction_given.item_description
