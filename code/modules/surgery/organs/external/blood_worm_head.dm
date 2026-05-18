// external organ - blood worm head overlay
// gives no protection, nothing, except another people(or not) can recognize you

/obj/item/organ/blood_worm_head
	name = "blood worm head organ"
	zone = BODY_ZONE_HEAD
	slot = "blood_worm_head"
	visual = TRUE
	bodypart_overlay = /datum/bodypart_overlay/simple/blood_worm_head

/datum/bodypart_overlay/simple/blood_worm_head
	icon = 'icons/mob/human/blood_worm_features.dmi'
	icon_state = "blood_worm_head_overlay"
	layers = EXTERNAL_FRONT
	draw_on_husks = HUSK_OVERLAY_GRAYSCALE
