
/obj/item/reagent_containers/honeycomb
	name = "honeycomb"
	desc = "A hexagonal mesh of honeycomb."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "honeycomb"
	possible_transfer_amounts = list()
	spillable = FALSE
	disease_amount = 0
	volume = 10
	amount_per_transfer_from_this = 0
<<<<<<< HEAD
	list_reagents = list(/datum/reagent/consumable/honey = 5)
=======
	list_reagents = list("honey" = 5)
>>>>>>> Updated this old code to fork
	grind_results = list()
	var/honey_color = ""

/obj/item/reagent_containers/honeycomb/Initialize()
	. = ..()
	pixel_x = rand(8,-8)
	pixel_y = rand(8,-8)
	update_icon()


/obj/item/reagent_containers/honeycomb/update_icon()
	cut_overlays()
<<<<<<< HEAD
	var/mutable_appearance/honey_overlay = mutable_appearance(icon, /datum/reagent/consumable/honey)
=======
	var/mutable_appearance/honey_overlay = mutable_appearance(icon, "honey")
>>>>>>> Updated this old code to fork
	if(honey_color)
		honey_overlay.icon_state = "greyscale_honey"
		honey_overlay.color = honey_color
	add_overlay(honey_overlay)


/obj/item/reagent_containers/honeycomb/proc/set_reagent(reagent)
	var/datum/reagent/R = GLOB.chemical_reagents_list[reagent]
	if(istype(R))
		name = "honeycomb ([R.name])"
		honey_color = R.color
<<<<<<< HEAD
		reagents.add_reagent(R.type,5)
=======
		reagents.add_reagent(R.id,5)
>>>>>>> Updated this old code to fork
	else
		honey_color = ""
	update_icon()