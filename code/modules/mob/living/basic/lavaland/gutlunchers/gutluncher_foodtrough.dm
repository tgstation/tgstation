/obj/structure/ore_container/gutlunch_trough
	name = "gutlunch trough"
	desc = "The gutlunches will eat out of it!"
	icon = 'icons/obj/structures.dmi'
	icon_state = "gutlunch_trough"
	density = TRUE
	anchored = TRUE
	///list of materials in the trough
	var/list/list_of_materials = list()

/obj/structure/ore_container/gutlunch_trough/Entered(atom/movable/mover)
	if(!istype(mover, /obj/item/stack/ore))
		return ..()
	if(list_of_materials[mover.type])
		return ..()
	list_of_materials[mover.type] = list("pixel_x" = rand(-5, 8), "pixel_y" = rand(-2, -7))
	return ..()

/obj/structure/ore_container/gutlunch_trough/Exited(atom/movable/mover)
	if(!istype(mover, /obj/item/stack/ore) || !isnull(locate(mover.type) in contents))
		return ..()
	list_of_materials -= mover.type
	return ..()

/obj/structure/ore_container/gutlunch_trough/deconstruct(disassembled = TRUE)
	if(flags_1 & NODECONSTRUCT_1)
		return
	new /obj/item/stack/sheet/mineral/wood(drop_location(), 5)
	qdel(src)

/obj/structure/ore_container/gutlunch_trough/update_overlays()
	. = ..()
	for(var/ore_entry in list_of_materials)
		var/obj/item/ore_item = ore_entry
		var/image/ore_icon = image(icon = initial(ore_item.icon), icon_state = initial(ore_item.icon_state), layer = LOW_ITEM_LAYER)
		var/list/pixel_positions = list_of_materials[ore_entry]
		ore_icon.transform = ore_icon.transform.Scale(0.4, 0.4)
		ore_icon.pixel_x = pixel_positions["pixel_x"]
		ore_icon.pixel_y = pixel_positions["pixel_y"]
		. += ore_icon
