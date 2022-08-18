/obj/item/bodypart/head/ethereal
	icon_greyscale = 'icons/mob/humanoid/ethereal/bodyparts.dmi'
	limb_id = SPECIES_ETHEREAL
	is_dimorphic = FALSE

/obj/item/bodypart/head/ethereal/update_limb(dropping_limb, is_creating)
	. = ..()
	if(isethereal(owner))
		var/mob/living/carbon/human/potato_oc = owner
		var/datum/species/ethereal/eth_holder = potato_oc.dna.species
		species_color = eth_holder.current_color

/obj/item/bodypart/chest/ethereal
	icon_greyscale = 'icons/mob/humanoid/ethereal/bodyparts.dmi'
	limb_id = SPECIES_ETHEREAL
	is_dimorphic = FALSE

/obj/item/bodypart/chest/ethereal/update_limb(dropping_limb, is_creating)
	. = ..()
	if(isethereal(owner))
		var/mob/living/carbon/human/potato_oc = owner
		var/datum/species/ethereal/eth_holder = potato_oc.dna.species
		species_color = eth_holder.current_color

/obj/item/bodypart/l_arm/ethereal
	icon_greyscale = 'icons/mob/humanoid/ethereal/bodyparts.dmi'
	limb_id = SPECIES_ETHEREAL

/obj/item/bodypart/l_arm/ethereal/update_limb(dropping_limb, is_creating)
	. = ..()
	if(isethereal(owner))
		var/mob/living/carbon/human/potato_oc = owner
		var/datum/species/ethereal/eth_holder = potato_oc.dna.species
		species_color = eth_holder.current_color

/obj/item/bodypart/r_arm/ethereal
	icon_greyscale = 'icons/mob/humanoid/ethereal/bodyparts.dmi'
	limb_id = SPECIES_ETHEREAL

/obj/item/bodypart/r_arm/ethereal/update_limb(dropping_limb, is_creating)
	. = ..()
	if(isethereal(owner))
		var/mob/living/carbon/human/potato_oc = owner
		var/datum/species/ethereal/eth_holder = potato_oc.dna.species
		species_color = eth_holder.current_color


/obj/item/bodypart/l_leg/ethereal
	icon_greyscale = 'icons/mob/humanoid/ethereal/bodyparts.dmi'
	limb_id = SPECIES_ETHEREAL

/obj/item/bodypart/l_leg/ethereal/update_limb(dropping_limb, is_creating)
	. = ..()
	if(isethereal(owner))
		var/mob/living/carbon/human/potato_oc = owner
		var/datum/species/ethereal/eth_holder = potato_oc.dna.species
		species_color = eth_holder.current_color

/obj/item/bodypart/r_leg/ethereal
	icon_greyscale = 'icons/mob/humanoid/ethereal/bodyparts.dmi'
	limb_id = SPECIES_ETHEREAL

/obj/item/bodypart/r_leg/ethereal/update_limb(dropping_limb, is_creating)
	. = ..()
	if(isethereal(owner))
		var/mob/living/carbon/human/potato_oc = owner
		var/datum/species/ethereal/eth_holder = potato_oc.dna.species
		species_color = eth_holder.current_color
