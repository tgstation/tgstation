
///Burdened grants some more mutations upon injuring yourself sufficiently
/datum/mutation/human/burdened
	name = "Burdened"
	desc = "Less of a genome and more of a forceful rewrite of genes. Nothing Nanotrasen supplies allows for a genetic restructure like this... \
	The user feels compelled to injure themselves in various incapacitating and horrific ways. Oddly enough, this gene seems to be connected \
	to several other ones, possibly ready to trigger more genetic changes in the future."
	quality = POSITIVE //so it gets carried over on revives
	locked = TRUE
	text_gain_indication = "<span class='notice'>You feel burdened!</span>"
	text_lose_indication = "<span class='warning'>You no longer feel the need to burden yourself!</span>"
	/// goes from 0 to 6 (but can be beyond 6, just does nothing) and gives rewards. increased by disabling yourself with debuffs
	var/burden_level = 0

/datum/mutation/human/burdened/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	RegisterSignal(owner, COMSIG_CARBON_GAIN_ORGAN, .proc/organ_added_burden)
	RegisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN, .proc/organ_removed_burden)

	RegisterSignal(owner, COMSIG_CARBON_ATTACH_LIMB, .proc/limbs_added_burden)
	RegisterSignal(owner, COMSIG_CARBON_REMOVE_LIMB, .proc/limbs_removed_burden)

	RegisterSignal(owner, COMSIG_CARBON_GAIN_ADDICTION, .proc/addict_added_burden)
	RegisterSignal(owner, COMSIG_CARBON_LOSE_ADDICTION, .proc/addict_removed_burden)

	RegisterSignal(owner, COMSIG_CARBON_GAIN_MUTATION, .proc/mutation_added_burden)
	RegisterSignal(owner, COMSIG_CARBON_LOSE_MUTATION, .proc/mutation_removed_burden)

	RegisterSignal(owner, COMSIG_CARBON_GAIN_TRAUMA, .proc/trauma_added_burden)
	RegisterSignal(owner, COMSIG_CARBON_LOSE_TRAUMA, .proc/trauma_removed_burden)

/datum/mutation/human/burdened/on_losing(mob/living/carbon/human/owner)
	. = ..()
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

/**
 * Called by hooked signals whenever burden_level var needs to go up or down by 1.
 * Sends messages on burden level, gives powers and takes them if needed, etc
 *
 * Arguments:
 * * increase: whether to tick burden_level up or down 1
 */
/datum/mutation/human/burdened/proc/update_burden(increase)
	//adjust burden
	burden_level = increase ? burden_level + 1 : burden_level - 1
	if(burden_level < 0) //basically a clamp with a stack on it, because this shouldn't be happening
		stack_trace("somehow, burden mutation is removing more burden than it's adding.")
		burden_level = 0
	//send a message and handle rewards
	switch(burden_level)
		if(0)
			to_chat(owner, span_warning("You feel no weight on your shoulders. You are not feeling [GLOB.deity]'s suffering."))
		if(1)
			if(increase)
				to_chat(owner, span_notice("You begin to feel the scars on [GLOB.deity]. You must continue to burden yourself."))
			else
				to_chat(owner, span_warning("The weight on your shoulders feels lighter. You are barely feeling [GLOB.deity]'s suffering."))
		if(2)
			if(increase)
				to_chat(owner, span_notice("You have done well to understand [GLOB.deity]. You are almost at a breakthrough."))
			else
				to_chat(owner, span_warning("The weight on your shoulders feels lighter. You have lost some universal truths."))
				dna.remove_mutation(/datum/mutation/human/telepathy)
				dna.remove_mutation(/datum/mutation/human/mute)
				owner.remove_filter("burden_outline")
		if(3)
			if(increase)
				to_chat(owner, span_notice("Your suffering is only a fraction of [GLOB.deity]'s, and yet the universal truths are coming to you."))
				dna.add_mutation(/datum/mutation/human/telepathy)
				dna.add_mutation(/datum/mutation/human/mute)
				owner.add_filter("burden_outline", 9, list("type" = "outline", "color" = "#6c6eff"))
			else
				to_chat(owner, span_warning("The weight on your shoulders feels lighter. You feel like you're about to forget."))
		if(4)
			if(increase)
				to_chat(owner, span_notice("The weight on your shoulders is immense. [GLOB.deity] is shattered across the cosmos."))
			else
				to_chat(owner, span_warning("The weight on your shoulders feels lighter. You're growing further from your goal."))
		if(5)
			if(increase)
				to_chat(owner, span_notice("You're on the cusp of another breakthrough. [GLOB.deity] lost everything."))
			else
				to_chat(owner, span_warning("The weight on your shoulders feels lighter. You have lost some universal truths."))
				dna.remove_mutation(/datum/mutation/human/telekinesis)
				dna.remove_mutation(/datum/mutation/human/mindreader)
		if(6)
			to_chat(owner, span_notice("You have finally broken yourself enough to understand [GLOB.deity]. It's all so clear to you."))
			dna.add_mutation(/datum/mutation/human/telekinesis)
			dna.add_mutation(/datum/mutation/human/mindreader)

/// Signal to decrease burden_level (see update_burden proc) if an organ is added
/datum/mutation/human/burdened/proc/organ_added_burden(mob/burdened, obj/item/organ/new_organ, special)
	SIGNAL_HANDLER

	if(special) //aheals
		return

	if(istype(new_organ, /obj/item/organ/eyes))
		var/obj/item/organ/eyes/new_eyes = new_organ
		if(new_eyes.tint < TINT_BLIND) //unless you added unworking eyes (flashlight eyes), this is removing burden
			update_burden(FALSE)
		return
	update_burden(FALSE)//working organ

/// Signal to increase burden_level (see update_burden proc) if an organ is removed
/datum/mutation/human/burdened/proc/organ_removed_burden(mob/burdened, obj/item/organ/old_organ, special)
	SIGNAL_HANDLER

	if(special) //aheals
		return

	if(istype(old_organ, /obj/item/organ/eyes))
		var/obj/item/organ/eyes/old_eyes = old_organ
		if(old_eyes.tint < TINT_BLIND) //unless you were already blinded by them (flashlight eyes), this is adding burden!
			update_burden(TRUE)

	update_burden(TRUE)//lost organ

/// Signal to decrease burden_level (see update_burden proc) if a limb is added
/datum/mutation/human/burdened/proc/limbs_added_burden(datum/source, obj/item/bodypart/new_limb, special)
	SIGNAL_HANDLER

	if(special) //something we don't wanna consider, like instaswapping limbs
		return
	update_burden(FALSE)

/// Signal to increase burden_level (see update_burden proc) if a limb is removed
/datum/mutation/human/burdened/proc/limbs_removed_burden(datum/source, obj/item/bodypart/old_limb, special)
	SIGNAL_HANDLER

	if(special) //something we don't wanna consider, like instaswapping limbs
		return
	update_burden(TRUE)

/// Signal to increase burden_level (see update_burden proc) if an addiction is added
/datum/mutation/human/burdened/proc/addict_added_burden(datum/addiction/new_addiction, datum/mind/addict_mind)
	SIGNAL_HANDLER

	update_burden(TRUE)

/// Signal to decrease burden_level (see update_burden proc) if an addiction is removed
/datum/mutation/human/burdened/proc/addict_removed_burden(datum/addiction/old_addiction, datum/mind/nonaddict_mind)
	SIGNAL_HANDLER

	update_burden(FALSE)

/// Signal to increase burden_level (see update_burden proc) if a mutation is added
/datum/mutation/human/burdened/proc/mutation_added_burden(mob/living/carbon/burdened, datum/mutation/human/mutation_type, class)
	SIGNAL_HANDLER

	if(class == MUT_OTHER) //getting a mutation can give a mutation as a reward, which in turn triggers this, which then rewards a mutation, which in turn...
		return
	if(initial(mutation_type.quality) == NEGATIVE)
		update_burden(TRUE)

/// Signal to decrease burden_level (see update_burden proc) if a mutation is removed
/datum/mutation/human/burdened/proc/mutation_removed_burden(mob/living/carbon/burdened, datum/mutation/human/mutation_type)
	SIGNAL_HANDLER

	if(class == MUT_OTHER) //see above
		return
	if(initial(mutation_type.quality) == NEGATIVE)
		update_burden(FALSE)

/// Signal to increase burden_level (see update_burden proc) if a trauma is added
/datum/mutation/human/burdened/proc/trauma_added_burden(mob/living/carbon/burdened, datum/brain_trauma/trauma_added)
	SIGNAL_HANDLER

	if(istype(trauma_added, /datum/brain_trauma/severe))
		update_burden(TRUE)

/// Signal to decrease burden_level (see update_burden proc) if a trauma is removed
/datum/mutation/human/burdened/proc/trauma_removed_burden(mob/living/carbon/burdened, datum/brain_trauma/trauma_removed)
	SIGNAL_HANDLER

	if(istype(trauma_removed, /datum/brain_trauma/severe))
		update_burden(FALSE)
