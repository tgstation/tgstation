/obj/item/organ/cyberimp/eyes/hud
	name = "cybernetic hud"
	desc = "artificial photoreceptors with specialized functionality"
	icon_state = "eye_implant"
	implant_overlay = "eye_implant_overlay"
	slot = "eye_sight"
	zone = "eyes"
	w_class = WEIGHT_CLASS_TINY

// HUD implants
/obj/item/organ/cyberimp/eyes/hud
	name = "HUD implant"
	desc = "These cybernetic eyes will display a HUD over everything you see. Maybe."
	slot = "eye_hud"
	var/HUD_type = 0

/obj/item/organ/cyberimp/eyes/hud/Insert(var/mob/living/carbon/M, var/special = 0)
	..()
	if(HUD_type)
		var/datum/atom_hud/H = huds[HUD_type]
		H.add_hud_to(M)
		M.permanent_huds |= H

/obj/item/organ/cyberimp/eyes/hud/Remove(var/mob/living/carbon/M, var/special = 0)
	if(HUD_type)
		var/datum/atom_hud/H = huds[HUD_type]
		M.permanent_huds ^= H
		H.remove_hud_from(M)
	..()

/obj/item/organ/cyberimp/eyes/hud/medical
	name = "Medical HUD implant"
	desc = "These cybernetic eye implants will display a medical HUD over everything you see."
	origin_tech = "materials=4;programming=4;biotech=4"
	HUD_type = DATA_HUD_MEDICAL_ADVANCED

/obj/item/organ/cyberimp/eyes/hud/security
	name = "Security HUD implant"
	desc = "These cybernetic eye implants will display a security HUD over everything you see."
	origin_tech = "materials=4;programming=4;biotech=3;combat=3"
	HUD_type = DATA_HUD_SECURITY_ADVANCED
