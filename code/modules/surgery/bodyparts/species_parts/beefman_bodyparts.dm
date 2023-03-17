/obj/item/bodypart/head/beef
	icon = 'icons/mob/species/beefman/beefman_bodyparts.dmi'
	icon_greyscale = 'icons/mob/species/beefman/beefman_bodyparts.dmi'
	icon_static = 'icons/mob/species/beefman/beefman_bodyparts_robotic.dmi'
	limb_id = SPECIES_BEEFMAN
	is_dimorphic = FALSE
	icon_state = "beefman_head"

/obj/item/bodypart/chest/beef
	icon = 'icons/mob/species/beefman/beefman_bodyparts.dmi'
	icon_greyscale = 'icons/mob/species/beefman/beefman_bodyparts.dmi'
	icon_static = 'icons/mob/species/beefman/beefman_bodyparts_robotic.dmi'
	limb_id = SPECIES_BEEFMAN
	is_dimorphic = FALSE
	icon_state = "beefman_chest"

/obj/item/bodypart/arm/right/beef
	icon = 'icons/mob/species/beefman/beefman_bodyparts.dmi'
	icon_greyscale = 'icons/mob/species/beefman/beefman_bodyparts.dmi'
	icon_static = 'icons/mob/species/beefman/beefman_bodyparts_robotic.dmi'
	unarmed_attack_sound = 'sound/voice/beefman/beef_hit.ogg'
	unarmed_attack_verb = "meat"
	unarmed_damage_low = 1
	unarmed_damage_high = 5
	limb_id = SPECIES_BEEFMAN
	icon_state = "beefman_r_arm"

/obj/item/bodypart/arm/right/beef/drop_limb(special)
	var/mob/living/carbon/owner_cache = owner
	..()
	if(special)
		return
	var/obj/item/food/meat/slab/new_meat = drop_meat(owner_cache)
	qdel(src)
	return new_meat

/obj/item/bodypart/arm/left/beef
	icon = 'icons/mob/species/beefman/beefman_bodyparts.dmi'
	icon_greyscale = 'icons/mob/species/beefman/beefman_bodyparts.dmi'
	icon_static = 'icons/mob/species/beefman/beefman_bodyparts_robotic.dmi'
	unarmed_attack_sound = 'sound/voice/beefman/beef_hit.ogg'
	unarmed_attack_verb = "meat"
	unarmed_damage_low = 1
	unarmed_damage_high = 5
	limb_id = SPECIES_BEEFMAN
	icon_state = "beefman_l_arm"

/obj/item/bodypart/arm/left/beef/drop_limb(special)
	var/mob/living/carbon/owner_cache = owner
	..()
	if(special)
		return
	var/obj/item/food/meat/slab/new_meat = drop_meat(owner_cache, TRUE)
	qdel(src)
	return new_meat

/obj/item/bodypart/leg/right/beef
	icon = 'icons/mob/species/beefman/beefman_bodyparts.dmi'
	icon_greyscale = 'icons/mob/species/beefman/beefman_bodyparts.dmi'
	icon_static = 'icons/mob/species/beefman/beefman_bodyparts_robotic.dmi'
	limb_id = SPECIES_BEEFMAN
	icon_state = "beefman_r_leg"

/obj/item/bodypart/leg/right/beef/drop_limb(special)
	var/mob/living/carbon/owner_cache = owner
	..()
	if(special)
		return
	var/obj/item/food/meat/slab/new_meat = drop_meat(owner_cache, TRUE)
	qdel(src)
	return new_meat

/obj/item/bodypart/leg/left/beef
	icon = 'icons/mob/species/beefman/beefman_bodyparts.dmi'
	icon_greyscale = 'icons/mob/species/beefman/beefman_bodyparts.dmi'
	icon_static = 'icons/mob/species/beefman/beefman_bodyparts_robotic.dmi'
	limb_id = SPECIES_BEEFMAN
	icon_state = "beefman_l_leg"

/obj/item/bodypart/leg/left/beef/drop_limb(special)
	var/mob/living/carbon/owner_cache = owner
	..()
	if(special)
		return
	var/obj/item/food/meat/slab/new_meat = drop_meat(owner_cache, TRUE)
	qdel(src)
	return new_meat
