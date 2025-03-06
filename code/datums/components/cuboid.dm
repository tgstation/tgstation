/datum/component/cuboid
	///Rarity of the cube
	var/rarity = COMMON_CUBE
	/// Name of the cube's rarity
	var/rarity_name = "Common"

/datum/component/cuboid/Initialize(mapload, cube_rarity = COMMON_CUBE)
	/// Rarity
	src.rarity = cube_rarity
	/// Unless there's some way to have the defines ALSO have names w/ the numbers, this is the best I can get lol
	var/list/all_rarenames = list(
		span_bold("Common"),
		span_boldnicegreen("Uncommon"),
		span_boldnotice("Rare"),
		span_hierophant("Epic"),
		span_bolddanger("Legendary"),
		span_clown("Mythical")
		)
	/// We love indexes!!!
	src.rarity_name = all_rarenames[src.rarity]

/datum/component/cuboid/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(examine))

/datum/component/cuboid/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_EXAMINE
	))

/datum/component/cuboid/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	// I don't think an april fools PR is the place to make a helper for this so I'm just gonna use the indexes.
	// Also I'm pretty sure a helper wouldn't work because it's using spans.

	//!Note to self, figure out how to use HTML to make this have a unique little window
	var/a_an = "a"
	if(src.rarity == UNCOMMON_CUBE || src.rarity == EPIC_CUBE)
		a_an = "an"
	examine_list += "It's [a_an] [src.rarity_name] Cube!"
