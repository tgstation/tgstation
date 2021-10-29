// Guns

/datum/crafting_recipe/ishotgun
	name = "Improvised Shotgun"
	result = /obj/item/gun/ballistic/rifle/ishotgun
	reqs = list(/obj/item/weaponcrafting/receiver = 1,
				/obj/item/pipe = 1,
				/obj/item/weaponcrafting/stock = 1,
				/obj/item/stack/package_wrap = 5,
				/obj/item/stack/sheet/iron = 5,
				/obj/item/stack/sheet/plasteel = 1)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	time = 100
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/irifle
	name = "Improvised Rifle"
	result = /obj/item/gun/ballistic/rifle/irifle
	reqs = list(/obj/item/weaponcrafting/receiver = 1,
				/obj/item/pipe = 1,
				/obj/item/weaponcrafting/stock = 1,
				/obj/item/stack/package_wrap = 5,
				/obj/item/stack/sheet/iron = 10,
				/obj/item/stack/sheet/mineral/wood = 5)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	time = 100
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/irevolvingrifle
	name = "Improvised Revolving Rifle"
	result = /obj/item/gun/ballistic/revolver/rifle/improvised
	reqs = list(/obj/item/weaponcrafting/receiver = 1,
				/obj/item/pipe = 1,
				/obj/item/weaponcrafting/stock = 1,
				/obj/item/stack/package_wrap = 5,
				/obj/item/stack/sheet/iron = 5,
				/obj/item/stack/sheet/plasteel = 1)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	time = 100
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

