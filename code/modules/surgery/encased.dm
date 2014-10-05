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
		return affected.encased && affected.open >= 2


/datum/surgery_step/open_encased/saw
	allowed_tools = list(
	/obj/item/weapon/circular_saw = 100, \
	/obj/item/weapon/hatchet = 75
	)

	min_duration = 50
	max_duration = 70

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if (!hasorgans(target))
			return
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return ..() && affected.open == 2

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		if (!hasorgans(target))
			return
		var/datum/organ/external/affected = target.get_organ(target_zone)

		user.visible_message("[user] begins to cut through [target]'s [affected.encased] with \the [tool].", \
		"You begin to cut through [target]'s [affected.encased] with \the [tool].")
		target.custom_pain("Something hurts horribly in your [affected.display_name]!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		if (!hasorgans(target))
			return
		var/datum/organ/external/affected = target.get_organ(target_zone)

		user.visible_message("\blue [user] has cut [target]'s [affected.encased] open with \the [tool].",		\
		"\blue You have cut [target]'s [affected.encased] open with \the [tool].")
		affected.open = 2.5

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		if (!hasorgans(target))
			return
		var/datum/organ/external/affected = target.get_organ(target_zone)

		user.visible_message("\red [user]'s hand slips, cracking [target]'s [affected.encased] with \the [tool]!" , \
		"\red Your hand slips, cracking [target]'s [affected.encased] with \the [tool]!" )

		affected.createwound(CUT, 20)
		affected.fracture()


/datum/surgery_step/open_encased/retract
	allowed_tools = list(
	/obj/item/weapon/retractor = 100, 	\
	/obj/item/weapon/crowbar = 75,	\
	/obj/item/weapon/kitchen/utensil/fork = 20
	)

	min_duration = 30
	max_duration = 40

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if (!hasorgans(target))
			return
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return ..() && affected.open == 2.5

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		if (!hasorgans(target))
			return
		var/datum/organ/external/affected = target.get_organ(target_zone)

		var/msg = "[user] starts to force open the [affected.encased] in [target]'s [affected.display_name] with \the [tool]."
		var/self_msg = "You start to force open the [affected.encased] in [target]'s [affected.display_name] with \the [tool]."
		user.visible_message(msg, self_msg)
		target.custom_pain("Something hurts horribly in your [affected.display_name]!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		if (!hasorgans(target))
			return
		var/datum/organ/external/affected = target.get_organ(target_zone)

		var/msg = "\blue [user] forces open [target]'s [affected.encased] with \the [tool]."
		var/self_msg = "\blue You force open [target]'s [affected.encased] with \the [tool]."
		user.visible_message(msg, self_msg)

		affected.open = 3

		// Whoops!
		if(prob(10))
			affected.fracture()

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		if (!hasorgans(target))
			return
		var/datum/organ/external/affected = target.get_organ(target_zone)

		var/msg = "\red [user]'s hand slips, cracking [target]'s [affected.encased]!"
		var/self_msg = "\red Your hand slips, cracking [target]'s  [affected.encased]!"
		user.visible_message(msg, self_msg)

		affected.createwound(BRUISE, 20)
		affected.fracture()

/datum/surgery_step/open_encased/close
	allowed_tools = list(
	/obj/item/weapon/retractor = 100, 	\
	/obj/item/weapon/crowbar = 75,	\
	/obj/item/weapon/kitchen/utensil/fork = 20
	)

	min_duration = 20
	max_duration = 40

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		if (!hasorgans(target))
			return
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return ..() && affected.open == 3

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		if (!hasorgans(target))
			return
		var/datum/organ/external/affected = target.get_organ(target_zone)

		var/msg = "[user] starts bending [target]'s [affected.encased] back into place with \the [tool]."
		var/self_msg = "You start bending [target]'s [affected.encased] back into place with \the [tool]."
		user.visible_message(msg, self_msg)
		target.custom_pain("Something hurts horribly in your [affected.display_name]!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		if (!hasorgans(target))
			return
		var/datum/organ/external/affected = target.get_organ(target_zone)

		var/msg = "\blue [user] bends [target]'s [affected.encased] back into place with \the [tool]."
		var/self_msg = "\blue You bend [target]'s [affected.encased] back into place with \the [tool]."
		user.visible_message(msg, self_msg)

		affected.open = 2.5

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		if (!hasorgans(target))
			return
		var/datum/organ/external/affected = target.get_organ(target_zone)

		var/msg = "\red [user]'s hand slips, bending [target]'s [affected.encased] the wrong way!"
		var/self_msg = "\red Your hand slips, bending [target]'s [affected.encased] the wrong way!"
		user.visible_message(msg, self_msg)

		affected.createwound(BRUISE, 20)
		affected.fracture()

		/*if (prob(40)) //TODO: ORGAN REMOVAL UPDATE.
			user.visible_message("\red A rib pierces the lung!")
			target.rupture_lung()*/

/datum/surgery_step/open_encased/mend
	allowed_tools = list(
	/obj/item/weapon/bonegel = 100,	\
	/obj/item/weapon/screwdriver = 75
	)

	min_duration = 20
	max_duration = 40

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		if (!hasorgans(target))
			return
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return ..() && affected.open == 2.5

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		if (!hasorgans(target))
			return
		var/datum/organ/external/affected = target.get_organ(target_zone)

		var/msg = "[user] starts applying \the [tool] to [target]'s [affected.encased]."
		var/self_msg = "You start applying \the [tool] to [target]'s [affected.encased]."
		user.visible_message(msg, self_msg)
		target.custom_pain("Something hurts horribly in your [affected.display_name]!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		if (!hasorgans(target))
			return
		var/datum/organ/external/affected = target.get_organ(target_zone)

		var/msg = "\blue [user] applied \the [tool] to [target]'s [affected.encased]."
		var/self_msg = "\blue You applied \the [tool] to [target]'s [affected.encased]."
		user.visible_message(msg, self_msg)

		affected.open = 2