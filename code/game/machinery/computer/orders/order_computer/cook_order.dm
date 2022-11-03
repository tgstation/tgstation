/obj/machinery/computer/order_console/cook
	name = "Produce Orders Console"
	desc = "An interface for ordering fresh produce and other. A far more expensive option than the botanists, but oh well."
	circuit = /obj/item/circuitboard/computer/order_console/cook
	order_categories = list(
		CATEGORY_FRUITS_VEGGIES,
		CATEGORY_MILK_EGGS,
		CATEGORY_SAUCES_REAGENTS,
	)

/obj/machinery/computer/order_console/cook/order_groceries(mob/living/purchaser, obj/item/card/id/card, list/groceries)
	for(var/datum/orderable_item/ordered_item in groceries)
		if(!(ordered_item.category_index in order_categories))
			groceries.Remove(ordered_item)
			continue
		if(ordered_item in SSshuttle.chef_groceries)
			SSshuttle.chef_groceries[ordered_item] += groceries[ordered_item]
		else
			SSshuttle.chef_groceries[ordered_item] = groceries[ordered_item]
