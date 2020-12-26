///Creates liquid gibs depending on acid power
/datum/element/plumbing_extractable/acid
	returned_reagents = list(/datum/reagent/liquidgibs = 1)

	///X acidpwr is one returned_reagents. If you're curious, as of writing 10u of acid equals 1u of liquid gibs
	var/acidpwr_needed = 100

/datum/element/plumbing_extractable/acid/has_required(datum/reagents/victim)
	for(var/datum/D in victim.reagent_list)
		if(istype(D, /datum/reagent/toxin/acid ))
			var/datum/reagent/toxin/acid/A = D
			if(A.acidpwr > 0)
				required_reagents.Cut()
				///Example: if we need 100 acidpwr and we have 50 acidpower, we'll use two units of acid
				required_reagents[A.type] = acidpwr_needed / A.acidpwr
				return ..()


/datum/element/plumbing_extractable/essence_of_drug
	required_reagents = list(/datum/reagent/drug/methamphetamine = 10, /datum/reagent/drug/krokodil = 10, /datum/reagent/drug/bath_salts = 10, \
		/datum/reagent/medicine/omnizine/protozine = 10)
	returned_reagents = list(/datum/reagent/drug/essence_of_drug = 5)

///Recipey is tweaked to be very slow but cheap. To get it faster, get more podpeople, which is the main bottleneck considering their rarity
/datum/element/plumbing_extractable/lights_blessing
	required_reagents = list(/datum/reagent/ammonia = 15)
	returned_reagents = list(/datum/reagent/medicine/light_blessing = 1)

///Needs a little bit of smart engineering to get stable liquid dark matter flowing, but otherwise the main bottle neck is getting shadowpeople
/datum/element/plumbing_extractable/darkness_blessing
	required_reagents = list(/datum/reagent/liquid_dark_matter = 1)
	returned_reagents = list(/datum/reagent/medicine/light_blessing/dark = 1)
