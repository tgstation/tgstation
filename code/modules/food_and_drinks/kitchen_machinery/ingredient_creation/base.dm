/obj/machinery/ingredient_creation
	name = "ingredient creator"
	desc = "I AM BEGUN"
	icon = 'icons/obj/kitchen/machines.dmi'
	icon_state = "debug_off"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	var/obj/item/cooking = null	//special, bell peppers and beef
	var/cook_time = 0
	var/lightly_done = "lightly debug'd"
	var/lightly_done_color = rgb(166,103,54)
	var/done = "debug'd"
	var/done_color = rgb(103,63,24)
	var/over_done = "over debug'd"
	var/over_done_color = rgb(63,23,4)

	var/icon_off = "debug_off"
	var/icon_on = "debug"

	var/uses_reagents = FALSE

	var/type_to_process_into = /obj/item/reagent_containers/food/ingredient/processed

/obj/machinery/ingredient_creation/examine()
	..()
	if(cooking)
		to_chat(usr, "You can make out [cooking] in [src]")

/obj/machinery/ingredient_creation/attackby(obj/item/I, mob/user)
	if(!uses_reagents)
		if(istype(I, /obj/item/reagent_containers/food/ingredient) || istype(I,/obj/item/reagent_containers/food/snacks/grown))
			if(user.drop_item() && !cooking)
				to_chat(user, "<span class='notice'>You put [I] into [src].</span>")
				cooking = I
				cooking.forceMove(src)
				icon_state = icon_on
	else

/obj/machinery/ingredient_creation/process()
	..()
	if(cooking)
		cook_time++
		if(cook_time == 30)
			playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
			visible_message("[src] dings!")
		else if (cook_time == 60)
			visible_message("[src] emits an acrid smell!")


/obj/machinery/ingredient_creation/attack_hand(mob/user)
	if(cooking)
		if(cooking.loc == src)
			to_chat(user, "<span class='notice'>You remove [cooking] from [src].</span>")
			var/obj/item/reagent_containers/food/ingredient/processed/P = new type_to_process_into(get_turf(src))
			P.add_ingredient(cooking, 0)
			switch(cook_time)
				if(0 to 15)
					P.add_atom_colour(lightly_done_color, FIXED_COLOUR_PRIORITY)
					P.name = "[lightly_done] [cooking.name]"
				if(16 to 49)
					P.add_atom_colour(done_color, FIXED_COLOUR_PRIORITY)
					P.name = "[done] [cooking.name]"
				if(50 to 59)
					P.add_atom_colour(over_done_color, FIXED_COLOUR_PRIORITY)
					P.name = "[over_done] [cooking.name]"
			icon_state = icon_off
			user.put_in_hands(S)
			cooking = null
			cook_time = 0
			return
	..()
