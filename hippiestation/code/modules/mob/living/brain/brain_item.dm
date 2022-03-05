/obj/item/organ/brain/transfer_identity(mob/living/L)	//hippie start, re-add cloning
	..()
	if(HAS_TRAIT(L, TRAIT_BADDNA))
		brainmob.status_traits[TRAIT_BADDNA] = L.status_traits[TRAIT_BADDNA]
		var/obj/item/organ/zombie_infection/ZI = L.getorganslot(ORGAN_SLOT_ZOMBIE)
		if(ZI)
			brainmob.set_species(ZI.old_species)	//For if the brain is cloned
