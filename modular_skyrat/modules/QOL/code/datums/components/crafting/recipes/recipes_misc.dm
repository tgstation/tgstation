/datum/crafting_recipe/mop
	name = "Mop"
	result = /obj/item/mop
	reqs = list(/obj/item/stack/rods = 1,
				/obj/item/stack/sheet/cloth = 2,
				/obj/item/stack/cable_coil = 5)
	time = 30
	category = CAT_MISC

/datum/crafting_recipe/mop
	name = "Tribal Mop"
	result = /obj/item/mop/tribal
	reqs = list(/obj/item/stack/sheet/mineral/wood = 1,
				/obj/item/stack/sheet/cloth = 2,
				/obj/item/stack/sheet/sinew = 1)
	time = 30
	category = CAT_PRIMAL
