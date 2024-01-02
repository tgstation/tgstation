/*/mob/living/simple_animal/hostile/cat_butcherer/CanAttack(atom/target)
	if(iscarbon(target))
		var/mob/living/carbon/human/carbon_target = target
		if(carbon_target.getorgan(/obj/item/organ/external/ears/cat) && carbon_target.getorgan(/obj/item/organ/external/tail/cat) && carbon_target.has_trauma_type(/datum/brain_trauma/severe/pacifism))//he wont attack his creations
			if(carbon_target.stat >= UNCONSCIOUS && (!HAS_TRAIT(carbon_target, TRAIT_NOMETABOLISM) || !istype(carbon_target.dna.species, /datum/species/ipc)))//unless they need healing
				return ..()
			else
				return FALSE
	return ..()
	*/
