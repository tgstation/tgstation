//Procedures in this file: Gneric surgery steps
//////////////////////////////////////////////////////////////////
//						COMMON STEPS							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/generic/
	can_infect = 1
	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if (target_zone == "eyes")	//there are specific steps for eye surgery
			return 0
		if (!hasorgans(target))
			return 0
		var/datum/organ/external/affected = target.get_organ(target_zone)
		if (affected == null)
			return 0
		if (affected.status & ORGAN_DESTROYED)
			return 0
		if (affected.status & ORGAN_ROBOT)
			return 0
		return 1

/datum/surgery_step/generic/cut_open
	required_tool = /obj/item/weapon/scalpel
	allowed_tools = list(/obj/item/weapon/shard, /obj/item/weapon/kitchenknife)

	min_duration = 90
	max_duration = 110

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return ..() && affected.open == 0 && target_zone != "mouth"

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts the incision on [target]'s [affected.display_name] with \the [tool].", \
		"You start the incision on [target]'s [affected.display_name] with \the [tool].")
		target.custom_pain("You feel a horrible pain as if from a sharp knife in your [affected.display_name]!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] has made an incision on [target]'s [affected.display_name] with \the [tool].", \
		"\blue You have made an incision on [target]'s [affected.display_name] with \the [tool].",)
		affected.open = 1
		affected.createwound(CUT, 1)
		if (target_zone == "head")
			target.brain_op_stage = 1

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, slicing open [target]'s [affected.display_name] in a wrong spot with \the [tool]!", \
		"\red Your hand slips, slicing open [target]'s [affected.display_name] in a wrong spot with \the [tool]!")
		affected.createwound(CUT, 10)

/datum/surgery_step/generic/clamp_bleeders
	required_tool = /obj/item/weapon/hemostat
	allowed_tools = list(/obj/item/weapon/cable_coil, /obj/item/device/assembly/mousetrap)

	min_duration = 40
	max_duration = 60

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return ..() && affected.open && (affected.status & ORGAN_BLEEDING)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts clamping bleeders in [target]'s [affected.display_name] with \the [tool].", \
		"You start clamping bleeders in [target]'s [affected.display_name] with \the [tool].")
		target.custom_pain("The pain in your [affected.display_name] is maddening!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] clamps bleeders in [target]'s [affected.display_name] with \the [tool].",	\
		"\blue You clamp bleeders in [target]'s [affected.display_name] with \the [tool].")
		affected.clamp()
		spread_germs_to_organ(affected, user)

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, tearing blood vessals and causing massive bleeding in [target]'s [affected.display_name] with the \[tool]!",	\
		"\red Your hand slips, tearing blood vessels and causing massive bleeding in [target]'s [affected.display_name] with \the [tool]!",)
		affected.createwound(CUT, 10)

/datum/surgery_step/generic/retract_skin
	required_tool = /obj/item/weapon/retractor
	allowed_tools = list(/obj/item/weapon/crowbar,/obj/item/weapon/kitchen/utensil/fork)

	min_duration = 30
	max_duration = 40

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
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
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
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

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
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
	allowed_tools = list(/obj/item/weapon/weldingtool, /obj/item/clothing/mask/cigarette, /obj/item/weapon/lighter)

	min_duration = 70
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return ..() && affected.open && target_zone != "mouth"

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] is beginning to cauterize the incision on [target]'s [affected.display_name] with \the [tool]." , \
		"You are beginning to cauterize the incision on [target]'s [affected.display_name] with \the [tool].")
		target.custom_pain("Your [affected.display_name] is being burned!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] cauterizes the incision on [target]'s [affected.display_name] with \the [tool].", \
		"\blue You cauterize the incision on [target]'s [affected.display_name] with \the [tool].")
		affected.open = 0
		affected.germ_level = 0
		affected.status &= ~ORGAN_BLEEDING

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, leaving a small burn on [target]'s [affected.display_name] with \the [tool]!", \
		"\red Your hand slips, leaving a small burn on [target]'s [affected.display_name] with \the [tool]!")
		target.apply_damage(3, BURN, affected)

/datum/surgery_step/generic/cut_limb
	required_tool = /obj/item/weapon/circular_saw

	min_duration = 110
	max_duration = 160

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target_zone != "chest" && target_zone != "groin" && target_zone != "head"

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] is beginning to cut off [target]'s [affected.display_name] with \the [tool]." , \
		"You are beginning to cut off [target]'s [affected.display_name] with \the [tool].")
		target.custom_pain("Your [affected.display_name] is being ripped apart!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] cuts off [target]'s [affected.display_name] with \the [tool].", \
		"\blue You cut off [target]'s [affected.display_name] with \the [tool].")
		affected.droplimb(1,1)

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, sawwing through the bone in [target]'s [affected.display_name] with \the [tool]!", \
		"\red Your hand slips, sawwing through the bone in [target]'s [affected.display_name] with \the [tool]!")
		affected.createwound(CUT, 30)
		affected.fracture()
