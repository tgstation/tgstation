/obj/item/mcobject/messaging/hand_scanner
	name = "hand scanner component"
	base_icon_state = "comp_hscan"
	icon_state = "comp_hscan"

/obj/item/mcobject/messaging/hand_scanner/Initialize(mapload)
	. = ..()
	configs -= MC_CFG_OUTPUT_MESSAGE

/obj/item/mcobject/messaging/hand_scanner/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(!anchored)
		return
	if(!ishuman(user))
		to_chat(user, span_warning("The hand scanner may only be used by humanoids."))
		return

	var/mob/living/carbon/human/H = user
	add_fingerprint(H)
	//playsoundhere
	flick("comp_hscan1", src)
	fire(md5(H.dna.unique_identity))
	log_message("scanned [key_name(user)]", LOG_MECHCOMP)
	return TRUE

/obj/item/mcobject/messaging/hand_scanner/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!isclosedturf(target))
		return

	if(!user.dropItemToGround(src, silent = TRUE))
		return

	forceMove(target)
