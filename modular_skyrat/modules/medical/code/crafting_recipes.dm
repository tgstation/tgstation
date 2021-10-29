/datum/crafting_recipe/tribalsplint
	name = "Tribal Splint"
	result = /obj/item/stack/medical/splint/tribal
	time = 30
	reqs = list(/obj/item/stack/sheet/bone = 2,
				/obj/item/stack/sheet/sinew = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/improvsplint
	name = "Improvised Splint"
	result = /obj/item/stack/medical/splint/improvised
	time = 30
	reqs = list(/obj/item/stack/sheet/mineral/wood = 2, /obj/item/stack/sheet/cloth = 2)
	category = CAT_MISC
