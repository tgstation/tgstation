/obj/item/organ/blood_worm_head
	name = "blood worm head organ"
	zone = BODY_ZONE_HEAD

	slot = "blood_worm_head" // i am not sure


	visual = TRUE // more sure

	bodypart_overlay = /datum/bodypart_overlay/mutant/blood_worm_head

/datum/sprite_accessory/blood_worm_head
	name = "blood_worm_head"
	icon = 'icons/mob/human/blood_worm_features.dmi'
	icon_state = "blood_worm_head_overlay"

	color_src = FALSE

	gender_specific = FALSE // maybe

/datum/sprite_accessory/blood_worm_head/default
	name = "blood_worm_head"
	icon = 'icons/mob/human/blood_worm_features.dmi'


/datum/bodypart_overlay/mutant/blood_worm_head

	// name = "blood worm head overlay"

	// sprite_datum = /datum/sprite_accessory/blood_worm_head // OK
	feature_key = FEATURE_BLOOD_WORM_HEAD // forgot this
	layers = EXTERNAL_FRONT|EXTERNAL_BEHIND
	imprint_on_next_insertion = FALSE // i think its need to be FALSE cause worms dont have DNA?
	var/default_appearance = "blood_worm_head" // same as for xeno que


/datum/bodypart_overlay/mutant/blood_worm_head/New()
	. = ..()
	set_appearance(/datum/sprite_accessory/blood_worm_head)
