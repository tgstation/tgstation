/obj/item/bodypart/head/ethereal
	icon_greyscale = 'icons/mob/human/species/ethereal/bodyparts.dmi'
	limb_id = SPECIES_ETHEREAL
	is_dimorphic = FALSE
	dmg_overlay_type = null
	attack_type = BURN // bish buzz
	unarmed_attack_sound = 'sound/items/weapons/etherealhit.ogg'
	unarmed_miss_sound = 'sound/items/weapons/etherealmiss.ogg'
	brute_modifier = 1.25 //ethereal are weak to brute damage
	head_flags = HEAD_HAIR|HEAD_FACIAL_HAIR|HEAD_EYESPRITES|HEAD_EYEHOLES|HEAD_DEBRAIN

/obj/item/bodypart/head/ethereal/update_limb(dropping_limb, is_creating)
	. = ..()
	if(isethereal(owner))
		var/mob/living/carbon/human/potato_oc = owner
		var/datum/species/ethereal/eth_holder = potato_oc.dna.species
		species_color = eth_holder.current_color

/obj/item/bodypart/chest/ethereal
	icon_greyscale = 'icons/mob/human/species/ethereal/bodyparts.dmi'
	limb_id = SPECIES_ETHEREAL
	is_dimorphic = FALSE
	dmg_overlay_type = null
	brute_modifier = 1.25 //ethereal are weak to brute damages
	wing_types = null
	bodypart_traits = list(TRAIT_NO_UNDERWEAR)

/obj/item/bodypart/chest/ethereal/update_limb(dropping_limb, is_creating)
	. = ..()
	if(isethereal(owner))
		var/mob/living/carbon/human/potato_oc = owner
		var/datum/species/ethereal/eth_holder = potato_oc.dna.species
		species_color = eth_holder.current_color

/obj/item/bodypart/arm/left/ethereal
	icon_greyscale = 'icons/mob/human/species/ethereal/bodyparts.dmi'
	limb_id = SPECIES_ETHEREAL
	dmg_overlay_type = null
	attack_type = BURN //burn bish
	unarmed_attack_verbs = list("burn", "sear")
	unarmed_attack_verbs_continuous = list("burns", "sears")
	grappled_attack_verb = "scorch"
	grappled_attack_verb_continuous = "scorches"
	unarmed_attack_sound = 'sound/items/weapons/etherealhit.ogg'
	unarmed_miss_sound = 'sound/items/weapons/etherealmiss.ogg'
	brute_modifier = 1.25 //ethereal are weak to brute damage

/obj/item/bodypart/arm/left/ethereal/update_limb(dropping_limb, is_creating)
	. = ..()
	if(isethereal(owner))
		var/mob/living/carbon/human/potato_oc = owner
		var/datum/species/ethereal/eth_holder = potato_oc.dna.species
		species_color = eth_holder.current_color

/obj/item/bodypart/arm/right/ethereal
	icon_greyscale = 'icons/mob/human/species/ethereal/bodyparts.dmi'
	limb_id = SPECIES_ETHEREAL
	dmg_overlay_type = null
	attack_type = BURN // bish buzz
	unarmed_attack_verbs = list("burn", "sear")
	unarmed_attack_verbs_continuous = list("burns", "sears")
	grappled_attack_verb = "scorch"
	grappled_attack_verb_continuous = "scorches"
	unarmed_attack_sound = 'sound/items/weapons/etherealhit.ogg'
	unarmed_miss_sound = 'sound/items/weapons/etherealmiss.ogg'
	brute_modifier = 1.25 //ethereal are weak to brute damage

/obj/item/bodypart/arm/right/ethereal/update_limb(dropping_limb, is_creating)
	. = ..()
	if(isethereal(owner))
		var/mob/living/carbon/human/potato_oc = owner
		var/datum/species/ethereal/eth_holder = potato_oc.dna.species
		species_color = eth_holder.current_color

/obj/item/bodypart/leg/left/ethereal
	icon_greyscale = 'icons/mob/human/species/ethereal/bodyparts.dmi'
	limb_id = SPECIES_ETHEREAL
	dmg_overlay_type = null
	attack_type = BURN // bish buzz
	unarmed_attack_sound = 'sound/items/weapons/etherealhit.ogg'
	unarmed_miss_sound = 'sound/items/weapons/etherealmiss.ogg'
	brute_modifier = 1.25 //ethereal are weak to brute damage

/obj/item/bodypart/leg/left/ethereal/update_limb(dropping_limb, is_creating)
	. = ..()
	if(isethereal(owner))
		var/mob/living/carbon/human/potato_oc = owner
		var/datum/species/ethereal/eth_holder = potato_oc.dna.species
		species_color = eth_holder.current_color

/obj/item/bodypart/leg/right/ethereal
	icon_greyscale = 'icons/mob/human/species/ethereal/bodyparts.dmi'
	limb_id = SPECIES_ETHEREAL
	dmg_overlay_type = null
	attack_type = BURN // bish buzz
	unarmed_attack_sound = 'sound/items/weapons/etherealhit.ogg'
	unarmed_miss_sound = 'sound/items/weapons/etherealmiss.ogg'
	brute_modifier = 1.25 //ethereal are weak to brute damage

/obj/item/bodypart/leg/right/ethereal/update_limb(dropping_limb, is_creating)
	. = ..()
	if(isethereal(owner))
		var/mob/living/carbon/human/potato_oc = owner
		var/datum/species/ethereal/eth_holder = potato_oc.dna.species
		species_color = eth_holder.current_color

/obj/item/bodypart/head/ethereal/lustrous
	icon_state = "lustrous_head"
	limb_id = SPECIES_ETHEREAL_LUSTROUS
	head_flags = NONE
	teeth_count = 0 // bro you seen these thinsg. they got a crystal for a head aint no teeth here
