//Procedures in this file: Robotic limbs attachment
//////////////////////////////////////////////////////////////////
//						LIMB SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/limb/
	can_infect = 1
	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if (!hasorgans(target))
			return 0
		var/datum/organ/external/affected = target.get_organ(target_zone)
		if (!affected || affected.name == "head")
			return 0
		if (!(affected.status & ORGAN_DESTROYED))
			return 0
		if (affected.parent)
			if (affected.parent.status & ORGAN_DESTROYED)
				return 0
		return 1


/datum/surgery_step/limb/cut
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

	min_duration = 80
	max_duration = 100

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts cutting away flesh where [target]'s [affected.display_name] used to be with \the [tool].", \
		"You start cutting away flesh where [target]'s [affected.display_name] used to be with \the [tool].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] cuts away flesh where [target]'s [affected.display_name] used to be with \the [tool].",	\
		"\blue You cut away flesh where [target]'s [affected.display_name] used to be with \the [tool].")
		affected.status |= ORGAN_CUT_AWAY

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		if (affected.parent)
			affected = affected.parent
			user.visible_message("\red [user]'s hand slips, cutting [target]'s [affected.display_name] open!", \
			"\red Your hand slips,  cutting [target]'s [affected.display_name] open!")
			affected.createwound(CUT, 10)


/datum/surgery_step/limb/mend
	allowed_tools = list(
	/obj/item/weapon/retractor = 100, 	\
	/obj/item/weapon/crowbar = 75,	\
	/obj/item/weapon/kitchen/utensil/fork = 50)

	min_duration = 80
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return ..() && affected.status & ORGAN_CUT_AWAY

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] is beginning reposition flesh and nerve endings where where [target]'s [affected.display_name] used to be with [tool].", \
		"You start repositioning flesh and nerve endings where where [target]'s [affected.display_name] used to be with [tool].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] has finished repositioning flesh and nerve endings where [target]'s [affected.display_name] used to be with [tool].",	\
		"\blue You have finished repositioning flesh and nerve endings where [target]'s [affected.display_name] used to be with [tool].")
		affected.open = 3

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		if (affected.parent)
			affected = affected.parent
			user.visible_message("\red [user]'s hand slips, tearing flesh on [target]'s [affected.display_name]!", \
			"\red Your hand slips, tearing flesh on [target]'s [affected.display_name]!")
			target.apply_damage(10, BRUTE, affected)


/datum/surgery_step/limb/prepare
	allowed_tools = list(
	/obj/item/weapon/cautery = 100,			\
	/obj/item/clothing/mask/cigarette = 75,	\
	/obj/item/weapon/lighter = 50,			\
	/obj/item/weapon/weldingtool = 25
	)

	min_duration = 60
	max_duration = 70

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return ..() && affected.open == 3

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts adjusting area around [target]'s [affected.display_name] with \the [tool].", \
		"You start adjusting area around [target]'s [affected.display_name] with \the [tool]..")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] has finished adjusting the area around [target]'s [affected.display_name] with \the [tool].",	\
		"\blue You have finished adjusting the area around [target]'s [affected.display_name] with \the [tool].")
		affected.status |= ORGAN_ATTACHABLE
		affected.amputated = 1
		affected.setAmputatedTree()
		affected.open = 0

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		if (affected.parent)
			affected = affected.parent
			user.visible_message("\red [user]'s hand slips, searing [target]'s [affected.display_name]!", \
			"\red Your hand slips, searing [target]'s [affected.display_name]!")
			target.apply_damage(10, BURN, affected)


/datum/surgery_step/limb/attach
	allowed_tools = list(/obj/item/robot_parts = 100)
	can_infect = 0

	min_duration = 80
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
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

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/robot_parts/L = tool
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] has attached [tool] where [target]'s [affected.display_name] used to be.",	\
		"\blue You have attached [tool] where [target]'s [affected.display_name] used to be.")
		affected.robotize()
		if(L.sabotaged)
			affected.sabotaged = 1
		else
			affected.sabotaged = 0
		target.update_body()
		target.updatehealth()
		target.UpdateDamageIcon()
		del(tool)

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, damaging connectors on [target]'s [affected.display_name]!", \
		"\red Your hand slips, damaging connectors on [target]'s [affected.display_name]!")
		target.apply_damage(10, BRUTE, affected)

/datum/surgery_step/limb/attach_plank
	allowed_tools = list(/obj/item/stack/sheet/wood=100)
	can_infect = 0

	min_duration = 80
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return ..() && affected.status & ORGAN_ATTACHABLE

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts attaching [tool] where [target]'s [affected.display_name] used to be.", \
		"You start attaching [tool] where [target]'s [affected.display_name] used to be.")

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] has attached [tool] where [target]'s [affected.display_name] used to be.",	\
		"\blue You have attached [tool] where [target]'s [affected.display_name] used to be.")
		affected.peggify()
		target.update_body()
		target.updatehealth()
		target.UpdateDamageIcon()
		var/obj/item/stack/sheet/wood/peg = tool
		peg.use(1)

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, damaging connectors on [target]'s [affected.display_name]!", \
		"\red Your hand slips, damaging connectors on [target]'s [affected.display_name]!")
		target.apply_damage(10, BRUTE, affected)
