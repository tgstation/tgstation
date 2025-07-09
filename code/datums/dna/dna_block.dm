/// A singleton for handling block-unique functions called by the DNA datum.
/datum/dna_block
	/// The unique identifier of a block used for looking it up on a global list.
	/// Try to use strings inside defines for these
	var/block_id
	/// The length of this block when converted to ascii
	var/block_length = DNA_BLOCK_SIZE

/// Blocks for unique identities (skin tones, hair style, and gender)
/datum/dna_block/identity

/// Blocks for unique features (mutant color, mutant bodyparts)
/datum/dna_block/feature

/datum/dna_block/feature/mutant_color
	block_id = DNA_UF_MUTANT_COLOR
