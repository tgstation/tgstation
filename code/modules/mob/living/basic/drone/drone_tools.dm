/obj/item/storage/drone_tools
	name = "built-in tools"
	desc = "Access your built-in tools."
	icon = 'icons/hud/screen_drone.dmi'
	icon_state = "tool_storage"
	item_flags = ABSTRACT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/storage/drone_tools/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

	var/static/list/drone_builtins = list(
		/obj/item/crowbar/drone,
		/obj/item/screwdriver/drone,
		/obj/item/wrench/drone,
		/obj/item/weldingtool/drone,
		/obj/item/wirecutters/drone,
		/obj/item/multitool/drone,
		/obj/item/pipe_dispenser,
		/obj/item/t_scanner,
		/obj/item/analyzer,
		/obj/item/soap/drone,
	)
	atom_storage.max_total_storage = 40
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_slots = 10
	atom_storage.do_rustle = FALSE
	atom_storage.set_holdable(drone_builtins)


/obj/item/storage/drone_tools/PopulateContents()
	var/list/builtintools = list()
	builtintools += new /obj/item/crowbar/drone(src)
	builtintools += new /obj/item/screwdriver/drone(src)
	builtintools += new /obj/item/wrench/drone(src)
	builtintools += new /obj/item/weldingtool/drone(src)
	builtintools += new /obj/item/wirecutters/drone(src)
	builtintools += new /obj/item/multitool/drone(src)
	builtintools += new /obj/item/pipe_dispenser(src)
	builtintools += new /obj/item/t_scanner(src)
	builtintools += new /obj/item/analyzer(src)
	builtintools += new /obj/item/soap/drone(src)
	for(var/obj/item/tool as anything in builtintools)
		tool.AddComponent(/datum/component/holderloving, src, TRUE)


/obj/item/crowbar/drone
	name = "built-in crowbar"
	desc = "A crowbar built into your chassis."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "toolkit_engiborg_crowbar"
	inhand_icon_state = "crowbar"
	item_flags = NO_MAT_REDEMPTION

/obj/item/screwdriver/drone
	name = "built-in screwdriver"
	desc = "A screwdriver built into your chassis."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "toolkit_engiborg_screwdriver"
	inhand_icon_state = "screwdriver"
	item_flags = NO_MAT_REDEMPTION
	random_color = FALSE


/obj/item/screwdriver/drone/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file)
	. = ..()
	if(!isinhands)
		return

	var/mutable_appearance/head = mutable_appearance(icon_file, "screwdriver_head")
	head.appearance_flags = RESET_COLOR
	. += head

/obj/item/wrench/drone
	name = "built-in wrench"
	desc = "A wrench built into your chassis."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "toolkit_engiborg_wrench"
	inhand_icon_state = "wrench"
	item_flags = NO_MAT_REDEMPTION

/obj/item/weldingtool/drone
	name = "built-in welding tool"
	desc = "A welding tool built into your chassis."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "indwelder_cyborg"
	item_flags = NO_MAT_REDEMPTION

/obj/item/wirecutters/drone
	name = "built-in wirecutters"
	desc = "Wirecutters built into your chassis."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "toolkit_engiborg_cutters"
	inhand_icon_state = "cutters"
	item_flags = NO_MAT_REDEMPTION
	random_color = FALSE

/obj/item/multitool/drone
	name = "built-in multitool"
	desc = "A multitool built into your chassis."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "toolkit_engiborg_multitool"
	item_flags = NO_MAT_REDEMPTION
	toolspeed = 0.5
