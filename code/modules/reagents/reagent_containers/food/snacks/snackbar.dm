/obj/item/weapon/reagent_containers/food/snacks/snackbar
	name = "snack bar"
	desc = "Made from your favorite completely harmless reagents!"
	icon_state = "snackbar"
	bitesize = 5
	volume = 10

/obj/item/weapon/reagent_containers/food/snacks/snackbar/on_reagent_change()
	if(!reagents.total_volume)  //This should only happen if a chemical reaction removes the reagents from the bar
		icon_state = "" //So it isn't visible in the 1/10th of a second before it is deleted
		spawn(1) //A small delay is needed before deleting to allow for reactions to occur
			del(src) //We don't want empty snack bars
	else
		update_icon()
		update_name()

/obj/item/weapon/reagent_containers/food/snacks/snackbar/update_icon()
	var/icon/I = icon('icons/obj/food.dmi', "snackbar")
	I += mix_color_from_reagents(reagents.reagent_list)
	src.icon = I

/obj/item/weapon/reagent_containers/food/snacks/snackbar/proc/update_name()
	var/newname = ""
	var/i = 0
	for(var/datum/reagent/r in reagents.reagent_list)
		i++
		if(i == 1)
			newname += "[r.name]"
		else if(i == reagents.reagent_list.len)
			newname += " and [r.name]"
		else
			newname += ", [r.name]"
	name = lowertext("[newname] snack bar")


//Instances for mapping

/obj/item/weapon/reagent_containers/food/snacks/snackbar/nutriment
	name = "nutriment snack bar"
	New()
		..()
		reagents.add_reagent("nutriment", 10)
		update_icon()
		update_name()