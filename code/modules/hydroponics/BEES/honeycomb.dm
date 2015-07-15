
/obj/item/weapon/reagent_containers/honeycomb
	name = "honeycomb"
	desc = "a hexagonal mesh of honeycomb"
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "honeycomb"
	possible_transfer_amounts = null
	spillable = 0
	disease_amount = 0
	volume = 10
	amount_per_transfer_from_this = 0
	list_reagents = list("honey" = 5)

/obj/item/weapon/reagent_containers/honeycomb/New()
	..()
	pixel_x = rand(8,-8)
	pixel_y = rand(8,-8)

