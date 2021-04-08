
/obj/item/storage/drone_tools
	name = "built-in tools"
	desc = "Access your built in tools"
	icon = 'icons/hud/screen_drone.dmi'
	icon_state = "tool_storage"
	item_flags = ABSTRACT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/storage/drone_tools/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

/obj/item/storage/drone_tools/ComponentInitialize()
	. = ..()
	var/static/list/drone_builtins = list(	/obj/item/crowbar/drone, /obj/item/screwdriver/drone, /obj/item/wrench/drone, \
											/obj/item/weldingtool/drone, /obj/item/wirecutters/drone)
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_combined_w_class = 40
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_items = 5
	STR.set_holdable(drone_builtins)


/obj/item/storage/drone_tools/PopulateContents()
	var/list/builtintools = list()
	builtintools += new /obj/item/crowbar/drone(src)
	builtintools += new /obj/item/screwdriver/drone(src)
	builtintools += new /obj/item/wrench/drone(src)
	builtintools += new /obj/item/weldingtool/drone(src)
	builtintools += new /obj/item/wirecutters/drone(src)

	for(var/_tool in builtintools)
		var/obj/item/tool = _tool
		tool.AddComponent(/datum/component/holderloving, src, TRUE)


///// DRONE TOOLS //////

/obj/item/crowbar/drone
	name = "built-in crowbar"
	desc = "A crowbar built into your chassis."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "crowbar_cyborg"

/obj/item/screwdriver/drone
	name = "built-in screwdriver"
	desc = "A screwdriver built into your chassis."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "screwdriver_cyborg"
	random_color = FALSE

/obj/item/wrench/drone
	name = "built-in wrench"
	desc = "A wrench built into your chassis."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "wrench_cyborg"

/obj/item/weldingtool/drone
	name = "built-in welding tool"
	desc = "A welding tool built into your chassis."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "indwelder_cyborg"

/obj/item/wirecutters/drone
	name = "built-in wirecutters"
	desc = "Wirecutters built into your chassis."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "wirecutters_cyborg"
	random_color = FALSE

