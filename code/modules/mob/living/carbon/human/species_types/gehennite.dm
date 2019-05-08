/datum/species/gehennite
	name = "Gehennite"
	burnmod = 1.2
	heatmod = 1.2
	id = "gehennite"
	no_equip = list(SLOT_GLASSES)
	inherent_traits = list(TRAIT_RESISTCOLD,TRAIT_RESISTLOWPRESSURE)
	species_traits = list(DIGITIGRADE, NOEYESPRITES)
	mutantears = /obj/item/organ/ears/gehennite
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	special_step_sounds = list('sound/effects/footstep/gehennite.ogg')


/datum/species/gehennite/qualifies_for_rank(rank, list/features)
	if(rank in GLOB.security_positions)
		return FALSE
	return ..()

/datum/species/gehennite/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.become_blind(ROUNDSTART_TRAIT)
	H.clear_fullscreen("blind")

/datum/species/gehennite/on_species_loss(mob/living/carbon/human/H)
	.=..()
	H.clear_fullscreen("echo")
	H.cure_blind(ROUNDSTART_TRAIT)