#define FIRST_TRUTH_REWARD 3
#define SECOND_TRUTH_REWARD 6

#define BAD_MUTATIONS_REQUIRED 3

/datum/religion_sect/burden
	name = "Punished God"
	desc = "A sect that desires to feel the pain of their god."
	alignment = ALIGNMENT_NEUT
	convert_opener = "\"To feel the freedom, you must first understand captivity.\"<br>\
	Incapacitate yourself in any way possible. Bad mutations, lost limbs, traumas, even addictions. You will learn the secrets of the universe \
	from your defeated shell."
	//a list for keeping track of how burdened each member is
	var/list/burdened_pool = list()

/datum/religion_sect/burden/on_conversion(mob/living/burdened_living)

	if(!iscarbon(burdened_living))
		to_chat(burdened_living, "<span class='warning'>Despite your willingness, you feel like your lesser form cannot properly incapacitate itself to impress [GLOB.deity]...")
		return
	var/mob/living/carbon/burdened_follower = burdened_living
	burdened_pool[burdened_follower] = 0
	RegisterSignal(burdened_follower, COMSIG_CARBON_GAIN_ORGAN, .proc/eyes_added_burden)
	RegisterSignal(burdened_follower, COMSIG_CARBON_LOSE_ORGAN, .proc/eyes_removed_burden)

	RegisterSignal(burdened_follower, COMSIG_CARBON_ATTACH_LIMB, .proc/limbs_added_burden)
	RegisterSignal(burdened_follower, COMSIG_CARBON_REMOVE_LIMB, .proc/limbs_removed_burden)

	RegisterSignal(burdened_follower, COMSIG_CARBON_GAIN_ADDICTION, .proc/addict_added_burden)
	RegisterSignal(burdened_follower, COMSIG_CARBON_LOSE_ADDICTION, .proc/addict_removed_burden)

	RegisterSignal(burdened_follower, COMSIG_CARBON_GAIN_MUTATION, .proc/mutation_added_burden)
	RegisterSignal(burdened_follower, COMSIG_CARBON_LOSE_MUTATION, .proc/mutation_removed_burden)

/datum/religion_sect/burden/proc/update_burden(mob/living/carbon/burdened_follower, increase)
	var/current_burden = burdened_pool[burdened_follower]
	if(burdened_follower.dna)
		var/datum/dna/woke_dna = burdened_follower.dna
		if(current_burden >= FIRST_TRUTH_REWARD)
			woke_dna.add_mutation(TELEPATHY)
			woke_dna.add_mutation(MUT_MUTE)
		else
			woke_dna.remove_mutation(TELEPATHY)
			woke_dna.remove_mutation(MUT_MUTE)
		if(current_burden == SECOND_TRUTH_REWARD)
			woke_dna.add_mutation(TK)
			woke_dna.add_mutation(GLOWY)
		else
			woke_dna.remove_mutation(TK)
			woke_dna.remove_mutation(GLOWY)
	switch(current_burden)
		if(0)
			to_chat(burdened_follower, "<span class='warning'>You feel no weight on your shoulders. You are not feeling [GLOB.deity]'s suffering.</span>")
		if(1)
			if(increase)
				to_chat(burdened_follower, "<span class='notice'>You begin to feel the scars on [GLOB.deity]. You must continue to burden yourself.</span>")
			else
				to_chat(burdened_follower, "<span class='warning'>The weight on your shoulders feels lighter. You are barely feeling [GLOB.deity]'s suffering.</span>")
		if(2)
			if(increase)
				to_chat(burdened_follower, "<span class='notice'>You have done well to understand [GLOB.deity]. You are almost at a breakthrough.</span>")
			else
				to_chat(burdened_follower, "<span class='warning'>The weight on your shoulders feels lighter. You have lost some universal truths.</span>")
		if(FIRST_TRUTH_REWARD)
			if(increase)
				to_chat(burdened_follower, "<span class='notice'>Your suffering is only a fraction of [GLOB.deity]'s, and yet the universal truths are coming to you.</span>")
			else
				to_chat(burdened_follower, "<span class='warning'>The weight on your shoulders feels lighter. You feel like you're about to forget.</span>")
		if(4)
			if(increase)
				to_chat(burdened_follower, "<span class='notice'>The weight on your shoulders is immense. [GLOB.deity] is shattered across the cosmos.</span>")
			else
				to_chat(burdened_follower, "<span class='warning'>The weight on your shoulders feels lighter. You're growing further from your goal.</span>")
		if(5)
			if(increase)
				to_chat(burdened_follower, "<span class='notice'>You're on the cusp of another breakthrough. [GLOB.deity] lost everything.</span>")
			else
				to_chat(burdened_follower, "<span class='warning'>The weight on your shoulders feels lighter. You have lost some universal truths.</span>")
		if(SECOND_TRUTH_REWARD)
			to_chat(burdened_follower, "<span class='notice'>You have finally broken yourself enough to understand [GLOB.deity]. It's all so clear to you.</span>")

/datum/religion_sect/burden/proc/eyes_added_burden(mob/burdened, obj/item/organ/eyes/new_eyes)
	SIGNAL_HANDLER

	if(!istype(new_eyes))
		return
	if(new_eyes.tint < TINT_BLIND) //unless you added unworking eyes (flashlight eyes), this is removing burden
		burdened_pool[burdened] -= 1
		update_burden(burdened)

/datum/religion_sect/burden/proc/eyes_removed_burden(mob/burdened, obj/item/organ/eyes/old_eyes)
	SIGNAL_HANDLER

	if(!istype(old_eyes))
		return
	if(old_eyes.tint < TINT_BLIND) //unless you were already blinded by them (flashlight eyes), this is adding burden!
		burdened_pool[burdened] += 1
		update_burden(burdened)

/datum/religion_sect/burden/proc/limbs_added_burden(obj/item/bodypart/limb_added, special, dismembered)
	SIGNAL_HANDLER

	if(special) //something we don't wanna consider, like instaswapping limbs
		return
	var/mob/living/carbon/burdened = limb_added.owner
	var/list/bodyparts = burdened.bodyparts.Copy()
	if(bodyparts.len == 5) //adding a limb got you to chest, head, 3 limbs
		burdened_pool[burdened] -= 1 //which counts as removing burden
		update_burden(burdened)

/datum/religion_sect/burden/proc/limbs_removed_burden(obj/item/bodypart/limb_lost, special, dismembered)
	SIGNAL_HANDLER

	if(special) //something we don't wanna consider, like instaswapping limbs
		return
	var/mob/living/carbon/burdened = limb_lost.owner
	var/list/bodyparts = burdened.bodyparts.Copy()
	if(bodyparts.len == 4) //adding a limb got you to chest, head, 2 limbs
		burdened_pool[burdened] += 1 //which counts as adding burden
		update_burden(burdened)

/datum/religion_sect/burden/proc/addict_added_burden(datum/addiction/new_addiction, datum/mind/addict_mind)
	SIGNAL_HANDLER

	var/mob/living/carbon/burdened = addict_mind.current
	if(addict_mind.active_addictions.len)
		return //already did this
	burdened_pool[burdened] += 1 //you're addicted to something
	update_burden(burdened)

/datum/religion_sect/burden/proc/addict_removed_burden(datum/addiction/old_addiction, datum/mind/nonaddict_mind)
	SIGNAL_HANDLER

	var/mob/living/carbon/burdened = nonaddict_mind.current
	if(!nonaddict_mind.active_addictions.len)
		burdened_pool[burdened] -= 1 //no longer addicted to anything
		update_burden(burdened)

/datum/religion_sect/burden/proc/mutation_added_burden(datum/dna/burden_dna, datum/mind/addict_mind)
	SIGNAL_HANDLER

	var/mob/living/carbon/burdened = burden_dna.holder
	var/bad_mutations = 0
	for(var/datum/mutation/human/mutation as anything in burden_dna.mutations)
		if(mutation.quality == NEGATIVE)
			bad_mutations++
	if(bad_mutations == BAD_MUTATIONS_REQUIRED)
		burdened_pool[burdened] += 1 //you're badly mutated!
		update_burden(burdened)

/datum/religion_sect/burden/proc/mutation_removed_burden(datum/dna/burden_dna, datum/mind/nonaddict_mind)
	SIGNAL_HANDLER

	var/mob/living/carbon/burdened = burden_dna.holder
	var/bad_mutations = 0
	for(var/datum/mutation/human/mutation as anything in burden_dna.mutations)
		if(mutation.quality == NEGATIVE)
			bad_mutations++
	if(bad_mutations == BAD_MUTATIONS_REQUIRED == 2) //looks bad but can only be checked if we are losing a mutation
		burdened_pool[burdened] -= 1 //you're no longer badly mutated!
		update_burden(burdened)

#undef FIRST_TRUTH_REWARD
#undef SECOND_TRUTH_REWARD
#undef BAD_MUTATIONS_REQUIRED
