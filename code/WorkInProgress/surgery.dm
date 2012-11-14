
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

proc/spread_germs_to_organ(datum/organ/external/E, mob/living/carbon/human/user)
	if(!istype(user) || !istype(E)) return

	var/germ_level = user.germ_level
	if(user.gloves)
		germ_level = user.gloves.germ_level

	E.germ_level = germ_level


//////////////////////////////////////////////////////////////////
//						COMMON STEPS							//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/generic/
	var/datum/organ/external/affected	//affected organ
	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if (target_zone == "eyes")	//there are specific steps for eye surgery
			return 0
		if (!hasorgans(target))
			return 0
		affected = target.get_organ(target_zone)
		if (affected == null)
			return 0
		if (affected.status & ORGAN_DESTROYED)
			return 0
		if (affected.status & ORGAN_ROBOT)
			return 0
		return 1

/datum/surgery_step/generic/cut_open
	required_tool = /obj/item/weapon/scalpel

	min_duration = 90
	max_duration = 110

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && affected.open == 0 && target_zone != "mouth"

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts the incision on [target]'s [affected.display_name] with \the [tool].", \
		"You start the incision on [target]'s [affected.display_name] with \the [tool].")
		target.custom_pain("You feel a horrible pain as if from a sharp knife in your [affected.display_name]!",1)

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] has made an incision on [target]'s [affected.display_name] with \the [tool].", \
		"\blue You have made an incision on [target]'s [affected.display_name] with \the [tool].",)
		affected.open = 1
		affected.createwound(CUT, 1)
		spread_germs_to_organ(affected, user)
		if (target_zone == "head")
			target.brain_op_stage = 1

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, slicing open [target]'s [affected.display_name] in a wrong spot with \the [tool]!", \
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
		user.visible_message("[user] starts clamping bleeders in [target]'s [affected.display_name] with \the [tool].", \
		"You start clamping bleeders in [target]'s [affected.display_name] with \the [tool].")
		target.custom_pain("The pain in your [affected.display_name] is maddening!",1)

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] clamps bleeders in [target]'s [affected.display_name] with \the [tool].",	\
		"\blue You clamp bleeders in [target]'s [affected.display_name] with \the [tool].")
		affected.clamp()
		affected.status &= ~ORGAN_BLEEDING
		spread_germs_to_organ(affected, user)

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, tearing blood vessals and causing massive bleeding in [target]'s [affected.display_name] with the \[tool]!",	\
		"\red Your hand slips, tearing blood vessels and causing massive bleeding in [target]'s [affected.display_name] with \the [tool]!",)
		affected.createwound(CUT, 10)

/datum/surgery_step/generic/retract_skin
	required_tool = /obj/item/weapon/retractor

	min_duration = 30
	max_duration = 40

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && affected.open < 2 && !(affected.status & ORGAN_BLEEDING)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		var/msg = "[user] starts to pry open the incision on [target]'s [affected.display_name] with \the [tool]."
		var/self_msg = "You start to pry open the incision on [target]'s [affected.display_name] with \the [tool]."
		if (target_zone == "chest")
			msg = "[user] starts to separate the ribcage and rearrange the organs in [target]'s torso with \the [tool]."
			self_msg = "You start to separate the ribcage and rearrange the organs in [target]'s torso with \the [tool]."
		if (target_zone == "groin")
			msg = "[user] starts to pry open the incision and rearrange the organs in [target]'s lower abdomen with \the [tool]."
			self_msg = "You start to pry open the incision and rearrange the organs in [target]'s lower abdomen with \the [tool]."
		user.visible_message(msg, self_msg)
		target.custom_pain("It feels like the skin on your [affected.display_name] is on fire!",1)

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		var/msg = "\blue [user] keeps the incision open on [target]'s [affected.display_name] with \the [tool]."
		var/self_msg = "\blue You keep the incision open on [target]'s [affected.display_name] with \the [tool]."
		if (target_zone == "chest")
			msg = "\blue [user] keeps the ribcage open on [target]'s torso with \the [tool]."
			self_msg = "\blue You keep the ribcage open on [target]'s torso with \the [tool]."
		if (target_zone == "groin")
			msg = "\blue [user] keeps the incision open on [target]'s lower abdomen with \the [tool]."
			self_msg = "\blue You keep the incision open on [target]'s lower abdomen with \the [tool]."
		user.visible_message(msg, self_msg)
		affected.open = 2
		spread_germs_to_organ(affected, user)

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		var/msg = "\red [user]'s hand slips, tearing the edges of incision on [target]'s [affected.display_name] with \the [tool]!"
		var/self_msg = "\red Your hand slips, tearing the edges of incision on [target]'s [affected.display_name] with \the [tool]!"
		if (target_zone == "chest")
			msg = "\red [user]'s hand slips, damaging several organs [target]'s torso with \the [tool]!"
			self_msg = "\red Your hand slips, damaging several organs [target]'s torso with \the [tool]!"
		if (target_zone == "groin")
			msg = "\red [user]'s hand slips, damaging several organs [target]'s lower abdomen with \the [tool]"
			self_msg = "\red Your hand slips, damaging several organs [target]'s lower abdomen with \the [tool]!"
		user.visible_message(msg, self_msg)
		target.apply_damage(12, BRUTE, affected)

/datum/surgery_step/generic/cauterize
	required_tool = /obj/item/weapon/cautery

	min_duration = 70
	max_duration = 100

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && affected.open && target_zone != "mouth"

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] is beginning to cauterize the incision on [target]'s [affected.display_name] with \the [tool]." , \
		"You are beginning to cauterize the incision on [target]'s [affected.display_name] with \the [tool].")
		target.custom_pain("Your [affected.display_name] is being burned!",1)

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] cauterizes the incision on [target]'s [affected.display_name] with \the [tool].", \
		"\blue You cauterize the incision on [target]'s [affected.display_name] with \the [tool].")
		affected.open = 0
		affected.germ_level = 0
		affected.status &= ~ORGAN_BLEEDING

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
		groin = target.get_organ("groin")
		if (!groin)
			return 0
		if (groin.open < 2)
			return 0
		return 1

/datum/surgery_step/appendectomy/cut_appendix
	required_tool = /obj/item/weapon/scalpel

	min_duration = 70
	max_duration = 90

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target.op_stage.appendix == 0

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts to separating [target]'s appendix from the abdominal wall with \the [tool].", \
		"You start to separating [target]'s appendix from the abdominal wall with \the [tool]." )
		target.custom_pain("The pain in your abdomen is living hell!",1)

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] has separated [target]'s appendix with \the [tool]." , \
		"\blue You have separated [target]'s appendix with \the [tool].")
		target.op_stage.appendix = 1

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/groin = target.get_organ("groin")
		user.visible_message("\red [user]'s hand slips, slicing an artery inside [target]'s abdomen with \the [tool]!", \
		"\red Your hand slips, slicing an artery inside [target]'s abdomen with \the [tool]!")
		groin.createwound(CUT, 50)

/datum/surgery_step/appendectomy/remove_appendix
	required_tool = /obj/item/weapon/hemostat

	min_duration = 60
	max_duration = 80

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target.op_stage.appendix == 1

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts removing [target]'s appendix with \the [tool].", \
		"You start removing [target]'s appendix with \the [tool].")
		target.custom_pain("Someone's ripping out your bowels!",1)

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] has removed [target]'s appendix with \the [tool].", \
		"\blue You have removed [target]'s appendix with \the [tool].")
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
		user.visible_message("\red [user]'s hand slips, nicking internal organs in [target]'s abdomen with \the [tool]!", \
		"\red Your hand slips, nicking internal organs in [target]'s abdomen with \the [tool]!")
		affected.createwound(BRUISE, 20)


//////////////////////////////////////////////////////////////////
//					INTERNAL WOUND PATCHING						//
//////////////////////////////////////////////////////////////////


/datum/surgery_step/fix_vein
	required_tool = /obj/item/weapon/FixOVein

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)

		var/internal_bleeding = 0
		for(var/datum/wound/W in affected.wounds) if(W.internal)
			internal_bleeding = 1
			break

		return affected.open == 2 && internal_bleeding

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		if (affected.stage == 0)
			user.visible_message("[user] starts patching the damaged vein in [target]'s [affected.display_name] with \the [tool]." , \
			"You start patching the damaged vein in [target]'s [affected.display_name] with \the [tool].")
		target.custom_pain("The pain in [affected.display_name] is unbearable!",1)

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] has patched the damaged vein in [target]'s [affected.display_name] with \the [tool].", \
			"\blue You have patched the damaged vein in [target]'s [affected.display_name] with \the [tool].")

		for(var/datum/wound/W in affected.wounds) if(W.internal)
			affected.wounds -= W
			affected.update_damages()

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, smearing [tool] in the incision in [target]'s [affected.display_name]!" , \
		"\red Your hand slips, smearing [tool] in the incision in [target]'s [affected.display_name]!")
		affected.take_damage(5, 0)


//////////////////////////////////////////////////////////////////
//						BONE SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/glue_bone
	required_tool = /obj/item/weapon/bonegel

	min_duration = 50
	max_duration = 60

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return affected.open == 2 && affected.stage == 0

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		if (affected.stage == 0)
			user.visible_message("[user] starts applying medication to the damaged bones in [target]'s [affected.display_name] with \the [tool]." , \
			"You start applying medication to the damaged bones in [target]'s [affected.display_name] with \the [tool].")
		target.custom_pain("Something in your [affected.display_name] is causing you a lot of pain!",1)

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] applies some [tool] to [target]'s bone in [affected.display_name]", \
			"\blue You apply some [tool] to [target]'s bone in [affected.display_name] with \the [tool].")
		affected.stage = 1
		spread_germs_to_organ(affected, user)

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, smearing [tool] in the incision in [target]'s [affected.display_name]!" , \
		"\red Your hand slips, smearing [tool] in the incision in [target]'s [affected.display_name]!")

/datum/surgery_step/set_bone
	required_tool = /obj/item/weapon/bonesetter

	min_duration = 60
	max_duration = 70

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return affected.name != "head" && affected.open == 2 && affected.stage == 1

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] is beginning to set the bone in [target]'s [affected.display_name] in place with \the [tool]." , \
			"You are beginning to set the bone in [target]'s [target_zone] in place with \the [tool].")
		target.custom_pain("The pain in your [affected.display_name] is going to make you pass out!",1)

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		if (affected.status & ORGAN_BROKEN)
			user.visible_message("\blue [user] sets the bone in [target]'s [affected.display_name] in place with \the [tool].", \
				"\blue You set the bone in [target]'s [affected.display_name] in place with \the [tool].")
			affected.stage = 2
			spread_germs_to_organ(affected, user)
		else
			user.visible_message("\blue [user] sets the bone in [target]'s [affected.display_name]\red in the WRONG place with \the [tool].", \
				"\blue You set the bone in [target]'s [affected.display_name]\red in the WRONG place with \the [tool].")
			affected.fracture()
			spread_germs_to_organ(affected, user)

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, damaging the bone in [target]'s [affected.display_name] with \the [tool]!" , \
			"\red Your hand slips, damaging the bone in [target]'s [affected.display_name] with \the [tool]!")
		affected.createwound(BRUISE, 5)

/datum/surgery_step/mend_skull
	required_tool = /obj/item/weapon/bonesetter

	min_duration = 60
	max_duration = 70

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return affected.name == "head" && affected.open == 2 && affected.stage == 1

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] is beginning piece together [target]'s skull with \the [tool]."  , \
			"You are beginning piece together [target]'s skull with \the [tool].")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] sets [target]'s [affected.display_name] skull with \the [tool]." , \
			"\blue You set [target]'s [affected.display_name] skull with \the [tool].")
		affected.stage = 2
		spread_germs_to_organ(affected, user)

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, damaging [target]'s [affected.display_name] face with \the [tool]!"  , \
			"\red Your hand slips, damaging [target]'s [affected.display_name] face with \the [tool]!")
		var/datum/organ/external/head/h = affected
		h.createwound(BRUISE, 10)
		h.disfigured = 1

/datum/surgery_step/finish_bone
	required_tool = /obj/item/weapon/bonegel

	min_duration = 50
	max_duration = 60

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return affected.open == 2 && affected.stage == 2

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts to finish mending the damaged bones in [target]'s [affected.display_name] with \the [tool].", \
		"You start to finish mending the damaged bones in [target]'s [affected.display_name] with \the [tool].")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] has mended the damaged bones in [target]'s [affected.display_name] with \the [tool]."  , \
			"\blue You have mended the damaged bones in [target]'s [affected.display_name] with \the [tool]." )
		affected.status &= ~ORGAN_BROKEN
		affected.status &= ~ORGAN_SPLINTED
		affected.stage = 0
		affected.perma_injury = 0
		spread_germs_to_organ(affected, user)

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, smearing [tool] in the incision in [target]'s [affected.display_name]!" , \
		"\red Your hand slips, smearing [tool] in the incision in [target]'s [affected.display_name]!")

//////////////////////////////////////////////////////////////////
//						EYE SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/eye
	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if (!hasorgans(target))
			return 0
		var/datum/organ/external/affected = target.get_organ(target_zone)
		if (!affected)
			return 0
		return target_zone == "eyes"

/datum/surgery_step/eye/cut_open
	required_tool = /obj/item/weapon/scalpel

	min_duration = 90
	max_duration = 110

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..()

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts to separate the corneas on [target]'s eyes with \the [tool].", \
		"You start to separate the corneas on [target]'s eyes with \the [tool].")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] has separated the corneas on [target]'s eyes with \the [tool]." , \
		"\blue You have separated the corneas on [target]'s eyes with \the [tool].",)
		target.op_stage.eyes = 1

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, slicing [target]'s eyes wth \the [tool]!" , \
		"\red Your hand slips, slicing [target]'s eyes wth \the [tool]!" )
		affected.createwound(CUT, 10)

/datum/surgery_step/eye/lift_eyes
	required_tool = /obj/item/weapon/retractor

	min_duration = 30
	max_duration = 40

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target.op_stage.eyes == 1

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts lifting corneas from [target]'s eyes with \the [tool].", \
		"You start lifting corneas from [target]'s eyes with \the [tool].")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] has lifted the corneas from [target]'s eyes from with \the [tool]." , \
		"\blue You has lifted the corneas from [target]'s eyes from with \the [tool]." )
		target.op_stage.eyes = 2

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, damaging [target]'s eyes with \the [tool]!", \
		"\red Your hand slips, damaging [target]'s eyes with \the [tool]!")
		target.apply_damage(10, BRUTE, affected)

/datum/surgery_step/eye/mend_eyes
	required_tool = /obj/item/weapon/hemostat

	min_duration = 80
	max_duration = 100

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target.op_stage.eyes == 2

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts mending the nerves and lenses in [target]'s eyes with \the [tool].", \
		"You start mending the nerves and lenses in [target]'s eyes with the [tool].")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] mends the nerves and lenses in [target]'s with \the [tool]." ,	\
		"\blue You mend the nerves and lenses in [target]'s with \the [tool].")
		target.op_stage.eyes = 3

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, stabbing \the [tool] into [target]'s eye!", \
		"\red Your hand slips, stabbing \the [tool] into [target]'s eye!")
		target.apply_damage(10, BRUTE, affected)

/datum/surgery_step/eye/cauterize
	required_tool = /obj/item/weapon/cautery

	min_duration = 70
	max_duration = 100

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..()

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] is beginning to cauterize the incision around [target]'s eyes with \the [tool]." , \
		"You are beginning to cauterize the incision around [target]'s eyes with \the [tool].")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] cauterizes the incision around [target]'s eyes with \the [tool].", \
		"\blue You cauterize the incision around [target]'s eyes with \the [tool].")
		if (target.op_stage.eyes == 3)
			target.sdisabilities &= ~BLIND
			target.eye_stat = 0
		target.op_stage.eyes = 0

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips,  searing [target]'s eyes with \the [tool]!", \
		"\red Your hand slips, searing [target]'s eyes with \the [tool]!")
		target.apply_damage(5, BURN, affected)
		target.eye_stat += 5

//////////////////////////////////////////////////////////////////
//						FACE SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/face
	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if (!hasorgans(target))
			return 0
		var/datum/organ/external/affected = target.get_organ(target_zone)
		if (!affected)
			return 0
		return target_zone == "mouth" && affected.open == 2 && !(affected.status & ORGAN_BLEEDING)

/datum/surgery_step/generic/cut_face
	required_tool = /obj/item/weapon/scalpel

	min_duration = 90
	max_duration = 110

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target_zone == "mouth" && target.op_stage.face == 0

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts to cut open [target]'s face and neck with \the [tool].", \
		"You start to cut open [target]'s face and neck with \the [tool].")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] has cut open [target]'s face and neck with \the [tool]." , \
		"\blue You have cut open [target]'s face and neck with \the [tool].",)
		target.op_stage.face = 1

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, slicing [target]'s throat wth \the [tool]!" , \
		"\red Your hand slips, slicing [target]'s throat wth \the [tool]!" )
		affected.createwound(CUT, 60)
		target.losebreath += 10

/datum/surgery_step/face/mend_vocal
	required_tool = /obj/item/weapon/hemostat

	min_duration = 70
	max_duration = 90

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target.op_stage.face == 1

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts mending [target]'s vocal cords with \the [tool].", \
		"You start mending [target]'s vocal cords with \the [tool].")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] mends [target]'s vocal cords with \the [tool].", \
		"\blue You mend [target]'s vocal cords with \the [tool].")
		target.op_stage.face = 2

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\red [user]'s hand slips, clamping [target]'s trachea shut for a moment with \the [tool]!", \
		"\red Your hand slips, clamping [user]'s trachea shut for a moment with \the [tool]!")
		target.losebreath += 10

/datum/surgery_step/face/fix_face
	required_tool = /obj/item/weapon/retractor

	min_duration = 80
	max_duration = 100

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target.op_stage.face == 2

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts pulling skin on [target]'s face back in place with \the [tool].", \
		"You start pulling skin on [target]'s face back in place with \the [tool].")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] pulls skin on [target]'s face back in place with \the [tool].",	\
		"\blue You pull skin on [target]'s face back in place with \the [tool].")
		target.op_stage.face = 3

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, tearing skin on [target]'s face with \the [tool]!", \
		"\red Your hand slips, tearing skin on [target]'s face with \the [tool]!")
		target.apply_damage(10, BRUTE, affected)

/datum/surgery_step/face/cauterize
	required_tool = /obj/item/weapon/cautery

	min_duration = 70
	max_duration = 100

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target.op_stage.face > 0

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] is beginning to cauterize the incision on [target]'s face and neck with \the [tool]." , \
		"You are beginning to cauterize the incision on [target]'s face and neck with \the [tool].")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] cauterizes the incision on [target]'s face and neck with \the [tool].", \
		"\blue You cauterize the incision on [target]'s face and neck with \the [tool].")
		affected.open = 0
		affected.status &= ~ORGAN_BLEEDING
		if (target.op_stage.face == 3)
			var/datum/organ/external/head/h = affected
			h.disfigured = 0
		target.op_stage.face = 0

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, leaving a small burn on [target]'s face with \the [tool]!", \
		"\red Your hand slips, leaving a small burn on [target]'s face with \the [tool]!")
		target.apply_damage(4, BURN, affected)

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
		user.visible_message("[user] begins to cut through [target]'s skull with \the [tool].", \
		"You begin to cut through [target]'s skull with \the [tool].")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] has cut through [target]'s skull open with \the [tool].",		\
		"\blue You have cut through [target]'s skull open with \the [tool].")
		target.brain_op_stage = 2

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\red [user]'s hand slips, cracking [target]'s skull with \the [tool]!" , \
		"\red Your hand slips, cracking [target]'s skull with \the [tool]!" )
		target.apply_damage(10, BRUTE, "head")

/datum/surgery_step/brain/cut_brain
	required_tool = /obj/item/weapon/scalpel

	min_duration = 80
	max_duration = 100

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target.brain_op_stage == 2

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts separating connections to [target]'s brain with \the [tool].", \
		"You start separating connections to [target]'s brain with \the [tool].")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] separates connections to [target]'s brain with \the [tool].",	\
		"\blue You separate connections to [target]'s brain with \the [tool].")
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
		user.visible_message("[user] starts separating [target]'s brain from \his spine with \the [tool].", \
		"You start separating [target]'s brain from spine with \the [tool].")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] separates [target]'s brain from \his spine with \the [tool].",	\
		"\blue You separate [target]'s brain from spine with \the [tool].")

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
		user.visible_message("[user] starts cutting [target]'s flesh with \the [tool].", \
		"You start cutting [target]'s flesh with \the [tool].")

	end_step(mob/user, mob/living/carbon/metroid/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] cuts [target]'s flesh with \the [tool].",	\
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
		user.visible_message("[user] starts cutting [target]'s silky innards apart with \the [tool].", \
		"You start cutting [target]'s silky innards apart with \the [tool].")

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
		user.visible_message("[user] starts cutting out one of [target]'s cores with \the [tool].", \
		"You start cutting out one of [target]'s cores with \the [tool].")

	end_step(mob/user, mob/living/carbon/metroid/target, target_zone, obj/item/tool)
		target.cores--
		user.visible_message("\blue [user] cuts out one of [target]'s cores with \the [tool].",,	\
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

/datum/surgery_step/limb/
	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if (!hasorgans(target))
			return 0
		var/datum/organ/external/affected = target.get_organ(target_zone)
		if (!affected)
			return 0
		if (!(affected.status & ORGAN_DESTROYED))
			return 0
		if (affected.parent)
			if (affected.parent.status & ORGAN_DESTROYED)
				return 0
		return 1


/datum/surgery_step/limb/cut
	required_tool = /obj/item/weapon/scalpel

	min_duration = 80
	max_duration = 100

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts cutting away flesh where [target]'s [affected.display_name] used to be with \the [tool].", \
		"You start cutting away flesh where [target]'s [affected.display_name] used to be with \the [tool].")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] cuts away flesh where [target]'s [affected.display_name] used to be with \the [tool].",	\
		"\blue You cut away flesh where [target]'s [affected.display_name] used to be with \the [tool].")
		affected.status |= ORGAN_CUT_AWAY

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		if (affected.parent)
			affected = affected.parent
			user.visible_message("\red [user]'s hand slips, cutting [target]'s [affected.display_name] open!", \
			"\red Your hand slips,  cutting [target]'s [affected.display_name] open!")
			affected.createwound(CUT, 10)


/datum/surgery_step/limb/mend
	required_tool = /obj/item/weapon/retractor

	min_duration = 80
	max_duration = 100

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return ..() && affected.status & ORGAN_CUT_AWAY

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] is beginning reposition flesh and nerve endings where where [target]'s [affected.display_name] used to be with [tool].", \
		"You start repositioning flesh and nerve endings where where [target]'s [affected.display_name] used to be with [tool].")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] has finished repositioning flesh and nerve endings where [target]'s [affected.display_name] used to be with [tool].",	\
		"\blue You have finished repositioning flesh and nerve endings where [target]'s [affected.display_name] used to be with [tool].")
		affected.open = 3

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		if (affected.parent)
			affected = affected.parent
			user.visible_message("\red [user]'s hand slips, tearing flesh on [target]'s [affected.display_name]!", \
			"\red Your hand slips, tearing flesh on [target]'s [affected.display_name]!")
			target.apply_damage(10, BRUTE, affected)


/datum/surgery_step/limb/prepare
	required_tool = /obj/item/weapon/cautery

	min_duration = 60
	max_duration = 70

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return ..() && affected.open == 3

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts adjusting area around [target]'s [affected.display_name] with \the [tool].", \
		"You start adjusting area around [target]'s [affected.display_name] with \the [tool]..")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] has finished adjusting the area around [target]'s [affected.display_name] with \the [tool].",	\
		"\blue You have finished adjusting the area around [target]'s [affected.display_name] with \the [tool].")
		affected.status |= ORGAN_ATTACHABLE
		affected.amputated = 1
		affected.open = 0

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		if (affected.parent)
			affected = affected.parent
			user.visible_message("\red [user]'s hand slips, searing [target]'s [affected.display_name]!", \
			"\red Your hand slips, searing [target]'s [affected.display_name]!")
			target.apply_damage(10, BURN, affected)


/datum/surgery_step/limb/attach
	required_tool = /obj/item/robot_parts

	min_duration = 80
	max_duration = 100

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/robot_parts/p = tool
		if (p.part)
			if (!(target_zone in p.part))
				return 0
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return ..() && affected.status & ORGAN_ATTACHABLE

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts attaching [tool] where [target]'s [affected.display_name] used to be.", \
		"You start attaching [tool] where [target]'s [affected.display_name] used to be.")

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] has attached [tool] where [target]'s [affected.display_name] used to be.",	\
		"\blue You have attached [tool] where [target]'s [affected.display_name] used to be.")
		affected.robotize()
		target.update_body()
		target.updatehealth()
		target.UpdateDamageIcon()
		del(tool)

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, damaging connectors on [target]'s [affected.display_name]!", \
		"\red Your hand slips, damaging connectors on [target]'s [affected.display_name]!")
		target.apply_damage(10, BRUTE, affected)


//////////////////////////////////////////////////////////////////
//						ALIEN SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/alien
	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/embryo = 0
		for(var/datum/disease/alien_embryo/A in target.viruses)
			embryo = 1
			break

		return embryo && target_zone == "chest"

/datum/surgery_step/alien/saw_ribcage
	required_tool = /obj/item/weapon/circular_saw

	min_duration = 50
	max_duration = 70

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return ..() && target.embryo_op_stage == 0 && affected.open >= 2

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] begins to cut through [target]'s ribcage with \the [tool].", \
		"You begin to cut through [target]'s ribcage with \the [tool].")
		target.custom_pain("Something hurts horribly in your chest!",1)

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] has cut through [target]'s ribcage open with \the [tool].",		\
		"\blue You have cut through [target]'s ribcage open with \the [tool].")
		target.embryo_op_stage = 1

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\red [user]'s hand slips, cracking [target]'s ribcage with \the [tool]!" , \
		"\red Your hand slips, cracking [target]'s ribcage with \the [tool]!" )


/datum/surgery_step/alien/retract_ribcage
	required_tool = /obj/item/weapon/retractor

	min_duration = 30
	max_duration = 40

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target.embryo_op_stage == 1

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/msg = "[user] starts to force open the ribcage in [target]'s torso with \the [tool]."
		var/self_msg = "You start to force open the ribcage in [target]'s torso with \the [tool]."
		user.visible_message(msg, self_msg)
		target.custom_pain("Something hurts horribly in your chest!",1)

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/msg = "\blue [user] forces open [target]'s ribcage with \the [tool]."
		var/self_msg = "\blue You force open [target]'s ribcage with \the [tool]."
		user.visible_message(msg, self_msg)
		target.embryo_op_stage = 2

		// Whoops!
		if(prob(10))
			var/datum/organ/external/affected = target.get_organ(target_zone)
			affected.fracture()

	fail_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/msg = "\red [user]'s hand slips, breaking [target]'s ribcage!"
		var/self_msg = "\red Your hand slips, breaking [target]'s ribcage!"
		user.visible_message(msg, self_msg)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		affected.fracture()

/datum/surgery_step/alien/remove_embryo
	required_tool = /obj/item/weapon/hemostat

	min_duration = 80
	max_duration = 100

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target.embryo_op_stage == 2

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/msg = "[user] starts to pull something out from [target]'s ribcage with \the [tool]."
		var/self_msg = "You start to pull something out from [target]'s ribcage with \the [tool]."
		user.visible_message(msg, self_msg)
		target.custom_pain("Something hurts horribly in your chest!",1)

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\red [user] rips the larva out of [target]'s ribcage!",
							 "You rip the larva out of [target]'s ribcage!")

		var/mob/living/carbon/alien/larva/stupid = new(target.loc)
		stupid.death(0)

		target.embryo_op_stage = 3

		for(var/datum/disease/alien_embryo in target.viruses)
			alien_embryo.cure()

/datum/surgery_step/alien/close_ribcage
	required_tool = /obj/item/weapon/retractor

	min_duration = 20
	max_duration = 40

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return target.embryo_op_stage >= 2

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/msg = "[user] starts bending [target]'s ribcage back into place with \the [tool]."
		var/self_msg = "You start bending [target]'s ribcage back into place with \the [tool]."
		user.visible_message(msg, self_msg)
		target.custom_pain("Something hurts horribly in your chest!",1)

	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/msg = "[user] bends [target]'s ribcage back into place with \the [tool]."
		var/self_msg = "You bends [target]'s ribcage back into place with \the [tool]."
		user.visible_message(msg, self_msg)

		target.embryo_op_stage = 1

/datum/surgery_step/alien/mend_ribcage
	required_tool = /obj/item/weapon/bonegel

	min_duration = 20
	max_duration = 40

	can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return target.embryo_op_stage == 1

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/msg = "[user] starts applying \the [tool] to [target]'s ribcage."
		var/self_msg = "You start applying \the [tool] to [target]'s ribcage."
		user.visible_message(msg, self_msg)
		target.custom_pain("Something hurts horribly in your chest!",1)


	end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/msg = "[user] applied \the [tool] to [target]'s ribcage."
		var/self_msg = "You applied \the [tool] to [target]'s ribcage."
		user.visible_message(msg, self_msg)

		target.embryo_op_stage = 0
