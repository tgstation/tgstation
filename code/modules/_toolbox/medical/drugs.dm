/datum/chemical_reaction/crowbar
	name = "Crowbar"
	id = "crowbar"
	results = list("crank" = 3)
	required_reagents = list("eznutriment" = 5, "oil" = 5, "welding_fuel" = 3)
	mix_message = "The mixture violently reacts, leaving behind a few crystalline shards."
	required_temp = 390



/datum/chemical_reaction/crowbar/on_reaction(datum/reagents/holder, created_volume)
	if (prob(50))
		var/turf/T = get_turf(holder.my_atom)
		for(var/turf/turf in range(1,T))
			new/obj/effect/hotspot(turf)
