/datum/crafting_recipe/naturalpaper
	name = "Hand-Pressed Paper"
	time = 3 SECONDS
	reqs = list(/datum/reagent/water = 50, /obj/item/stack/sheet/mineral/wood = 1)
	tool_paths = list(/obj/item/hatchet)
	result = /obj/item/paper_bin/bundlenatural
	category = CAT_MISC

/datum/crafting_recipe/skeleton_key
	name = "Skeleton Key"
	time = 3 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 5)
	result = /obj/item/skeleton_key
	always_available = FALSE
	category = CAT_MISC

/datum/crafting_recipe/coffee_cartridge
	name = "Bootleg Coffee Cartridge"
	result = /obj/item/coffee_cartridge/bootleg
	time = 2 SECONDS
	reqs = list(
		/obj/item/blank_coffee_cartridge = 1,
		/datum/reagent/toxin/coffeepowder = 10,
	)
	category = CAT_MISC
