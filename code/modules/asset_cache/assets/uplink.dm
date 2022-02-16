/// Sends information needed for uplinks
/datum/asset/json/uplink
	name = "uplink"

/datum/asset/json/uplink/generate()
	var/list/data = list()
	var/list/categories = list()
	var/list/items = list()
	for(var/datum/uplink_category/category as anything in subtypesof(/datum/uplink_category))
		categories += category
	categories = sortTim(categories, .proc/cmp_uplink_category_desc)

	var/list/new_categories = list()
	for(var/datum/uplink_category/category as anything in categories)
		new_categories += initial(category.name)
	categories = new_categories

	for(var/datum/uplink_item/item_path as anything in subtypesof(/datum/uplink_item))
		var/datum/uplink_item/item = new item_path()
		if(item.item) {
			items += list(list(
				"id" = item_path,
				"name" = item.name,
				"cost" = item.cost,
				"desc" = item.desc,
				"category" = item.category? initial(item.category.name) : null,
				"purchasable_from" = item.purchasable_from,
				"restricted" = item.restricted,
				"limited_stock" = item.limited_stock,
				"restricted_roles" = item.restricted_roles,
				"restricted_species" = item.restricted_species,
				"progression_minimum" = item.progression_minimum,
			))
		}
		SStraitor.uplink_items += item
		SStraitor.uplink_items_by_type[item_path] = item

	data["items"] = items
	data["categories"] = categories
	return data
