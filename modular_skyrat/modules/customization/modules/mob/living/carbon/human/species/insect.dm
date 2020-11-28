/datum/species/insect
	name = "Anthromorphic Insect"
	id = "insect"
	default_color = "4B4B4B"
	species_traits = list(MUTCOLORS,EYECOLOR,LIPS,HAS_FLESH,HAS_BONE,HAIR,FACEHAIR)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_BUG
	mutant_bodyparts = list()
	default_mutant_bodyparts = list("tail" = "None", "snout" = "None", "horns" = "None", "ears" = "None", "legs" = "Normal Legs", "taur" = "None", "wings" = "Bee", "moth_antennae" = ACC_RANDOM)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	limbs_icon = 'modular_skyrat/modules/customization/icons/mob/species/insect_parts_greyscale.dmi'
