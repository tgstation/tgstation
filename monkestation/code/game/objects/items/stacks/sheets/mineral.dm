//Metal Hydrogen
GLOBAL_LIST_INIT(metalhydrogen_recipes, list(
	new /datum/stack_recipe("incomplete servant golem shell", /obj/item/golem_shell/servant, req_amount=20, res_amount=1),
	new /datum/stack_recipe("ancient armor", /obj/item/clothing/suit/armor/elder_atmosian, req_amount = 8, res_amount = 1),
	new /datum/stack_recipe("ancient helmet", /obj/item/clothing/head/helmet/elder_atmosian, req_amount = 5, res_amount = 1),
	new /datum/stack_recipe("metallic hydrogen axe", /obj/item/fireaxe/metal_hydrogen_axe, req_amount = 15, res_amount = 1),
	))

/obj/item/stack/sheet/mineral/metal_hydrogen
	name = "Metal Hydrogen"
	icon_state = "sheet-metalhydrogen"
	item_state = "sheet-metalhydrogen"
	singular_name = "Metal Hydrogen sheet"
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF | LAVA_PROOF | ACID_PROOF | INDESTRUCTIBLE
	point_value = 100
	custom_materials = list(/datum/material/metalhydrogen = MINERAL_MATERIAL_AMOUNT)
	merge_type = /obj/item/stack/sheet/mineral/metal_hydrogen

/obj/item/stack/sheet/mineral/metal_hydrogen/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.metalhydrogen_recipes
	. = ..()

/obj/item/stack/sheet/mineral/zaukerite
	name = "zaukerite"
	icon_state = "zaukerite"
	item_state = "sheet-zaukerite"
	singular_name = "zaukerite crystal"
	w_class = WEIGHT_CLASS_NORMAL
	point_value = 120
	materials = list(/datum/material/zaukerite = MINERAL_MATERIAL_AMOUNT)
	merge_type = /obj/item/stack/sheet/mineral/zaukerite
