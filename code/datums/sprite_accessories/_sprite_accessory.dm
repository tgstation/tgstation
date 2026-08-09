/*
 *	Hello and welcome to sprite_accessories: For sprite accessories, such as hair,
 *	facial hair, and possibly tattoos and stuff somewhere along the line. This file is
 *	intended to be friendly for people with little to no actual coding experience.
 *	The process of adding in new hairstyles has been made pain-free and easy to do.
 *	Enjoy! - Doohl
 *
 *
 *	Notice: This all gets automatically compiled in a list in dna.dm, so you do not
 *	have to define any UI values for sprite accessories manually for hair and facial
 *	hair. Just add in new hair types and the game will naturally adapt.
 *
 *	!!WARNING!!: changing existing hair information can be VERY hazardous to savefiles,
 *	to the point where you may completely corrupt a server's savefiles. Please refrain
 *	from doing this unless you absolutely know what you are doing, and have defined a
 *	conversion in savefile.dm
 */

/datum/sprite_accessory
	/// The icon file the accessory is located in.
	var/icon
	/// The icon_state of the accessory.
	var/icon_state
	/// The preview name of the accessory.
	var/name
	/// Determines if the accessory will be skipped or included in random hair generations.
	var/gender = NEUTER
	/// Something that can be worn by either gender, but looks different on each.
	var/gender_specific = FALSE
	/// Determines if the accessory will be skipped by color preferences.
	var/use_static
	/**
	 * Currently only used by mutantparts so don't worry about hair and stuff.
	 * This is the source that this accessory will get its color from. Default is MUTCOLOR, but can also be HAIR, FACEHAIR, EYECOLOR and 0 if none.
	 */
	var/color_src = MUTANT_COLOR
	/// Is this part locked from roundstart selection? Used for parts that apply effects.
	var/locked = FALSE
	/// Should we center the sprite?
	var/center = FALSE
	/// The width of the sprite in pixels. Used to center it if necessary.
	var/dimension_x = 32
	/// The height of the sprite in pixels. Used to center it if necessary.
	var/dimension_y = 32
	/// Should this sprite block emissives?
	var/em_block = FALSE
	/// Determines if this is considered "sane" for the purpose of [/proc/randomize_human_normie]
	/// Basically this is to blacklist the extremely wacky stuff from being picked in random human generation.
	var/natural_spawn = TRUE

/datum/sprite_accessory/blank
	name = SPRITE_ACCESSORY_NONE
	icon_state = SPRITE_ACCESSORY_NONE

//////////.//////////////////
// MutantParts Definitions //
/////////////////////////////

/datum/sprite_accessory/caps
	icon = 'icons/mob/human/species/mush_cap.dmi'
	color_src = HAIR_COLOR
	em_block = TRUE

/datum/sprite_accessory/caps/round
	name = "Round"
	icon_state = "round"
