///Burdened grants some mutations upon injuring yourself sufficiently
/datum/brain_trauma/special/burdened
	name = "Flagellating Compulsions"
	desc = "Patient feels compelled to injure themselves in various incapacitating and horrific ways. There seems to be an odd genetic... trigger, following these compulsions may lead to?"
	scan_desc = "damaged frontal lobe"
	gain_text = span_notice("You feel burdened!")
	lose_text = span_warning("You no longer feel the need to burden yourself!")
	random_gain = FALSE
	/// goes from 0 to 9 (but can be beyond 9, just does nothing) and gives rewards. increased by disabling yourself with debuffs
	var/burden_level = 0
	/// Static list of organ slots that add burden when lost
	var/static/list/burden_organ_slots = list(
		ORGAN_SLOT_BRAIN,
		ORGAN_SLOT_HEART,
		ORGAN_SLOT_LUNGS,
		ORGAN_SLOT_EYES,
		ORGAN_SLOT_EARS,
		ORGAN_SLOT_TONGUE,
		ORGAN_SLOT_LIVER,
		ORGAN_SLOT_STOMACH,
	)

/datum/brain_trauma/special/burdened/on_gain()
	RegisterSignal(owner, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(organ_added_burden))
	RegisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(organ_removed_burden))

	RegisterSignal(owner, COMSIG_CARBON_ATTACH_LIMB, PROC_REF(limbs_added_burden))
	RegisterSignal(owner, COMSIG_CARBON_REMOVE_LIMB, PROC_REF(limbs_removed_burden))

	RegisterSignal(owner, COMSIG_CARBON_GAIN_ADDICTION, PROC_REF(addict_added_burden))
	RegisterSignal(owner, COMSIG_CARBON_LOSE_ADDICTION, PROC_REF(addict_removed_burden))

	RegisterSignal(owner, COMSIG_CARBON_GAIN_MUTATION, PROC_REF(mutation_added_burden))
	RegisterSignal(owner, COMSIG_CARBON_LOSE_MUTATION, PROC_REF(mutation_removed_burden))

	RegisterSignal(owner, COMSIG_CARBON_GAIN_TRAUMA, PROC_REF(trauma_added_burden))
	RegisterSignal(owner, COMSIG_CARBON_LOSE_TRAUMA, PROC_REF(trauma_removed_burden))

	for (var/burden_slot in burden_organ_slots)
		if (!owner.get_organ_slot(burden_slot) && is_burdensome_organ(owner, burden_slot, null, FALSE))
			update_burden(TRUE, silent = TRUE)

	var/list/missing_limbs = owner.get_missing_limbs()
	for (var/i in 1 to length(missing_limbs) + length(owner.mind?.active_addictions))
		update_burden(TRUE, silent = TRUE)

	if (owner.dna)
		for (var/datum/mutation/mutation in owner.dna.mutations)
			if (mutation.quality == NEGATIVE)
				update_burden(TRUE, silent = TRUE)

	for (var/datum/brain_trauma/severe/trauma in owner.get_traumas())
		update_burden(TRUE, silent = TRUE)

	return ..()

/datum/brain_trauma/special/burdened/on_lose()
	UnregisterSignal(owner, list(
		COMSIG_CARBON_GAIN_ORGAN,
		COMSIG_CARBON_LOSE_ORGAN,
		COMSIG_CARBON_ATTACH_LIMB,
		COMSIG_CARBON_REMOVE_LIMB,
		COMSIG_CARBON_GAIN_ADDICTION,
		COMSIG_CARBON_LOSE_ADDICTION,
		COMSIG_CARBON_GAIN_MUTATION,
		COMSIG_CARBON_LOSE_MUTATION,
		COMSIG_CARBON_GAIN_TRAUMA,
		COMSIG_CARBON_LOSE_TRAUMA,
	))

	for (var/i in 1 to burden_level)
		update_burden(FALSE, silent = TRUE)

	return ..()

/**
 * Called by hooked signals whenever burden_level var needs to go up or down by 1.
 * Sends messages on burden level, gives powers and takes them if needed, etc
 *
 * Arguments:
 * * increase: whether to tick burden_level up or down 1
 * * silent: if TRUE, this does not print out any to_chats
 */
/datum/brain_trauma/special/burdened/proc/update_burden(increase, silent = FALSE)
	var/datum/dna/dna = owner?.dna
	if(!dna)
		qdel(src)
		return
	//adjust burden
	burden_level = increase ? burden_level + 1 : burden_level - 1
	if(burden_level < 0)
		burden_level = 0
	//send a message and handle rewards
	switch(burden_level)
		if(0)
			if (!silent)
				to_chat(owner, span_warning("You feel no weight on your shoulders. You are not feeling [GLOB.deity]'s suffering."))
		if(1)
			if (!silent)
				if(increase)
					to_chat(owner, span_notice("You begin to feel the scars on [GLOB.deity]. You must continue to burden yourself."))
				else
					to_chat(owner, span_warning("The weight on your shoulders feels lighter. You are barely feeling [GLOB.deity]'s suffering."))
		if(2)
			if(increase)
				if (!silent)
					to_chat(owner, span_notice("You have done well to understand [GLOB.deity]. You are almost at a breakthrough."))
			else
				if (!silent)
					to_chat(owner, span_warning("The weight on your shoulders feels lighter. You have lost some universal truths."))
				dna.remove_mutation(/datum/mutation/telepathy, MUTATION_SOURCE_BURDENED_TRAUMA)
				dna.remove_mutation(/datum/mutation/unintelligible, MUTATION_SOURCE_BURDENED_TRAUMA)
				owner.remove_filter("burden_outline")
		if(3)
			if(increase)
				if (!silent)
					to_chat(owner, span_notice("Your suffering is only a fraction of [GLOB.deity]'s, and yet the universal truths are coming to you."))
				dna.add_mutation(/datum/mutation/telepathy, MUTATION_SOURCE_BURDENED_TRAUMA)
				dna.add_mutation(/datum/mutation/unintelligible, MUTATION_SOURCE_BURDENED_TRAUMA)
				owner.add_filter("burden_outline", 9, list("type" = "outline", "color" = "#6c6eff"))
			else
				if (!silent)
					to_chat(owner, span_warning("The weight on your shoulders feels lighter. You feel like you're about to forget."))
		if(4)
			if (!silent)
				if(increase)
					to_chat(owner, span_notice("It hurts, each ounce of pain a lesson told. How does [GLOB.deity] bear this weight?"))
				else
					to_chat(owner, span_warning("The weight on your shoulders feels lighter. You're growing further from your goal."))
		if(5)
			if(increase)
				if (!silent)
					to_chat(owner, span_notice("Your body is a canvas of loss. You are almost at a breakthrough."))
			else
				if (!silent)
					to_chat(owner, span_warning("The weight on your shoulders feels lighter. You have lost some universal truths."))
				dna.remove_mutation(/datum/mutation/telekinesis, MUTATION_SOURCE_BURDENED_TRAUMA)
				dna.remove_mutation(/datum/mutation/mindreader, MUTATION_SOURCE_BURDENED_TRAUMA)
		if(6)
			if(increase)
				if (!silent)
					to_chat(owner, span_notice("Your suffering is respectful, your scars immaculate. More universal truths are clear, but you do not fully understand yet."))
				dna.add_mutation(/datum/mutation/telekinesis, MUTATION_SOURCE_BURDENED_TRAUMA)
				dna.add_mutation(/datum/mutation/mindreader, MUTATION_SOURCE_BURDENED_TRAUMA)
			else
				if (!silent)
					to_chat(owner, span_warning("The weight on your shoulders feels lighter. You feel like you're about to forget."))
		if(7)
			if (!silent)
				if(increase)
					to_chat(owner, span_notice("The weight on your shoulders is immense. [GLOB.deity] is shattered across the cosmos."))
				else
					to_chat(owner, span_warning("The weight on your shoulders feels lighter. You're growing further from your goal."))
		if(8)
			if (!silent)
				if(increase)
					to_chat(owner, span_notice("You're on the cusp of another breakthrough. [GLOB.deity] lost everything."))
				else
					to_chat(owner, span_warning("The weight on your shoulders feels lighter. You have lost some universal truths."))
		if(9)
			if(increase)
				if (!silent)
					to_chat(owner, span_notice("You have finally broken yourself enough to understand [GLOB.deity]. It's all so clear to you."))
				var/mob/living/carbon/human/knower = owner
				if(!istype(knower))
					return
				INVOKE_ASYNC(knower, TYPE_PROC_REF(/mob/living/carbon/human, slow_psykerize))

/datum/brain_trauma/special/burdened/proc/is_burdensome_organ(mob/burdened, organ_slot, obj/item/organ/organ, special)
	if(special) //aheals
		return
	if(!ishuman(burdened))
		return //mobs that don't care about organs
	var/mob/living/carbon/human/burdened_human = burdened
	var/datum/species/burdened_species = burdened_human.dna?.species
	if(!burdened_species)
		return

	/// only organs that are slotted in these count. because there's a lot of useless organs to cheese with.
	var/list/critical_slots = burden_organ_slots.Copy()
	if(!burdened_species.mutantheart)
		critical_slots -= ORGAN_SLOT_HEART
	if(!burdened_species.mutanttongue)
		critical_slots -= ORGAN_SLOT_TONGUE
	if(!burdened_species.mutantlungs)
		critical_slots -= ORGAN_SLOT_LUNGS
	if(!burdened_species.mutantstomach)
		critical_slots -= ORGAN_SLOT_STOMACH
	if(!burdened_species.mutantliver)
		critical_slots -= ORGAN_SLOT_LIVER

	if(!(organ_slot in critical_slots))
		return FALSE
	if(istype(organ, /obj/item/organ/eyes))
		var/obj/item/organ/eyes/eyes = organ
		if(eyes.tint < TINT_BLIND) //unless you were already blinded by them (flashlight eyes), this is adding burden!
			return TRUE
		return FALSE
	return TRUE

/// Signal to decrease burden_level (see update_burden proc) if an organ is added
/datum/brain_trauma/special/burdened/proc/organ_added_burden(mob/burdened, obj/item/organ/new_organ, special)
	SIGNAL_HANDLER

	if(is_burdensome_organ(burdened, new_organ.slot, new_organ, special))
		update_burden(increase = FALSE)//working organ

/// Signal to increase burden_level (see update_burden proc) if an organ is removed
/datum/brain_trauma/special/burdened/proc/organ_removed_burden(mob/burdened, obj/item/organ/old_organ, special)
	SIGNAL_HANDLER

	if(is_burdensome_organ(burdened, old_organ.slot, old_organ, special))
		update_burden(increase = TRUE) //lost organ

/// Signal to decrease burden_level (see update_burden proc) if a limb is added
/datum/brain_trauma/special/burdened/proc/limbs_added_burden(datum/source, obj/item/bodypart/new_limb, special)
	SIGNAL_HANDLER

	if(special) //something we don't wanna consider, like instaswapping limbs
		return
	update_burden(increase = FALSE)

/// Signal to increase burden_level (see update_burden proc) if a limb is removed
/datum/brain_trauma/special/burdened/proc/limbs_removed_burden(datum/source, obj/item/bodypart/old_limb, special, dismembered)
	SIGNAL_HANDLER

	if(special) //something we don't wanna consider, like instaswapping limbs
		return
	update_burden(increase = TRUE)

/// Signal to increase burden_level (see update_burden proc) if an addiction is added
/datum/brain_trauma/special/burdened/proc/addict_added_burden(datum/addiction/new_addiction, datum/mind/addict_mind)
	SIGNAL_HANDLER

	update_burden(increase = TRUE)

/// Signal to decrease burden_level (see update_burden proc) if an addiction is removed
/datum/brain_trauma/special/burdened/proc/addict_removed_burden(datum/addiction/old_addiction, datum/mind/nonaddict_mind)
	SIGNAL_HANDLER

	update_burden(increase = FALSE)

/// Signal to increase burden_level (see update_burden proc) if a mutation is added
/datum/brain_trauma/special/burdened/proc/mutation_added_burden(mob/living/carbon/burdened, datum/mutation/mutation_type, class)
	SIGNAL_HANDLER

	if(initial(mutation_type.quality) == NEGATIVE)
		update_burden(increase = TRUE)

/// Signal to decrease burden_level (see update_burden proc) if a mutation is removed
/datum/brain_trauma/special/burdened/proc/mutation_removed_burden(mob/living/carbon/burdened, datum/mutation/mutation_type)
	SIGNAL_HANDLER

	if(initial(mutation_type.quality) == NEGATIVE)
		update_burden(increase = FALSE)

/// Signal to increase burden_level (see update_burden proc) if a trauma is added
/datum/brain_trauma/special/burdened/proc/trauma_added_burden(mob/living/carbon/burdened, datum/brain_trauma/trauma_added)
	SIGNAL_HANDLER

	if(istype(trauma_added, /datum/brain_trauma/severe))
		update_burden(increase = TRUE)

/// Signal to decrease burden_level (see update_burden proc) if a trauma is removed
/datum/brain_trauma/special/burdened/proc/trauma_removed_burden(mob/living/carbon/burdened, datum/brain_trauma/trauma_removed)
	SIGNAL_HANDLER

	if(istype(trauma_removed, /datum/brain_trauma/severe))
		update_burden(increase = FALSE)
