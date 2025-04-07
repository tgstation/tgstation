/obj/item/storage/toolbox/drone
	name = "mechanical toolbox"
	icon_state = "blue"
	inhand_icon_state = "toolbox_blue"
	material_flags = NONE

/obj/item/storage/toolbox/drone/PopulateContents()
	var/obj/item/stack/cable_coil/cable = new (null, MAXCOIL)
	cable.set_cable_color(pick(GLOB.cable_colors))

	return list(
		/obj/item/screwdriver,
		/obj/item/wrench,
		/obj/item/weldingtool,
		/obj/item/crowbar,
		cable,
		/obj/item/wirecutters,
		/obj/item/multitool,
	)

/obj/item/storage/toolbox/artistic
	name = "artistic toolbox"
	desc = "A toolbox painted bright green. Why anyone would store art supplies in a toolbox is beyond you, but it has plenty of extra space."
	icon_state = "green"
	inhand_icon_state = "artistic_toolbox"
	w_class = WEIGHT_CLASS_GIGANTIC //Holds more than a regular toolbox!
	material_flags = NONE
	storage_type = /datum/storage/toolbox/artistic

/obj/item/storage/toolbox/artistic/PopulateContents()
	return list(
		/obj/item/storage/crayons,
		/obj/item/crowbar,
		/obj/item/stack/pipe_cleaner_coil/red,
		/obj/item/stack/pipe_cleaner_coil/yellow,
		/obj/item/stack/pipe_cleaner_coil/blue,
		/obj/item/stack/pipe_cleaner_coil/green,
		/obj/item/stack/pipe_cleaner_coil/pink,
		/obj/item/stack/pipe_cleaner_coil/orange,
		/obj/item/stack/pipe_cleaner_coil/cyan,
		/obj/item/stack/pipe_cleaner_coil/white,
		/obj/item/stack/pipe_cleaner_coil/brown,
	)

/obj/item/storage/toolbox/haunted
	name = "old toolbox"
	custom_materials = list(/datum/material/hauntium = SMALL_MATERIAL_AMOUNT*5)
