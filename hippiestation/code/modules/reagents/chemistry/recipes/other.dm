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
	required_reagents = list("pyrosium" = 5, "cryostylane" = 5, "gold" = 20)

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
	required_reagents = list("pyrosium" = 5, "cryostylane" = 5, "banana" = 80)//There is 1000u of banana juice on station at roundstart, an enterpirsing robitisict could have a honk up every round if I kept it the same.
	mob_react = FALSE

/datum/chemical_reaction/bananasolidification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/stack/sheet/mineral/bananium(location)


/datum/chemical_reaction/plastic_polymers/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/stack/sheet/plastic(location)