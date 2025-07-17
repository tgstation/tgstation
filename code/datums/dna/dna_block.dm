// This DNA block system is by no means perfect, and individual (Especially feature) blocks still contain a lot of copypaste
// It might be worth abstracting these, and compacting all SSaccessories vars that use dna_blocks into a single keyed list
// That's out of scope for me refactoring DNA, but to be considered for a future atomic change

/// A singleton for handling block-unique functions called by the DNA datum.
///
/// You don't need to add a DNA block for every feature.
/// Only add a new one if you want this feature to be changed via genetics.
/datum/dna_block
	/// The length of this block when converted to ascii
	var/block_length = DNA_BLOCK_SIZE

/// Returns the unique block created from target. To be used for external calls.
///
/// Does extra checks to make sure target is valid before calling the internal
/// `create_unique_block`, don't override this.
/datum/dna_block/proc/unique_block(mob/living/carbon/human/target)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(!ishuman(target))
		CRASH("Non-human mobs shouldn't have DNA")
	return create_unique_block(target)

/// Actually creates the unique block from the inputted target.
/// Not used outside of the type, see `unique_block` instead.
///
/// Children should always override this.
/datum/dna_block/proc/create_unique_block(mob/living/carbon/human/target)
	PROTECTED_PROC(TRUE)
	return null

/// The position of this block's string in its hash type
/datum/dna_block/proc/position_in_hash()
	return null

/// Takes in the old hash and a string value to change this block to inside the hash.
///
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
	if(isnull(from_hash))
		CRASH("Null hash provided for getting dna block string")
	var/block_pos = position_in_hash()
	return copytext(from_hash, block_pos, block_pos + block_length)

/// Applies the DNA effects/appearance that this block's string encodes
/datum/dna_block/proc/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	return

/// Blocks for unique identities (skin tones, hair style, and gender)
/datum/dna_block/identity

/datum/dna_block/identity/position_in_hash()
	return GLOB.total_ui_len_by_block[type]

/// Blocks for unique features (mutant color, mutant bodyparts)
/datum/dna_block/feature
	/// The feature key this block ties in to.
	var/feature_key = null

/datum/dna_block/feature/position_in_hash()
	return GLOB.total_uf_len_by_block[type]
