/datum/crafting_recipe/paperframes
	name = "Paper Frames"
	result = /obj/item/stack/sheet/paperframes/five
	time = 1 SECONDS
	reqs = list(
		/obj/item/stack/sheet/mineral/wood = 5,
		/obj/item/paper = 20,
	)
	category = CAT_STRUCTURE

/datum/crafting_recipe/rib
	name = "Colossal Rib"
	always_available = FALSE
	reqs = list(
		/obj/item/stack/sheet/bone = 10,
		/datum/reagent/fuel/oil = 5,
	)
	result = /obj/structure/statue/bone/rib
	category = CAT_STRUCTURE

/datum/crafting_recipe/skull
	name = "Skull Carving"
	always_available = FALSE
	reqs = list(
		/obj/item/stack/sheet/bone = 6,
		/datum/reagent/fuel/oil = 5,
	)
	result = /obj/structure/statue/bone/skull
	category = CAT_STRUCTURE

/datum/crafting_recipe/halfskull
	name = "Cracked Skull Carving"
	always_available = FALSE
	reqs = list(
		/obj/item/stack/sheet/bone = 3,
		/datum/reagent/fuel/oil = 5,
	)
	result = /obj/structure/statue/bone/skull/half
	category = CAT_STRUCTURE
