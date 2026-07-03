/obj/item/cigarette/crackrollie
	name = "Crack rollie"
	desc = "Ручная махорка, имеет спецефичный запах."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "spliffoff"
	icon_on = "spliffon"
	icon_off = "spliffoff"
	type_butt = /obj/item/cigbutt/roach
	chem_volume = 60
	lung_harm = 2.5
	list_reagents = list(/datum/reagent/drug/cocaine/freebase_cocaine = 10)

/datum/crafting_recipe/crackrollie
	name = "Crack rollie"
	result = /obj/item/cigarette/crackrollie
	reqs = list(/obj/item/rollingpaper = 1,
				/obj/item/reagent_containers/crack = 1)
	time = 20
	category = CAT_CHEMISTRY
