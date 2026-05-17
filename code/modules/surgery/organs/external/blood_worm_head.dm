/obj/item/organ/blood_worm_head
	name = "blood worm head organ"
	zone = BODY_ZONE_HEAD
	bodypart_overlay = /datum/bodypart_overlay/mutant/blood_worm_head

/datum/sprite_accessory/blood_worm_head
	name = "blood worm sprite accessory"
	icon = 'icons/mob/human/blood_worm_features.dmi'
	icon_state = "blood_worm_head_overlay"

	color_src = FALSE


/datum/bodypart_overlay/mutant/blood_worm_head

	layers = EXTERNAL_FRONT|EXTERNAL_BEHIND
	var/default_appearance = "blood worm sprite accessory" // same as for xeno que


/datum/bodypart_overlay/mutant/blood_worm_head/New()
	. = ..()
	set_appearance_from_name(default_appearance)
