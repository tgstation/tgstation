/obj/item/reagent_containers/cup/tube
	name = "tube"
	desc = "A small test tube."
	icon_state = "test_tube"
	fill_icon_state = "tube"
	inhand_icon_state = "atoxinbottle"
	worn_icon_state = "test_tube"
	possible_transfer_amounts = list(5, 10, 15, 30)
	volume = 30
	fill_icon_thresholds = list(0, 1, 20, 40, 60, 80, 100)

/obj/item/reagent_containers/cup/tube/Initialize(mapload)
	. = ..()
	if(!icon_state)
		icon_state = "test_tube"
	update_appearance()
