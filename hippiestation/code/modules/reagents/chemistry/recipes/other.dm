/datum/chemical_reaction/plasmasolidification
	required_reagents = list("pyrosium" = 5, "cryostylane" = 5, "plasma" = 20)

/datum/chemical_reaction/silversolidification
	name = "Solid Silver"
	id = "solidsilver"
	required_reagents = list("pyrosium" = 5, "cryostylane" = 5, "silver" = 20)
	mob_react = FALSE


/datum/chemical_reaction/silversolidification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/stack/sheet/mineral/silver(location)

/datum/chemical_reaction/metalsolidification
	name = "Solid metal"
	id = "solidmetal"
	required_reagents = list("pyrosium" = 5, "cryostylane" = 5, "iron" = 20)
	mob_react = FALSE


/datum/chemical_reaction/metalsolidification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/stack/sheet/metal(location)

/datum/chemical_reaction/glasssolidification
	name = "Solid Glass"
	id = "solidglass"
	required_reagents = list("pyrosium" = 5, "cryostylane" = 5, "silicon" = 20)
	mob_react = FALSE


/datum/chemical_reaction/glasssolidification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/stack/sheet/glass(location)

/datum/chemical_reaction/goldsolidification
	name = "Solid Gold"
	id = "solidgold"
	required_reagents = list("pyrosium" = 5, "cryostylane" = 5, "gold" = 20)
	mob_react = FALSE


/datum/chemical_reaction/goldsolidification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/stack/sheet/mineral/gold(location)

/datum/chemical_reaction/uraniumsolidification
	name = "Solid Uranium"
	id = "soliduranium"
	required_reagents = list("pyrosium" = 5, "cryostylane" = 5, "uranium" = 20)
	mob_react = FALSE


/datum/chemical_reaction/uraniumsolidification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/stack/sheet/mineral/uranium(location)

/datum/chemical_reaction/bananasolidification
	name = "Solid Bananium"
	id = "solidbanana"
	required_reagents = list("pyrosium" = 5, "cryostylane" = 5, "banana" = 20)
	mob_react = FALSE


/datum/chemical_reaction/bananasolidification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		if(prob(75)) // Bananaium is kinda strong when sold to cargo and the clown starts with a shittone of banana juice so this little bit of fun also serves as a limiter.
			new /obj/item/stack/sheet/mineral/bananium(location)
		else
			new /obj/item/reagent_containers/food/snacks/grown/banana(location)




/datum/chemical_reaction/plastic_polymers/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/stack/sheet/plastic(location)