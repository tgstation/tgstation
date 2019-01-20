/datum/mutation

	var/name

/datum/mutation/human
	name = "mutation"
	var/desc = "A mutation."
	var/locked
	var/quality
	var/get_chance = 100
	var/lowest_value = 256 * 8
	var/text_gain_indication = ""
	var/text_lose_indication = ""
	var/static/list/mutable_appearance/visual_indicators = list()
	var/obj/effect/proc_holder/spell/power
	var/layer_used = MUTATIONS_LAYER //which mutation layer to use
	var/list/species_allowed = list() //to restrict mutation to only certain species
	var/health_req //minimum health required to acquire the mutation
	var/limb_req //required limbs to acquire this mutation
	var/time_coeff = 1 //coefficient for timed mutations
	var/datum/dna/dna
	var/mob/living/carbon/human/owner
	var/instability = 0 //instability the holder gets when the mutation is not native
	var/blocks = 4 //Amount of those big blocks with gene sequences
	var/difficulty = 8 //Amount of missing sequences. Sometimes it removes an entire pair for 2 points
	var/timed = FALSE   //Boolean to easily check if we're going to self destruct
	var/alias           //'Mutation #49', decided every round to get some form of distinction between undiscovered mutations
	var/scrambled = FALSE //Wheter we can read it if it's active. To avoid cheesing with mutagen
	var/class           //Decides player accesibility, sorta
	//MUT_NORMAL - A mutation that can be activated and deactived by completing a sequence
	//MUT_EXTRA - A mutation that is in the mutations tab, and can be given and taken away through though the DNA console. Has a 0 before it's name in the mutation section of the dna console
	//MUT_OTHER Cannot be interacted with by players through normal means. I.E. wizards mutate

/datum/mutation/human/New(class_ = MUT_OTHER, timer)
	. = ..()
	class = class_
	if(timer)
		addtimer(CALLBACK(src, .proc/remove), timer)
		timed = TRUE

/datum/mutation/human/proc/on_acquiring(mob/living/carbon/human/H)
	if(!H || !istype(H) || H.stat == DEAD || (src in H.dna.mutations))
		return TRUE
	if(species_allowed.len && !species_allowed.Find(H.dna.species.id))
		return TRUE
	if(health_req && H.health < health_req)
		return TRUE
	if(limb_req && !H.get_bodypart(limb_req))
		return TRUE
	owner = H
	dna = H.dna
	dna.mutations += src
	if(text_gain_indication)
		to_chat(owner, text_gain_indication)
	if(visual_indicators.len)
		var/list/mut_overlay = list(get_visual_indicator())
		if(owner.overlays_standing[layer_used])
			mut_overlay = owner.overlays_standing[layer_used]
			mut_overlay |= get_visual_indicator()
		owner.remove_overlay(layer_used)
		owner.overlays_standing[layer_used] = mut_overlay
		owner.apply_overlay(layer_used)
	if(power)
		power = new power()
		power.action_background_icon_state = "bg_tech_blue_on"
		power.panel = "Genetic"
		owner.AddSpell(power)

/datum/mutation/human/proc/get_visual_indicator()
	return

/datum/mutation/human/proc/on_attack_hand( atom/target, proximity)
	return

/datum/mutation/human/proc/on_ranged_attack(atom/target)
	return

/datum/mutation/human/proc/on_move(new_loc)
	return

/datum/mutation/human/proc/on_life()
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
			mut_overlay.Remove(get_visual_indicator())
			owner.overlays_standing[layer_used] = mut_overlay
			owner.apply_overlay(layer_used)
		if(power)
			owner.RemoveSpell(power)
			qdel(src)
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
			dna.force_lose(CM) //shouldn't have that mutation at all
			continue
		if(CM.visual_indicators.len)
			var/list/mut_overlay = list()
			if(overlays_standing[CM.layer_used])
				mut_overlay = overlays_standing[CM.layer_used]
			var/mutable_appearance/V = CM.get_visual_indicator()
			if(!mut_overlay.Find(V)) //either we lack the visual indicator or we have the wrong one
				remove_overlay(CM.layer_used)
				for(var/mutable_appearance/MA in CM.visual_indicators[CM.type])
					mut_overlay.Remove(MA)
				mut_overlay |= V
				overlays_standing[CM.layer_used] = mut_overlay
				apply_overlay(CM.layer_used)

/datum/mutation/human/proc/copy_mutation(datum/mutation/human/HM) //Not yet implemented, useful for when assigning specific stats.

/datum/mutation/human/proc/remove()
	if(dna)
		dna.force_lose(src)
	else
		qdel(src)

