/datum/crafting_recipe/curtain
	name = "Curtains"
	reqs = list(
		/obj/item/stack/sheet/cloth = 4,
		/obj/item/stack/rods = 1,
	)
	result = /obj/structure/curtain/cloth
	category = CAT_FURNITURE

/datum/crafting_recipe/showercurtain
	name = "Shower Curtains"
	reqs = list(
		/obj/item/stack/sheet/cloth = 2,
		/obj/item/stack/sheet/plastic = 2,
		/obj/item/stack/rods = 1,
	)
	result = /obj/structure/curtain
	category = CAT_FURNITURE

/datum/crafting_recipe/aquarium
	name = "Aquarium"
	result = /obj/structure/aquarium
	time = 10 SECONDS
	reqs = list(
		/obj/item/stack/sheet/iron = 15,
		/obj/item/stack/sheet/glass = 10,
		/obj/item/aquarium_kit = 1,
	)
	category = CAT_FURNITURE

/datum/crafting_recipe/mirror
	name = "Mirror"
	result = /obj/item/wallframe/mirror
	reqs = list(
		/obj/item/stack/sheet/glass = 5,
		/obj/item/stack/sheet/mineral/silver = 2,
	)
	category = CAT_FURNITURE
