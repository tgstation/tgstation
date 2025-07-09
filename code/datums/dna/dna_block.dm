/// A singleton for handling block-unique functions called by the DNA datum.
/datum/dna_block
	/// The unique identifier of a block used for looking it up on a global list.
	/// Try to use strings inside defines for these
	var/block_id
	/// The length of this block when converted to ascii
	var/block_length = DNA_BLOCK_SIZE

/// Used to generate a unique block from the target.
/datum/dna_block/proc/unique_block(mob/living/carbon/human/target)
	if(!ishuman(target))
		CRASH("Non-human mobs shouldn't have DNA")

/// The position of this block's string in its hash type
/datum/dna_block/proc/position_in_hash()
	return null

/// Takes in the old hash and a string value to change this block to inside the hash.
/// Returns a new hash with block's value updated
/datum/dna_block/proc/modified_hash(old_hash, value)
	var/block_pos = position_in_hash()
	if(isnull(block_pos))
		return old_hash
	var/preceding_blocks = copytext(old_hash, 1, block_pos)
	var/succeeding_blocks = copytext(old_hash, block_pos + block_length)
	return (preceding_blocks + value + succeeding_blocks)

/// Gets the block string from the hash inserted
/datum/dna_block/proc/get_block(from_hash)
	var/block_pos = position_in_hash()
	return copytext(from_hash, block_pos, block_pos + block_length)

/// Applies the DNA effects/appearance that this block's string encodes
/datum/dna_block/proc/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	return

/// Blocks for unique identities (skin tones, hair style, and gender)
/datum/dna_block/identity

/datum/dna_block/identity/position_in_hash()
	return GLOB.total_ui_len_by_block[block_id]

/// Blocks for unique features (mutant color, mutant bodyparts)
/datum/dna_block/feature

/datum/dna_block/feature/position_in_hash()
	return GLOB.total_uf_len_by_block[block_id]

/datum/dna_block/feature/mutant_color
	block_id = DNA_UF_MUTANT_COLOR
