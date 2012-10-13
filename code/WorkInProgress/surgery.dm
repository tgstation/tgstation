/datum/surgery_step
	// type path referencing the required tool for this step
	var/required_tool = null

	// When multiple steps can be applied with the current tool etc., choose the one with higher priority

	// checks whether this step can be applied with the given user and target
	proc/can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return 0

	// does stuff to begin the step, usually just printing messages
	proc/begin_step(user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return

	// does stuff to end the step, which is normally print a message + do whatever this step changes
	proc/end_step(user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return

	// stuff that happens when the step fails
	proc/fail_step(user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return null

	// duration of the step
	var/min_duration = 0
	var/max_duration = 0

	// evil infection stuff that will make everyone hate me
	var/can_infect = 0

// Build this list by iterating over all typesof(/datum/surgery_step) and sorting the results by priority
var/global/list/surgery_steps = null

proc/build_surgery_steps_list()
	surgery_steps = list()
	for(var/T in typesof(/datum/surgery_step)-/datum/surgery_step)
		var/datum/surgery_step/S = new T
		surgery_steps += S

/* SURGERY STEPS */

/datum/surgery_step/cut_open
	required_tool = /obj/item/weapon/scalpel

	min_duration = 90
	max_duration = 110

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return affected.open == 0

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts cutting open [target]'s [target_zone] with \the [tool]", \
		"You start cutting open [user]'s [target_zone] with \the [tool]")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] cuts open [target]'s [affected.display_name] with \the [tool]", \
		"\blue You cut open [user]'s [affected.display_name] with \the [tool]")
		affected.open = 1
		affected.createwound(CUT, 1)

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, slicing open [target]'s [affected.display_name] in wrong spot  with \the [tool]!", \
		"\red Your hand slips, slicing open [user]'s [affected.display_name] in wrong spot with \the [tool]!")
		affected.createwound(CUT, 10)

/datum/surgery_step/clamp_bleeders
	required_tool = /obj/item/weapon/hemostat

	min_duration = 40
	max_duration = 60

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return affected.open && (affected.status & ORGAN_BLEEDING)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts clamping bleeders in the wound in [target]'s [target_zone] with \the [tool]", \
		"You start clamping bleeders in the wound in [user]'s [target_zone] with \the [tool]")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] clapms bleeders in the wound in [target]'s [affected.display_name] with \the [tool]",	\
		"\blue You clapm bleeders in [user]'s [affected.display_name] with \the [tool]")
		affected.open = 1
		//Can't directly set status to not bleeding, or next organ damage update will just revert it.
		for(var/datum/wound/W in affected.wounds)
			W.bandaged = 1

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, tearing blood vessels in the wound in [target]'s [affected.display_name] with \the [tool]!", \
		"\red Your hand slips, tearing blood vessels in the wound in [affected.display_name] with \the [tool]!")
		target.apply_damage(5, BRUTE, affected)

/datum/surgery_step/retract_skin
	required_tool = /obj/item/weapon/retractor

	min_duration = 30
	max_duration = 40

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return affected.open && !(affected.status & ORGAN_BLEEDING)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts retracting flap of skin in the wound in [target]'s [target_zone] with \the [tool]", \
		"You starts retracting flap of skin in the wound in [user]'s [target_zone] with \the [tool]")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] retracts flap of skin in the wound in [target]'s [affected.display_name] with \the [tool]", \
		"\blue You retract flap of skin in the wound in [user]'s [affected.display_name] with \the [tool]")
		affected.open = 2

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, tearing skin flap in the wound in [target]'s [affected.display_name] with \the [tool]!", \
		"\red Your hand slips, tearing skin flap in the wound in [user]'s [affected.display_name] with \the [tool]!")
		target.apply_damage(4, BRUTE, affected)

/datum/surgery_step/cautherize
	required_tool = /obj/item/weapon/cautery

	min_duration = 70
	max_duration = 100

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return affected.open

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] is beginning to cauterize the incision in [target]'s [target_zone] with \the [tool]", \
		"You are beginning to cauterize the incision in [user]'s [target_zone] with \the [tool]")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] cauterizes the incision in [target]'s [affected.display_name] with \the [tool]", \
		"\blue You cauterize the incision in [user]'s [affected.display_name] with \the [tool]")
		affected.open = 0
		affected.status &= ~ORGAN_BLEEDING

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, leaving small burn on [target]'s [affected.display_name] with \the [tool]!", \
		"\red Your hand slips, leaving small burn on [user]'s [affected.display_name] with \the [tool]!")
		target.apply_damage(3, BURN, affected)

/datum/surgery_step/cut_appendix
	required_tool = /obj/item/weapon/scalpel

	min_duration = 70
	max_duration = 90

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/groin = target.get_organ("groin")
		return target_zone == "groin" && groin.open == 2 && !(/datum/disease/appendicitis/ in target.resistances)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts cutting out [target]'s appendix with \the [tool]", \
		"You start cutting out [user]'s appendix with \the [tool]")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] cuts out [target]'s appendix with \the [tool]", \
		"\blue You cut out [user]'s appendix with \the [tool]")

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, slicing artery inside [target]'s abdomen with \the [tool]!", \
		"\red Your hand slips, slicing artery inside [target]'s abdomen with \the [tool]!")
		affected.createwound(CUT, 50)

/datum/surgery_step/remove_appendix
	required_tool = /obj/item/weapon/hemostat

	min_duration = 60
	max_duration = 80

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/groin = target.get_organ("groin")
		return target_zone == "groin" && groin.open == 2

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts removing [target]'s appendix with \the [tool]", \
		"You removing [user]'s appendix with \the [tool]")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] removes [target]'s appendix with \the [tool]", \
		"\blue You remove [user]'s appendix with \the [tool]")
		for(var/datum/disease/appendicitis/appendicitis in target.viruses)
			new /obj/item/weapon/reagent_containers/food/snacks/appendix/inflamed(get_turf(target))
			appendicitis.cure()
			target.resistances += appendicitis

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, hitting internal organs in [target]'s abdomen with \the [tool]!", \
		"\red Your hand slips, hitting internal organs in [target]'s abdomen with \the [tool]!")
		affected.createwound(BRUISE, 20)
