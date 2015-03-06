/obj/item/organ/cybernetic_implant
	name = "cybernetic implant"
	desc = "a state-of-the-art implant that improves a baseline's functionality"
	var/mob/owner = null

/obj/item/organ/cybernetic_implant/proc/function()
	return

/obj/item/organ/cybernetic_implant/eyes
	name = "cybernetic eyes"
	desc = "artificial photoreceptors with specialized functionality"
	icon_state = "hudeye"
	var/eye_color = "fff"

/obj/item/organ/cybernetic_implant/eyes/proc/update_eye_color()
	if(istype(owner,/mob/living/carbon/human))
		var/mob/living/carbon/human/HMN = owner
		HMN.eye_color = eye_color
		HMN.regenerate_icons()

/obj/item/organ/cybernetic_implant/eyes/medical_hud
	name = "medical hud implant"
	desc = "These cybernetic eyes will display a permanent medical HUD over everything you see. Wiggle eyes to control."
	icon_state = "hudeye"
	eye_color = "0ff"

/obj/item/organ/cybernetic_implant/eyes/medical_hud/function()
	if(!owner)
		return

	var/datum/atom_hud/H = huds[DATA_HUD_MEDICAL_ADVANCED]
	H.add_hud_to(owner)
	owner.permanent_huds |= H

	update_eye_color()

/obj/item/organ/cybernetic_implant/eyes/security_hud
	name = "security hud implant"
	desc = "These cybernetic eyes will display a permanent security HUD over everything you see. Wiggle eyes to control."
	icon_state = "hudeye"
	eye_color = "b00"

/obj/item/organ/cybernetic_implant/eyes/security_hud/function()
	if(!owner)
		return

	var/datum/atom_hud/H = huds[DATA_HUD_SECURITY_ADVANCED]
	H.add_hud_to(owner)
	owner.permanent_huds |= H

	update_eye_color()