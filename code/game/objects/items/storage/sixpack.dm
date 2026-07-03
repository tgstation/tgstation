/obj/item/storage/cans
	name = "can ring"
	desc = "Holds up to six drink cans, and select bottles."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "canholder"
	inhand_icon_state = "cola"
	lefthand_file = 'icons/mob/inhands/items/drinks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/drinks_righthand.dmi'
	custom_materials = list(/datum/material/plastic = HALF_SHEET_MATERIAL_AMOUNT*1.2)
	max_integrity = 500
	storage_type = /datum/storage/sixcan

/obj/item/storage/cans/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins popping open a final cold one with the boys! Кажется, [user.ru_p_they()] пытается совершить самоубийство!"))
	return BRUTELOSS

/obj/item/storage/cans/update_icon_state()
	icon_state = "[initial(icon_state)][contents.len]"
	return ..()

/obj/item/storage/cans/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/storage/cans/sixsoda
	name = "soda bottle ring"
	desc = "Holds six soda cans. Remember to recycle when you're done!"

/obj/item/storage/cans/sixsoda/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/reagent_containers/cup/soda_cans/cola(src)

/obj/item/storage/cans/sixbeer
	name = "beer can ring"
	desc = "Holds six beers. Remember to recycle when you're done!"

/obj/item/storage/cans/sixbeer/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/reagent_containers/cup/soda_cans/beer(src)

/obj/item/storage/cans/sixgamerdrink
	name = "gamer drink bottle ring"
	desc = "Holds six gamer drink cans. Remember to recycle when you're done!"

	/// Pool of gamer drinks tm we may add from
	var/list/gamer_drink_options = list(
		/obj/item/reagent_containers/cup/soda_cans/pwr_game = 55,
		/obj/item/reagent_containers/cup/soda_cans/space_mountain_wind = 15,
		/obj/item/reagent_containers/cup/soda_cans/monkey_energy = 15,
		/obj/item/reagent_containers/cup/soda_cans/volt_energy = 10,
		/obj/item/reagent_containers/cup/soda_cans/thirteenloko = 5,
	)

/obj/item/storage/cans/sixgamerdrink/PopulateContents()
	for(var/i in 1 to 6)
		var/obj/item/chosen_gamer_drink = pick_weight(gamer_drink_options)
		new chosen_gamer_drink(src)

/obj/item/storage/cans/sixenergydrink
	name = "energy drink bottle ring"
	desc = "Holds six energy drink cans. Remember to recycle when you're done!"

	/// Pool of energy drinks tm we may add from
	var/list/energy_drink_options = list(
		/obj/item/reagent_containers/cup/soda_cans/space_mountain_wind = 50,
		/obj/item/reagent_containers/cup/soda_cans/monkey_energy = 30,
		/obj/item/reagent_containers/cup/soda_cans/volt_energy = 15,
		/obj/item/reagent_containers/cup/soda_cans/thirteenloko = 5,
	)

/obj/item/storage/cans/sixenergydrink/PopulateContents()
	for(var/i in 1 to 6)
		var/obj/item/chosen_energy_drink = pick_weight(energy_drink_options)
		new chosen_energy_drink(src)
