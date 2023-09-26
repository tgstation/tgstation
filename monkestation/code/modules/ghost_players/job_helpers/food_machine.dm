/obj/structure/food_machine
	name = "all in one food transporter"
	desc = "Centcomms latest and greatest, capable of transporting all forms of produce to Centcommms chefs in training."


	resistance_flags = INDESTRUCTIBLE
	anchored = TRUE

	icon = 'icons/obj/money_machine.dmi'
	icon_state = "bogdanoff"


/obj/structure/food_machine/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	var/list/foods = subtypesof(/obj/item/food/grown) + subtypesof(/obj/item/food/meat) + typesof(/obj/item/food/fishmeat) + subtypesof(/obj/item/reagent_containers/condiment)

	var/atom/choice = tgui_input_list(user, "Choose a food item to send", "[src.name]", foods)
	if(!choice)
		return
	var/number = tgui_input_number(user, "How many should we send", "[src.name]", 1, 10, 1)
	if(!number)
		return

	while(number > 0)
		number--
		new choice(get_turf(src))
