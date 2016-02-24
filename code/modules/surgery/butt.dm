//The proceeding is a minor surgery for anal cheek removal.
///////////////////////////////////////////////////////////
////                                      BUTT REMOVAL ////
///////////////////////////////////////////////////////////
/datum/surgery/extract_butt
	name = "butt extraction"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/saw, /datum/surgery_step/extract_butt, /datum/surgery_step/close)
	species = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list("groin")


//extract butt
/datum/surgery_step/extract_butt
	name = "extract butt"
	accept_hand = 1
	time = 64
	var/datum/organ/butt/A = null

/datum/surgery_step/extract_butt/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	A = target.get_organ("butt")
	if(A && A.exists())
		user.visible_message("<span class='notice'>[user] begins to extract [target]'s butt.</span>")
	else
		user.visible_message("<span class='notice'>[user] looks for [target]'s butt.</span>")

/datum/surgery_step/extract_butt/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(A && A.exists())
		user.visible_message("<span class='notice'>[user] successfully removes [target]'s butt!</span>")
		A.dismember(ORGAN_REMOVED)
//		A = new /obj/item/clothing/head/butt(get_turf(target))	//No more asshats until I can figure out how to make this work
		A.name = "[target.name]'s butt"

	else
		user.visible_message("<span class='notice'>[user] can't find [target]'s butt!</span>")
	return 1