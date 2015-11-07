//SURGERY STEPS

/datum/surgery_step/saw/amputate
	name = "saw off limb"
	var/datum/organ/limb/L = null // L because "limb"

/datum/surgery_step/saw/amputate/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	L = surgery.organ.organdatum
	if(L && L.exists())
		user.visible_message("[user] begins to saw off [target]'s [parse_zone(user.zone_sel.selecting)].", "<span class ='notice'>You begin to saw off [target]'s [parse_zone(user.zone_sel.selecting)]...</span>")
	else
		user.visible_message("[user] looks for [target]'s [parse_zone(user.zone_sel.selecting)].", "<span class ='notice'>You look for [target]'s [parse_zone(user.zone_sel.selecting)]...</span>")

/datum/surgery_step/close/cleanstump
	name = "mend wound"
	var/datum/organ/limb/L = null // L because "limb"

/datum/surgery_step/close/cleanstump/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	L = target.getorgan(target_zone)
	user.visible_message("<span class='notice'>[user] begins to mend the wound in [target]'s [parse_zone(target_zone)].</span>")

//ACTUAL SURGERIES

/datum/surgery/amputation
	name = "amputation"
	requires_organic_bodypart = 0
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/replace, /datum/surgery_step/saw/amputate, /datum/surgery_step/close/cleanstump)
	species = list(/mob/living/carbon/human)	//For now
	possible_locs = list("r_arm","l_arm","r_leg","l_leg","head")

/datum/surgery/stumpcleanup
	name = "stump amputation"
	requires_organic_bodypart = 0
	steps = list(/datum/surgery_step/replace, /datum/surgery_step/saw, /datum/surgery_step/close/cleanstump)
	species = list(/mob/living/carbon/human)	//For now
	possible_locs = list("r_arm","l_arm","r_leg","l_leg","head")

/datum/surgery/stumpcleanup/can_start(mob/user, mob/living/carbon/target, datum/organ/organdata)
	if(organdata && ((organdata.status & ORGAN_DESTROYED) || (organdata.status & ORGAN_NOBLEED)))	//Stump cleanup can only be done if you, well, have a stump!
		return 1
	else return 0

//SURGERY STEP SUCCESSES

/datum/surgery_step/saw/amputate/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(L.exists())
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			user.visible_message("[user] successfully saws off [target]'s [parse_zone(target_zone)]!", "<span class='notice'>You successfully saw off [target]'s [parse_zone(target_zone)].</span>")
			H.organs -= L.organitem
			L.dismember(ORGAN_DESTROYED)
			H.update_damage_overlays(0)
			H.update_body_parts()
			add_logs(user, target, "amputated", addition="by removing his [parse_zone(target_zone)] INTENT: [uppertext(user.a_intent)]")
	else
		user << "<span class='warning'>[target] has no [parse_zone(target_zone)] there!</span>"
	return 1

/datum/surgery_step/close/cleanstump/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	L = target.getorgan(target_zone)
	L.status = ORGAN_REMOVED	//No more permadamage
	return 1