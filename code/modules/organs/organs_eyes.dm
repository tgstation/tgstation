/obj/item/organ/internal/eyes
	name = "eyes"
	desc = "Looks like you've caught someone's eye"
	hardpoint = "eyes"
	icon_state = "eye"
	var/sight_flags = 0
	var/eye_color = "fff"
//	var/old_eye_color = "fff"
	var/flash_protect = 0

/obj/item/organ/internal/eyes/set_dna(var/datum/dna/D)
	..(D)
	eye_color = dna.get_eye_color()

/obj/item/organ/internal/eyes/on_insertion(special = 0)
	owner.regenerate_icons()

/obj/item/organ/internal/eyes/Remove(special = 0)
	owner.regenerate_icons()

/obj/item/organ/internal/eyes/proc/get_img()
	var/state = "eyes"
	if(dna && dna.species)
		state = dna.species.eyes
	var/image/img_eyes_s = image("icon" = 'icons/mob/human_face.dmi', "icon_state" = "[state]_s", "layer" = -BODY_LAYER)
	img_eyes_s.color = "#" + eye_color
	return img_eyes_s

/obj/item/organ/internal/eyes/alien
	name = "alien eyes"
	eye_color = "83F52C"
	var/obj/effect/proc_holder/alien/nightvisiontoggle/power = null
	organtype = ORGAN_ALIEN


/obj/item/organ/internal/eyes/alien/New()
	power = new/obj/effect/proc_holder/alien/nightvisiontoggle(src)
	..()

/obj/item/organ/internal/eyes/alien/on_insertion(special = 0)
	..()
	owner.AddAbility(power)

/obj/item/organ/internal/eyes/alien/Remove(special = 0)
	..()
	owner.RemoveAbility(power)

/obj/item/organ/internal/eyes/cyberimp
	name = "cybernetic eyes"
	desc = "artificial photoreceptors with specialized functionality"
	icon_state = "eye_implant"
	var/implant_color = "#FFFFFF"
	var/implant_overlay = "eye_implant_overlay"
	slot = "eye_sight"
	zone = "eyes"
	w_class = 1

	var/aug_message = "Your vision is augmented!"

/obj/item/organ/internal/cyberimp/New(var/mob/M = null)
	if(iscarbon(M))
		src.Insert(M)
	if(implant_overlay)
		var/image/overlay = new /image(icon, implant_overlay)
		overlay.color = implant_color
		overlays |= overlay
	return ..()

/obj/item/organ/internal/eyes/cyberimp/on_life()
	..()
	owner.sight |= sight_flags

/obj/item/organ/internal/eyes/cyberimp/on_insertion(special = 0)
	..()
	if(aug_message && !special)
		owner << "<span class='notice'>[aug_message]</span>"
	owner.sight |= sight_flags
	return 1

/obj/item/organ/internal/eyes/cyberimp/Remove(var/special = 0)
	owner.sight ^= sight_flags
	..()

/obj/item/organ/internal/eyes/cyberimp/emp_act(severity)
	if(!owner)
		return
	if(severity > 1)
		if(prob(10 * severity))
			return
	var/save_sight = owner.sight
	owner.sight &= 0
	owner.disabilities |= BLIND
	owner << "<span class='warning'>Static obfuscates your vision!</span>"
	spawn(60 / severity)
		if(owner)
			owner.sight |= save_sight
			owner.disabilities ^= BLIND



/obj/item/organ/internal/eyes/cyberimp/xray
	name = "X-ray implant"
	desc = "These cybernetic eye implants will give you X-ray vision. Blinking is futile."
	eye_color = "000"
	implant_color = "#000000"
	origin_tech = "materials=6;programming=4;biotech=6;magnets=5"
	sight_flags = SEE_MOBS | SEE_OBJS | SEE_TURFS

/obj/item/organ/internal/eyes/cyberimp/thermals
	name = "Thermals implant"
	desc = "These cybernetic eye implants will give you Thermal vision. Vertical slit pupil included."
	eye_color = "FC0"
	implant_color = "#FFCC00"
	sight_flags = SEE_MOBS
	flash_protect = -1
	origin_tech = "materials=6;programming=4;biotech=5;magnets=5;syndicate=4"
	aug_message = "You see prey everywhere you look..."


// HUD implants
/obj/item/organ/internal/eyes/cyberimp/hud
	name = "HUD implant"
	desc = "These cybernetic eyes will display a HUD over everything you see. Maybe."
	slot = "eye_hud"
	var/HUD_type = 0

/obj/item/organ/internal/eyes/cyberimp/hud/on_insertion()
	..()
	if(HUD_type && owner)
		var/datum/atom_hud/H = huds[HUD_type]
		H.add_hud_to(owner)
		owner.permanent_huds |= H
	return

/obj/item/organ/internal/eyes/cyberimp/hud/Remove(var/special = 0)
	if(HUD_type)
		var/datum/atom_hud/H = huds[HUD_type]
		owner.permanent_huds ^= H
		H.remove_hud_from(owner)
	..()

/obj/item/organ/internal/eyes/cyberimp/hud/medical
	name = "Medical HUD implant"
	desc = "These cybernetic eye implants will display a medical HUD over everything you see."
	eye_color = "0ff"
	implant_color = "#00FFFF"
	origin_tech = "materials=4;programming=3;biotech=4"
	aug_message = "You suddenly see health bars floating above people's heads..."
	HUD_type = DATA_HUD_MEDICAL_ADVANCED

/obj/item/organ/internal/eyes/cyberimp/hud/security
	name = "Security HUD implant"
	desc = "These cybernetic eye implants will display a security HUD over everything you see."
	eye_color = "d00"
	implant_color = "#CC0000"
	origin_tech = "materials=4;programming=4;biotech=3;combat=1"
	aug_message = "Job indicator icons pop up in your vision. That is not a certified surgeon..."
	HUD_type = DATA_HUD_SECURITY_ADVANCED


// Welding shield implant
/obj/item/organ/internal/eyes/cyberimp/shield
	name = "welding shield implant"
	desc = "These reactive micro-shields will protect you from welders and flashes without obscuring your vision."
	slot = "eye_shield"
	origin_tech = "materials=4;biotech=3"
	implant_color = "#101010"
	flash_protect = 2
	aug_message = null
	eye_color = "fff"

/obj/item/organ/internal/eyes/cyberimp/shield/emp_act(severity)
	return