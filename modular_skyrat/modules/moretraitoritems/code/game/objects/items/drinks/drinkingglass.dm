/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/syndicate
	name = "shot glass"
	desc = "A shot glass - the universal symbol for terrible decisions."
	icon_state = "shotglass"
	base_icon_state = "shotglass"
	gulp_size = 50
	amount_per_transfer_from_this = 50
	possible_transfer_amounts = list(50)
	volume = 50
	reagent_flags = REFILLABLE | DRAINABLE

/obj/item/storage/box/syndieshotglasses
	name = "box of shot glasses"
	desc = "It has a picture of shot glasses on it."
	illustration = "drinkglass"

/obj/item/storage/box/syndieshotglasses/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/syndicate(src)
