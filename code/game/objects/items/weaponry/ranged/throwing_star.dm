/obj/item/throwing_star
	name = "throwing star"
	desc = "An ancient weapon still used to this day, due to its ease of lodging itself into its victim's body parts."
	icon = 'icons/obj/weapons/thrown.dmi'
	icon_state = "throwingstar"
	inhand_icon_state = "eshield"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	force = 2
	throwforce = 10 //10 + 2 (WEIGHT_CLASS_SMALL) * 4 (EMBEDDED_IMPACT_PAIN_MULTIPLIER) = 18 damage on hit due to guaranteed embedding
	throw_speed = 4
	embed_type = /datum/embedding/throwing_star
	armour_penetration = 40
	mob_throw_hit_sound = 'sound/items/weapons/pierce.ogg'
	hitsound = 'sound/items/weapons/bladeslice.ogg'

	w_class = WEIGHT_CLASS_SMALL
	sharpness = SHARP_POINTY
	custom_materials = list(/datum/material/iron= SMALL_MATERIAL_AMOUNT * 5, /datum/material/glass= SMALL_MATERIAL_AMOUNT * 5)
	resistance_flags = FIRE_PROOF

/datum/embedding/throwing_star
	pain_mult = 4
	embed_chance = 100
	fall_chance = 0

/obj/item/throwing_star/stamina
	name = "shock throwing star"
	desc = "An aerodynamic disc designed to cause excruciating pain when stuck inside fleeing targets, hopefully without causing fatal harm."
	throwforce = 5
	embed_type = /datum/embedding/throwing_star/stamina

/datum/embedding/throwing_star/stamina
	pain_mult = 5
	jostle_chance = 10
	pain_stam_pct = 0.8
	jostle_pain_mult = 3

/obj/item/throwing_star/toy
	name = "toy throwing star"
	desc = "An aerodynamic disc strapped with adhesive for sticking to people, good for playing pranks and getting yourself killed by security."
	sharpness = NONE
	force = 0
	throwforce = 0
	embed_type = /datum/embedding/throwing_star/toy

/datum/embedding/throwing_star/toy
	pain_mult = 0
	jostle_pain_mult = 0

//Ninja throwing stars are located in the ninja mod modules
