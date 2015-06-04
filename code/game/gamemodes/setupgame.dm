/datum/subsystem/ticker/proc/setupGenetics()
	var/list/avnums = new /list(DNA_STRUC_ENZYMES_BLOCKS)
	for(var/i=1, i<=DNA_STRUC_ENZYMES_BLOCKS, i++)
		avnums[i] = i

	for(var/A in typesof(/datum/mutation/human) - /datum/mutation/human)
		var/datum/mutation/human/B = new A()
		if(B.dna_block == NON_SCANNABLE)	return
		B.dna_block = pick_n_take(avnums)
		if(B.quality == POSITIVE)
			good_mutations |= B
		else if(B.quality == NEGATIVE)
			bad_mutations |= B
		else if(B.quality == MINOR_NEGATIVE)
			not_good_mutations |= B

/datum/subsystem/ticker/proc/setupFactions()
	// Populate the factions list:
	for(var/typepath in typesof(/datum/faction))
		var/datum/faction/F = new typepath()
		if(!F.name)
			qdel(F)
			continue
		else
			factions.Add(F)
			availablefactions.Add(F)

	// Populate the syndicate coalition:
	for(var/datum/faction/syndicate/S in factions)
		syndicate_coalition.Add(S)
