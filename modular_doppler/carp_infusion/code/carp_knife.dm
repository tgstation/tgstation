/obj/item/knife/carp
	name = "carp tooth"
	desc = "Teeth like these are predominantly used by space carp to impale their prey. This example likely comes from a hybrid, but don't let the length fool you. It's sharp enough to poke an eye out- and would be great for skinning as well"
	icon = 'modular_doppler/carp_infusion/icons/carptooth.dmi'
	icon_state = "carptooth"
	icon_angle = 0
	custom_materials = list(/datum/material/bone=SMALL_MATERIAL_AMOUNT *4, /datum/material/iron=SMALL_MATERIAL_AMOUNT * 2)

/obj/item/knife/carp/set_butchering()
	AddComponent(/datum/component/butchering, \
	speed = 8 SECONDS - force, \
	effectiveness = 100, \
	bonus_modifier = force + 10, \
	)
