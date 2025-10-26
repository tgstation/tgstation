/obj/item/organ/cyberimp/eyes
	name = "cybernetic eye implant"
	desc = "Implants for your eyes."
	icon_state = "eye_implant"
	slot = ORGAN_SLOT_EYES
	zone = BODY_ZONE_PRECISE_EYES
	w_class = WEIGHT_CLASS_TINY

// HUD implants
/obj/item/organ/cyberimp/eyes/hud
	name = "HUD implant"
	desc = "These cybernetic eyes will display a HUD over everything you see. Maybe."
	slot = ORGAN_SLOT_HUD
	actions_types = list(/datum/action/item_action/organ_action/toggle_hud)
	var/HUD_traits = list()
	/// Whether the HUD implant is on or off
	var/toggled_on = TRUE
	/// Eyecolor from the HUD
	var/hud_color = "#3CB8A5"

/obj/item/organ/cyberimp/eyes/hud/Initialize(mapload)
	. = ..()
	if(toggled_on)
		for(var/hud_trait in HUD_traits)
			add_organ_trait(hud_trait)

/obj/item/organ/cyberimp/eyes/hud/proc/toggle_hud(mob/living/carbon/human/eye_owner)
	if(toggled_on)
		toggled_on = FALSE
		for(var/hud_trait in HUD_traits)
			remove_organ_trait(hud_trait)
		balloon_alert(eye_owner, "hud disabled")
		if(hud_color)
			eye_owner.remove_eye_color(EYE_COLOR_HUD_PRIORITY)
		return
	toggled_on = TRUE
	for(var/hud_trait in HUD_traits)
		add_organ_trait(hud_trait)
	balloon_alert(eye_owner, "hud enabled")
	if(hud_color)
		eye_owner.add_eye_color_right(hud_color, EYE_COLOR_HUD_PRIORITY)

/obj/item/organ/cyberimp/eyes/hud/on_mob_insert(mob/living/carbon/human/eye_owner, special = FALSE, movement_flags)
	. = ..()
	if(toggled_on && hud_color)
		eye_owner.add_eye_color_right(hud_color, EYE_COLOR_HUD_PRIORITY, !special)

/obj/item/organ/cyberimp/eyes/hud/on_mob_remove(mob/living/carbon/human/eye_owner, special, movement_flags)
	. = ..()
	if(toggled_on && hud_color)
		eye_owner.remove_eye_color(EYE_COLOR_HUD_PRIORITY, !special)

/obj/item/organ/cyberimp/eyes/hud/medical
	name = "medical HUD implant"
	desc = "These cybernetic eye implants will display a medical HUD over everything you see."
	icon_state = "eye_implant_medical"
	HUD_traits = list(TRAIT_MEDICAL_HUD)
	hud_color = "#1D8FEC"

/obj/item/organ/cyberimp/eyes/hud/security
	name = "security HUD implant"
	desc = "These cybernetic eye implants will display a security HUD over everything you see."
	icon_state = "eye_implant_security"
	HUD_traits = list(TRAIT_SECURITY_HUD)
	hud_color = "#9A151E"

/obj/item/organ/cyberimp/eyes/hud/diagnostic
	name = "diagnostic HUD implant"
	desc = "These cybernetic eye implants will display a diagnostic HUD over everything you see."
	icon_state = "eye_implant_diagnostic"
	HUD_traits = list(TRAIT_DIAGNOSTIC_HUD, TRAIT_BOT_PATH_HUD)
	hud_color = "#CC6E33"

/obj/item/organ/cyberimp/eyes/hud/security/syndicate
	name = "contraband security HUD implant"
	desc = "A Cybersun Industries brand Security HUD Implant. These illicit cybernetic eye implants will display a security HUD over everything you see."
	icon_state = "eye_implant_syndicate"
	organ_flags = ORGAN_ROBOTIC | ORGAN_HIDDEN
	hud_color = null
