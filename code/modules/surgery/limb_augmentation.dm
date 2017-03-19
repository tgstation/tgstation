
/////AUGMENTATION SURGERIES//////


//SURGERY STEPS

/datum/surgery_step/replace
	name = "sever muscles"
	implements = list(/obj/item/weapon/scalpel = 100, /obj/item/weapon/wirecutters = 55)
	time = 32


/datum/surgery_step/replace/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[IDENTITY_SUBJECT(1)] begins to sever the muscles on [IDENTITY_SUBJECT(2)]'s [parse_zone(user.zone_selected)].", "<span class ='notice'>You begin to sever the muscles on [IDENTITY_SUBJECT(2)]'s [parse_zone(user.zone_selected)]...</span>", subjects=list(user, target))


/datum/surgery_step/add_limb
	name = "replace limb"
	implements = list(/obj/item/bodypart = 100)
	time = 32
	var/obj/item/bodypart/L = null // L because "limb"


/datum/surgery_step/add_limb/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/bodypart/aug = tool
	if(aug.status != BODYPART_ROBOTIC)
		to_chat(user, "<span class='warning'>that's not an augment silly!</span>")
		return -1
	if(aug.body_zone != target_zone)
		to_chat(user, "<span class='warning'>[tool] isn't the right type for [parse_zone(target_zone)].</span>")
		return -1
	L = surgery.operated_bodypart
	if(L)
		user.visible_message("[IDENTITY_SUBJECT(1)] begins to augment [IDENTITY_SUBJECT(2)]'s [parse_zone(user.zone_selected)].", "<span class ='notice'>You begin to augment [IDENTITY_SUBJECT(2)]'s [parse_zone(user.zone_selected)]...</span>", subjects=list(user, target))
	else
		user.visible_message("[IDENTITY_SUBJECT(1)] looks for [IDENTITY_SUBJECT(2)]'s [parse_zone(user.zone_selected)].", "<span class ='notice'>You look for [IDENTITY_SUBJECT(2)]'s [parse_zone(user.zone_selected)]...</span>", subjects=list(user, target))


//ACTUAL SURGERIES

/datum/surgery/augmentation
	name = "augmentation"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/replace, /datum/surgery_step/saw, /datum/surgery_step/add_limb)
	species = list(/mob/living/carbon/human)
	possible_locs = list("r_arm","l_arm","r_leg","l_leg","chest","head")

//SURGERY STEP SUCCESSES

/datum/surgery_step/add_limb/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(L)
		user.visible_message("[IDENTITY_SUBJECT(1)] successfully augments [IDENTITY_SUBJECT(2)]'s [parse_zone(target_zone)]!", "<span class='notice'>You successfully augment [IDENTITY_SUBJECT(2)]'s [parse_zone(target_zone)].</span>", subjects=list(user, target))
		L.change_bodypart_status(BODYPART_ROBOTIC, 1)
		user.drop_item()
		qdel(tool)
		target.update_damage_overlays()
		target.updatehealth()
		add_logs(user, target, "augmented", addition="by giving him new [parse_zone(target_zone)] INTENT: [uppertext(user.a_intent)]")
	else
		to_chat(user, "<span class='warning'>[IDENTITY_SUBJECT(1)] has no organic [parse_zone(target_zone)] there!</span>", list(target))
	return 1