/**
 * A list of numbers that keeps track of where ui blocks start in the unique_identity string variable of the dna datum.
 * Commonly used by the datum/dna/set_uni_identity_block and datum/dna/get_uni_identity_block procs.
 */
GLOBAL_LIST_INIT(total_ui_len_by_block, populate_total_ui_len_by_block())

GLOBAL_LIST_INIT(standard_mutation_sources, list(MUTATION_SOURCE_ACTIVATED, MUTATION_SOURCE_MUTATOR, MUTATION_SOURCE_TIMED_INJECTOR))

/proc/populate_total_ui_len_by_block()
	. = list()
	var/total_block_len = 1
	for(var/block_path in GLOB.dna_identity_blocks)
		var/datum/dna_block/identity/block = GLOB.dna_identity_blocks[block_path]
		.[block_path] += total_block_len
		total_block_len += block.block_length

///Ditto but for unique features. Used by the datum/dna/set_uni_feature_block and datum/dna/get_uni_feature_block procs.
GLOBAL_LIST_INIT(total_uf_len_by_block, populate_total_uf_len_by_block())

/proc/populate_total_uf_len_by_block()
	. = list()
	var/total_block_len = 1
	for(var/block_path in GLOB.dna_feature_blocks)
		var/datum/dna_block/feature/block = GLOB.dna_feature_blocks[block_path]
		.[block_path] += total_block_len
		total_block_len += block.block_length

/////////////////////////// DNA DATUM
/datum/dna
	///An md5 hash of the dna holder's real name
	var/unique_enzymes
	///Stores the hashed values of traits such as skin tones, hair style, and gender
	var/unique_identity
	///The blood type datum, usually a singleton
	var/datum/blood_type/blood_type
	///The type of mutant race the player is if applicable (i.e. potato-man)
	var/datum/species/species = new /datum/species/human
	/// Assoc list of feature keys to their value
	/// Note if you set these manually, and do not update [unique_features] afterwards, it will likely be reset.
	var/list/features = list(FEATURE_MUTANT_COLOR = COLOR_WHITE)
	///Stores the hashed values of the person's non-human features
	var/unique_features
	///Stores the real name of the person who originally got this dna datum. Used primarily for changelings
	var/real_name
	///All mutations are from now on here
	var/list/mutations = list()
	///Temporary changes to the UE
	var/list/temporary_mutations = list()
	///For temporary name/ui/ue/blood_type modifications
	var/list/previous = list()
	var/mob/living/holder
	///List of which mutations this carbon has and its assigned block
	var/mutation_index[DNA_MUTATION_BLOCKS]
	///List of the default genes from this mutation to allow DNA Scanner highlighting
	var/default_mutation_genes[DNA_MUTATION_BLOCKS]
	var/stability = 100
	///Did we take something like mutagen? In that case we can't get our genes scanned to instantly cheese all the powers.
	var/scrambled = FALSE
	/// Weighted list of nonlethal meltdowns
	var/static/list/nonfatal_meltdowns = list()
	/// Weighted list of lethal meltdowns
	var/static/list/fatal_meltdowns = list()

/datum/dna/New(mob/living/new_holder)
	if(istype(new_holder))
		holder = new_holder

/datum/dna/Destroy()
	if (iscarbon(holder))
		var/mob/living/carbon/as_carbon = holder
		for(var/datum/mutation/mutation as anything in mutations)
			remove_mutation(mutation, mutation.sources) // mutations hold a reference to the dna, we need to delete them.
		if(as_carbon.dna == src)
			as_carbon.dna = null
	holder = null

	QDEL_NULL(species)

	mutations.Cut() //This only references mutations, just dereference.
	temporary_mutations.Cut() //^
	previous.Cut() //^

	return ..()

///Copies the variables of a dna datum onto another.
/datum/dna/proc/copy_dna(datum/dna/new_dna, transfer_flags = COPY_DNA_SE|COPY_DNA_SPECIES)
	new_dna.unique_enzymes = unique_enzymes
	new_dna.unique_identity = unique_identity
	new_dna.unique_features = unique_features
	new_dna.features = features.Copy()
	new_dna.real_name = real_name
	new_dna.temporary_mutations = temporary_mutations.Copy()
	new_dna.mutation_index = mutation_index
	new_dna.default_mutation_genes = default_mutation_genes
	//if the new DNA has a holder, transform them immediately, otherwise save it
	if(new_dna.holder)
		if (iscarbon(new_dna.holder))
			var/mob/living/carbon/as_carbon = new_dna.holder
			as_carbon.set_blood_type(blood_type)
		if(transfer_flags & COPY_DNA_SPECIES)
			new_dna.holder.set_species(species.type, icon_update = FALSE)
	else
		new_dna.blood_type = blood_type
		if(transfer_flags & COPY_DNA_SPECIES)
			new_dna.species = new species.type
	if(transfer_flags & COPY_DNA_MUTATIONS && holder?.can_mutate())
		// Mutations aren't gc managed, but they still aren't templates
		// Let's do a proper copy
		for(var/datum/mutation/mutation in mutations)
			var/list/valid_sources = mutation.sources & GLOB.standard_mutation_sources
			if(!length(valid_sources))
				continue
			new_dna.add_mutation(mutation, valid_sources)

///Adds a mutation to the dna if possible. See defines/dna.dm for all sources.
/datum/dna/proc/add_mutation(mutation_to_add, list/sources)
	if(!islist(sources))
		if(!sources)
			CRASH("add_mutation() called without set source(s)")
		sources = list(sources)

	var/datum/mutation/actual_mutation = get_mutation(mutation_to_add)
	var/list/sources_to_add = sources.Copy() //make sure not to modify the original if it's stored in a variable outside this proc
	if(!actual_mutation)
		if(istype(mutation_to_add, /datum/mutation))
			var/datum/mutation/mutation_instance = mutation_to_add
			actual_mutation = mutation_instance.make_copy()
		else
			actual_mutation = new mutation_to_add
		SEND_SIGNAL(holder, COMSIG_CARBON_GAIN_MUTATION, actual_mutation.type, sources_to_add)
	else
		sources_to_add -= actual_mutation.sources
		if(!length(sources_to_add)) //no new sources to add, don't do anything.
			return

	if(!length(actual_mutation.sources))
		if(!actual_mutation.on_acquiring(holder))
			qdel(actual_mutation)
			return
		actual_mutation.setup()

	actual_mutation.sources |= sources

	if(MUTATION_SOURCE_ACTIVATED in sources)
		set_se(1, actual_mutation)

	update_instability()

/datum/dna/proc/remove_mutation(mutation_to_remove, list/sources)
	if(!islist(sources))
		if(!sources)
			CRASH("remove_mutation() called without set source(s)")
		sources = list(sources)

	var/datum/mutation/actual_mutation = get_mutation(mutation_to_remove)

	if(!actual_mutation || !(sources & actual_mutation.sources))
		return

	actual_mutation.sources -= sources

	if(MUTATION_SOURCE_ACTIVATED in sources)
		set_se(0, actual_mutation)

	// Check that it exists first before trying to remove it with mutadone
	if(!length(actual_mutation.sources))
		SEND_SIGNAL(holder, COMSIG_CARBON_LOSE_MUTATION, actual_mutation.type)
		actual_mutation.on_losing(holder)
		qdel(actual_mutation)

	update_instability(FALSE)

/datum/dna/proc/check_mutation(mutation_type)
	return get_mutation(mutation_type)

/datum/dna/proc/remove_all_mutations(sources = GLOB.standard_mutation_sources)
	remove_mutation_group(mutations, sources)
	scrambled = FALSE

/datum/dna/proc/remove_mutation_group(list/group, sources = GLOB.standard_mutation_sources)
	if(!group)
		return
	for(var/mutation in group)
		remove_mutation(mutation, sources)

/datum/dna/proc/generate_unique_identity()
	. = ""
	for(var/block_type in GLOB.dna_identity_blocks)
		var/datum/dna_block/identity/block = GLOB.dna_identity_blocks[block_type]
		. += block.unique_block(holder)

/datum/dna/proc/generate_unique_features()
	. = ""
	for(var/block_type in GLOB.dna_feature_blocks)
		var/datum/dna_block/feature/block = GLOB.dna_feature_blocks[block_type]
		if(isnull(features[block.feature_key]))
			. += random_string(block.block_length, GLOB.hex_characters)
			continue
		. += block.unique_block(holder)

/**
 * Picks what mutations this DNA has innate and generates DNA blocks for them
 *
 * * mutation_blacklist - Optional list of mutation typepaths to exclude from generation.
 */
/datum/dna/proc/generate_dna_blocks(list/mutation_blacklist)
	var/list/mutations_temp = list() + GLOB.good_mutations + GLOB.bad_mutations + GLOB.not_good_mutations
	if(species?.inert_mutation)
		mutations_temp |= GET_INITIALIZED_MUTATION(species.inert_mutation)
	for(var/mutation_type in mutation_blacklist)
		mutations_temp -= GET_INITIALIZED_MUTATION(mutation_type)
	if(!length(mutations_temp))
		return
	mutation_index.Cut()
	default_mutation_genes.Cut()
	shuffle_inplace(mutations_temp)
	mutation_index[/datum/mutation/race] = create_sequence(/datum/mutation/race, FALSE)
	default_mutation_genes[/datum/mutation/race] = mutation_index[/datum/mutation/race]
	for(var/i in 2 to DNA_MUTATION_BLOCKS)
		var/datum/mutation/M = mutations_temp[i]
		mutation_index[M.type] = create_sequence(M.type, FALSE, M.difficulty)
		default_mutation_genes[M.type] = mutation_index[M.type]
	shuffle_inplace(mutation_index)

//Used to generate original gene sequences for every mutation
/proc/generate_gene_sequence(length=4)
	var/static/list/active_sequences = list("AT","TA","GC","CG")
	var/sequence
	for(var/i in 1 to length*DNA_SEQUENCE_LENGTH)
		sequence += pick(active_sequences)
	return sequence

//Used to create a chipped gene sequence
/proc/create_sequence(mutation, active, difficulty)
	if(!difficulty)
		var/datum/mutation/A = GET_INITIALIZED_MUTATION(mutation) //leaves the possibility to change difficulty mid-round
		if(!A)
			return
		difficulty = A.difficulty
	difficulty += rand(-2,4)
	var/sequence = GET_SEQUENCE(mutation)
	if(active)
		return sequence
	while(difficulty)
		var/randnum = rand(1, length(sequence))
		sequence = copytext(sequence, 1, randnum) + "X" + copytext(sequence, randnum + 1)
		difficulty--
	return sequence

/datum/dna/proc/generate_unique_enzymes()
	. = ""
	if(istype(holder))
		real_name = holder.real_name
		. += md5(holder.real_name)
	else
		. += random_string(DNA_UNIQUE_ENZYMES_LEN, GLOB.hex_characters)
	return .

///Setter macro used to modify unique features blocks.
/datum/dna/proc/set_uni_feature_block(blocknum, input)
	var/precesing_blocks = copytext(unique_features, 1, GLOB.total_uf_len_by_block[blocknum])
	var/succeeding_blocks = blocknum < GLOB.total_uf_len_by_block.len ? copytext(unique_features, GLOB.total_uf_len_by_block[blocknum+1]) : ""
	unique_features = precesing_blocks + input + succeeding_blocks

/datum/dna/proc/update_ui_block(blocktype)
	if(isnull(blocktype))
		CRASH("UI block type is null")
	if(!ishuman(holder))
		CRASH("Non-human mobs shouldn't have DNA")
	var/datum/dna_block/identity/block = GLOB.dna_identity_blocks[blocktype]
	unique_identity = block.modified_hash(unique_identity, block.unique_block(holder))

/datum/dna/proc/update_uf_block(blocktype)
	if(!blocktype)
		CRASH("UF block type is null")
	if(!ishuman(holder))
		CRASH("Non-human mobs shouldn't have DNA")
	var/datum/dna_block/feature/block = GLOB.dna_feature_blocks[blocktype]
	unique_features = block.modified_hash(unique_features, block.unique_block(holder))

/**
 * Checks if two DNAs are practically the same by comparing their most defining features
 *
 * Arguments:
 * * target_dna The DNA that we are comparing to
 */
/datum/dna/proc/is_same_as(datum/dna/target_dna)
	if( \
		unique_identity == target_dna.unique_identity \
		&& mutation_index == target_dna.mutation_index \
		&& real_name == target_dna.real_name \
		&& species.type == target_dna.species.type \
		&& compare_list(features, target_dna.features) \
		&& blood_type.type == target_dna.blood_type.type \
	)
		return TRUE

	return FALSE

/datum/dna/proc/update_instability(alert=TRUE)
	var/old_stability = stability
	stability = 100
	for(var/datum/mutation/mutation in mutations)
		if((MUTATION_SOURCE_MUTATOR in mutation.sources) || mutation.instability < 0)
			stability -= mutation.instability * GET_MUTATION_STABILIZER(mutation)
	if(holder)
		var/message
		if(alert)
			switch(stability)
				if(70 to 90)
					message = span_warning("You shiver.")
				if(60 to 69)
					message = span_warning("You feel cold.")
				if(40 to 59)
					message = span_warning("You feel sick.")
				if(20 to 39)
					message = span_warning("It feels like your skin is moving.")
				if(1 to 19)
					message = span_warning("You can feel your cells burning.")
				if(-INFINITY to 0)
					message = span_boldwarning("You can feel your DNA exploding, we need to do something fast!")
		if(stability <= 0)
			holder.apply_status_effect(/datum/status_effect/dna_melt)
		if(message && stability < old_stability)
			to_chat(holder, message)

/// Updates the UI, UE, and UF of the DNA according to the features, appearance, name, etc. of the DNA / holder.
/datum/dna/proc/update_dna_identity()
	if(!holder.has_dna())
		return
	unique_identity = generate_unique_identity()
	unique_enzymes = generate_unique_enzymes()
	unique_features = generate_unique_features()

/**
 * Sets up DNA codes and initializes some features.
 *
 * * newblood_type - Optional, the blood type to set the DNA to
 * * create_mutation_blocks - If true, generate_dna_blocks is called, which is used to set up mutation blocks (what a mob can naturally mutate).
 * * randomize_features - If true, all entries in the features list will be randomized.
 */
/datum/dna/proc/initialize_dna(newblood_type = random_human_blood_type(), create_mutation_blocks = TRUE, randomize_features = TRUE)
	if(newblood_type)
		blood_type = newblood_type
	if(create_mutation_blocks) //I hate this
		generate_dna_blocks(mutation_blacklist = list(/datum/mutation/headless))
	if(randomize_features)
		for(var/species_type in GLOB.species_prototypes)
			var/list/new_features = GLOB.species_prototypes[species_type].randomize_features()
			for(var/feature in new_features)
				features[feature] = new_features[feature]

		features[FEATURE_MUTANT_COLOR] = "#[random_color()]"

	update_dna_identity()

/datum/dna/stored //subtype used by brain mob's stored_dna and the crew manifest

/datum/dna/stored/add_mutation(mutation_name, list/sources) //no mutation changes on stored dna.
	return

/datum/dna/stored/remove_mutation(mutation_name, list/sources)
	return

/datum/dna/stored/check_mutation(mutation_name)
	return

/datum/dna/stored/remove_all_mutations(list/classes, list/sources)
	return

/datum/dna/stored/remove_mutation_group(list/group)
	return

/////////////////////////// DNA MOB-PROCS //////////////////////

/mob/proc/set_species(datum/species/mrace, icon_update = 1)
	SHOULD_NOT_SLEEP(TRUE)
	return

/mob/living/brain/set_species(datum/species/mrace, icon_update = 1)
	if(mrace)
		if(ispath(mrace))
			stored_dna.species = new mrace()
		else
			stored_dna.species = mrace //not calling any species update procs since we're a brain, not a monkey/human


/mob/living/carbon/set_species(datum/species/mrace, icon_update = TRUE, pref_load = FALSE, replace_missing = TRUE)
	if(QDELETED(src))
		CRASH("You're trying to change your species post deletion, this is a recipe for madness")
	if(isnull(mrace))
		CRASH("set_species called without a species to set to")
	if(!has_dna())
		return

	var/datum/species/new_race
	if(ispath(mrace))
		new_race = new mrace
	else if(istype(mrace))
		if(QDELING(mrace))
			CRASH("someone is calling set_species() and is passing it a qdeling species datum, this is VERY bad, stop it")
		new_race = mrace
	else
		CRASH("set_species called with an invalid mrace [mrace]")

	death_sound = new_race.death_sound

	var/datum/species/old_species = dna.species
	dna.species = new_race

	if (old_species.properly_gained)
		old_species.on_species_loss(src, new_race, pref_load)

	dna.species.on_species_gain(src, old_species, pref_load, icon_update, replace_missing)
	log_mob_tag("TAG: [tag] SPECIES: [key_name(src)] \[[mrace]\]")

/mob/living/carbon/human/set_species(datum/species/mrace, icon_update = TRUE, pref_load = FALSE, replace_missing = TRUE)
	..()
	if(icon_update)
		update_body(is_creating = TRUE)
		update_mutations_overlay()// no lizard with human hulk overlay please.

/mob/proc/has_dna()
	return

/mob/living/carbon/has_dna()
	return dna

/// Returns TRUE if the mob is allowed to mutate via its DNA, or FALSE if otherwise.
/// Only an organic Carbon with valid DNA may mutate; not robots, AIs, aliens, Ians, or other mobs.
/mob/proc/can_mutate()
	return FALSE

/mob/living/carbon/can_mutate()
	if(!(mob_biotypes & MOB_ORGANIC))
		return FALSE
	if(has_dna() && !HAS_TRAIT(src, TRAIT_GENELESS) && !HAS_TRAIT(src, TRAIT_BADDNA))
		return TRUE

/// Sets the DNA of the mob to the given DNA.
/mob/living/carbon/human/proc/hardset_dna(unique_identity, list/mutation_index, list/default_mutation_genes, newreal_name, newblood_type, datum/species/mrace, newfeatures, list/mutations, force_transfer_mutations)
	if(newfeatures)
		dna.features = newfeatures
		dna.generate_unique_features()

	if(mrace)
		var/datum/species/newrace = new mrace.type
		newrace.copy_properties_from(mrace)
		set_species(newrace, icon_update=0)

	if(newreal_name)
		dna.real_name = newreal_name
		dna.generate_unique_enzymes()

	if(newblood_type)
		set_blood_type(newblood_type)

	if(unique_identity)
		dna.unique_identity = unique_identity
		updateappearance(icon_update = 0)

	if(LAZYLEN(mutation_index))
		dna.mutation_index = mutation_index.Copy()
		if(LAZYLEN(default_mutation_genes))
			dna.default_mutation_genes = default_mutation_genes.Copy()
		else
			dna.default_mutation_genes = mutation_index.Copy()
		domutcheck()

	if(mrace || newfeatures || unique_identity)
		update_body(is_creating = TRUE)
		update_mutations_overlay()

	if(LAZYLEN(mutations) && force_transfer_mutations && can_mutate())
		for(var/datum/mutation/mutation as anything in mutations)
			var/list/allowed_sources = mutation.sources & GLOB.standard_mutation_sources
			if(allowed_sources)
				dna.add_mutation(mutation, allowed_sources)

/mob/living/carbon/proc/create_dna()
	dna = new /datum/dna(src)
	if(!dna.species)
		var/rando_race = pick(get_selectable_species())
		dna.species = new rando_race()

//proc used to update the mob's appearance after its dna UI has been changed
//2025: Im unsure if dna is meant to be living, carbon, or human level.. there's contradicting stuff and bugfixes going back 8 years
//If youre reading this, and you know for sure, update this, or maybe remove the carbon part entirely
/mob/living/carbon/proc/updateappearance(icon_update = TRUE, mutcolor_update = FALSE, mutations_overlay_update = FALSE)
	if(!has_dna())
		return

/mob/living/carbon/human/updateappearance(icon_update = TRUE, mutcolor_update = FALSE, mutations_overlay_update = FALSE)
	. = ..()
	for(var/block_type in GLOB.dna_identity_blocks)
		var/datum/dna_block/identity/block_to_apply = GLOB.dna_identity_blocks[block_type]
		block_to_apply.apply_to_mob(src, dna.unique_identity)

	for(var/block_type in GLOB.dna_feature_blocks)
		var/datum/dna_block/feature/block_to_apply = GLOB.dna_feature_blocks[block_type]
		if(dna.features[block_to_apply.feature_key])
			block_to_apply.apply_to_mob(src, dna.unique_features)

	for(var/obj/item/organ/organ in organs)
		organ.mutate_feature(dna.unique_features, src)

	if(icon_update)
		update_body(is_creating = mutcolor_update)
	if(mutations_overlay_update)
		update_mutations_overlay()

/mob/proc/domutcheck()
	return

/mob/living/carbon/domutcheck()
	if(!has_dna())
		return

	for(var/mutation in dna.mutation_index)
		dna.check_block(mutation)

	update_mutations_overlay()

/datum/dna/proc/check_block(mutation_path)
	var/datum/mutation/mutation = get_mutation(mutation_path)
	if(check_block_string(mutation_path))
		if(!mutation)
			add_mutation(mutation_path, MUTATION_SOURCE_ACTIVATED)
		return
	if(MUTATION_SOURCE_ACTIVATED in mutation?.sources)
		remove_mutation(mutation, MUTATION_SOURCE_ACTIVATED)

//Return the active mutation of a type if there is one
/datum/dna/proc/get_mutation(mutation_path)
	if(istype(mutation_path, /datum/mutation))
		var/datum/mutation/mutation = mutation_path
		mutation_path = mutation.type
	for(var/datum/mutation/mutation as anything in mutations)
		if(mutation.type == mutation_path)
			return mutation
	return null

/datum/dna/proc/check_block_string(mutation)
	if((LAZYLEN(mutation_index) > DNA_MUTATION_BLOCKS) || !(mutation in mutation_index))
		return FALSE
	return is_gene_active(mutation)

/datum/dna/proc/is_gene_active(mutation)
	return (mutation_index[mutation] == GET_SEQUENCE(mutation))

/datum/dna/proc/set_se(on=TRUE, datum/mutation/HM)
	if(!HM || !(HM.type in mutation_index) || (LAZYLEN(mutation_index) < DNA_MUTATION_BLOCKS))
		return
	. = TRUE
	if(on)
		mutation_index[HM.type] = GET_SEQUENCE(HM.type)
		default_mutation_genes[HM.type] = mutation_index[HM.type]
	else if(GET_SEQUENCE(HM.type) == mutation_index[HM.type])
		mutation_index[HM.type] = create_sequence(HM.type, FALSE, HM.difficulty)
		default_mutation_genes[HM.type] = mutation_index[HM.type]


/datum/dna/proc/activate_mutation(mutation) //note that this returns a boolean and not a new mob
	if(!mutation)
		return FALSE
	var/mutation_type = mutation
	if(istype(mutation, /datum/mutation))
		var/datum/mutation/instance = mutation
		mutation_type = instance.type
	if(!mutation_in_sequence(mutation_type)) //can't activate what we don't have, use add_mutation
		return FALSE
	add_mutation(mutation, MUTATION_SOURCE_ACTIVATED)
	return TRUE

/////////////////////////// DNA HELPER-PROCS //////////////////////////////

/datum/dna/proc/mutation_in_sequence(mutation)
	if(!mutation)
		return
	if(istype(mutation, /datum/mutation))
		var/datum/mutation/HM = mutation
		if(HM.type in mutation_index)
			return TRUE
	else if(mutation in mutation_index)
		return TRUE


/mob/living/carbon/proc/random_mutate(list/candidates)
	if(!has_dna())
		CRASH("[src] does not have DNA")
	var/mutation = pick(candidates)
	. = dna.add_mutation(mutation, MUTATION_SOURCE_MUTATOR)

///Returns a random mutation typepath based on the given arguments. By default, all available mutations in the dna sequence but the monkey one.
/mob/living/carbon/proc/get_random_mutation_path(quality = POSITIVE|NEGATIVE|MINOR_NEGATIVE, scrambled = TRUE, sequence = TRUE, list/excluded_mutations = list(/datum/mutation/race))
	if(!has_dna())
		return null
	var/list/mutations = list()
	if(quality & POSITIVE)
		mutations += GLOB.good_mutations
	if(quality & NEGATIVE)
		mutations += GLOB.bad_mutations
	if(quality & MINOR_NEGATIVE)
		mutations += GLOB.not_good_mutations
	var/list/possible = list()
	for(var/datum/mutation/mutation in mutations)
		if((!sequence || dna.mutation_in_sequence(mutation.type)) && !dna.get_mutation(mutation.type))
			possible += mutation.type
	possible -= excluded_mutations
	return length(possible) ? pick(possible) : null //prevent runtimes from picking null

///Gives the mob a random mutation based on the given arguments.
/mob/living/carbon/proc/easy_random_mutate(quality = POSITIVE|NEGATIVE|MINOR_NEGATIVE, scrambled = TRUE, sequence = TRUE, list/excluded_mutations = list(/datum/mutation/race))
	var/mutation_path = get_random_mutation_path(quality, scrambled, sequence, excluded_mutations)
	if(!mutation_path)
		return
	dna.add_mutation(mutation_path, MUTATION_SOURCE_ACTIVATED)
	if(!scrambled)
		return
	var/datum/mutation/mutation = dna.get_mutation(mutation_path)
	if(mutation)
		mutation.scrambled = TRUE

/mob/living/carbon/proc/random_mutate_unique_identity()
	if(!has_dna())
		CRASH("[src] does not have DNA")
	var/mutblock_path = pick(GLOB.dna_identity_blocks)
	var/datum/dna_block/identity/mutblock = GLOB.dna_identity_blocks[mutblock_path]
	dna.unique_identity = mutblock.modified_hash(dna.unique_identity, random_string(mutblock.block_length, GLOB.hex_characters))
	updateappearance(mutations_overlay_update = TRUE)

/mob/living/carbon/proc/random_mutate_unique_features()
	if(!has_dna())
		CRASH("[src] does not have DNA")
	var/mutblock_path = pick(GLOB.dna_feature_blocks)
	var/datum/dna_block/feature/mutblock = GLOB.dna_feature_blocks[mutblock_path]
	dna.unique_features = mutblock.modified_hash(dna.unique_features, random_string(mutblock.block_length, GLOB.hex_characters))
	updateappearance(mutcolor_update = TRUE, mutations_overlay_update = TRUE)

/mob/living/carbon/proc/clean_dna()
	if(!has_dna())
		CRASH("[src] does not have DNA")
	dna.remove_all_mutations()

/mob/living/carbon/proc/clean_random_mutate(list/candidates, difficulty = 2)
	clean_dna()
	random_mutate(candidates, difficulty)

/proc/scramble_dna(mob/living/carbon/M, ui = FALSE, se = FALSE, uf = FALSE, probability = 100)
	if(!M.has_dna())
		CRASH("[M] does not have DNA")
	if(HAS_TRAIT(M, TRAIT_NO_DNA_SCRAMBLE))
		return
	if(se)
		for(var/i=1, i <= DNA_MUTATION_BLOCKS, i++)
			if(prob(probability))
				M.dna.generate_dna_blocks()
		M.domutcheck()
	if(ui)
		for(var/block_id in GLOB.dna_identity_blocks)
			var/datum/dna_block/identity/block = GLOB.dna_identity_blocks[block_id]
			if(prob(probability))
				M.dna.unique_identity = block.modified_hash(M.dna.unique_identity, random_string(block.block_length, GLOB.hex_characters))
	if(uf)
		for(var/block_id in GLOB.dna_feature_blocks)
			var/datum/dna_block/feature/block = GLOB.dna_feature_blocks[block_id]
			if(prob(probability))
				M.dna.unique_identity = block.modified_hash(M.dna.unique_identity, random_string(block.block_length, GLOB.hex_characters))
	if(ui || uf)
		M.updateappearance(mutcolor_update=uf, mutations_overlay_update=1)

//value in range 1 to values. values must be greater than 0
//all arguments assumed to be positive integers
/proc/construct_block(value, values, blocksize=DNA_BLOCK_SIZE)
	var/width = round((16**blocksize)/values)
	if(value < 1)
		value = 1
	value = (value * width) - rand(1,width)
	return num2hex(value, blocksize)

//value is hex
/proc/deconstruct_block(value, values, blocksize=DNA_BLOCK_SIZE)
	var/width = round((16**blocksize)/values)
	value = round(hex2num(value) / width) + 1
	if(value > values)
		value = values
	return value

/////////////////////////// DNA HELPER-PROCS

/mob/living/carbon/human/proc/something_horrible(ignore_stability)
	if(!has_dna()) //shouldn't ever happen anyway so it's just in really weird cases
		return
	if(!ignore_stability && (dna.stability > 0))
		return
	var/instability = -dna.stability
	dna.remove_all_mutations()
	dna.stability = 100

	var/nonfatal = prob(max(70-instability, 0))

	if(!dna.nonfatal_meltdowns.len)
		for(var/datum/instability_meltdown/meltdown_type as anything in typecacheof(/datum/instability_meltdown, ignore_root_path = TRUE))
			if(initial(meltdown_type.abstract_type) == meltdown_type)
				continue

			if (initial(meltdown_type.fatal))
				dna.fatal_meltdowns[meltdown_type] = initial(meltdown_type.meltdown_weight)
				continue

			dna.nonfatal_meltdowns[meltdown_type] = initial(meltdown_type.meltdown_weight)

	var/picked_type = pick_weight(nonfatal ? dna.nonfatal_meltdowns : dna.fatal_meltdowns)
	var/datum/instability_meltdown/meltdown = new picked_type
	meltdown.meltdown(src)

/mob/living/carbon/human/proc/something_horrible_mindmelt()
	if(!is_blind())
		var/obj/item/organ/eyes/eyes = locate(/obj/item/organ/eyes) in organs
		if(!eyes)
			return
		eyes.Remove(src)
		qdel(eyes)
		visible_message(span_notice("[src] looks up and their eyes melt away!"), span_userdanger("I understand now."))
		addtimer(CALLBACK(src, PROC_REF(adjustOrganLoss), ORGAN_SLOT_BRAIN, 200), 2 SECONDS)
