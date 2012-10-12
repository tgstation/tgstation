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

/datum/surgery_step/cut_open_abdomen
	required_tool = /obj/item/weapon/scalpel

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return target_zone == "groin"

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts cutting open [target]'s abdomen with \the [tool]", "You start cutting open [user] with \the [tool]")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/groin = target.get_organ("groin")
		groin.open = 1

/datum/surgery_step/remove_appendix
	required_tool = /obj/item/weapon/scalpel

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/groin = target.get_organ("groin")
		return target_zone == "groin" && groin.open

// Build this list by iterating over all typesof(/datum/surgery_step) and sorting the results by priority
var/global/list/surgery_steps = null

proc/build_surgery_steps_list()
	surgery_steps = list()
	for(var/T in typesof(/datum/surgery_step)-/datum/surgery_step)
		var/datum/surgery_step/S = new T
		surgery_steps += S

