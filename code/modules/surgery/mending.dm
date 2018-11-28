/datum/surgery/mending
	name = "Mending"
	desc = "A surgical procedure that manually mends the patient's internal wounds."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/mend,
				/datum/surgery_step/close)

	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_CHEST)
	requires_bodypart_type = 0

/datum/surgery_step/mend
	name = "mend"
	implements = list(/obj/item/hemostat = 100, TOOL_SCREWDRIVER = 35, /obj/item/pen = 15)
	repeatable = TRUE
	time = 25

/datum/surgery_step/mend/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] starts mending some of [target]'s internal wounds.", "<span class='notice'>You start mending some of [target]'s internal wounds.</span>")

/datum/surgery_step/mend/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] fixes some of [target]'s internal wounds.", "<span class='notice'>You succeed in fixing some of [target]'s internal wounds.</span>")
	target.adjustInternalLoss(-20)
	return TRUE

/datum/surgery_step/mend/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] screws up!", "<span class='warning'>You screwed up!</span>")
	target.adjustInternalLoss(15,0)
	return FALSE