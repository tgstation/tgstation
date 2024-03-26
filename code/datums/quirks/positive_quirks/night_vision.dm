/datum/quirk/night_vision
	name = "Nightmare Vision"
	desc = "You purchased a grey-market night-vision augment from a sketchy back-alley vendor. No refunds."
	icon = FA_ICON_MOON
	value = 2
	gain_text = span_notice("You see things for what they truly are.")
	lose_text = span_danger("Everything seems a little less horrifying.")
	medical_record_text = "Patient's eyes show above-average acclimation to the horrors of working here."
	mail_goodies = list(
		/obj/item/flashlight/flashdark,
		/obj/item/food/grown/mushroom/glowshroom/shadowshroom,
		/obj/item/skillchip/light_remover,
	)

/datum/quirk/night_vision/add(client/client_source)
	var/mob/living/carbon/human/human_quirk_holder = quirk_holder
	var/obj/item/organ/internal/eyes/eyes = human_quirk_holder.get_organ_by_type(/obj/item/organ/internal/eyes)
	if(!eyes)
		return
	eyes.client_color_to_apply = /datum/client_colour/glass_colour/nightmare
	eyes.lighting_cutoff = LIGHTING_CUTOFF_FULLBRIGHT
	eyes.eye_color_left = "#FF0000"
	eyes.eye_color_right = "#FF0000"
	eyes.refresh()

/datum/quirk/night_vision/remove()
	var/mob/living/carbon/human/human_quirk_holder = quirk_holder
	var/obj/item/organ/internal/eyes/eyes = human_quirk_holder.get_organ_by_type(/obj/item/organ/internal/eyes)
	if(!eyes)
		return
	eyes.client_color_to_apply = initial(eyes.client_color_to_apply)
	eyes.lighting_cutoff = initial(eyes.lighting_cutoff)
	eyes.eye_color_left = initial(eyes.eye_color_left)
	eyes.eye_color_right = initial(eyes.eye_color_right)
	eyes.refresh()
