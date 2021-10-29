/datum/crafting_recipe/chain_armor
	name = "Chain Armor"
	result = /obj/item/clothing/suit/armor/reagent_clothing
	reqs = list(/obj/item/forging/complete/chain = 6)
	time = 40
	category = CAT_CLOTHING

/datum/crafting_recipe/chain_glove
	name = "Chain Gloves"
	result = /obj/item/clothing/gloves/reagent_clothing
	reqs = list(/obj/item/forging/complete/chain = 4)
	time = 40
	category = CAT_CLOTHING

/datum/crafting_recipe/chain_helmet
	name = "Chain Helmet"
	result = /obj/item/clothing/head/helmet/reagent_clothing
	reqs = list(/obj/item/forging/complete/chain = 5)
	time = 40
	category = CAT_CLOTHING

/datum/crafting_recipe/reagent_sword
	name = "Reagent Sword"
	result = /obj/item/forging/reagent_weapon/sword
	reqs = list(/obj/item/forging/complete/sword = 1,
				/obj/item/stack/sheet/mineral/wood = 2)
	time = 40
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/reagent_staff
	name = "Reagent Staff"
	result = /obj/item/forging/reagent_weapon/staff
	reqs = list(/obj/item/forging/complete/staff = 1,
				/obj/item/stack/sheet/mineral/wood = 2)
	time = 40
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/reagent_spear
	name = "Reagent Staff"
	result = /obj/item/forging/reagent_weapon/spear
	reqs = list(/obj/item/forging/complete/spear = 1,
				/obj/item/stack/sheet/mineral/wood = 2)
	time = 40
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/reagent_tile
	name = "Reagent Tile"
	result = /obj/item/forging/reagent_tile
	reqs = list(/obj/item/forging/complete/plate = 4)
	category = CAT_MISC

/datum/crafting_recipe/primitive_billow
	name = "Primitive Forging Billow"
	result = /obj/item/forging/billow/primitive
	reqs = list(/obj/item/stack/sheet/mineral/wood = 5)
	category = CAT_PRIMAL

/datum/crafting_recipe/primitive_tong
	name = "Primitive Forging Tong"
	result = /obj/item/forging/tongs/primitive
	reqs = list(/obj/item/stack/sheet/iron = 5)
	category = CAT_PRIMAL

/datum/crafting_recipe/primitive_hammer
	name = "Primitive Forging Hammer"
	result = /obj/item/forging/hammer/primitive
	reqs = list(/obj/item/stack/sheet/iron = 5)
	category = CAT_PRIMAL

//cargo supply pack for items
/datum/supply_pack/service/forging_items
	name = "Forging Starter Item Pack"
	desc = "Featuring: Forging. This pack is full of three items necessary to start your forging career: tongs, hammer, and billow."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/obj/item/forging/tongs, /obj/item/forging/hammer, /obj/item/forging/billow)
	crate_name = "forging start items"
	crate_type = /obj/structure/closet/crate/forging_items

/obj/structure/closet/crate/forging_items
	name = "forging starter items"
	desc = "A crate filled with the items necessary to start forging (billow, hammer, and tongs)."
