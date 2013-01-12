//Procedures in this file: Eye mending surgery
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
	allowed_tools = list(/obj/item/weapon/shard, /obj/item/weapon/kitchenknife)

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
	allowed_tools = list(/obj/item/weapon/kitchen/utensil/fork)

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
	allowed_tools = list(/obj/item/weapon/cable_coil, /obj/item/device/assembly/mousetrap)

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
	allowed_tools = list(/obj/item/weapon/weldingtool, /obj/item/clothing/mask/cigarette, /obj/item/weapon/lighter)

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