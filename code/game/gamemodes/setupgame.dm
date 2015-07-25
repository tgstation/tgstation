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


/datum/subsystem/ticker/proc/combinations(n, list/got, pos, list/from, list/out)
	var/cnt = 0
	if (got.len == n)
		out.Add(list2text(got))
		return 1
	for(var/i = pos, i <= from.len, i++)
		got.Add(from[i])
		cnt += combinations(n, got, i, from, out)
		pop(got)
	return cnt

/datum/subsystem/ticker/proc/setupPrototypes()
	var/list/abstract_types = list(/datum/prototype,/datum/prototype/effect,/datum/prototype/target,/datum/prototype/activator)
	var/list/prototypes = typesof(/datum/prototype) - abstract_types

	var/list/patterns = list()

	var/list/blocks = list("A","B","C","D","E","F","G","H") 
	var/list/availible = list()
	combinations(3,new/list(),1,blocks,availible)

	for(var/prototype in prototypes)
		var/picked = pick(availible)
		patterns[picked] = prototype
		availible.Remove(picked)

	prototype_mapping = patterns