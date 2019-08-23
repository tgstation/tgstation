/datum/species/monthmen
	//an exotic species that arrives once a year to remove the worst species, mothpeople.
	name = "Monthman"
	id = "month"
	//visuals
	default_color = "FFFFFF"
	species_traits = list(NO_UNDERWEAR, NOBLOOD)
	default_features = list("mcolor" = "FFF", "tail_human" = "None", "ears" = "None", "wings" = "None")
	skinned_type = /obj/item/paper
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | ERT_SPAWN
	damage_overlay_type = "" //no blood
	//organs
	mutant_brain = /obj/item/organ/brain/monthmen
	mutanteyes = /obj/item/organ/eyes/monthmen
	mutanttongue = /obj/item/organ/tongue/monthmen
	mutantears = /obj/item/organ/ears/monthmen
	//other traits
	siemens_coeff = 0
	nojumpsuit = TRUE
	sexes = FALSE
	inherent_traits = list(TRAIT_NOHUNGER,TRAIT_NOBREATH)
	meat = /obj/item/paper

/datum/species/moth/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		return TRUE
	return FALSE

/datum/species/monthmen/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
	if(head)
		head.drop_limb()
		qdel(head)

/datum/species/monthmen/cloth/spec_life(mob/living/carbon/human/H)
	if(H.fire_stacks < 1)
		H.adjust_fire_stacks(1) //always prone to burning
	..()


//all the organs, just abstract copies
/obj/item/organ/brain/monthmen
	decoy_override = TRUE
	organ_flags = 0

/obj/item/organ/tongue/monthmen
	zone = "abstract"

/obj/item/organ/ears/monthmen
	zone = "abstract"

/obj/item/organ/eyes/monthmen
	name = "head vision"
	desc = "An abstraction."
	zone = "abstract"
