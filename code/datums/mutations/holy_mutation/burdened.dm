
#define FIRST_TRUTH_REWARD 2
#define SECOND_TRUTH_REWARD 4

#define BAD_MUTATIONS_REQUIRED 3

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
	var/burden_level = 0

/datum/mutation/human/burdened/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	//two burdens - eyes and tongue
	RegisterSignal(owner, COMSIG_CARBON_GAIN_ORGAN, .proc/organ_added_burden)
	RegisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN, .proc/organ_removed_burden)
	//one burden - majority of limbs
	RegisterSignal(owner, COMSIG_CARBON_ATTACH_LIMB, .proc/limbs_added_burden)
	RegisterSignal(owner, COMSIG_CARBON_REMOVE_LIMB, .proc/limbs_removed_burden)
	//one burden - an addiction
	RegisterSignal(owner, COMSIG_CARBON_GAIN_ADDICTION, .proc/addict_added_burden)
	RegisterSignal(owner, COMSIG_CARBON_LOSE_ADDICTION, .proc/addict_removed_burden)
	//one burden - 2 major negative mutations
	RegisterSignal(owner, COMSIG_CARBON_GAIN_MUTATION, .proc/mutation_added_burden)
	RegisterSignal(owner, COMSIG_CARBON_LOSE_MUTATION, .proc/mutation_removed_burden)
	//one burden - a severe trauma
	RegisterSignal(owner, COMSIG_CARBON_GAIN_TRAUMA, .proc/trauma_added_burden)
	RegisterSignal(owner, COMSIG_CARBON_LOSE_TRAUMA, .proc/trauma_removed_burden)


/datum/mutation/human/burdened/proc/update_burden(increase)
	//adjust burden
	burden_level = increase ? burden_level + 1 : burden_level - 1
	if(owner.dna)
		var/datum/dna/woke_dna = owner.dna
		if(burden_level >= FIRST_TRUTH_REWARD)
			woke_dna.add_mutation(TELEPATHY)
			woke_dna.add_mutation(MUT_MUTE)
			owner.add_filter("burden_outline", 9, list("type" = "outline", "color" = "#6c6eff"))
		else
			woke_dna.remove_mutation(TELEPATHY)
			woke_dna.remove_mutation(MUT_MUTE)
			owner.remove_filter("burden_outline")
		if(burden_level >= SECOND_TRUTH_REWARD)
			woke_dna.add_mutation(TK)
			woke_dna.add_mutation(GLOWY)
			owner.add_filter("burden_rays", 10, list("type" = "rays", "size" = 35, "color" = "#6c6eff"))
		else
			woke_dna.remove_mutation(TK)
			woke_dna.remove_mutation(GLOWY)
			owner.remove_filter("burden_rays")
	switch(burden_level)
		if(0)
			to_chat(owner, "<span class='warning'>You feel no weight on your shoulders. You are not feeling [GLOB.deity]'s suffering.</span>")
		if(1)
			if(increase)
				to_chat(owner, "<span class='notice'>You begin to feel the scars on [GLOB.deity]. You must continue to burden yourself.</span>")
			else
				to_chat(owner, "<span class='warning'>The weight on your shoulders feels lighter. You are barely feeling [GLOB.deity]'s suffering.</span>")
		if(2)
			if(increase)
				to_chat(owner, "<span class='notice'>You have done well to understand [GLOB.deity]. You are almost at a breakthrough.</span>")
			else
				to_chat(owner, "<span class='warning'>The weight on your shoulders feels lighter. You have lost some universal truths.</span>")
		if(FIRST_TRUTH_REWARD)
			if(increase)
				to_chat(owner, "<span class='notice'>Your suffering is only a fraction of [GLOB.deity]'s, and yet the universal truths are coming to you.</span>")
			else
				to_chat(owner, "<span class='warning'>The weight on your shoulders feels lighter. You feel like you're about to forget.</span>")
		if(4)
			if(increase)
				to_chat(owner, "<span class='notice'>The weight on your shoulders is immense. [GLOB.deity] is shattered across the cosmos.</span>")
			else
				to_chat(owner, "<span class='warning'>The weight on your shoulders feels lighter. You're growing further from your goal.</span>")
		if(5)
			if(increase)
				to_chat(owner, "<span class='notice'>You're on the cusp of another breakthrough. [GLOB.deity] lost everything.</span>")
			else
				to_chat(owner, "<span class='warning'>The weight on your shoulders feels lighter. You have lost some universal truths.</span>")
		if(SECOND_TRUTH_REWARD)
			to_chat(owner, "<span class='notice'>You have finally broken yourself enough to understand [GLOB.deity]. It's all so clear to you.</span>")

/datum/mutation/human/burdened/proc/organ_added_burden(mob/burdened, obj/item/organ/new_organ)
	SIGNAL_HANDLER

	if(istype(new_organ, /obj/item/organ/eyes))
		var/obj/item/organ/eyes/new_eyes = new_organ
		if(new_eyes.tint < TINT_BLIND) //unless you added unworking eyes (flashlight eyes), this is removing burden
			update_burden(FALSE)

	else if(istype(new_organ, /obj/item/organ/tongue))
		update_burden(FALSE)//working tongue

/datum/mutation/human/burdened/proc/organ_removed_burden(mob/burdened, obj/item/organ/old_organ)
	SIGNAL_HANDLER

	if(istype(old_organ, /obj/item/organ/eyes))
		var/obj/item/organ/eyes/old_eyes = old_organ
		if(old_eyes.tint < TINT_BLIND) //unless you were already blinded by them (flashlight eyes), this is adding burden!
			update_burden(TRUE)

	else if(istype(old_organ, /obj/item/organ/tongue))
		update_burden(TRUE)//lost tongue

/datum/mutation/human/burdened/proc/limbs_added_burden(obj/item/bodypart/limb_added, special, dismembered)
	SIGNAL_HANDLER

	if(special) //something we don't wanna consider, like instaswapping limbs
		return
	var/mob/living/carbon/burdened = limb_added.owner
	if(burdened.bodyparts.len == 5) //adding a limb got you to chest, head, 3 limbs
		update_burden(FALSE)

/datum/mutation/human/burdened/proc/limbs_removed_burden(obj/item/bodypart/limb_lost, special, dismembered)
	SIGNAL_HANDLER

	if(special) //something we don't wanna consider, like instaswapping limbs
		return
	var/mob/living/carbon/burdened = limb_lost.owner
	if(burdened.bodyparts.len == 4) //adding a limb got you to chest, head, 2 limbs
		update_burden(TRUE)

/datum/mutation/human/burdened/proc/addict_added_burden(datum/addiction/new_addiction, datum/mind/addict_mind)
	SIGNAL_HANDLER

	if(addict_mind.active_addictions.len)
		return //already did this
	update_burden(TRUE)

/datum/mutation/human/burdened/proc/addict_removed_burden(datum/addiction/old_addiction, datum/mind/nonaddict_mind)
	SIGNAL_HANDLER

	if(!nonaddict_mind.active_addictions.len)
		update_burden(FALSE)

/datum/mutation/human/burdened/proc/mutation_added_burden(mob/living/carbon/burdened, mutation_type)
	SIGNAL_HANDLER

	var/bad_mutations = 0
	for(var/datum/mutation/human/mutation as anything in burdened.dna.mutations)
		if(mutation.quality == NEGATIVE)
			bad_mutations++
	if(bad_mutations == BAD_MUTATIONS_REQUIRED)
		update_burden(TRUE)

/datum/mutation/human/burdened/proc/mutation_removed_burden(mob/living/carbon/burdened, mutation_type)
	SIGNAL_HANDLER

	var/bad_mutations = 0
	for(var/datum/mutation/human/mutation as anything in burdened.dna.mutations)
		if(mutation.quality == NEGATIVE)
			bad_mutations++
	if(bad_mutations == BAD_MUTATIONS_REQUIRED - 1) //one less than mutations required on a proc that goes off when you lose one = no more burden
		update_burden(FALSE)

/datum/mutation/human/burdened/proc/trauma_added_burden(mob/living/carbon/burdened, datum/brain_trauma/trauma_added)
	SIGNAL_HANDLER

	var/obj/item/organ/brain/trauma_brain = burdened.getorganslot(ORGAN_SLOT_BRAIN)
	if(trauma_brain.traumas.len == 1) //your first trauma
		update_burden(TRUE)

/datum/mutation/human/burdened/proc/trauma_removed_burden(mob/living/carbon/burdened, datum/brain_trauma/trauma_removed)
	SIGNAL_HANDLER

	var/obj/item/organ/brain/trauma_brain = burdened.getorganslot(ORGAN_SLOT_BRAIN)
	if(!trauma_brain.traumas.len) //your last trauma
		update_burden(FALSE)

#undef FIRST_TRUTH_REWARD
#undef SECOND_TRUTH_REWARD
#undef BAD_MUTATIONS_REQUIRED
