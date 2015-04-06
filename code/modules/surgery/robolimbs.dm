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


//////CUT///////
/datum/surgery_step/limb/cut
	allowed_tools = list(
		/obj/item/weapon/scalpel = 100,
		/obj/item/weapon/kitchen/utensil/knife/large = 75,
		/obj/item/weapon/shard = 50,
		)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/limb/cut/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts cutting away flesh where [target]'s [affected.display_name] used to be with \the [tool].", \
	"You start cutting away flesh where [target]'s [affected.display_name] used to be with \the [tool].")
	..()

/datum/surgery_step/limb/cut/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] cuts away flesh where [target]'s [affected.display_name] used to be with \the [tool].</span>",	\
	"<span class='notice'>You cut away flesh where [target]'s [affected.display_name] used to be with \the [tool].</span>")
	affected.status |= ORGAN_CUT_AWAY

/datum/surgery_step/limb/cut/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if (affected.parent)
		affected = affected.parent
		user.visible_message("<span class='warning'>[user]'s hand slips, cutting [target]'s [affected.display_name] open!</span>", \
		"<span class='warning'>Your hand slips,  cutting [target]'s [affected.display_name] open!</span>")
		affected.createwound(CUT, 10)



////////MEND////////
/datum/surgery_step/limb/mend
	allowed_tools = list(
		/obj/item/weapon/retractor = 100,
		/obj/item/weapon/crowbar = 75,
		/obj/item/weapon/kitchen/utensil/fork = 50,
		)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/limb/mend/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	return ..() && affected.status & ORGAN_CUT_AWAY

/datum/surgery_step/limb/mend/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] is beginning reposition flesh and nerve endings where where [target]'s [affected.display_name] used to be with [tool].", \
	"You start repositioning flesh and nerve endings where where [target]'s [affected.display_name] used to be with [tool].")
	..()

/datum/surgery_step/limb/mend/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has finished repositioning flesh and nerve endings where [target]'s [affected.display_name] used to be with [tool].</span>",	\
	"<span class='notice'>You have finished repositioning flesh and nerve endings where [target]'s [affected.display_name] used to be with [tool].</span>")
	affected.open = 3

/datum/surgery_step/limb/mend/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if (affected.parent)
		affected = affected.parent
		user.visible_message("<span class='warning'>[user]'s hand slips, tearing flesh on [target]'s [affected.display_name]!</span>", \
		"<span class='warning'>Your hand slips, tearing flesh on [target]'s [affected.display_name]!</span>")
		target.apply_damage(10, BRUTE, affected)



//////PREPARE///////
/datum/surgery_step/limb/prepare/tool_quality(obj/item/tool)
	if(tool.is_hot())
		for (var/T in allowed_tools)
			if (istype(tool,T))
				return allowed_tools[T]
	return 0
/datum/surgery_step/limb/prepare
	allowed_tools = list(
		/obj/item/weapon/cautery = 100,
		/obj/item/clothing/mask/cigarette = 75,
		/obj/item/weapon/lighter = 50,
		/obj/item/weapon/weldingtool = 25,
		)

	min_duration = 60
	max_duration = 70

/datum/surgery_step/limb/prepare/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	return ..() && affected.open == 3

/datum/surgery_step/limb/prepare/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts adjusting area around [target]'s [affected.display_name] with \the [tool].", \
	"You start adjusting area around [target]'s [affected.display_name] with \the [tool]..")
	..()

/datum/surgery_step/limb/prepare/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has finished adjusting the area around [target]'s [affected.display_name] with \the [tool].</span>",	\
	"<span class='notice'>You have finished adjusting the area around [target]'s [affected.display_name] with \the [tool].</span>")
	affected.status |= ORGAN_ATTACHABLE
	affected.amputated = 1
	affected.setAmputatedTree()
	affected.open = 0

/datum/surgery_step/limb/prepare/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if (affected.parent)
		affected = affected.parent
		user.visible_message("<span class='warning'>[user]'s hand slips, searing [target]'s [affected.display_name]!</span>", \
		"<span class='warning'>Your hand slips, searing [target]'s [affected.display_name]!</span>")
		target.apply_damage(10, BURN, affected)



//////ATTACH///////
/datum/surgery_step/limb/attach
	allowed_tools = list(
		/obj/item/robot_parts = 100,
		)

	can_infect = 0

	min_duration = 80
	max_duration = 100

/datum/surgery_step/limb/attach/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	var/obj/item/robot_parts/p = tool
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if(!(affected.status & ORGAN_ATTACHABLE) || !istype(p))
		return 0 //not even ready for this and we're assuming they're using a fucking robot part!
	if (p.part)
		if (!(target_zone in p.part))
			return 0
	return ..()

/datum/surgery_step/limb/attach/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts attaching [tool] where [target]'s [affected.display_name] used to be.", \
	"You start attaching [tool] where [target]'s [affected.display_name] used to be.")

/datum/surgery_step/limb/attach/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/robot_parts/L = tool
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has attached [tool] where [target]'s [affected.display_name] used to be.</span>",	\
	"<span class='notice'>You have attached [tool] where [target]'s [affected.display_name] used to be.</span>")
	affected.robotize()
	if(L.sabotaged)
		affected.sabotaged = 1
	else
		affected.sabotaged = 0
	target.update_body()
	target.updatehealth()
	target.UpdateDamageIcon()
	del(tool)

/datum/surgery_step/limb/attach/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging connectors on [target]'s [affected.display_name]!</span>", \
	"<span class='warning'>Your hand slips, damaging connectors on [target]'s [affected.display_name]!</span>")
	target.apply_damage(10, BRUTE, affected)



///////ATTACH PLANK///////
/datum/surgery_step/limb/attach_plank
	allowed_tools = list(
		/obj/item/stack/sheet/wood=100,
		)

	can_infect = 0

	min_duration = 80
	max_duration = 100

/datum/surgery_step/limb/attach_plank/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	return ..() && affected.status & ORGAN_ATTACHABLE

/datum/surgery_step/limb/attach_plank/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts attaching [tool] where [target]'s [affected.display_name] used to be.", \
	"You start attaching [tool] where [target]'s [affected.display_name] used to be.")

/datum/surgery_step/limb/attach_plank/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has attached [tool] where [target]'s [affected.display_name] used to be.</span>",	\
	"<span class='notice'>You have attached [tool] where [target]'s [affected.display_name] used to be.</span>")
	affected.peggify()
	target.update_body()
	target.updatehealth()
	target.UpdateDamageIcon()
	var/obj/item/stack/sheet/wood/peg = tool
	peg.use(1)

/datum/surgery_step/limb/attach_plank/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging connectors on [target]'s [affected.display_name]!</span>", \
	"<span class='warning'>Your hand slips, damaging connectors on [target]'s [affected.display_name]!</span>")
	target.apply_damage(10, BRUTE, affected)
