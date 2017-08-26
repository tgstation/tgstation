/obj/item/stack/cable_coil/Initialize(mapload, new_amount = null, param_color = null)
	.=..()
	recipes = list(new/datum/stack_recipe("cable restraints", /obj/item/restraints/handcuffs/cable, 15), new/datum/stack_recipe("noose", /obj/structure/chair/noose, 30, time = 80, one_per_turf = 1, on_floor = 1))