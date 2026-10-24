#define LIZARD_ZOMBIE_COLOR "#508556" // slightly greyer than normal because lizard blood is green

/obj/item/bodypart/head/lizard
	icon_greyscale = 'icons/mob/human/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD
	is_dimorphic = FALSE
	head_flags = HEAD_LIPS|HEAD_EYESPRITES|HEAD_EYECOLOR|HEAD_EYEHOLES|HEAD_DEBRAIN
	// lizardshave many teeth
	teeth_count = 72
	zombie_color = LIZARD_ZOMBIE_COLOR

/obj/item/bodypart/chest/lizard
	icon_greyscale = 'icons/mob/human/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD
	is_dimorphic = TRUE
	wing_types = list(/obj/item/organ/wings/dragon)
	zombie_color = LIZARD_ZOMBIE_COLOR

/obj/item/bodypart/chest/lizard/get_butt_sprite()
	return icon('icons/mob/butts.dmi', BUTT_SPRITE_LIZARD)

/obj/item/bodypart/arm/left/lizard
	icon_greyscale = 'icons/mob/human/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD
	unarmed_attack_verbs = list("slash", "scratch", "claw")
	unarmed_attack_verbs = list("slashed", "scratched", "clawed")
	grappled_attack_verb = "lacerate"
	grappled_attack_verb_continuous = "lacerates"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/items/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'
	zombie_color = LIZARD_ZOMBIE_COLOR

/obj/item/bodypart/arm/right/lizard
	icon_greyscale = 'icons/mob/human/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD
	unarmed_attack_verbs = list("slash", "scratch", "claw")
	unarmed_attack_verbs = list("slashed", "scratched", "clawed")
	grappled_attack_verb = "lacerate"
	grappled_attack_verb_continuous = "lacerates"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/items/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'
	zombie_color = LIZARD_ZOMBIE_COLOR

/obj/item/bodypart/arm/left/lizard/ashwalker
	bodypart_traits = list(TRAIT_CHUNKYFINGERS)

/obj/item/bodypart/arm/right/lizard/ashwalker
	bodypart_traits = list(TRAIT_CHUNKYFINGERS)

/obj/item/bodypart/leg/left/lizard
	icon_greyscale = 'icons/mob/human/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD
	zombie_color = LIZARD_ZOMBIE_COLOR
	///If this leg is digitigrade regardless of owner
	var/always_digitigrade = FALSE

/obj/item/bodypart/leg/left/lizard/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/digitigrade_limb, "[initial(limb_id)]_[BODYPART_ID_DIGITIGRADE]", limb_id, always_digitigrade)
	RegisterSignal(src, SIGNAL_BODYPART_LEG_DIGITIGRADE_CHANGED, PROC_REF(on_digi_changed))

/obj/item/bodypart/leg/left/lizard/proc/on_digi_changed(datum/source, is_digi)
	SIGNAL_HANDLER
	footprint_sprite = is_digi ? FOOTPRINT_SPRITE_CLAWS : initial(footprint_sprite)
	footstep_type = is_digi ? FOOTSTEP_MOB_CLAW : initial(footstep_type)
	butcher_replacement = is_digi ? /obj/item/bodypart/leg/left/skeleton/nonfunctional/digitigrade : initial(butcher_replacement)

/obj/item/bodypart/leg/right/lizard
	icon_greyscale = 'icons/mob/human/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD
	zombie_color = LIZARD_ZOMBIE_COLOR
	///If this leg is digitigrade regardless of owner
	var/always_digitigrade = FALSE

/obj/item/bodypart/leg/right/lizard/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/digitigrade_limb, "[initial(limb_id)]_[BODYPART_ID_DIGITIGRADE]", limb_id, always_digitigrade)
	RegisterSignal(src, SIGNAL_BODYPART_LEG_DIGITIGRADE_CHANGED, PROC_REF(on_digi_changed))

/obj/item/bodypart/leg/right/lizard/proc/on_digi_changed(datum/source, is_digi)
	SIGNAL_HANDLER
	footprint_sprite = is_digi ? FOOTPRINT_SPRITE_CLAWS : initial(footprint_sprite)
	footstep_type = is_digi ? FOOTSTEP_MOB_CLAW : initial(footstep_type)
	butcher_replacement = is_digi ? /obj/item/bodypart/leg/right/skeleton/nonfunctional/digitigrade : initial(butcher_replacement)

///Printable from limb growers and forced on ashwalkers: the digitigrade version of lizard left legs that cannot be converted back to plantigrade on species change or dna manipulation.
/obj/item/bodypart/leg/left/lizard/digitigrade
	always_digitigrade = TRUE

///Printable from limb growers and forced on ashwalkers: the digitigrade version of lizard right legs that cannot be converted back to plantigrade on species change or dna manipulation.
/obj/item/bodypart/leg/right/lizard/digitigrade
	always_digitigrade = TRUE

#undef LIZARD_ZOMBIE_COLOR
