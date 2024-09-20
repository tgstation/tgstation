//generic primitive recipe
/datum/crafting_recipe/primitive_recipe
    reqs = list(
        /obj/item/stack/sheet/bone = 1,
        /obj/item/stack/sheet/sinew = 1,
    )
    time = 4 SECONDS
    category = CAT_TOOLS

//ASH TOOL
/obj/item/screwdriver/primitive
	name = "primitive screwdriver"
	icon = 'modular_doppler/hearthkin/primitive_production/icons/primitive_tools.dmi'
	icon_state = "screwdriver"
	custom_materials = list(/datum/material/bone = SMALL_MATERIAL_AMOUNT * 1)

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/primitive_recipe/primitive_screwdriver
	name = "Primitive Screwdriver"
	result = /obj/item/screwdriver/primitive

/obj/item/wirecutters/primitive
	name = "primitive wirecutters"
	icon = 'modular_doppler/hearthkin/primitive_production/icons/primitive_tools.dmi'
	icon_state = "cutters"
	custom_materials = list(/datum/material/bone = SMALL_MATERIAL_AMOUNT * 1)

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/primitive_recipe/primitive_cutters
	name = "Primitive Wirecutters"
	result = /obj/item/wirecutters/primitive

/obj/item/wrench/primitive
	name = "primitive wrench"
	icon = 'modular_doppler/hearthkin/primitive_production/icons/primitive_tools.dmi'
	icon_state = "wrench"
	custom_materials = list(/datum/material/bone = SMALL_MATERIAL_AMOUNT * 1)

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/primitive_recipe/primitive_wrench
	name = "Primitive Wrench"
	result = /obj/item/wrench/primitive

/obj/item/crowbar/primitive
	name = "primitive crowbar"
	icon = 'modular_doppler/hearthkin/primitive_production/icons/primitive_tools.dmi'
	icon_state = "crowbar"
	custom_materials = list(/datum/material/bone = SMALL_MATERIAL_AMOUNT * 1)

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/primitive_recipe/primitive_crowbar
	name = "Primitive Crowbar"
	result = /obj/item/crowbar/primitive

/obj/item/chisel/primitive
	name = "primitive chisel"
	desc = "Where there is a will there is a way; the tool head of this chisel is fashioned from bone shaped when it was fresh and then left to calcify in iron rich water, to make a strong head for all your carving needs."
	icon = 'modular_doppler/hearthkin/primitive_production/icons/primitive_tools.dmi'
	icon_state = "chisel"
	custom_materials = list(/datum/material/bone = SMALL_MATERIAL_AMOUNT * 1)

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null
	toolspeed = 4

/datum/crafting_recipe/primitive_recipe/primitive_chisel
	name = "Primitive Chisel"
	result = /obj/item/chisel/primitive

/obj/item/mop/tribal
    desc = "A primitive mop, made of cloth, sinew, and wood."

/datum/crafting_recipe/mop
    name = "Tribal Mop"
    result = /obj/item/mop/tribal
    reqs = list(/obj/item/stack/sheet/mineral/wood = 1,
                /obj/item/stack/sheet/cloth = 2,
                /obj/item/stack/sheet/sinew = 1)
    time = 3 SECONDS
    category = CAT_TOOLS
