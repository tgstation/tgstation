/// Makes sure that no orderable items have dynamic descriptions, if they
/// don't explicitly set a description.
/datum/unit_test/orderable_item_descriptions

/datum/unit_test/orderable_item_descriptions/Run()
	for (var/datum/orderable_item/orderable_item as anything in subtypesof(/datum/orderable_item))
		if (!isnull(initial(orderable_item.desc)))
			continue

		var/item_path = initial(orderable_item.item_path)

		var/obj/item/item_instance = new item_path
		var/initial_desc = initial(item_instance.desc)

		if (item_instance.desc != initial_desc)
			Fail("[orderable_item] has an item ([item_path]) that has a dynamic description. [item_instance.desc] (dynamic description) != [initial_desc] (initial description)")
