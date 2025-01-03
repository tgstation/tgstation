
/**
 * Some identity blocks (basically pieces of the unique_identity string variable of the dna datum, commonly abbreviated with ui)
 * may have a length that differ from standard length of 3 ASCII characters. This list is necessary
 * for these non-standard blocks to work, as well as the entire unique identity string.
 * Should you add a new ui block which size differ from the standard (again, 3 ASCII characters), like for example, a color,
 * please do not forget to also include it in this list in the following format:
 *  "[dna block number]" = dna block size,
 * Failure to do that may result in bugs. Thanks.
 */
GLOBAL_LIST_INIT(identity_block_lengths, list(
		"[DNA_HAIR_COLOR_BLOCK]" = DNA_BLOCK_SIZE_COLOR,
		"[DNA_FACIAL_HAIR_COLOR_BLOCK]" = DNA_BLOCK_SIZE_COLOR,
		"[DNA_EYE_COLOR_LEFT_BLOCK]" = DNA_BLOCK_SIZE_COLOR,
		"[DNA_EYE_COLOR_RIGHT_BLOCK]" = DNA_BLOCK_SIZE_COLOR,
		"[DNA_HAIR_COLOR_GRADIENT_BLOCK]" = DNA_BLOCK_SIZE_COLOR,
		"[DNA_FACIAL_HAIR_COLOR_GRADIENT_BLOCK]" = DNA_BLOCK_SIZE_COLOR,
	))

/**
 * The same rules of the above also apply here, with the exception that this is for the unique_features string variable
 * (commonly abbreviated with uf) and its blocks. Both ui and uf have a standard block length of 3 ASCII characters.
 */
GLOBAL_LIST_INIT(features_block_lengths, list(
		"[DNA_MUTANT_COLOR_BLOCK]" = DNA_BLOCK_SIZE_COLOR,
		"[DNA_ETHEREAL_COLOR_BLOCK]" = DNA_BLOCK_SIZE_COLOR,
	))

/**
 * A list of numbers that keeps track of where ui blocks start in the unique_identity string variable of the dna datum.
 * Commonly used by the datum/dna/set_uni_identity_block and datum/dna/get_uni_identity_block procs.
 */
GLOBAL_LIST_INIT(total_ui_len_by_block, populate_total_ui_len_by_block())

/proc/populate_total_ui_len_by_block()
	. = list()
	var/total_block_len = 1
	for(var/blocknumber in 1 to DNA_UNI_IDENTITY_BLOCKS)
		. += total_block_len
		total_block_len += GET_UI_BLOCK_LEN(blocknumber)

///Ditto but for unique features. Used by the datum/dna/set_uni_feature_block and datum/dna/get_uni_feature_block procs.
GLOBAL_LIST_INIT(total_uf_len_by_block, populate_total_uf_len_by_block())

/proc/populate_total_uf_len_by_block()
	. = list()
	var/total_block_len = 1
	for(var/blocknumber in 1 to DNA_FEATURE_BLOCKS)
		. += total_block_len
		total_block_len += GET_UF_BLOCK_LEN(blocknumber)

/////////////////////////// DNA DATUM
/datum/dna
	///An md5 hash of the dna holder's real name
	var/unique_enzymes
	///Stores the hashed values of traits such as skin tones, hair style, and gender
	var/unique_identity
	var/blood_type
	///The type of mutant race the player is if applicable (i.e. potato-man)
	var/datum/species/species = new /datum/species/human
	/// Assoc list of feature keys to their value
	/// Note if you set these manually, and do not update [unique_features] afterwards, it will likely be reset.
	var/list/features = list("mcolor" = COLOR_WHITE)
	///Stores the hashed values of the person's non-human features
	var/unique_features
	///Stores the real name of the person who originally got this dna datum. Used primarily for changelings,
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
	if(iscarbon(holder))
		var/mob/living/carbon/cholder = holder
		remove_all_mutations() // mutations hold a reference to the dna
		if(cholder.dna == src)
			cholder.dna = null
	holder = null

	QDEL_NULL(species)

	mutations.Cut() //This only references mutations, just dereference.
	temporary_mutations.Cut() //^
	previous.Cut() //^

	return ..()

/datum/dna/proc/transfer_identity(mob/living/carbon/destination, transfer_SE = FALSE, transfer_species = TRUE)
	if(!istype(destination))
		return
	destination.dna.unique_enzymes = unique_enzymes
	destination.dna.unique_identity = unique_identity
	destination.dna.blood_type = blood_type
	destination.dna.unique_features = unique_features
	destination.dna.features = features.Copy()
	destination.dna.real_name = real_name
	destination.dna.temporary_mutations = temporary_mutations.Copy()
	if(transfer_SE)
		destination.dna.mutation_index = mutation_index
		destination.dna.default_mutation_genes = default_mutation_genes
	if(transfer_species)
		destination.set_species(species.type, icon_update=0)

/datum/dna/proc/copy_dna(datum/dna/new_dna)
	new_dna.unique_enzymes = unique_enzymes
	new_dna.mutation_index = mutation_index
	new_dna.default_mutation_genes = default_mutation_genes
	new_dna.unique_identity = unique_identity
	new_dna.unique_features = unique_features
	new_dna.blood_type = blood_type
	new_dna.features = features.Copy()
	//if the new DNA has a holder, transform them immediately, otherwise save it
	if(new_dna.holder)
		new_dna.holder.set_species(species.type, icon_update = 0)
	else
		new_dna.species = new species.type
	new_dna.real_name = real_name
	// Mutations aren't gc managed, but they still aren't templates
	// Let's do a proper copy
	for(var/datum/mutation/human/mutation in mutations)
		new_dna.add_mutation(mutation, mutation.class, mutation.timeout)

//See mutation.dm for what 'class' does. 'time' is time till it removes itself in decimals. 0 for no timer
/datum/dna/proc/add_mutation(mutation, class = MUT_OTHER, time)
	var/mutation_type = mutation
	if(istype(mutation, /datum/mutation/human))
		var/datum/mutation/human/HM = mutation
		mutation_type = HM.type
	if(get_mutation(mutation_type))
		return
	SEND_SIGNAL(holder, COMSIG_CARBON_GAIN_MUTATION, mutation_type, class)
	return force_give(new mutation_type (class, time, copymut = mutation))

/datum/dna/proc/remove_mutation(datum/mutation/human/mutation_type, mutadone)

	var/datum/mutation/human/actual_mutation = get_mutation(mutation_type)

	if(!actual_mutation)
		return FALSE

	// Check that it exists first before trying to remove it with mutadone
	if(actual_mutation.mutadone_proof && mutadone)
		return FALSE

	SEND_SIGNAL(holder, COMSIG_CARBON_LOSE_MUTATION, mutation_type)
	return force_lose(actual_mutation)

/datum/dna/proc/check_mutation(mutation_type)
	return get_mutation(mutation_type)

/datum/dna/proc/remove_all_mutations(list/classes = list(MUT_NORMAL, MUT_EXTRA, MUT_OTHER), mutadone = FALSE)
	remove_mutation_group(mutations, classes, mutadone)
	scrambled = FALSE

/datum/dna/proc/remove_mutation_group(list/group, list/classes = list(MUT_NORMAL, MUT_EXTRA, MUT_OTHER), mutadone = FALSE)
	if(!group)
		return
	for(var/datum/mutation/human/HM in group)
		if((HM.class in classes) && !(HM.mutadone_proof && mutadone))
			remove_mutation(HM)

/datum/dna/proc/generate_unique_identity()
	. = ""
	var/list/L = new /list(DNA_UNI_IDENTITY_BLOCKS)

	//ignores TRAIT_AGENDER so that a "real" gender can be stored in the DNA if later use is needed
	switch(holder.gender)
		if(MALE)
			L[DNA_GENDER_BLOCK] = construct_block(G_MALE, GENDERS)
		if(FEMALE)
			L[DNA_GENDER_BLOCK] = construct_block(G_FEMALE, GENDERS)
		if(NEUTER)
			L[DNA_GENDER_BLOCK] = construct_block(G_NEUTER, GENDERS)
		else
			L[DNA_GENDER_BLOCK] = construct_block(G_PLURAL, GENDERS)
	if(ishuman(holder))
		var/mob/living/carbon/human/H = holder
		if(length(SSaccessories.hairstyles_list) == 0 || length(SSaccessories.facial_hairstyles_list) == 0)
			CRASH("SSaccessories lists are empty, this is bad!")

		L[DNA_HAIRSTYLE_BLOCK] = construct_block(SSaccessories.hairstyles_list.Find(H.hairstyle), length(SSaccessories.hairstyles_list))
		L[DNA_HAIR_COLOR_BLOCK] = sanitize_hexcolor(H.hair_color, include_crunch = FALSE)
		L[DNA_FACIAL_HAIRSTYLE_BLOCK] = construct_block(SSaccessories.facial_hairstyles_list.Find(H.facial_hairstyle), length(SSaccessories.facial_hairstyles_list))
		L[DNA_FACIAL_HAIR_COLOR_BLOCK] = sanitize_hexcolor(H.facial_hair_color, include_crunch = FALSE)
		L[DNA_SKIN_TONE_BLOCK] = construct_block(GLOB.skin_tones.Find(H.skin_tone), GLOB.skin_tones.len)
		L[DNA_EYE_COLOR_LEFT_BLOCK] = sanitize_hexcolor(H.eye_color_left, include_crunch = FALSE)
		L[DNA_EYE_COLOR_RIGHT_BLOCK] = sanitize_hexcolor(H.eye_color_right, include_crunch = FALSE)
		L[DNA_HAIRSTYLE_GRADIENT_BLOCK] = construct_block(SSaccessories.hair_gradients_list.Find(H.grad_style[GRADIENT_HAIR_KEY]), length(SSaccessories.hair_gradients_list))
		L[DNA_HAIR_COLOR_GRADIENT_BLOCK] = sanitize_hexcolor(H.grad_color[GRADIENT_HAIR_KEY], include_crunch = FALSE)
		L[DNA_FACIAL_HAIRSTYLE_GRADIENT_BLOCK] = construct_block(SSaccessories.facial_hair_gradients_list.Find(H.grad_style[GRADIENT_FACIAL_HAIR_KEY]), length(SSaccessories.facial_hair_gradients_list))
		L[DNA_FACIAL_HAIR_COLOR_GRADIENT_BLOCK] = sanitize_hexcolor(H.grad_color[GRADIENT_FACIAL_HAIR_KEY], include_crunch = FALSE)

	for(var/blocknum in 1 to DNA_UNI_IDENTITY_BLOCKS)
		. += L[blocknum] || random_string(GET_UI_BLOCK_LEN(blocknum), GLOB.hex_characters)

/datum/dna/proc/generate_unique_features()
	. = ""
	var/list/L = new /list(DNA_FEATURE_BLOCKS)

	if(features["mcolor"])
		L[DNA_MUTANT_COLOR_BLOCK] = sanitize_hexcolor(features["mcolor"], include_crunch = FALSE)
	if(features["ethcolor"])
		L[DNA_ETHEREAL_COLOR_BLOCK] = sanitize_hexcolor(features["ethcolor"], include_crunch = FALSE)
	if(features["lizard_markings"])
		L[DNA_LIZARD_MARKINGS_BLOCK] = construct_block(SSaccessories.lizard_markings_list.Find(features["lizard_markings"]), length(SSaccessories.lizard_markings_list))
	if(features["tail_cat"])
		L[DNA_TAIL_BLOCK] = construct_block(SSaccessories.tails_list_felinid.Find(features["tail_cat"]), length(SSaccessories.tails_list_felinid))
	if(features["tail_lizard"])
		L[DNA_LIZARD_TAIL_BLOCK] = construct_block(SSaccessories.tails_list_lizard.Find(features["tail_lizard"]), length(SSaccessories.tails_list_lizard))
	if(features["snout"])
		L[DNA_SNOUT_BLOCK] = construct_block(SSaccessories.snouts_list.Find(features["snout"]), length(SSaccessories.snouts_list))
	if(features["horns"])
		L[DNA_HORNS_BLOCK] = construct_block(SSaccessories.horns_list.Find(features["horns"]), length(SSaccessories.horns_list))
	if(features["frills"])
		L[DNA_FRILLS_BLOCK] = construct_block(SSaccessories.frills_list.Find(features["frills"]), length(SSaccessories.frills_list))
	if(features["spines"])
		L[DNA_SPINES_BLOCK] = construct_block(SSaccessories.spines_list.Find(features["spines"]), length(SSaccessories.spines_list))
	if(features["ears"])
		L[DNA_EARS_BLOCK] = construct_block(SSaccessories.ears_list.Find(features["ears"]), length(SSaccessories.ears_list))
	if(features["moth_wings"] != "Burnt Off")
		L[DNA_MOTH_WINGS_BLOCK] = construct_block(SSaccessories.moth_wings_list.Find(features["moth_wings"]), length(SSaccessories.moth_wings_list))
	if(features["moth_antennae"] != "Burnt Off")
		L[DNA_MOTH_ANTENNAE_BLOCK] = construct_block(SSaccessories.moth_antennae_list.Find(features["moth_antennae"]), length(SSaccessories.moth_antennae_list))
	if(features["moth_markings"])
		L[DNA_MOTH_MARKINGS_BLOCK] = construct_block(SSaccessories.moth_markings_list.Find(features["moth_markings"]), length(SSaccessories.moth_markings_list))
	if(features["caps"])
		L[DNA_MUSHROOM_CAPS_BLOCK] = construct_block(SSaccessories.caps_list.Find(features["caps"]), length(SSaccessories.caps_list))
	if(features["pod_hair"])
		L[DNA_POD_HAIR_BLOCK] = construct_block(SSaccessories.pod_hair_list.Find(features["pod_hair"]), length(SSaccessories.pod_hair_list))
	if(features["fish_tail"])
		L[DNA_FISH_TAIL_BLOCK] = construct_block(SSaccessories.tails_list_fish.Find(features["fish_tail"]), length(SSaccessories.tails_list_fish))

	for(var/blocknum in 1 to DNA_FEATURE_BLOCKS)
		. += L[blocknum] || random_string(GET_UI_BLOCK_LEN(blocknum), GLOB.hex_characters)

/datum/dna/proc/generate_dna_blocks()
	var/bonus
	if(species?.inert_mutation)
		bonus = GET_INITIALIZED_MUTATION(species.inert_mutation)
	var/list/mutations_temp = GLOB.good_mutations + GLOB.bad_mutations + GLOB.not_good_mutations + bonus
	if(!LAZYLEN(mutations_temp))
		return
	mutation_index.Cut()
	default_mutation_genes.Cut()
	shuffle_inplace(mutations_temp)
	mutation_index[/datum/mutation/human/race] = create_sequence(/datum/mutation/human/race, FALSE)
	default_mutation_genes[/datum/mutation/human/race] = mutation_index[/datum/mutation/human/race]
	for(var/i in 2 to DNA_MUTATION_BLOCKS)
		var/datum/mutation/human/M = mutations_temp[i]
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
		var/datum/mutation/human/A = GET_INITIALIZED_MUTATION(mutation) //leaves the possibility to change difficulty mid-round
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

///Setter macro used to modify unique identity blocks.
/datum/dna/proc/set_uni_identity_block(blocknum, input)
	var/precesing_blocks = copytext(unique_identity, 1, GLOB.total_ui_len_by_block[blocknum])
	var/succeeding_blocks = blocknum < GLOB.total_ui_len_by_block.len ? copytext(unique_identity, GLOB.total_ui_len_by_block[blocknum+1]) : ""
	unique_identity = precesing_blocks + input + succeeding_blocks

///Setter macro used to modify unique features blocks.
/datum/dna/proc/set_uni_feature_block(blocknum, input)
	var/precesing_blocks = copytext(unique_features, 1, GLOB.total_uf_len_by_block[blocknum])
	var/succeeding_blocks = blocknum < GLOB.total_uf_len_by_block.len ? copytext(unique_features, GLOB.total_uf_len_by_block[blocknum+1]) : ""
	unique_features = precesing_blocks + input + succeeding_blocks

/datum/dna/proc/update_ui_block(blocknumber)
	if(!blocknumber)
		CRASH("UI block index is null")
	if(!ishuman(holder))
		CRASH("Non-human mobs shouldn't have DNA")
	var/mob/living/carbon/human/H = holder
	switch(blocknumber)
		if(DNA_HAIR_COLOR_BLOCK)
			set_uni_identity_block(blocknumber, sanitize_hexcolor(H.hair_color, include_crunch = FALSE))
		if(DNA_FACIAL_HAIR_COLOR_BLOCK)
			set_uni_identity_block(blocknumber, sanitize_hexcolor(H.facial_hair_color, include_crunch = FALSE))
		if(DNA_SKIN_TONE_BLOCK)
			set_uni_identity_block(blocknumber, construct_block(GLOB.skin_tones.Find(H.skin_tone), GLOB.skin_tones.len))
		if(DNA_EYE_COLOR_LEFT_BLOCK)
			set_uni_identity_block(blocknumber, sanitize_hexcolor(H.eye_color_left, include_crunch = FALSE))
		if(DNA_EYE_COLOR_RIGHT_BLOCK)
			set_uni_identity_block(blocknumber, sanitize_hexcolor(H.eye_color_right, include_crunch = FALSE))
		if(DNA_GENDER_BLOCK)
			switch(H.gender)
				if(MALE)
					set_uni_identity_block(blocknumber, construct_block(G_MALE, GENDERS))
				if(FEMALE)
					set_uni_identity_block(blocknumber, construct_block(G_FEMALE, GENDERS))
				if(NEUTER)
					set_uni_identity_block(blocknumber, construct_block(G_NEUTER, GENDERS))
				else
					set_uni_identity_block(blocknumber, construct_block(G_PLURAL, GENDERS))
		if(DNA_FACIAL_HAIRSTYLE_BLOCK)
			set_uni_identity_block(blocknumber, construct_block(SSaccessories.facial_hairstyles_list.Find(H.facial_hairstyle), length(SSaccessories.facial_hairstyles_list)))
		if(DNA_HAIRSTYLE_BLOCK)
			set_uni_identity_block(blocknumber, construct_block(SSaccessories.hairstyles_list.Find(H.hairstyle), length(SSaccessories.hairstyles_list)))
		if(DNA_HAIRSTYLE_GRADIENT_BLOCK)
			set_uni_identity_block(blocknumber, construct_block(SSaccessories.hair_gradients_list.Find(H.grad_style[GRADIENT_HAIR_KEY]), length(SSaccessories.hair_gradients_list)))
		if(DNA_FACIAL_HAIRSTYLE_GRADIENT_BLOCK)
			set_uni_identity_block(blocknumber, construct_block(SSaccessories.facial_hair_gradients_list.Find(H.grad_style[GRADIENT_FACIAL_HAIR_KEY]), length(SSaccessories.facial_hair_gradients_list)))
		if(DNA_HAIR_COLOR_GRADIENT_BLOCK)
			set_uni_identity_block(blocknumber, sanitize_hexcolor(H.grad_color[GRADIENT_HAIR_KEY], include_crunch = FALSE))
		if(DNA_FACIAL_HAIR_COLOR_GRADIENT_BLOCK)
			set_uni_identity_block(blocknumber, sanitize_hexcolor(H.grad_color[GRADIENT_FACIAL_HAIR_KEY], include_crunch = FALSE))

/datum/dna/proc/update_uf_block(blocknumber)
	if(!blocknumber)
		CRASH("UF block index is null")
	if(!ishuman(holder))
		CRASH("Non-human mobs shouldn't have DNA")
	switch(blocknumber)
		if(DNA_MUTANT_COLOR_BLOCK)
			set_uni_feature_block(blocknumber, sanitize_hexcolor(features["mcolor"], include_crunch = FALSE))
		if(DNA_ETHEREAL_COLOR_BLOCK)
			set_uni_feature_block(blocknumber, sanitize_hexcolor(features["ethcolor"], include_crunch = FALSE))
		if(DNA_LIZARD_MARKINGS_BLOCK)
			set_uni_feature_block(blocknumber, construct_block(SSaccessories.lizard_markings_list.Find(features["lizard_markings"]), length(SSaccessories.lizard_markings_list)))
		if(DNA_TAIL_BLOCK)
			set_uni_feature_block(blocknumber, construct_block(SSaccessories.tails_list_felinid.Find(features["tail_cat"]), length(SSaccessories.tails_list_felinid)))
		if(DNA_LIZARD_TAIL_BLOCK)
			set_uni_feature_block(blocknumber, construct_block(SSaccessories.tails_list_lizard.Find(features["tail_lizard"]), length(SSaccessories.tails_list_lizard)))
		if(DNA_SNOUT_BLOCK)
			set_uni_feature_block(blocknumber, construct_block(SSaccessories.snouts_list.Find(features["snout"]), length(SSaccessories.snouts_list)))
		if(DNA_HORNS_BLOCK)
			set_uni_feature_block(blocknumber, construct_block(SSaccessories.horns_list.Find(features["horns"]), length(SSaccessories.horns_list)))
		if(DNA_FRILLS_BLOCK)
			set_uni_feature_block(blocknumber, construct_block(SSaccessories.frills_list.Find(features["frills"]), length(SSaccessories.frills_list)))
		if(DNA_SPINES_BLOCK)
			set_uni_feature_block(blocknumber, construct_block(SSaccessories.spines_list.Find(features["spines"]), length(SSaccessories.spines_list)))
		if(DNA_EARS_BLOCK)
			set_uni_feature_block(blocknumber, construct_block(SSaccessories.ears_list.Find(features["ears"]), length(SSaccessories.ears_list)))
		if(DNA_MOTH_WINGS_BLOCK)
			set_uni_feature_block(blocknumber, construct_block(SSaccessories.moth_wings_list.Find(features["moth_wings"]), length(SSaccessories.moth_wings_list)))
		if(DNA_MOTH_ANTENNAE_BLOCK)
			set_uni_feature_block(blocknumber, construct_block(SSaccessories.moth_antennae_list.Find(features["moth_antennae"]), length(SSaccessories.moth_antennae_list)))
		if(DNA_MOTH_MARKINGS_BLOCK)
			set_uni_feature_block(blocknumber, construct_block(SSaccessories.moth_markings_list.Find(features["moth_markings"]), length(SSaccessories.moth_markings_list)))
		if(DNA_MUSHROOM_CAPS_BLOCK)
			set_uni_feature_block(blocknumber, construct_block(SSaccessories.caps_list.Find(features["caps"]), length(SSaccessories.caps_list)))
		if(DNA_POD_HAIR_BLOCK)
			set_uni_feature_block(blocknumber, construct_block(SSaccessories.pod_hair_list.Find(features["pod_hair"]), length(SSaccessories.pod_hair_list)))
		if(DNA_FISH_TAIL_BLOCK)
			set_uni_feature_block(blocknumber, construct_block(SSaccessories.tails_list_fish.Find(features["fish_tail"]), length(SSaccessories.tails_list_fish)))

//Please use add_mutation or activate_mutation instead
/datum/dna/proc/force_give(datum/mutation/human/human_mutation)
	if(holder && human_mutation)
		if(human_mutation.class == MUT_NORMAL)
			set_se(1, human_mutation)
		. = human_mutation.on_acquiring(holder)
		if(.)
			qdel(human_mutation)
		update_instability()

//Use remove_mutation instead
/datum/dna/proc/force_lose(datum/mutation/human/human_mutation)
	if(holder && (human_mutation in mutations))
		set_se(0, human_mutation)
		. = human_mutation.on_losing(holder)
		if(!(human_mutation in mutations))
			qdel(human_mutation) // qdel mutations on removal
			update_instability(FALSE)
		return

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
		&& blood_type == target_dna.blood_type \
	)
		return TRUE

	return FALSE

/datum/dna/proc/update_instability(alert=TRUE)
	stability = 100
	for(var/datum/mutation/human/M in mutations)
		if(M.class == MUT_EXTRA || M.instability < 0)
			stability -= M.instability * GET_MUTATION_STABILIZER(M)
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
		if(message)
			to_chat(holder, message)

/// Updates the UI, UE, and UF of the DNA according to the features, appearance, name, etc. of the DNA / holder.
/datum/dna/proc/update_dna_identity()
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
/datum/dna/proc/initialize_dna(newblood_type, create_mutation_blocks = TRUE, randomize_features = TRUE)
	if(newblood_type)
		blood_type = newblood_type
	if(create_mutation_blocks) //I hate this
		generate_dna_blocks()
	if(randomize_features)
		for(var/species_type in GLOB.species_prototypes)
			var/list/new_features = GLOB.species_prototypes[species_type].randomize_features()
			for(var/feature in new_features)
				features[feature] = new_features[feature]

		features["mcolor"] = "#[random_color()]"

	update_dna_identity()

/datum/dna/stored //subtype used by brain mob's stored_dna and the crew manifest

/datum/dna/stored/add_mutation(mutation_name) //no mutation changes on stored dna.
	return

/datum/dna/stored/remove_mutation(mutation_name, mutadone)
	return

/datum/dna/stored/check_mutation(mutation_name)
	return

/datum/dna/stored/remove_all_mutations(list/classes, mutadone = FALSE)
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


/mob/living/carbon/set_species(datum/species/mrace, icon_update = TRUE, pref_load = FALSE)
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

	dna.species.on_species_gain(src, old_species, pref_load, regenerate_icons = icon_update)
	log_mob_tag("TAG: [tag] SPECIES: [key_name(src)] \[[mrace]\]")

/mob/living/carbon/human/set_species(datum/species/mrace, icon_update = TRUE, pref_load = FALSE)
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
//Do not use force_transfer_mutations for stuff like cloners without some precautions, otherwise some conditional mutations could break (timers, drill hat etc)
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
		dna.blood_type = newblood_type

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

	if(LAZYLEN(mutations) && force_transfer_mutations)
		for(var/datum/mutation/human/mutation as anything in mutations)
			dna.force_give(new mutation.type(mutation.class, copymut = mutation)) //using force_give since it may include exotic mutations that otherwise won't be handled properly

/mob/living/carbon/proc/create_dna()
	dna = new /datum/dna(src)
	if(!dna.species)
		var/rando_race = pick(get_selectable_species())
		dna.species = new rando_race()

//proc used to update the mob's appearance after its dna UI has been changed
/mob/living/carbon/proc/updateappearance(icon_update=1, mutcolor_update=0, mutations_overlay_update=0)
	if(!has_dna())
		return

	//Always plural gender if agender
	if(HAS_TRAIT(src, TRAIT_AGENDER))
		gender = PLURAL
		return

	switch(deconstruct_block(get_uni_identity_block(dna.unique_identity, DNA_GENDER_BLOCK), GENDERS))
		if(G_MALE)
			gender = MALE
		if(G_FEMALE)
			gender = FEMALE
		if(G_NEUTER)
			gender = NEUTER
		else
			gender = PLURAL

/mob/living/carbon/human/updateappearance(icon_update = TRUE, mutcolor_update = FALSE, mutations_overlay_update = FALSE)
	..()
	var/structure = dna.unique_identity
	skin_tone = GLOB.skin_tones[deconstruct_block(get_uni_identity_block(structure, DNA_SKIN_TONE_BLOCK), GLOB.skin_tones.len)]
	eye_color_left = sanitize_hexcolor(get_uni_identity_block(structure, DNA_EYE_COLOR_LEFT_BLOCK))
	eye_color_right = sanitize_hexcolor(get_uni_identity_block(structure, DNA_EYE_COLOR_RIGHT_BLOCK))
	set_haircolor(sanitize_hexcolor(get_uni_identity_block(structure, DNA_HAIR_COLOR_BLOCK)), update = FALSE)
	set_facial_haircolor(sanitize_hexcolor(get_uni_identity_block(structure, DNA_FACIAL_HAIR_COLOR_BLOCK)), update = FALSE)
	set_hair_gradient_color(sanitize_hexcolor(get_uni_identity_block(structure, DNA_HAIR_COLOR_GRADIENT_BLOCK)), update = FALSE)
	set_facial_hair_gradient_color(sanitize_hexcolor(get_uni_identity_block(structure, DNA_FACIAL_HAIR_COLOR_GRADIENT_BLOCK)), update = FALSE)
	if(HAS_TRAIT(src, TRAIT_SHAVED))
		set_facial_hairstyle("Shaved", update = FALSE)
	else
		var/style = SSaccessories.facial_hairstyles_list[deconstruct_block(get_uni_identity_block(structure, DNA_FACIAL_HAIRSTYLE_BLOCK), length(SSaccessories.facial_hairstyles_list))]
		var/gradient_style = SSaccessories.facial_hair_gradients_list[deconstruct_block(get_uni_identity_block(structure, DNA_FACIAL_HAIRSTYLE_GRADIENT_BLOCK), length(SSaccessories.facial_hair_gradients_list))]
		set_facial_hairstyle(style, update = FALSE)
		set_facial_hair_gradient_style(gradient_style, update = FALSE)
	if(HAS_TRAIT(src, TRAIT_BALD))
		set_hairstyle("Bald", update = FALSE)
	else
		var/style = SSaccessories.hairstyles_list[deconstruct_block(get_uni_identity_block(structure, DNA_HAIRSTYLE_BLOCK), length(SSaccessories.hairstyles_list))]
		var/gradient_style = SSaccessories.hair_gradients_list[deconstruct_block(get_uni_identity_block(structure, DNA_HAIRSTYLE_GRADIENT_BLOCK), length(SSaccessories.hair_gradients_list))]
		set_hairstyle(style, update = FALSE)
		set_hair_gradient_style(gradient_style, update = FALSE)
	var/features = dna.unique_features
	if(dna.features["mcolor"])
		dna.features["mcolor"] = sanitize_hexcolor(get_uni_feature_block(features, DNA_MUTANT_COLOR_BLOCK))
	if(dna.features["ethcolor"])
		dna.features["ethcolor"] = sanitize_hexcolor(get_uni_feature_block(features, DNA_ETHEREAL_COLOR_BLOCK))
	if(dna.features["lizard_markings"])
		dna.features["lizard_markings"] = SSaccessories.lizard_markings_list[deconstruct_block(get_uni_feature_block(features, DNA_LIZARD_MARKINGS_BLOCK), length(SSaccessories.lizard_markings_list))]
	if(dna.features["snout"])
		dna.features["snout"] = SSaccessories.snouts_list[deconstruct_block(get_uni_feature_block(features, DNA_SNOUT_BLOCK), length(SSaccessories.snouts_list))]
	if(dna.features["horns"])
		dna.features["horns"] = SSaccessories.horns_list[deconstruct_block(get_uni_feature_block(features, DNA_HORNS_BLOCK), length(SSaccessories.horns_list))]
	if(dna.features["frills"])
		dna.features["frills"] = SSaccessories.frills_list[deconstruct_block(get_uni_feature_block(features, DNA_FRILLS_BLOCK), length(SSaccessories.frills_list))]
	if(dna.features["spines"])
		dna.features["spines"] = SSaccessories.spines_list[deconstruct_block(get_uni_feature_block(features, DNA_SPINES_BLOCK), length(SSaccessories.spines_list))]
	if(dna.features["tail_cat"])
		dna.features["tail_cat"] = SSaccessories.tails_list_felinid[deconstruct_block(get_uni_feature_block(features, DNA_TAIL_BLOCK), length(SSaccessories.tails_list_felinid))]
	if(dna.features["tail_lizard"])
		dna.features["tail_lizard"] = SSaccessories.tails_list_lizard[deconstruct_block(get_uni_feature_block(features, DNA_LIZARD_TAIL_BLOCK), length(SSaccessories.tails_list_lizard))]
	if(dna.features["ears"])
		dna.features["ears"] = SSaccessories.ears_list[deconstruct_block(get_uni_feature_block(features, DNA_EARS_BLOCK), length(SSaccessories.ears_list))]
	if(dna.features["moth_wings"])
		var/genetic_value = SSaccessories.moth_wings_list[deconstruct_block(get_uni_feature_block(features, DNA_MOTH_WINGS_BLOCK), length(SSaccessories.moth_wings_list))]
		dna.features["original_moth_wings"] = genetic_value
		dna.features["moth_wings"] = genetic_value
	if(dna.features["moth_antennae"])
		var/genetic_value = SSaccessories.moth_antennae_list[deconstruct_block(get_uni_feature_block(features, DNA_MOTH_ANTENNAE_BLOCK), length(SSaccessories.moth_antennae_list))]
		dna.features["original_moth_antennae"] = genetic_value
		dna.features["moth_antennae"] = genetic_value
	if(dna.features["moth_markings"])
		dna.features["moth_markings"] = SSaccessories.moth_markings_list[deconstruct_block(get_uni_feature_block(features, DNA_MOTH_MARKINGS_BLOCK), length(SSaccessories.moth_markings_list))]
	if(dna.features["caps"])
		dna.features["caps"] = SSaccessories.caps_list[deconstruct_block(get_uni_feature_block(features, DNA_MUSHROOM_CAPS_BLOCK), length(SSaccessories.caps_list))]
	if(dna.features["pod_hair"])
		dna.features["pod_hair"] = SSaccessories.pod_hair_list[deconstruct_block(get_uni_feature_block(features, DNA_POD_HAIR_BLOCK), length(SSaccessories.pod_hair_list))]
	if(dna.features["fish_tail"])
		dna.features["fish_tail"] = SSaccessories.tails_list_fish[deconstruct_block(get_uni_feature_block(features, DNA_FISH_TAIL_BLOCK), length(SSaccessories.tails_list_fish))]

	for(var/obj/item/organ/organ in organs)
		organ.mutate_feature(features, src)

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

/datum/dna/proc/check_block(mutation)
	var/datum/mutation/human/HM = get_mutation(mutation)
	if(check_block_string(mutation))
		if(!HM)
			. = add_mutation(mutation, MUT_NORMAL)
		return
	return force_lose(HM)

//Return the active mutation of a type if there is one
/datum/dna/proc/get_mutation(A)
	for(var/datum/mutation/human/HM in mutations)
		if(istype(HM, A))
			return HM

/datum/dna/proc/check_block_string(mutation)
	if((LAZYLEN(mutation_index) > DNA_MUTATION_BLOCKS) || !(mutation in mutation_index))
		return FALSE
	return is_gene_active(mutation)

/datum/dna/proc/is_gene_active(mutation)
	return (mutation_index[mutation] == GET_SEQUENCE(mutation))

/datum/dna/proc/set_se(on=TRUE, datum/mutation/human/HM)
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
	if(istype(mutation, /datum/mutation/human))
		var/datum/mutation/human/M = mutation
		mutation_type = M.type
	if(!mutation_in_sequence(mutation_type)) //can't activate what we don't have, use add_mutation
		return FALSE
	add_mutation(mutation, MUT_NORMAL)
	return TRUE

/////////////////////////// DNA HELPER-PROCS //////////////////////////////

/datum/dna/proc/mutation_in_sequence(mutation)
	if(!mutation)
		return
	if(istype(mutation, /datum/mutation/human))
		var/datum/mutation/human/HM = mutation
		if(HM.type in mutation_index)
			return TRUE
	else if(mutation in mutation_index)
		return TRUE


/mob/living/carbon/proc/random_mutate(list/candidates, difficulty = 2)
	if(!has_dna())
		CRASH("[src] does not have DNA")
	var/mutation = pick(candidates)
	. = dna.add_mutation(mutation)

/mob/living/carbon/proc/easy_random_mutate(quality = POSITIVE + NEGATIVE + MINOR_NEGATIVE, scrambled = TRUE, sequence = TRUE, exclude_monkey = TRUE, resilient = NONE)
	if(!has_dna())
		CRASH("[src] does not have DNA")
	var/list/mutations = list()
	if(quality & POSITIVE)
		mutations += GLOB.good_mutations
	if(quality & NEGATIVE)
		mutations += GLOB.bad_mutations
	if(quality & MINOR_NEGATIVE)
		mutations += GLOB.not_good_mutations
	var/list/possible = list()
	for(var/datum/mutation/human/A in mutations)
		if((!sequence || dna.mutation_in_sequence(A.type)) && !dna.get_mutation(A.type))
			possible += A.type
	if(exclude_monkey)
		possible.Remove(/datum/mutation/human/race)
	if(LAZYLEN(possible))
		var/mutation = pick(possible)
		. = dna.activate_mutation(mutation)
		if(scrambled)
			var/datum/mutation/human/HM = dna.get_mutation(mutation)
			if(HM)
				HM.scrambled = TRUE
				if(HM.quality & resilient)
					HM.mutadone_proof = TRUE
		return TRUE

/mob/living/carbon/proc/random_mutate_unique_identity()
	if(!has_dna())
		CRASH("[src] does not have DNA")
	var/num = rand(1, DNA_UNI_IDENTITY_BLOCKS)
	dna.set_uni_feature_block(num, random_string(GET_UI_BLOCK_LEN(num), GLOB.hex_characters))
	updateappearance(mutations_overlay_update=1)

/mob/living/carbon/proc/random_mutate_unique_features()
	if(!has_dna())
		CRASH("[src] does not have DNA")
	var/num = rand(1, DNA_FEATURE_BLOCKS)
	dna.set_uni_feature_block(num, random_string(GET_UF_BLOCK_LEN(num), GLOB.hex_characters))
	updateappearance(mutcolor_update = TRUE, mutations_overlay_update = TRUE)

/mob/living/carbon/proc/clean_dna()
	if(!has_dna())
		CRASH("[src] does not have DNA")
	dna.remove_all_mutations()

/mob/living/carbon/proc/clean_random_mutate(list/candidates, difficulty = 2)
	clean_dna()
	random_mutate(candidates, difficulty)

/proc/scramble_dna(mob/living/carbon/M, ui=FALSE, se=FALSE, uf=FALSE, probability)
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
		for(var/blocknum in 1 to DNA_UNI_IDENTITY_BLOCKS)
			if(prob(probability))
				M.dna.set_uni_feature_block(blocknum, random_string(GET_UI_BLOCK_LEN(blocknum), GLOB.hex_characters))
	if(uf)
		for(var/blocknum in 1 to DNA_FEATURE_BLOCKS)
			if(prob(probability))
				M.dna.set_uni_feature_block(blocknum, random_string(GET_UF_BLOCK_LEN(blocknum), GLOB.hex_characters))
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

/proc/get_uni_identity_block(identity, blocknum)
	return copytext(identity, GLOB.total_ui_len_by_block[blocknum], LAZYACCESS(GLOB.total_ui_len_by_block, blocknum+1))

/proc/get_uni_feature_block(features, blocknum)
	return copytext(features, GLOB.total_uf_len_by_block[blocknum], LAZYACCESS(GLOB.total_uf_len_by_block, blocknum+1))

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
