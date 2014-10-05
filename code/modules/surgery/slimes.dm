//////////////////////////////////////////////////////////////////
//				SLIME CORE EXTRACTION							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/slime
	is_valid_mutantrace(mob/living/carbon/slime/target)
		return istype(target, /mob/living/carbon/slime/)

	can_use(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
		return target.stat == 2

/datum/surgery_step/slime/cut_flesh
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

	min_duration = 30
	max_duration = 50

	can_use(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
		return ..() && istype(target) && target.core_removal_stage == 0

	begin_step(mob/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts cutting through [target]'s flesh with \the [tool].", \
		"You start cutting through [target]'s flesh with \the [tool].")

	end_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] cuts through [target]'s flesh with \the [tool].",	\
		"\blue You cut through [target]'s flesh with \the [tool], revealing its silky innards.")
		target.core_removal_stage = 1

	fail_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
		user.visible_message("\red [user]'s hand slips, tearing [target]'s flesh with \the [tool]!", \
		"\red Your hand slips, tearing [target]'s flesh with \the [tool]!")

/datum/surgery_step/slime/cut_innards
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

	min_duration = 30
	max_duration = 50

	can_use(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
		return ..() && istype(target) && target.core_removal_stage == 1

	begin_step(mob/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts cutting [target]'s silky innards apart with \the [tool].", \
		"You start cutting [target]'s silky innards apart with \the [tool].")

	end_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] cuts [target]'s innards apart with \the [tool], exposing the cores.",	\
		"\blue You cut [target]'s innards apart with \the [tool], exposing the cores.")
		target.core_removal_stage = 2

	fail_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
		user.visible_message("\red [user]'s hand slips, tearing [target]'s innards with \the [tool]!", \
		"\red Your hand slips, tearing [target]'s innards with \the [tool]!")

/datum/surgery_step/slime/saw_core
	allowed_tools = list(
	/obj/item/weapon/circular_saw = 100, \
	/obj/item/weapon/hatchet = 75
	)

	min_duration = 50
	max_duration = 70

	can_use(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
		return ..() && (istype(target) && target.core_removal_stage == 2 && target.cores > 0) //This is being passed a human as target, unsure why.

	begin_step(mob/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts cutting out one of [target]'s cores with \the [tool].", \
		"You start cutting out one of [target]'s cores with \the [tool].")

	end_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
		target.cores--
		user.visible_message("\blue [user] cuts out one of [target]'s cores with \the [tool].",,	\
		"\blue You cut out one of [target]'s cores with \the [tool]. [target.cores] cores left.")

		if(target.cores >= 0)
			new target.coretype(target.loc)
		if(target.cores <= 0)
			target.icon_state = "[target.colour] baby slime dead-nocore"


	fail_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
		user.visible_message("\red [user]'s hand slips, causing \him to miss the core!", \
		"\red Your hand slips, causing you to miss the core!")