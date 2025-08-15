/obj/item/storage/drone_tools
	name = "built-in tools"
	desc = "Access your built-in tools."
	icon = 'icons/hud/screen_drone.dmi'
	icon_state = "tool_storage"
	storage_type = /datum/storage/drone
	item_flags = ABSTRACT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/storage/drone_tools/Initialize(mapload)
	. = ..()

	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

/obj/item/storage/drone_tools/PopulateContents()
	var/list/builtintools = list()
	builtintools += new /obj/item/crowbar/drone(src)
	builtintools += new /obj/item/screwdriver/drone(src)
	builtintools += new /obj/item/wrench/drone(src)
	builtintools += new /obj/item/weldingtool/drone(src)
	builtintools += new /obj/item/wirecutters/drone(src)
	builtintools += new /obj/item/multitool/drone(src)
	builtintools += new /obj/item/pipe_dispenser/drone(src)
	builtintools += new /obj/item/t_scanner/drone(src)
	builtintools += new /obj/item/analyzer/drone(src)
	builtintools += new /obj/item/soap/drone(src)

	for(var/obj/item/tool as anything in builtintools)
		tool.AddComponent(/datum/component/holderloving, src)

/obj/item/crowbar/drone
	name = "built-in crowbar"
	desc = "A crowbar built into your chassis."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "toolkit_engiborg_crowbar"
	inhand_icon_state = "crowbar"
	icon_angle = 0
	item_flags = NO_MAT_REDEMPTION

/obj/item/screwdriver/drone
	name = "built-in screwdriver"
	desc = "A screwdriver built into your chassis."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "toolkit_engiborg_screwdriver"
	post_init_icon_state = null
	inhand_icon_state = "screwdriver"
	item_flags = NO_MAT_REDEMPTION
	random_color = FALSE
	greyscale_config = null
	greyscale_colors = null

/obj/item/screwdriver/drone/separate_worn_overlays(mutable_appearance/standing, mutable_appearance/draw_target, isinhands = FALSE, icon_file)
	. = ..()
	if(!isinhands)
		return
	. += mutable_appearance(icon_file, "screwdriver_head", appearance_flags = RESET_COLOR)

/obj/item/wrench/drone
	name = "built-in wrench"
	desc = "A wrench built into your chassis."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "toolkit_engiborg_wrench"
	inhand_icon_state = "wrench"
	icon_angle = 0
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
	icon_angle = 0
	item_flags = NO_MAT_REDEMPTION
	toolspeed = 0.5

/obj/item/analyzer/drone
	name = "digital gas analyzer"
	desc = "A gas analyzer built into your chassis."
	item_flags = NO_MAT_REDEMPTION

/obj/item/t_scanner/drone
	name = "digital T-ray scanner"
	desc = "A T-ray scanner built into your chassis."
	item_flags = NO_MAT_REDEMPTION

/obj/item/pipe_dispenser/drone
	name = "built-in rapid pipe dispenser"
	desc = "A rapid pipe dispenser built into your chassis."
	item_flags = NO_MAT_REDEMPTION
