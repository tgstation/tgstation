
/// Negatives that are virtually harmless and mostly just funny (language)
// Set to 0 because munchkinning via miscommunication = bad
#define NEGATIVE_STABILITY_MINI 0
/// Negatives that are slightly annoying (unused)
#define NEGATIVE_STABILITY_MINOR -20
/// Negatives that present an uncommon or weak, consistent hindrance to gameplay (cough, paranoia)
#define NEGATIVE_STABILITY_MODERATE -30
/// Negatives that present a major consistent hindrance to gameplay (deaf, mute, acid flesh)
#define NEGATIVE_STABILITY_MAJOR -40

/// Positives that provide basically no benefit (glowy)
#define POSITIVE_INSTABILITY_MINI 5
/// Positives that are niche in application or useful in rare circumstances (parlor tricks, geladikinesis, autotomy)
#define POSITIVE_INSTABILITY_MINOR 10
/// Positives that provide a new ability that's roughly par with station equipment (insulated, cryokinesis)
#define POSITIVE_INSTABILITY_MODERATE 25
/// Positives that are unique, very powerful, and noticeably change combat/gameplay (hulk, tk)
#define POSITIVE_INSTABILITY_MAJOR 35

/datum/mutation
	var/name

/datum/mutation/human
	name = "mutation"
	/// Description of the mutation
	var/desc = "A mutation."
	/// Is this mutation currently locked?
	var/locked
	/// Quality of the mutation
	var/quality
	/// Message given to the user upon gaining this mutation
	var/text_gain_indication = ""
	/// Message given to the user upon losing this mutation
	var/text_lose_indication = ""
	/// Visual indicators upon the character of the owner of this mutation
	var/static/list/visual_indicators = list()
	/// The path of action we grant to our user on mutation gain
	var/datum/action/cooldown/power_path
	/// Which mutation layer to use
	var/layer_used = MUTATIONS_LAYER
	/// To restrict mutation to only certain species
	var/list/species_allowed
	/// Minimum health required to acquire the mutation
	var/health_req
	/// Required limbs to acquire this mutation
	var/limb_req
	/// The owner of this mutation's DNA
	var/datum/dna/dna
	/// Owner of this mutation
	var/mob/living/carbon/human/owner
	/// Instability the holder gets when the mutation is not native
	var/instability = 0
	/// Amount of those big blocks with gene sequences
	var/blocks = 4
	/// Amount of missing sequences. Sometimes it removes an entire pair for 2 points
	var/difficulty = 8
	/// Time between mutation creation and removal. If this exists, we have a timer
	var/timeout
	/// 'Mutation #49', decided every round to get some form of distinction between undiscovered mutations
	var/alias
	/// Whether we can read it if it's active. To avoid cheesing with mutagen
	var/scrambled = FALSE
	/// The class of mutation (MUT_NORMAL, MUT_EXTRA, MUT_OTHER)
	var/class
	/**
	 * any mutations that might conflict.
	 * put mutation typepath defines in here.
	 * make sure to enter it both ways (so that A conflicts with B, and B with A)
	 */
	var/list/conflicts
	var/remove_on_aheal = TRUE

	/**
	 * can we take chromosomes?
	 * 0: CHROMOSOME_NEVER never
	 * 1: CHROMOSOME_NONE yeah
	 * 2: CHROMOSOME_USED no, already have one
	 */
	var/can_chromosome = CHROMOSOME_NONE
	/// Name of the chromosome
	var/chromosome_name
	/// Has the chromosome been modified
	var/modified = FALSE //ugly but we really don't want chromosomes and on_acquiring to overlap and apply double the powers
	/// Is this mutation mutadone proof
	var/mutadone_proof = FALSE

	//Chromosome stuff - set to -1 to prevent people from changing it. Example: It'd be a waste to decrease cooldown on mutism
	/// genetic stability coeff
	var/stabilizer_coeff = 1
	/// Makes the mutation hurt the user less
	var/synchronizer_coeff = -1
	/// Boosts mutation strength
	var/power_coeff = -1
	/// Lowers mutation cooldown
	var/energy_coeff = -1
	/// List of strings of valid chromosomes this mutation can accept.
	var/list/valid_chrom_list = list()
	/// List of traits that are added or removed by the mutation with GENETIC_TRAIT source.
	var/list/mutation_traits

/datum/mutation/human/New(class = MUT_OTHER, timer, datum/mutation/human/copymut)
	. = ..()
	src.class = class
	if(timer)
		addtimer(CALLBACK(src, PROC_REF(remove)), timer)
		timeout = timer
	if(copymut && istype(copymut, /datum/mutation/human))
		copy_mutation(copymut)
	update_valid_chromosome_list()

/datum/mutation/human/Destroy()
	power_path = null
	dna = null
	owner = null
	return ..()

/datum/mutation/human/proc/on_acquiring(mob/living/carbon/human/acquirer)
	if(!acquirer || !istype(acquirer) || acquirer.stat == DEAD || (src in acquirer.dna.mutations))
		return TRUE
	if(species_allowed && !species_allowed.Find(acquirer.dna.species.id))
		return TRUE
	if(health_req && acquirer.health < health_req)
		return TRUE
	if(limb_req && !acquirer.get_bodypart(limb_req))
		return TRUE
	for(var/datum/mutation/human/mewtayshun as anything in acquirer.dna.mutations) //check for conflicting powers
		if(!(mewtayshun.type in conflicts) && !(type in mewtayshun.conflicts))
			continue
		to_chat(acquirer, span_warning("You feel your genes resisting something."))
		return TRUE
	owner = acquirer
	dna = acquirer.dna
	dna.mutations += src
	SEND_SIGNAL(src, COMSIG_MUTATION_GAINED, acquirer)
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
	grant_power() //we do checks here so nothing about hulk getting magic
	if(mutation_traits)
		owner.add_traits(mutation_traits, GENETIC_MUTATION)
	if(!modified)
		addtimer(CALLBACK(src, PROC_REF(modify), 0.5 SECONDS)) //gonna want children calling ..() to run first

/datum/mutation/human/proc/get_visual_indicator()
	return

/datum/mutation/human/proc/on_life(seconds_per_tick, times_fired)
	return

/datum/mutation/human/proc/on_losing(mob/living/carbon/human/owner)
	if(!istype(owner) || !(owner.dna.mutations.Remove(src)))
		return TRUE
	. = FALSE
	SEND_SIGNAL(src, COMSIG_MUTATION_LOST, owner)
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

	if(mutation_traits)
		owner.remove_traits(mutation_traits, GENETIC_MUTATION)

/mob/living/carbon/proc/update_mutations_overlay()
	return

/mob/living/carbon/human/update_mutations_overlay()
	for(var/datum/mutation/human/mutation in dna.mutations)
		if(mutation.species_allowed && !mutation.species_allowed.Find(dna.species.id))
			dna.force_lose(mutation) //shouldn't have that mutation at all
			continue
		if(mutation.visual_indicators.len == 0)
			continue
		var/list/mut_overlay = list()
		if(overlays_standing[mutation.layer_used])
			mut_overlay = overlays_standing[mutation.layer_used]
		var/mutable_appearance/indicator_to_add = mutation.get_visual_indicator()
		if(!mut_overlay.Find(indicator_to_add)) //either we lack the visual indicator or we have the wrong one
			remove_overlay(mutation.layer_used)
			for(var/mutable_appearance/indicator_to_remove in mutation.visual_indicators[mutation.type])
				mut_overlay.Remove(indicator_to_remove)
			mut_overlay |= indicator_to_add
			overlays_standing[mutation.layer_used] = mut_overlay
			apply_overlay(mutation.layer_used)

/**
 * Called when a chromosome is applied so we can properly update some stats
 * without having to remove and reapply the mutation from someone
 *
 * Returns `null` if no modification was done, and
 * returns an instance of a power if modification was complete
 */
/datum/mutation/human/proc/modify()
	if(modified || !power_path || QDELETED(owner))
		return
	var/datum/action/cooldown/modified_power = locate(power_path) in owner.actions
	if(!modified_power)
		CRASH("Genetic mutation [type] called modify(), but could not find a action to modify!")
	modified_power.cooldown_time *= GET_MUTATION_ENERGY(src) // Doesn't do anything for mutations with energy_coeff unset
	return modified_power

/datum/mutation/human/proc/copy_mutation(datum/mutation/human/mutation_to_copy)
	if(!mutation_to_copy)
		return
	chromosome_name = mutation_to_copy.chromosome_name
	stabilizer_coeff = mutation_to_copy.stabilizer_coeff
	synchronizer_coeff = mutation_to_copy.synchronizer_coeff
	power_coeff = mutation_to_copy.power_coeff
	energy_coeff = mutation_to_copy.energy_coeff
	mutadone_proof = mutation_to_copy.mutadone_proof
	can_chromosome = mutation_to_copy.can_chromosome
	valid_chrom_list = mutation_to_copy.valid_chrom_list

/datum/mutation/human/proc/remove_chromosome()
	stabilizer_coeff = initial(stabilizer_coeff)
	synchronizer_coeff = initial(synchronizer_coeff)
	power_coeff = initial(power_coeff)
	energy_coeff = initial(energy_coeff)
	mutadone_proof = initial(mutadone_proof)
	can_chromosome = initial(can_chromosome)
	chromosome_name = null

/datum/mutation/human/proc/remove()
	if(dna)
		dna.force_lose(src)
	else
		qdel(src)

/datum/mutation/human/proc/grant_power()
	if(!ispath(power_path) || !owner)
		return FALSE

	var/datum/action/cooldown/new_power = new power_path(src)
	new_power.background_icon_state = "bg_tech_blue"
	new_power.base_background_icon_state = new_power.background_icon_state
	new_power.active_background_icon_state = "[new_power.base_background_icon_state]_active"
	new_power.overlay_icon_state = "bg_tech_blue_border"
	new_power.active_overlay_icon_state = "bg_spell_border_active_blue"
	new_power.panel = "Genetic"
	new_power.Grant(owner)

	return new_power

// Runs through all the coefficients and uses this to determine which chromosomes the
// mutation can take. Stores these as text strings in a list.
/datum/mutation/human/proc/update_valid_chromosome_list()
	valid_chrom_list.Cut()

	if(can_chromosome == CHROMOSOME_NEVER)
		valid_chrom_list += "none"
		return

	if(stabilizer_coeff != -1)
		valid_chrom_list += "Stabilizer"
	if(synchronizer_coeff != -1)
		valid_chrom_list += "Synchronizer"
	if(power_coeff != -1)
		valid_chrom_list += "Power"
	if(energy_coeff != -1)
		valid_chrom_list += "Energetic"
