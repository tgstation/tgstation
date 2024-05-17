/obj/structure/ore_container/food_trough
	density = TRUE
	anchored = TRUE
	///list of materials in the trough
	var/list/list_of_materials = list()
	///x offsets for materials to be placed
	var/list/x_offsets = list()
	///y offsets for materials to be placed
	var/list/y_offsets = list()

/obj/structure/ore_container/food_trough/Entered(atom/movable/mover)
	if(!istype(mover, /obj/item/stack/ore))
		return ..()
	if(list_of_materials[mover.type])
		return ..()
	list_of_materials[mover.type] = list("pixel_x" = rand(x_offsets[1], x_offsets[2]), "pixel_y" = rand(y_offsets[1], y_offsets[2]))
	return ..()

/obj/structure/ore_container/food_trough/Exited(atom/movable/mover)
	if(!istype(mover, /obj/item/stack/ore) || !isnull(locate(mover.type) in contents))
		return ..()
	list_of_materials -= mover.type
	return ..()

/obj/structure/ore_container/food_trough/atom_deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/mineral/wood(drop_location(), 5)

/obj/structure/ore_container/food_trough/update_overlays()
	. = ..()
	for(var/ore_entry in list_of_materials)
		var/obj/item/ore_item = ore_entry
		var/image/ore_icon = image(icon = initial(ore_item.icon), icon_state = initial(ore_item.icon_state), layer = LOW_ITEM_LAYER)
		var/list/pixel_positions = list_of_materials[ore_entry]
		ore_icon.transform = ore_icon.transform.Scale(0.4, 0.4)
		ore_icon.pixel_x = pixel_positions["pixel_x"]
		ore_icon.pixel_y = pixel_positions["pixel_y"]
		. += ore_icon

/obj/structure/ore_container/food_trough/gutlunch_trough
	name = "gutlunch trough"
	desc = "The gutlunches will eat out of it!"
	icon = 'icons/obj/structures.dmi'
	icon_state = "gutlunch_trough"
	x_offsets = list(-5, 8)
	y_offsets = list(-2, -7)
