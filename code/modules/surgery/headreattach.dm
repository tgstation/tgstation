//This is an uguu head restoration surgery TOTALLY not yoinked from chinsky's limb reattacher


/datum/surgery_step/head/
	can_infect = 0
	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
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
		return target_zone == LIMB_HEAD



////////PEEL//////
/datum/surgery_step/head/peel
	allowed_tools = list(
		/obj/item/weapon/retractor = 100,
		/obj/item/weapon/crowbar = 75,
		/obj/item/weapon/kitchen/utensil/fork = 50,
		)

	min_duration = 80
	max_duration = 100


/datum/surgery_step/head/peel/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts peeling back tattered flesh where [target]'s head used to be with \the [tool].", \
	"You start peeling back tattered flesh where [target]'s head used to be with \the [tool].")
	..()

/datum/surgery_step/head/peel/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] peels back tattered flesh where [target]'s head used to be with \the [tool].</span>",	\
	"<span class='notice'>You peel back tattered flesh where [target]'s head used to be with \the [tool].</span>")
	affected.status |= ORGAN_CUT_AWAY

/datum/surgery_step/head/peel/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if (affected.parent)
		affected = affected.parent
		user.visible_message("<span class='warning'>[user]'s hand slips, ripping [target]'s [affected.display_name] open!</span>", \
		"<span class='warning'>Your hand slips,  ripping [target]'s [affected.display_name] open!</span>")
		affected.createwound(CUT, 10)



//////SHAPE///////
/datum/surgery_step/head/shape
	allowed_tools = list(
		/obj/item/weapon/FixOVein = 100,
		/obj/item/stack/cable_coil = 75,
		/obj/item/device/assembly/mousetrap = 10,	//ok chinsky
		)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/head/shape/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	return ..() && (affected.status & ORGAN_CUT_AWAY) && affected.open != 3

/datum/surgery_step/head/shape/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] is beginning to reshape [target]'s esophagal and vocal region with \the [tool].", \
	"You start to reshape [target]'s [affected.display_name] esophagal and vocal region with \the [tool].")
	..()

/datum/surgery_step/head/shape/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has finished repositioning flesh and tissue to something anatomically recognizable where [target]'s head used to be with \the [tool].</span>",	\
	"<span class='notice'>You have finished repositioning flesh and tissue to something anatomically recognizable where [target]'s head used to be with \the [tool].</span>")
	affected.open = 3

/datum/surgery_step/head/shape/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if (affected.parent)
		affected = affected.parent
		user.visible_message("<span class='warning'>[user]'s hand slips, further rending flesh on [target]'s neck!</span>", \
		"<span class='warning'>Your hand slips, further rending flesh on [target]'s neck!</span>")
		target.apply_damage(10, BRUTE, affected)



//////SUTURE//////
/datum/surgery_step/head/suture
	allowed_tools = list(
		/obj/item/weapon/hemostat = 100,
		/obj/item/stack/cable_coil = 60,
		/obj/item/weapon/FixOVein = 80,
		)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/head/suture/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	return ..() && affected.open == 3

/datum/surgery_step/head/suture/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] is stapling and suturing flesh into place in [target]'s esophagal and vocal region with \the [tool].", \
	"You start to staple and suture flesh into place in [target]'s esophagal and vocal region with \the [tool].")
	..()

/datum/surgery_step/head/suture/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has finished stapling [target]'s neck into place with \the [tool].</span>",	\
	"<span class='notice'>You have finished stapling [target]'s neck into place with \the [tool].</span>")
	affected.open = 4

/datum/surgery_step/head/suture/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if (affected.parent)
		affected = affected.parent
		user.visible_message("<span class='warning'>[user]'s hand slips, ripping apart flesh on [target]'s neck!</span>", \
		"<span class='warning'>Your hand slips, ripping apart flesh on [target]'s neck!</span>")
		target.apply_damage(10, BRUTE, affected)



//////PREPARE///////
/datum/surgery_step/head/prepare/tool_quality(obj/item/tool)
	if(tool.is_hot())
		for (var/T in allowed_tools)
			if (istype(tool,T))
				return allowed_tools[T]
	return 0
/datum/surgery_step/head/prepare
	allowed_tools = list(
		/obj/item/weapon/cautery = 100,
		/obj/item/weapon/scalpel/laser = 100,
		/obj/item/clothing/mask/cigarette = 75,
		/obj/item/weapon/lighter = 50,
		/obj/item/weapon/weldingtool = 25,
		)

	min_duration = 60
	max_duration = 70

/datum/surgery_step/head/prepare/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	return ..() && affected.open == 4

/datum/surgery_step/head/prepare/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts adjusting area around [target]'s neck with \the [tool].", \
	"You start adjusting area around [target]'s neck with \the [tool].")
	..()

/datum/surgery_step/head/prepare/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has finished adjusting the area around [target]'s neck with \the [tool].</span>",	\
	"<span class='notice'>You have finished adjusting the area around [target]'s neck with \the [tool].</span>")
	affected.status |= ORGAN_ATTACHABLE
	affected.amputated = 1
	affected.setAmputatedTree()
	affected.open = 0

/datum/surgery_step/head/prepare/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if (affected.parent)
		affected = affected.parent
		user.visible_message("<span class='warning'>[user]'s hand slips, searing [target]'s neck!</span>", \
		"<span class='warning'>Your hand slips, searing [target]'s [affected.display_name]!</span>")
		target.apply_damage(10, BURN, affected)



//////ATTACH//////
/datum/surgery_step/head/attach
	allowed_tools = list(
		/obj/item/weapon/organ/head = 100,
		)

	can_infect = 0

	min_duration = 80
	max_duration = 100

/datum/surgery_step/head/attach/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/head = target.get_organ(target_zone)
	return ..() && head.status & ORGAN_ATTACHABLE

/datum/surgery_step/head/attach/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts attaching [tool] to [target]'s reshaped neck.", \
	"You start attaching [tool] to [target]'s reshaped neck.")

/datum/surgery_step/head/attach/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has attached [target]'s head to the body.</span>",	\
	"<span class='notice'>You have attached [target]'s head to the body.</span>")
	affected.status = 0
	affected.amputated = 0
	affected.destspawn = 0

	var/obj/item/weapon/organ/O = tool
	if(istype(O))
		affected.species = O.species

	target.update_body()
	target.updatehealth()
	target.UpdateDamageIcon()
	var/obj/item/weapon/organ/head/B = tool
	if (B.brainmob.mind)
		B.brainmob.mind.transfer_to(target)
	target.languages = B.brainmob.languages
	target.default_language = B.brainmob.default_language

	if (B.butchering_drops.len) //Transferring teeth and other stuff
		for(var/datum/butchering_product/BP in B.butchering_drops) //First, search for all "stuff" inside the head

			var/datum/butchering_product/match = locate(BP.type) in target.butchering_drops //See if our guy already has the same thing in him (shouldn't happen, but who knows)
			if(istype(match)) //If he does have a duplicate
				target.butchering_drops -= match //Remove it!
				qdel(match)

			target.butchering_drops.Add(BP) //Transfer
			B.butchering_drops.Remove(BP)

	affected.cancer_stage = B.cancer_stage

	var/datum/organ/internal/brain/copied
	if(B.organ_data)
		var/datum/organ/internal/I = B.organ_data
		copied = I.Copy()
	else
		copied = new
	copied.owner = target
	target.internal_organs_by_name["brain"] = copied
	target.internal_organs += copied
	target.decapitated = null
	affected.internal_organs += copied

	user.u_equip(B,1)
	qdel(B)


/datum/surgery_step/head/attach/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging connectors on [target]'s neck!</span>", \
	"<span class='warning'>Your hand slips, damaging connectors on [target]'s neck!</span>")
	target.apply_damage(10, BRUTE, affected)
