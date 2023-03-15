///This is mainly a debug item for testing various chemical gases and how much each chem gives in terms of gas.
/obj/item/reagent_containers/glass/beaker/gasifier
	name = "Gasifier"
	desc = "A large beaker with the added function of being able to convert the chemicals inside it into gas."
	volume = 200
	amount_per_transfer_from_this = 200


/obj/item/reagent_containers/glass/beaker/gasifier/attack_self(mob/user)
	. = ..()
	for(var/datum/reagent/contained_reagent in reagents.reagent_list)
		var/temp = reagents?.chem_temp
		var/turf/turf = get_turf(src.loc)
		if(!temp)
			if(isopenturf(turf))
				var/turf/open/open_turf = turf
				var/datum/gas_mixture/air = open_turf.return_air()
				temp = air.return_temperature()
			else
				temp = T20C
		turf.atmos_spawn_air("[contained_reagent.get_gas()]=[volume/contained_reagent.molarity];TEMP=[temp]")
		reagents.reagent_list -= contained_reagent
