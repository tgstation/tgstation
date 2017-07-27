/datum/crafting_recipe/stunprod
	result = /obj/item/weapon/melee/baton/cattleprod/hippie_cattleprod

/datum/crafting_recipe/butterfly
	name = "Butterfly Knife"
	result = /obj/item/weapon/melee/transforming/butterfly
	reqs = list(/obj/item/weapon/restraints/handcuffs/cable = 1,
				/obj/item/weapon/scalpel = 1,
				/obj/item/stack/sheet/plasteel = 6)
	tools = list(/obj/item/weapon/weldingtool, /obj/item/weapon/screwdriver, /obj/item/weapon/wirecutters)
	time = 100
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON