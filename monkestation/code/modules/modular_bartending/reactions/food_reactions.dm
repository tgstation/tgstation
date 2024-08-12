/datum/chemical_reaction/saltsolidification
	required_reagents = list(/datum/reagent/consumable/salt = 10)
	required_temp = 600

/datum/chemical_reaction/saltsolidification/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/garnish/salt(location)

/datum/chemical_reaction/ashsolidification
	required_reagents = list(/datum/reagent/ash = 10)
	required_temp = 600

/datum/chemical_reaction/ashsolidification/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/garnish/ash(location)
