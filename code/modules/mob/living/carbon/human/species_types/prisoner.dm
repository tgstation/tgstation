/datum/species/prisoner
	name = "Prisoner Simulation"
	id = SPECIES_PRISONER
	sexes = FALSE
	inherent_traits = list(
		TRAIT_NEVER_WOUNDED,
		TRAIT_NOBLOOD,
		TRAIT_NOBREATH,
		TRAIT_NODISMEMBER,
		TRAIT_NOHUNGER,
		TRAIT_NO_UNDERWEAR,
		TRAIT_VIRUSIMMUNE,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_AGENDER
	)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	mutanttongue = /obj/item/organ/tongue/robot
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/prisoner,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/prisoner,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/prisoner,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/prisoner,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/prisoner,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/prisoner,
	)

/obj/item/bodypart/head/prisoner
	icon = 'icons/mob/human/species/prisoner/prisoner.dmi'
	icon_static = 'icons/mob/human/species/prisoner/prisoner.dmi'
	limb_id = SPECIES_PRISONER
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	head_flags = NONE
	teeth_count = 0

/obj/item/bodypart/chest/prisoner
	icon = 'icons/mob/human/species/prisoner/prisoner.dmi'
	icon_static = 'icons/mob/human/species/prisoner/prisoner.dmi'
	limb_id = SPECIES_PRISONER
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	wing_types = NONE

/obj/item/bodypart/arm/left/prisoner
	icon = 'icons/mob/human/species/prisoner/prisoner.dmi'
	icon_static = 'icons/mob/human/species/prisoner/prisoner.dmi'
	limb_id = SPECIES_PRISONER
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/right/prisoner
	icon = 'icons/mob/human/species/prisoner/prisoner.dmi'
	icon_static = 'icons/mob/human/species/prisoner/prisoner.dmi'
	limb_id = SPECIES_PRISONER
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/left/prisoner
	icon = 'icons/mob/human/species/prisoner/prisoner.dmi'
	icon_static = 'icons/mob/human/species/prisoner/prisoner.dmi'
	limb_id = SPECIES_PRISONER
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/right/prisoner
	icon = 'icons/mob/human/species/prisoner/prisoner.dmi'
	icon_static = 'icons/mob/human/species/prisoner/prisoner.dmi'
	limb_id = SPECIES_PRISONER
	should_draw_greyscale = FALSE

