/obj/item/weaponcrafting/gunkit/disabler_rifle
	name = "disabler rifle parts kit (nonlethal)"
	desc = "A suitcase containing the necessary gun parts to transform a normal disabler into a high-precision disabler rifle."

/datum/crafting_recipe/disabler_rifle
	name = "Disabler Rifle"
	result = /obj/item/gun/energy/disabler/rifle
	reqs = list(
		/obj/item/gun/energy/disabler = 1,
		/obj/item/weaponcrafting/gunkit/disabler_rifle = 1,
	)
	time = 10 SECONDS
	category = CAT_WEAPON_RANGED
