/obj/item/storage/toolbox/ce
	name = "mechanical toolbox"
	icon = 'monkestation/icons/obj/storage/toolbox.dmi'
	icon_state = "toolbox_ce"
	item_state = "toolbox_default"
	material_flags = MATERIAL_NO_COLOR
	w_class = WEIGHT_CLASS_BULKY
	force = 15 // Hits slightly higher, throw range is lower because it is heavy
	throwforce = 15
	throw_speed = 1
	throw_range = 4
	drag_slowdown = 1.2

/obj/item/storage/toolbox/ce/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_combined_w_class = 200
	STR.max_items = 20
	STR.max_w_class = WEIGHT_CLASS_BULKY
	STR.insert_preposition = "in"
	//Whitelist for items that can be held
	STR.can_hold = typecacheof(list(
		/obj/item/airlock_painter,
		/obj/item/holosign_creator,
		/obj/item/inducer,
		/obj/item/pipe_dispenser,
		/obj/item/construction,
		/obj/item/rcd_ammo,
		/obj/item/flashlight,
		/obj/item/multitool,
		/obj/item/analyzer,
		/obj/item/crowbar,
		/obj/item/weldingtool,
		/obj/item/extinguisher/mini,
		/obj/item/screwdriver,
		/obj/item/wrench,
		/obj/item/wirecutters,
		/obj/item/rcl,
		/obj/item/assembly/flash/handheld,
	))

/obj/item/storage/toolbox/ce/PopulateContents()
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/analyzer(src)
	new /obj/item/wirecutters(src)
	new /obj/item/multitool(src)
	new /obj/item/airlock_painter(src)
	new /obj/item/holosign_creator/engineering(src)
	new /obj/item/holosign_creator/atmos(src)
	new /obj/item/inducer(src)
	new /obj/item/pipe_dispenser(src)
	new /obj/item/construction/plumbing/engineering(src)
	new /obj/item/construction/rcd/loaded(src)
	new /obj/item/rcd_ammo/large(src)
	new /obj/item/assembly/flash/handheld(src)
