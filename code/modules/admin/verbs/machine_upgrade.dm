ADMIN_VERB_CONTEXT_MENU(machine_upgrade, "Tweak Component Ratings", R_DEBUG, obj/machinery/target in world)
	var/new_rating = input(user, "Enter new rating:","Num") as num|null
	if(new_rating && target.component_parts)
		for(var/obj/item/stock_parts/P in target.component_parts)
			P.rating = new_rating
		target.RefreshParts()
