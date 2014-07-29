/obj/machinery/cooking
	name = "oven"
	desc = "Cookies are ready, dear."
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "oven_off"
	var/orig = "oven"
	var/production_meth = "cooking"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	var/grown_only = 0
	idle_power_usage = 5
	var/on = FALSE	//Is it making food already?
	var/list/food_choices = list()
/obj/machinery/cooking/New()
	..()
	updatefood()

/obj/machinery/cooking/attackby(obj/item/I, mob/user)
	if(on)
		user << "The machine is already running."
		return
	if(istype(I,/obj/item/weapon/wrench))
		if(!anchored)
			playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
			anchored = 1
			user << "You wrench [src] in place."
		else if(anchored)
			playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
			anchored = 0
			user << "You unwrench [src]."
	if(!istype(I,/obj/item/weapon/reagent_containers/food/snacks/))
		user << "That isn't food."
		return
	if(!istype(I,/obj/item/weapon/reagent_containers/food/snacks/grown/) && grown_only)
		user << "You can only still grown items."
		return
	else
		var/obj/item/weapon/reagent_containers/food/snacks/F = I
		var/obj/item/weapon/reagent_containers/food/snacks/customizable/C
		user.drop_item()
		F.loc = src
		C = input("Select food to make.", "Cooking", C) in food_choices
		if(!C)
			F.loc = user.loc
			return
		else
			user << "You put [F] into [src] for [production_meth]."
			user.drop_item()
			F.loc = src
			on = TRUE
			icon_state = "[orig]_on"
			sleep(100)
			on = FALSE
			icon_state = "[orig]_off"
			C.loc = get_turf(src)
			C.attackby(F,user)
			playsound(loc, 'sound/machines/ding.ogg', 50, 1)
			updatefood()
			return

/obj/machinery/cooking/proc/updatefood()
	return

/obj/machinery/cooking/oven
	name = "oven"
	desc = "Cookies are ready, dear."
	icon_state = "oven_off"

/obj/machinery/cooking/oven/updatefood()
	for(var/U in food_choices)
		food_choices.Remove(U)
	for(var/U in typesof(/obj/item/weapon/reagent_containers/food/snacks/customizable/cook)-(/obj/item/weapon/reagent_containers/food/snacks/customizable/cook))
		var/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/V = new U
		src.food_choices += V
	return

/obj/machinery/cooking/candy
	name = "candy machine"
	desc = "Get yer box of deep fried deep fried deep fried deep fried cotton candy cereal sandwich cookies here!"
	icon_state = "mixer_off"
	orig = "mixer"
	production_meth = "candizing"

/obj/machinery/cooking/candy/updatefood()
	for(var/U in food_choices)
		food_choices.Remove(U)
	for(var/U in typesof(/obj/item/weapon/reagent_containers/food/snacks/customizable/candy)-(/obj/item/weapon/reagent_containers/food/snacks/customizable/candy))
		var/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/V = new U
		src.food_choices += V
	return


/obj/machinery/cooking/still
	name = "still"
	desc = "Alright, so, t'make some moonshine, fust yo' gotta combine some of this hyar egg wif th' deep fried sausage."
	icon_state = "still_off"
	orig = "still"
	grown_only = 1
	production_meth = "brewing"

/obj/machinery/cooking/still/updatefood()
	for(var/U in food_choices)
		food_choices.Remove(U)
	for(var/U in typesof(/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/)-(/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/))
		var/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/V = new U
		src.food_choices += V
	return
