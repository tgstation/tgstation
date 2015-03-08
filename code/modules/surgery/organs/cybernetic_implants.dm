/obj/item/organ/cybernetic_implant
	name = "cybernetic implant"
	desc = "a state-of-the-art implant that improves a baseline's functionality"
	var/mob/owner = null

/obj/item/organ/cybernetic_implant/New(var/mob/M = null)
	if(M)
		owner = M
	return ..()

/obj/item/organ/cybernetic_implant/proc/function()
	return

/obj/item/organ/cybernetic_implant/eyes
	name = "cybernetic eyes"
	desc = "artificial photoreceptors with specialized functionality"
	icon_state = "eye_implant"
	var/eye_color = "fff"
	var/implant_color = "#FFFFFF"

/obj/item/organ/cybernetic_implant/eyes/New()
	var/icon/overlay = new /icon('icons/obj/surgery.dmi',"eye_implant_overlay")
	overlay.ColorTone(implant_color)
	overlays |= overlay
	..()

/obj/item/organ/cybernetic_implant/eyes/proc/update_eye_color()
	if(istype(owner,/mob/living/carbon/human))
		var/mob/living/carbon/human/HMN = owner
		HMN.eye_color = eye_color
		HMN.regenerate_icons()

/obj/item/organ/cybernetic_implant/eyes/medical_hud
	name = "medical hud implant"
	desc = "These cybernetic eyes will display a permanent medical HUD over everything you see. Wiggle eyes to control."
	icon_state = "eye_implant"
	eye_color = "0ff"
	implant_color = "#00FFFF"

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
	icon_state = "eye_implant"
	eye_color = "d00"
	implant_color = "#CC0000"

/obj/item/organ/cybernetic_implant/eyes/security_hud/function()
	if(!owner)
		return

	var/datum/atom_hud/H = huds[DATA_HUD_SECURITY_ADVANCED]
	H.add_hud_to(owner)
	owner.permanent_huds |= H

	update_eye_color()

/obj/item/organ/cybernetic_implant/eyes/xray
	name = "xray implant"
	desc = "These cybernetic eyes will enhance your vision with X-Ray. Blinking is futile."
	icon_state = "eye_implant"
	eye_color = "000"
	implant_color = "#000000"

/obj/item/organ/cybernetic_implant/eyes/xray/function()
	if(!owner)
		return

	owner.sight |= SEE_MOBS|SEE_OBJS|SEE_TURFS
	owner.see_in_dark = 8
	owner.permanent_sight_flags |= SEE_MOBS|SEE_OBJS|SEE_TURFS

	update_eye_color()