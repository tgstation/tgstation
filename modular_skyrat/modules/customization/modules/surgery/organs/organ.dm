/obj/item/organ
	///This is for associating an organ with a mutant bodypart. Look at tails for examples
	var/mutantpart_key
	var/list/list/mutantpart_info

/obj/item/organ/Initialize()
	. = ..()
	if(mutantpart_key)
		color = mutantpart_info[MUTANT_INDEX_COLOR_LIST][1]

/obj/item/organ/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE)
	var/mob/living/carbon/human/H = M
	if(mutantpart_key && istype(H))
		H.dna.species.mutant_bodyparts[mutantpart_key] = mutantpart_info.Copy()
		H.update_body()
	. = ..()

/obj/item/organ/Remove(mob/living/carbon/M, special = FALSE)
	var/mob/living/carbon/human/H = M
	if(mutantpart_key && istype(H))
		if(H.dna.species.mutant_bodyparts[mutantpart_key])
			mutantpart_info = H.dna.species.mutant_bodyparts[mutantpart_key].Copy() //Update the info in case it was changed on the person
		color = "#[mutantpart_info[MUTANT_INDEX_COLOR_LIST][1]]"
		H.dna.species.mutant_bodyparts -= mutantpart_key
		H.update_body()
	. = ..()

/obj/item/organ/proc/build_from_dna(datum/dna/DNA, associated_key)
	mutantpart_key = associated_key
	mutantpart_info = DNA.mutant_bodyparts[associated_key].Copy()
	color = "#[mutantpart_info[MUTANT_INDEX_COLOR_LIST][1]]"
