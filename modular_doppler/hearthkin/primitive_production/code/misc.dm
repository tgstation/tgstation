/obj/item/shard/attackby(obj/item/item, mob/user, params)
	//xenoarch hammer, forging hammer, etc.
	if(item.tool_behaviour == TOOL_HAMMER)
		var/added_color
		switch(src.type)
			if(/obj/item/shard)
				added_color = "#88cdf1"

			if(/obj/item/shard/plasma)
				added_color = "#ff80f4"

			if(/obj/item/shard/plastitanium)
				added_color = "#5d3369"

			if(/obj/item/shard/titanium)
				added_color = "#cfbee0"

		var/obj/colored_item = new /obj/item/stack/ore/glass/zero_cost(get_turf(src))
		colored_item.add_atom_colour(added_color, FIXED_COLOUR_PRIORITY)
		new /obj/effect/decal/cleanable/glass(get_turf(src))
		user.balloon_alert(user, "[src] shatters!")
		playsound(src, SFX_SHATTER, 30, TRUE)
		qdel(src)
		return TRUE

	return ..()

/obj/item/stack/ore/glass/zero_cost
	points = 0
	merge_type = /obj/item/stack/ore/glass/zero_cost

/obj/item/stack/ore/examine(mob/user)
	. = ..()
	if(points == 0)
		. += span_warning("<br> [src] is worthless and will not reward any mining points!")
