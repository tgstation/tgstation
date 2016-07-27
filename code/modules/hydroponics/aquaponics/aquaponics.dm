//Aquaponics is a subdivision of Hydroponics dedicated to cultivating ocean plants.
//This file has base paths, like machinery and edibles.

/obj/machinery/aquaponics
	name = "aquaponics machinery"
	desc = "An unidentifiable machine used for cultivating ocean plants."
	icon = 'icons/obj/aquaponics/aquaponics.dmi'
	icon_state = "placeholder"
	anchored = TRUE
	density = TRUE
	opacity = FALSE

/obj/item/weapon/reagent_containers/food/aquaponic
	name = "edible aquaponic plant"
	desc = "Makes you feel drowned with every bite!"
	icon = 'icons/obj/aquaponics/plants.dmi'
	icon_state = "placeholder"
	w_class = 2
	burn_state = FLAMMABLE
	list_reagents = list("nutriment" = 1, "vitamin" = 0.5)

/obj/item/plant_sample
	name = "plant sample"
	desc = "Some uprooted plants. They won't last long."
	icon = 'icons/obj/aquaponics/plants.dmi'
	icon_state = "placeholder"
	w_class = 3
	burn_state = FLAMMABLE
	var/datum/aquaponics_plant/sample //What this object is a sample of
	var/lifetime = 150 //Seconds this plant has until its death once uprooted
	var/usable = TRUE //If the plant can be planted in an aquaponics tank

/obj/item/plant_sample/New()
	..()
	addtimer(src, "decay", lifetime)

/obj/item/plant_sample/proc/decay()
	usable = FALSE
	name = "decayed [name]"
	desc = "[desc] This particular sample has decayed beyond usability."
