
//check if mob is lying down on something we can operate him on.
/proc/can_operate(mob/living/carbon/M)
	return (locate(/obj/machinery/optable, M.loc) && M.resting) || \
	(locate(/obj/structure/stool/bed/roller, M.loc) && 	\
	(M.buckled || M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat)) && prob(75) || 	\
	(locate(/obj/structure/table/, M.loc) && 	\
	(M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat) && prob(66))

/datum/surgery_status/
	var/eyes	=	0
	var/face	=	0
	var/appendix =	0

/mob/living/carbon/var/datum/surgery_status/op_stage = new/datum/surgery_status

/* SURGERY STEPS */

/datum/surgery_step
	// type path referencing the required tool for this step
	var/required_tool = null

	// type path referencing tools that can be used as substitude for this step
	var/list/allowed_tools = null

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


//////////////////////////////////////////////////////////////////
//						COMMON STEPS							//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/generic/
	var/datum/organ/external/affected	//affected organ
	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if (!hasorgans(target))
			return 0
		affected = target.get_organ(target_zone)
		if (affected == null)
			return 0
		return 1

/datum/surgery_step/generic/cut_open
	required_tool = /obj/item/weapon/scalpel

	min_duration = 90
	max_duration = 110

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && affected.open == 0

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts cutting open [target]'s [affected.display_name] with \the [tool]", \
		"You start cutting open [target]'s [affected.display_name] with \the [tool]")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] cuts open [target]'s [affected.display_name] with \the [tool]", \
		"\blue You cut open [target]'s [affected.display_name] with \the [tool]")
		affected.open = 1
		affected.createwound(CUT, 1)
		if (target_zone == "head")
			target.brain_op_stage = 1

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, slicing open [target]'s [affected.display_name] in a wrong spot  with \the [tool]!", \
		"\red Your hand slips, slicing open [target]'s [affected.display_name] in a wrong spot with \the [tool]!")
		affected.createwound(CUT, 10)

/datum/surgery_step/generic/clamp_bleeders
	required_tool = /obj/item/weapon/hemostat

	min_duration = 40
	max_duration = 60

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && affected.open && (affected.status & ORGAN_BLEEDING)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts clamping bleeders in [target]'s [affected.display_name] with \the [tool]", \
		"You start clamping bleeders in [target]'s [affected.display_name] with \the [tool]")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] clamps bleeders in [target]'s [affected.display_name] with \the [tool]",	\
		"\blue You clamp bleeders in [target]'s [affected.display_name] with \the [tool]")
		affected.bandage()

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, tearing blood vessels in the wound in [target]'s [affected.display_name] with \the [tool]!", \
		"\red Your hand slips, tearing blood vessels in the wound in [target]'s [affected.display_name] with \the [tool]!")
		target.apply_damage(5, BRUTE, affected)

/datum/surgery_step/generic/retract_skin
	required_tool = /obj/item/weapon/retractor

	min_duration = 30
	max_duration = 40

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && affected.open < 2 && !(affected.status & ORGAN_BLEEDING)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts retracting flap of skin in the wound in [target]'s [affected.display_name] with \the [tool]", \
		"You starts retracting a flap of skin in the wound in [target]'s [affected.display_name] with \the [tool]")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] retracts flap of skin in the wound in [target]'s [affected.display_name] with \the [tool]", \
		"\blue You retract a flap of skin in the wound in [target]'s [affected.display_name] with \the [tool]")
		affected.open = 2

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, tearing skin flap in the wound in [target]'s [affected.display_name] with \the [tool]!", \
		"\red Your hand slips, tearing the skin flap in the wound in [target]'s [affected.display_name] with \the [tool]!")
		target.apply_damage(4, BRUTE, affected)

/datum/surgery_step/generic/cauterize
	required_tool = /obj/item/weapon/cautery

	min_duration = 70
	max_duration = 100

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && affected.open

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] is beginning to cauterize the incision in [target]'s [affected.display_name] with \the [tool]", \
		"You are beginning to cauterize the incision in [target]'s [affected.display_name] with \the [tool]")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] cauterizes the incision in [target]'s [affected.display_name] with \the [tool]", \
		"\blue You cauterize the incision in [target]'s [affected.display_name] with \the [tool]")
		affected.open = 0
		affected.status &= ~ORGAN_BLEEDING
		if (target_zone == "eyes" && target.op_stage.eyes > 0)
			if (target.op_stage.eyes == 2)
				target.sdisabilities &= ~BLIND
				target.eye_stat = 0
			target.op_stage.eyes = 0
		if (target_zone == "mouth" && target.op_stage.face > 0)
			if (target.op_stage.face == 2)
				var/datum/organ/external/head/h = affected
				h.disfigured = 0
			target.op_stage.face = 0

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, leaving a small burn on [target]'s [affected.display_name] with \the [tool]!", \
		"\red Your hand slips, leaving a small burn on [target]'s [affected.display_name] with \the [tool]!")
		target.apply_damage(3, BURN, affected)

//////////////////////////////////////////////////////////////////
//						APPENDECTOMY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/appendectomy/
	var/datum/organ/external/groin
	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if (target_zone != "groin")
			return 0
		world << "Aiming right..."
		groin = target.get_organ("groin")
		if (!groin)
			return 0
		world << "Target locked..."
		if (groin.open < 2)
			return 0
		world << "Entry gained..."
		return 1

/datum/surgery_step/appendectomy/cut_appendix
	required_tool = /obj/item/weapon/scalpel

	min_duration = 70
	max_duration = 90

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		world << "Opstage: [target.op_stage.appendix]"
		return ..() && target.op_stage.appendix == 0

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts cutting out [target]'s appendix with \the [tool]", \
		"You start cutting out [user]'s appendix with \the [tool]")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] cuts out [target]'s appendix with \the [tool]", \
		"\blue You cut out [user]'s appendix with \the [tool]")
		target.op_stage.appendix = 1

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/groin = target.get_organ("groin")
		user.visible_message("\red [user]'s hand slips, slicing an artery inside [target]'s abdomen with \the [tool]!", \
		"\red Your hand slips, slicing an artery inside [target]'s abdomen with \the [tool]!")
		groin.createwound(CUT, 50)

/datum/surgery_step/remove_appendix
	required_tool = /obj/item/weapon/hemostat

	min_duration = 60
	max_duration = 80

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target.op_stage.appendix == 1

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts removing [target]'s appendix with \the [tool]", \
		"You start removing [user]'s appendix with \the [tool]")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] removes [target]'s appendix with \the [tool]", \
		"\blue You remove [user]'s appendix with \the [tool]")
		var/datum/disease/appendicitis/app = null
		for(var/datum/disease/appendicitis/appendicitis in target.viruses)
			app = appendicitis
			appendicitis.cure()
		if (app)
			new /obj/item/weapon/reagent_containers/food/snacks/appendix/inflamed(get_turf(target))
		else
			new /obj/item/weapon/reagent_containers/food/snacks/appendix(get_turf(target))
		target.resistances += app
		target.op_stage.appendix = 2

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, hitting internal organs in [target]'s abdomen with \the [tool]!", \
		"\red Your hand slips, hitting internal organs in [target]'s abdomen with \the [tool]!")
		affected.createwound(BRUISE, 20)

//////////////////////////////////////////////////////////////////
//						BONE SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/glue_bone
	required_tool = /obj/item/weapon/bonegel

	min_duration = 50
	max_duration = 60

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return affected.open == 2 && affected.stage < 3

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts applying [tool] to [target]'s bone in [affected.display_name]", \
		"You start applying [tool] to [target]'s bone in [affected.display_name] with \the [tool]")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] applies some [tool] to [target]'s bone in [affected.display_name]", \
		"\blue You apply some [tool] to [target]'s bone in [affected.display_name] with \the [tool]")
		if (affected.stage == 0)
			affected.stage = 1
		if (affected.stage == 2)
			affected.status &= ~ORGAN_BROKEN
			affected.status &= ~ORGAN_SPLINTED
			affected.stage = 0
			affected.perma_injury = 0

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, applying [tool] to the wrong spot in [target]'s [affected.display_name]!", \
		"\red Your hand slips, applying [tool] to the wrong spot in [target]'s [affected.display_name]!")

/datum/surgery_step/set_bone
	required_tool = /obj/item/weapon/bonesetter

	min_duration = 60
	max_duration = 70

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return affected.open == 2 && affected.stage == 1

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] is beginning to set [target]'s [target_zone] bone in place with \the [tool]", \
		"You are beginning to set [target]'s [target_zone] bone in place with \the [tool]")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] set [target]'s [affected.display_name] bone in place with \the [tool]", \
		"\blue You set [target]'s [affected.display_name] bone in place with \the [tool]")
		affected.stage = 2

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, setting [target]'s [affected.display_name] in the wrong place with \the [tool]!", \
		"\red Your hand slips, setting [target]'s [affected.display_name] in the wrong place  with \the [tool]!")
		affected.createwound(BRUISE, 5)

//////////////////////////////////////////////////////////////////
//						EYE SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/lift_eyes
	required_tool = /obj/item/weapon/retractor

	min_duration = 30
	max_duration = 40

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return target_zone == "eyes" && target.op_stage.eyes < 1 && affected.open && !(affected.status & ORGAN_BLEEDING)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts lifting [target]'s eyes from sockets with \the [tool]", \
		"You start lifting [target]'s eyes from sockets with \the [tool]")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] lifts [target]'s eyes from sockets with \the [tool]", \
		"\blue You lift [target]'s eyes from sockets with \the [tool]")
		target.op_stage.eyes = 1

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, damaging [target]'s eyes with \the [tool]!", \
		"\red Your hand slips, damaging [target]'s eyes with \the [tool]!")
		target.apply_damage(10, BRUTE, affected)
		//TODO eye damage

/datum/surgery_step/mend_eyes
	required_tool = /obj/item/weapon/hemostat

	min_duration = 80
	max_duration = 100

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return target_zone == "eyes" && target.op_stage.eyes == 1 && affected.open && !(affected.status & ORGAN_BLEEDING)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts mending nerves in [target]'s eyes with \the [tool]", \
		"You start mending nerves in [target]'s eyes with \the [tool]")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] mend [target]'s eyes and nerves with \the [tool]",	\
		"\blue You mend [target]'s eyes and nerves with \the [tool]")
		target.op_stage.eyes = 2

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, clamping on [target]'s eye nerves with \the [tool]!", \
		"\red Your hand slips, clamping on [target]'s eye nerves with \the [tool]!")
		target.apply_damage(10, BRUTE, affected)

//////////////////////////////////////////////////////////////////
//						FACE SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/mend_vocal
	required_tool = /obj/item/weapon/hemostat

	min_duration = 70
	max_duration = 90

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return target_zone == "mouth" && target.op_stage.face < 1 && affected.open && !(affected.status & ORGAN_BLEEDING)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts mending [target]'s vocal cords with \the [tool]", \
		"You start mending [target]'s vocal cords with \the [tool]")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] mends [target]'s vocal cords with \the [tool]", \
		"\blue You mend [target]'s vocal cords with \the [tool]")
		target.op_stage.face = 1

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\red [user]'s hand slips, clamping [target]'s trachea shut for a moment with \the [tool]!", \
		"\red Your hand slips, clamping [user]'s trachea shut for a moment with \the [tool]!")
		target.losebreath += 10

/datum/surgery_step/fix_face
	required_tool = /obj/item/weapon/retractor

	min_duration = 80
	max_duration = 100

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return target_zone == "mouth" && target.op_stage.face == 1 && affected.open && !(affected.status & ORGAN_BLEEDING)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts pulling skin on [target]'s face back in place with \the [tool]", \
		"You start pulling skin on [target]'s face back in place with \the [tool]")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] pulls skin on [target]'s face back in place with \the [tool]",	\
		"\blue You pull skin on [target]'s face back in place with \the [tool]")
		target.op_stage.face = 2

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, tearing skin on [target]'s face with \the [tool]!", \
		"\red Your hand slips, tearing skin on [target]'s face with \the [tool]!")
		target.apply_damage(10, BRUTE, affected)

//////////////////////////////////////////////////////////////////
//						BRAIN SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/brain/
	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return target_zone == "head" && hasorgans(target)

/datum/surgery_step/brain/saw_skull
	required_tool = /obj/item/weapon/circular_saw

	min_duration = 50
	max_duration = 70

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target_zone == "head" && target.brain_op_stage == 1

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts sawing open [target]'s skull with \the [tool]", \
		"You start start sawing open [target]'s skull with \the [tool]")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] saws [target]'s skull open with \the [tool]",	\
		"\blue You saw on [target]'s skull open with \the [tool]")
		target.brain_op_stage = 2

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\red [user]'s hand slips, cutting [target]'s scalp with \the [tool]!", \
		"\red Your hand slips, cutting [target]'s scalp with \the [tool]!")
		target.apply_damage(10, BRUTE, "head")

/datum/surgery_step/brain/cut_brain
	required_tool = /obj/item/weapon/scalpel

	min_duration = 80
	max_duration = 100

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target.brain_op_stage == 2

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts separating connections to [target]'s brain with \the [tool]", \
		"You start separating connections to [target]'s brain with \the [tool]")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] separates connections to [target]'s brain with \the [tool]",	\
		"\blue You separate connections to [target]'s brain with \the [tool]")
		target.brain_op_stage = 3

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\red [user]'s hand slips, cutting a vein in [target]'s brain with \the [tool]!", \
		"\red Your hand slips, cutting a vein in [target]'s brain with \the [tool]!")
		target.apply_damage(50, BRUTE, "head")

/datum/surgery_step/brain/saw_spine
	required_tool = /obj/item/weapon/circular_saw

	min_duration = 50
	max_duration = 70

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target.brain_op_stage == 3

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts separating [target]'s brain from spine with \the [tool]", \
		"You start separating [target]'s brain from spine with \the [tool]")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] separates [target]'s rain from spine with \the [tool]",	\
		"\blue You separate [target]'s rain from spine with \the [tool]")

		user.attack_log += "\[[time_stamp()]\]<font color='red'> Debrained [target.name] ([target.ckey]) with [tool.name] (INTENT: [uppertext(user.a_intent)])</font>"
		target.attack_log += "\[[time_stamp()]\]<font color='orange'> Debrained by [user.name] ([user.ckey]) with [tool.name] (INTENT: [uppertext(user.a_intent)])</font>"

		log_admin("ATTACK: [user] ([user.ckey]) debrained [target] ([target.ckey]) with [tool].")
		message_admins("ATTACK: [user] ([user.ckey]) debrained [target] ([target.ckey]) with [tool].")
		log_attack("<font color='red'>[user.name] ([user.ckey]) debrained [target.name] ([target.ckey]) with [tool.name] (INTENT: [uppertext(user.a_intent)])</font>")

		var/obj/item/brain/B = new(target.loc)
		B.transfer_identity(target)

		target:brain_op_stage = 4.0
		target.death()//You want them to die after the brain was transferred, so not to trigger client death() twice.

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\red [user]'s hand slips, cutting a vein in [target]'s brain with \the [tool]!", \
		"\red Your hand slips, cutting a vein in [target]'s brain with \the [tool]!")
		target.apply_damage(30, BRUTE, "head")


//////////////////////////////////////////////////////////////////
//				METROID CORE EXTRACTION							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/metroid/
	can_use(mob/user, mob/living/carbon/metroid/target, target_zone, obj/item/tool)
		return istype(target, /mob/living/carbon/metroid/) && target.stat == 2

/datum/surgery_step/metroid/cut_flesh
	required_tool = /obj/item/weapon/scalpel

	min_duration = 30
	max_duration = 50

	can_use(mob/user, mob/living/carbon/metroid/target, target_zone, obj/item/tool)
		return ..() && target.brain_op_stage == 0

	begin_step(mob/user, mob/living/carbon/metroid/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts cutting [target]'s flesh with \the [tool]", \
		"You start cutting [target]'s flesh with \the [tool]")

	end_step(mob/user, mob/living/carbon/metroid/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] cuts [target]'s flesh with \the [tool]",	\
		"\blue You cut [target]'s flesh with \the [tool], exposing the cores")
		target.brain_op_stage = 1

	fail_step(mob/user, mob/living/carbon/metroid/target, target_zone, obj/item/tool)
		user.visible_message("\red [user]'s hand slips, tearing [target]'s flesh with \the [tool]!", \
		"\red Your hand slips, tearing [target]'s flesh with \the [tool]!")

/datum/surgery_step/metroid/cut_innards
	required_tool = /obj/item/weapon/scalpel

	min_duration = 30
	max_duration = 50

	can_use(mob/user, mob/living/carbon/metroid/target, target_zone, obj/item/tool)
		return ..() && target.brain_op_stage == 1

	begin_step(mob/user, mob/living/carbon/metroid/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts cutting [target]'s silky innards apart with \the [tool]", \
		"You start cutting [target]'s silky innards apart with \the [tool]")

	end_step(mob/user, mob/living/carbon/metroid/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] cuts [target]'s innards apart with \the [tool], exposing the cores",	\
		"\blue You cut [target]'s innards apart with \the [tool], exposing the cores")
		target.brain_op_stage = 2

	fail_step(mob/user, mob/living/carbon/metroid/target, target_zone, obj/item/tool)
		user.visible_message("\red [user]'s hand slips, tearing [target]'s innards with \the [tool]!", \
		"\red Your hand slips, tearing [target]'s innards with \the [tool]!")

/datum/surgery_step/metroid/saw_core
	required_tool = /obj/item/weapon/circular_saw

	min_duration = 50
	max_duration = 70

	can_use(mob/user, mob/living/carbon/metroid/target, target_zone, obj/item/tool)
		return ..() && target.brain_op_stage == 2 && target.cores > 0

	begin_step(mob/user, mob/living/carbon/metroid/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts cutting out one of [target]'s cores with \the [tool]", \
		"You start cutting out one of [target]'s cores with \the [tool]")

	end_step(mob/user, mob/living/carbon/metroid/target, target_zone, obj/item/tool)
		target.cores--
		user.visible_message("\blue [user] cuts out one of [target]'s cores with \the [tool]",,	\
		"\blue You cut out one of [target]'s cores with \the [tool]. [target.cores] cores left.")
		new/obj/item/metroid_core(target.loc)
		if(target.cores <= 0)
			target.icon_state = "baby roro dead-nocore"

	fail_step(mob/user, mob/living/carbon/metroid/target, target_zone, obj/item/tool)
		user.visible_message("\red [user]'s hand slips, failing to cut core out!", \
		"\red Your hand slips, failing to cut core out!")

//////////////////////////////////////////////////////////////////
//						LIMB SURGERY							//
//////////////////////////////////////////////////////////////////

//uh, sometime later, okay?