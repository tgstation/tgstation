/datum/chemical_reaction/pizzaification
	name = "Pizzaification"
	id = "pizzaification"
	required_reagents = list("tomatojuice" = 10, "oil"  = 5, "flour"=20, "sodium"=5)
	required_temp = 450
	mob_react = FALSE

/datum/chemical_reaction/pizzaification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		var/pizza = pick(typesof(/obj/item/reagent_containers/food/snacks/pizza))
		new pizza(location)