/datum/surgery/maggot_removal
	name = "maggot removal"
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/remove_maggots,
		/datum/surgery_step/close
	)

	target_mobtypes = list(/mob/living/carbon/human)
	possible_locs = list(BODY_ZONE_HEAD)
	requires_bodypart_type = 0

/datum/surgery_step/remove_maggots
	name = "remove maggots"
	implements = list(/obj/item/hemostat = 85, TOOL_SCREWDRIVER = 35, /obj/item/pen = 15)
	time = 9 SECONDS

/datum/surgery/maggot_removal/can_start(mob/user, mob/living/carbon/target)
	if(target.stat != DEAD)
		return FALSE
	var/obj/item/organ/brain/B = target.getorganslot(ORGAN_SLOT_BRAIN)
	if(!B)
		return FALSE
	var/delta = world.time - B.maggots_timer
	return delta >= MAGGOTS_INFESTATION_LEVEL_1 && delta < MAGGOTS_INFESTATION_LEVEL_3

/datum/surgery_step/remove_maggots/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to remove the maggots from [target]'s brain.", "<span class='notice'>You begin to remove the maggots from [target]'s brain...</span>")

/datum/surgery_step/remove_maggots/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] successfully removes the maggots from [target]'s brain!", "<span class='notice'>You succeed in remove the maggots from [target]'s brain.</span>")
	var/obj/item/organ/brain/B = target.getorganslot(ORGAN_SLOT_BRAIN)
	if(B)
		B.maggots_timer = world.time
	return TRUE
