GLOBAL_LIST_EMPTY(mutations_list)

/datum/mutation

	var/name

/datum/mutation/New()
	GLOB.mutations_list[name] = src

/datum/mutation/human
	var/dna_block
	var/quality
	var/get_chance = 100
	var/lowest_value = 256 * 8
	var/text_gain_indication = ""
	var/text_lose_indication = ""
	var/list/mutable_appearance/visual_indicators = list()
	var/layer_used = MUTATIONS_LAYER //which mutation layer to use
	var/list/species_allowed = list() //to restrict mutation to only certain species
	var/health_req //minimum health required to acquire the mutation
	var/limb_req //required limbs to acquire this mutation
	var/time_coeff = 1 //coefficient for timed mutations

/datum/mutation/human/proc/force_give(mob/living/carbon/human/owner)
	set_block(owner)
	. = on_acquiring(owner)

/datum/mutation/human/proc/force_lose(mob/living/carbon/human/owner)
	set_block(owner, 0)
	. = on_losing(owner)

/datum/mutation/human/proc/set_se(se_string, on = 1)
	if(!se_string || lentext(se_string) < DNA_STRUC_ENZYMES_BLOCKS * DNA_BLOCK_SIZE)
		return
	var/before = copytext(se_string, 1, ((dna_block - 1) * DNA_BLOCK_SIZE) + 1)
	var/injection = num2hex(on ? rand(lowest_value, (256 * 16) - 1) : rand(0, lowest_value - 1), DNA_BLOCK_SIZE)
	var/after = copytext(se_string, (dna_block * DNA_BLOCK_SIZE) + 1, 0)
	return before + injection + after

/datum/mutation/human/proc/set_block(mob/living/carbon/owner, on = 1)
	if(owner && owner.has_dna())
		owner.dna.struc_enzymes = set_se(owner.dna.struc_enzymes, on)

/datum/mutation/human/proc/check_block_string(se_string)
	if(!se_string || lentext(se_string) < DNA_STRUC_ENZYMES_BLOCKS * DNA_BLOCK_SIZE)
		return 0
	if(hex2num(getblock(se_string, dna_block)) >= lowest_value)
		return 1

/datum/mutation/human/proc/check_block(mob/living/carbon/human/owner, force_powers=0)
	if(check_block_string(owner.dna.struc_enzymes))
		if(prob(get_chance)||force_powers)
			. = on_acquiring(owner)
	else
		. = on_losing(owner)

/datum/mutation/human/proc/on_acquiring(mob/living/carbon/human/owner)
	if(!owner || !istype(owner) || owner.stat == DEAD || (src in owner.dna.mutations))
		return TRUE
	if(species_allowed.len && !species_allowed.Find(owner.dna.species.id))
		return TRUE
	if(health_req && owner.health < health_req)
		return TRUE
	if(limb_req && !owner.get_bodypart(limb_req))
		return TRUE
	owner.dna.mutations.Add(src)
	if(text_gain_indication)
		to_chat(owner, text_gain_indication)
	if(visual_indicators.len)
		var/list/mut_overlay = list(get_visual_indicator(owner))
		if(owner.overlays_standing[layer_used])
			mut_overlay = owner.overlays_standing[layer_used]
			mut_overlay |= get_visual_indicator(owner)
		owner.remove_overlay(layer_used)
		owner.overlays_standing[layer_used] = mut_overlay
		owner.apply_overlay(layer_used)

/datum/mutation/human/proc/get_visual_indicator(mob/living/carbon/human/owner)
	return

/datum/mutation/human/proc/on_attack_hand(mob/living/carbon/human/owner, atom/target, proximity)
	return

/datum/mutation/human/proc/on_ranged_attack(mob/living/carbon/human/owner, atom/target)
	return

/datum/mutation/human/proc/on_move(mob/living/carbon/human/owner, new_loc)
	return

/datum/mutation/human/proc/on_life(mob/living/carbon/human/owner)
	return

/datum/mutation/human/proc/on_losing(mob/living/carbon/human/owner)
	if(owner && istype(owner) && (owner.dna.mutations.Remove(src)))
		if(text_lose_indication && owner.stat != DEAD)
			to_chat(owner, text_lose_indication)
		if(visual_indicators.len)
			var/list/mut_overlay = list()
			if(owner.overlays_standing[layer_used])
				mut_overlay = owner.overlays_standing[layer_used]
			owner.remove_overlay(layer_used)
			mut_overlay.Remove(get_visual_indicator(owner))
			owner.overlays_standing[layer_used] = mut_overlay
			owner.apply_overlay(layer_used)
		return 0
	return 1

/datum/mutation/human/proc/say_mod(message)
	if(message)
		return message

/datum/mutation/human/proc/get_spans()
	return list()

/mob/living/carbon/proc/update_mutations_overlay()
	return

/mob/living/carbon/human/update_mutations_overlay()
	for(var/datum/mutation/human/CM in dna.mutations)
		if(CM.species_allowed.len && !CM.species_allowed.Find(dna.species.id))
			CM.force_lose(src) //shouldn't have that mutation at all
			continue
		if(CM.visual_indicators.len)
			var/list/mut_overlay = list()
			if(overlays_standing[CM.layer_used])
				mut_overlay = overlays_standing[CM.layer_used]
			var/mutable_appearance/V = CM.get_visual_indicator(src)
			if(!mut_overlay.Find(V)) //either we lack the visual indicator or we have the wrong one
				remove_overlay(CM.layer_used)
				for(var/mutable_appearance/MA in CM.visual_indicators)
					mut_overlay.Remove(MA)
				mut_overlay |= V
				overlays_standing[CM.layer_used] = mut_overlay
				apply_overlay(CM.layer_used)
