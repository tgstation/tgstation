/datum/element/plumbing_extractable/acid
	returned_reagents = list(/datum/reagent/liquidgibs = 1)

	///X acidpwr is one returned_reagents. If you're curious, as of writing 10u of acid equals 1u of liquid gibs
	var/acidpwr_needed = 100

/datum/element/plumbing_extractable/acid/has_required(datum/reagents/victim)
	for(var/datum/D in victim.reagent_list)
		if(istype(D, /datum/reagent/toxin/acid/))
			var/datum/reagent/toxin/acid/A = D
			if(A.acidpwr > 0)
				required_reagents.Cut()
				///Example: if we need 100 acidpwr and we have 50 acidpower, we'll use two units of acid
				required_reagents[A.type] = acidpwr_needed / A.acidpwr
				return ..()

