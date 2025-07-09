/// A singleton for handling block-unique functions called by the DNA datum.
/datum/dna_block
	/// The unique identifier of a block used for looking it up on a global list.
	/// Try to use strings inside defines for these
	var/block_id
	/// The length of this block when converted to ascii
	var/block_length = DNA_BLOCK_SIZE

/// Used to generate a unique block for set target.
/datum/dna_block/proc/get_unique_block(var/mob/living/carbon/human/target)
	if(!ishuman(target))
		CRASH("Non-human mobs shouldn't have DNA")

/// The position of this block in its respec
/datum/dna_block/proc/hash_position()
	return null

/datum/dna_block/proc/get_modified_block(old_hash, value)
	var/block_pos = hash_position()
	if(isnull(block_pos))
		return old_hash
	var/preceding_blocks = copytext(old_hash, 1, block_pos)
	var/succeeding_blocks = copytext(old_hash, block_pos + block_length)
	return (preceding_blocks + value + succeeding_blocks)

/datum/dna_block/proc/update_mob_appearance(var/mob/living/carbon/target)
	return

/// Blocks for unique identities (skin tones, hair style, and gender)
/datum/dna_block/identity

/datum/dna_block/identity/hash_position()
	return GLOB.total_ui_len_by_block[block_id]

/// Blocks for unique features (mutant color, mutant bodyparts)
/datum/dna_block/feature

/datum/dna_block/feature/hash_position()
	return GLOB.total_uf_len_by_block[block_id]

/datum/dna_block/feature/mutant_color
	block_id = DNA_UF_MUTANT_COLOR
