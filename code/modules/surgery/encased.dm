//Procedures in this file: Generic ribcage opening steps, Removing alien embryo, Fixing internal organs.
//////////////////////////////////////////////////////////////////
//				GENERIC	RIBCAGE SURGERY							//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/open_encased
	priority = 2
	can_infect = 1
	blood_level = 1
	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		if (!hasorgans(target))
			return 0

		var/datum/organ/external/affected = target.get_organ(target_zone)
		return affected.encased && (affected.open >= 2 || (target.species.flags & NO_SKIN))



//////SAW///////
/datum/surgery_step/open_encased/saw
	allowed_tools = list(
		/obj/item/weapon/circular_saw = 100,
		/obj/item/weapon/kitchen/utensil/knife/large/butch = 75, \
		/obj/item/weapon/hatchet = 75,
		)

	min_duration = 50
	max_duration = 70

/datum/surgery_step/open_encased/saw/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return
	var/datum/organ/external/affected = target.get_organ(target_zone)
	return ..() && (affected.open == 2 || (target.species.flags & NO_SKIN))

/datum/surgery_step/open_encased/saw/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if (!hasorgans(target))
		return
	var/datum/organ/external/affected = target.get_organ(target_zone)

	user.visible_message("[user] begins to cut through [target]'s [affected.encased] with \the [tool].", \
	"You begin to cut through [target]'s [affected.encased] with \the [tool].")
	target.custom_pain("Something hurts horribly in your [affected.display_name]!",1)
	..()

/datum/surgery_step/open_encased/saw/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if (!hasorgans(target))
		return
	var/datum/organ/external/affected = target.get_organ(target_zone)

	user.visible_message("<span class='notice'>[user] has cut [target]'s [affected.encased] open with \the [tool].</span>",		\
	"<span class='notice'>You have cut [target]'s [affected.encased] open with \the [tool].</span>")
	affected.open = 2.5

/datum/surgery_step/open_encased/saw/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if (!hasorgans(target))
		return
	var/datum/organ/external/affected = target.get_organ(target_zone)

	user.visible_message("<span class='warning'>[user]'s hand slips, cracking [target]'s [affected.encased] with \the [tool]!</span>" , \
	"<span class='warning'>Your hand slips, cracking [target]'s [affected.encased] with \the [tool]!</span>" )

	affected.createwound(CUT, 20)
	affected.fracture()



///////RETRACT////////
/datum/surgery_step/open_encased/retract
	allowed_tools = list(
		/obj/item/weapon/retractor = 100,
		/obj/item/weapon/crowbar = 75,
		/obj/item/weapon/kitchen/utensil/fork = 20,
		)

	min_duration = 30
	max_duration = 40

/datum/surgery_step/open_encased/retract/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return
	var/datum/organ/external/affected = target.get_organ(target_zone)
	return ..() && affected.open == 2.5

/datum/surgery_step/open_encased/retract/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if (!hasorgans(target))
		return
	var/datum/organ/external/affected = target.get_organ(target_zone)

	var/msg = "[user] starts to force open the [affected.encased] in [target]'s [affected.display_name] with \the [tool]."
	var/self_msg = "You start to force open the [affected.encased] in [target]'s [affected.display_name] with \the [tool]."
	user.visible_message(msg, self_msg)
	target.custom_pain("Something hurts horribly in your [affected.display_name]!",1)
	..()

/datum/surgery_step/open_encased/retract/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if (!hasorgans(target))
		return
	var/datum/organ/external/affected = target.get_organ(target_zone)

	var/msg = "<span class='notice'>[user] forces open [target]'s [affected.encased] with \the [tool].</span>"
	var/self_msg = "<span class='notice'>You force open [target]'s [affected.encased] with \the [tool].</span>"
	user.visible_message(msg, self_msg)

	affected.open = 3

	// Whoops!
	if(prob(10))
		affected.fracture()

/datum/surgery_step/open_encased/retract/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if (!hasorgans(target))
		return
	var/datum/organ/external/affected = target.get_organ(target_zone)

	var/msg = "<span class='warning'>[user]'s hand slips, cracking [target]'s [affected.encased]!</span>"
	var/self_msg = "<span class='warning'>Your hand slips, cracking [target]'s  [affected.encased]!</span>"
	user.visible_message(msg, self_msg)

	affected.createwound(BRUISE, 20)
	affected.fracture()



////////CLOSE////////
/datum/surgery_step/open_encased/close
	allowed_tools = list(
		/obj/item/weapon/retractor = 100,
		/obj/item/weapon/crowbar = 75,
		/obj/item/weapon/kitchen/utensil/fork = 20,
		)

	min_duration = 20
	max_duration = 40

/datum/surgery_step/open_encased/close/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if (!hasorgans(target))
		return
	var/datum/organ/external/affected = target.get_organ(target_zone)
	return ..() && affected.open == 3

/datum/surgery_step/open_encased/close/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if (!hasorgans(target))
		return
	var/datum/organ/external/affected = target.get_organ(target_zone)

	var/msg = "[user] starts bending [target]'s [affected.encased] back into place with \the [tool]."
	var/self_msg = "You start bending [target]'s [affected.encased] back into place with \the [tool]."
	user.visible_message(msg, self_msg)
	target.custom_pain("Something hurts horribly in your [affected.display_name]!",1)
	..()

/datum/surgery_step/open_encased/close/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if (!hasorgans(target))
		return
	var/datum/organ/external/affected = target.get_organ(target_zone)

	var/msg = "<span class='notice'>[user] bends [target]'s [affected.encased] back into place with \the [tool].</span>"
	var/self_msg = "<span class='notice'>You bend [target]'s [affected.encased] back into place with \the [tool].</span>"
	user.visible_message(msg, self_msg)

	affected.open = 2.5

/datum/surgery_step/open_encased/close/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if (!hasorgans(target))
		return
	var/datum/organ/external/affected = target.get_organ(target_zone)

	var/msg = "<span class='warning'>[user]'s hand slips, bending [target]'s [affected.encased] the wrong way!</span>"
	var/self_msg = "<span class='warning'>Your hand slips, bending [target]'s [affected.encased] the wrong way!</span>"
	user.visible_message(msg, self_msg)

	affected.createwound(BRUISE, 20)
	affected.fracture()

	/*if (prob(40)) //TODO: ORGAN REMOVAL UPDATE.
		user.visible_message("<span class='warning'>A rib pierces the lung!")
		target.rupture_lung()*/



///////MEND///////
/datum/surgery_step/open_encased/mend
	allowed_tools = list(
		/obj/item/weapon/bonegel = 100,
		/obj/item/weapon/screwdriver = 75,
		)

	min_duration = 20
	max_duration = 40

/datum/surgery_step/open_encased/mend/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if (!hasorgans(target))
		return
	var/datum/organ/external/affected = target.get_organ(target_zone)
	return ..() && affected.open == 2.5

/datum/surgery_step/open_encased/mend/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if (!hasorgans(target))
		return
	var/datum/organ/external/affected = target.get_organ(target_zone)

	var/msg = "[user] starts applying \the [tool] to [target]'s [affected.encased]."
	var/self_msg = "You start applying \the [tool] to [target]'s [affected.encased]."
	user.visible_message(msg, self_msg)
	target.custom_pain("Something hurts horribly in your [affected.display_name]!",1)
	..()

/datum/surgery_step/open_encased/mend/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if (!hasorgans(target))
		return
	var/datum/organ/external/affected = target.get_organ(target_zone)

	var/msg = "<span class='notice'>[user] applied \the [tool] to [target]'s [affected.encased].</span>"
	var/self_msg = "<span class='notice'>You applied \the [tool] to [target]'s [affected.encased].</span>"
	user.visible_message(msg, self_msg)

	affected.open = 2
