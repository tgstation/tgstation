////////////////////////////////////////////////////////////////////////////////
/// Food.
////////////////////////////////////////////////////////////////////////////////

//Food is basically a glorified beaker with a lot of fancy coding. Now you know, and knowing is half the battle
/obj/item/weapon/reagent_containers/food
	possible_transfer_amounts = null
	volume = 50 //Food can contain a beaker's worth of reagents unless specified otherwise. Do note large servings of complex food items can contain well over 50 reagents total

/obj/item/weapon/reagent_containers/food/New()
		..()
		src.pixel_x = rand(-5.0, 5)	//Randomizes position slightly.
		src.pixel_y = rand(-5.0, 5)
