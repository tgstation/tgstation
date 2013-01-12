//Procedures in this file: Robotic limbs attachment
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
	allowed_tools = list(/obj/item/weapon/shard, /obj/item/weapon/kitchenknife)

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
	allowed_tools = list(/obj/item/weapon/kitchen/utensil/fork)

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
	allowed_tools = list(/obj/item/weapon/weldingtool, /obj/item/clothing/mask/cigarette, /obj/item/weapon/lighter)

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
		affected.setAmputatedTree()
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
