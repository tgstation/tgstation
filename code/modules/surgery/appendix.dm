//Procedures in this file: Appendectomy
//////////////////////////////////////////////////////////////////
//						APPENDECTOMY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/appendectomy/
	priority = 2
	can_infect = 1
	blood_level = 1
	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if (target_zone != "groin")
			return 0
		var/datum/organ/external/groin = target.get_organ("groin")
		if (!groin)
			return 0
		if (groin.open < 2)
			return 0
		return 1

/datum/surgery_step/appendectomy/cut_appendix
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

	min_duration = 70
	max_duration = 90

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target.op_stage.appendix == 0

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts to separate [target]'s appendix from the abdominal wall with \the [tool].", \
		"You start to separate [target]'s appendix from the abdominal wall with \the [tool]." )
		target.custom_pain("The pain in your abdomen is living hell!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] has separated [target]'s appendix with \the [tool]." , \
		"\blue You have separated [target]'s appendix with \the [tool].")
		target.op_stage.appendix = 1

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/groin = target.get_organ("groin")
		user.visible_message("\red [user]'s hand slips, slicing an artery inside [target]'s abdomen with \the [tool]!", \
		"\red Your hand slips, slicing an artery inside [target]'s abdomen with \the [tool]!")
		groin.createwound(CUT, 50, 1)

/datum/surgery_step/appendectomy/remove_appendix
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100,	\
	/obj/item/weapon/wirecutters = 75,	\
	/obj/item/weapon/kitchen/utensil/fork = 20
	)

	min_duration = 60
	max_duration = 80

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target.op_stage.appendix == 1

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts removing [target]'s appendix with \the [tool].", \
		"You start removing [target]'s appendix with \the [tool].")
		target.custom_pain("Someone's ripping out your bowels!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] has removed [target]'s appendix with \the [tool].", \
		"\blue You have removed [target]'s appendix with \the [tool].")
		var/app = 0
		for(var/datum/disease/appendicitis/appendicitis in target.viruses)
			app = 1
			appendicitis.cure()
			target.resistances += appendicitis
		if (app)
			new /obj/item/weapon/reagent_containers/food/snacks/appendix/inflamed(get_turf(target))
		else
			new /obj/item/weapon/reagent_containers/food/snacks/appendix(get_turf(target))
		target.op_stage.appendix = 2

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, nicking internal organs in [target]'s abdomen with \the [tool]!", \
		"\red Your hand slips, nicking internal organs in [target]'s abdomen with \the [tool]!")
		affected.createwound(BRUISE, 20)
