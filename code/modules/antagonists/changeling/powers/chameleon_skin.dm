/datum/action/changeling/chameleon_skin
	name = "Darkness Adaptation"
	desc = "Our skin pigmentation and eyes rapidly changes to suit the darkness. Needs 25 chemicals in-hand to toggle."
	helptext = "Allows us to darken and change the translucency of our pigmentation, and adapt our eyes to see in dark conditions, \
	The translucent effect works best in dark enviroments. Can be toggled on and off."
	button_icon_state = "chameleon_skin"
	dna_cost = 2
	chemical_cost = 25
	req_human = TRUE
	/////is ability active?
	var/is_active = FALSE

/datum/action/changeling/chameleon_skin/sting_action(mob/user)
	var/mob/living/carbon/human/cling = user //SHOULD always be human, because req_human = TRUE
	..()
	if(is_active == FALSE)
		animate(cling, alpha = 85,time = 3 SECONDS)
		cling.visible_message("
			span_warning("[cling]'s skin suddenly starts becoming translucent!",
			span_notice("We are now far more stealthy and better at seeing in the dark.",
		)
		animate(cling, color = COLOR_GRAY, time = 3 SECONDS) //darkens their overall appearance
		var/obj/item/organ/internal/eyes/eyes = cling.get_organ_by_type(/obj/item/organ/internal/eyes)
		eyes.lighting_cutoff = LIGHTING_CUTOFF_MEDIUM // Adds barely usable, kinda shit night vision
		eyes.flash_protect = max(eyes.flash_protect - 1, FLASH_PROTECTION_HYPER_SENSITIVE) //Reduces flash protection by one level.
		cling.update_sight()
		is_active = TRUE
	else
		disable_ability(cling)
		is_active = FALSE

/datum/action/changeling/chameleon_skin/Remove(mob/user)
	..()
	var/mob/living/carbon/human/cling = user
	disable_ability(cling)

/datum/action/changeling/chameleon_skin/proc/disable_ability(mob/living/carbon/human/cling) //Restores adaptation
	animate(cling, alpha = 255, time = 3 SECONDS)
	cling.visible_message(
		span_warning("[cling] appears from thin air!)",
		span_notice("We are now appearing normal and lost the ability to see in the dark."),
	)
	animate(cling, color = null, time = 3 SECONDS)
	var/obj/item/organ/internal/eyes/eyes = cling.get_organ_by_type(/obj/item/organ/internal/eyes)
	eyes.lighting_cutoff = LIGHTING_CUTOFF_VISIBLE
	eyes.flash_protect = max(eyes.flash_protect + 1, FLASH_PROTECTION_WELDER)
	cling.update_sight()
