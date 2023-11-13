///unique items that spawn at the mook village
/obj/structure/material_stand
	name = "material stand"
	desc = "Is everyone free to use this thing?"
	icon = 'icons/mob/simple/jungle/mook.dmi'
	icon_state = "material_stand"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	bound_width = 64
	bound_height = 64

/obj/structure/material_stand/attackby(obj/item/ore, mob/living/carbon/human/user, list/modifiers)
	if(istype(ore, /obj/item/stack/ore))
		ore.forceMove(src)
		return
	return ..()

/obj/structure/material_stand/Entered(atom/movable/mover)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/material_stand/Exited(atom/movable/mover)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

///put ore icons on the counter!
/obj/structure/material_stand/update_overlays()
	. = ..()
	for(var/obj/item/stack/ore/ore_item in contents)
		var/image/ore_icon = image(icon = initial(ore_item.icon), icon_state = initial(ore_item.icon_state), layer = LOW_ITEM_LAYER)
		ore_icon.transform = ore_icon.transform.Scale(0.6, 0.6)
		ore_icon.pixel_x = rand(9, 17)
		ore_icon.pixel_y = rand(2, 4)
		. += ore_icon

/obj/structure/material_stand/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MaterialStand")
		ui.open()

/obj/structure/material_stand/ui_data(mob/user)
	var/list/data = list()
	data["ores"] = list()
	for(var/obj/item/stack/ore/ore_item in contents)
		data["ores"] += list(list(
			"id" = REF(ore_item),
			"name" = ore_item.name,
			"amount" = ore_item.amount,
		))
	return data

/obj/structure/material_stand/ui_static_data(mob/user)
	var/list/data = list()
	data["ore_images"] = list()
	for(var/obj/item/stack/ore_item as anything in subtypesof(/obj/item/stack/ore))
		data["ore_images"] += list(list(
			"name" = initial(ore_item.name),
			"icon" = icon2base64(getFlatIcon(image(icon = initial(ore_item.icon), icon_state = initial(ore_item.icon_state)), no_anim=TRUE))
		))
	return data

/obj/structure/material_stand/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(. || !isliving(usr))
		return TRUE

	var/mob/living/customer = usr
	var/obj/item/stack_to_move
	switch(action)
		if("withdraw")
			if(isnull(params["reference"]))
				return TRUE
			stack_to_move = locate(params["reference"]) in contents
			if(isnull(stack_to_move))
				return TRUE
			stack_to_move.forceMove(get_turf(customer))
			return TRUE

/obj/effect/landmark/mook_village
	name = "mook village landmark"
	icon_state = "x"
