/obj/item/weapon/reagent_containers/food/snacks/snackbar
	name = "snack bar"
	desc = "Made from your favorite completely harmless reagents!"
	icon_state = "snackbar"
	bitesize = 5
	volume = 10

/obj/item/weapon/reagent_containers/food/snacks/snackbar/on_reagent_change()
	update_icon()
	update_name()

/obj/item/weapon/reagent_containers/food/snacks/snackbar/update_icon()
	var/icon/I = icon('icons/obj/food.dmi', "snackbar")
	if(reagents.reagent_list)
		I += mix_color_from_reagents(reagents.reagent_list)
	src.icon = I

/obj/item/weapon/reagent_containers/food/snacks/snackbar/proc/update_name()
	if(reagents.reagent_list)
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
	else
		name = "snack bar"


//Instances for mapping
/obj/item/weapon/reagent_containers/food/snacks/snackbar/nutriment
	name = "nutriment snack bar"
	New()
		..()
		reagents.add_reagent("nutriment", 10)
		update_icon()
		update_name()