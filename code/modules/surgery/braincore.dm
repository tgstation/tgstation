//Procedures in this file: Brain extraction. Metroid Core extraction.
//////////////////////////////////////////////////////////////////
//						BRAIN SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/brain/
	blood_level = 1
	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return target_zone == "head" && hasorgans(target)

/datum/surgery_step/brain/saw_skull
	required_tool = /obj/item/weapon/circular_saw

	min_duration = 50
	max_duration = 70

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target_zone == "head" && target.brain_op_stage == 1

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] begins to cut through [target]'s skull with \the [tool].", \
		"You begin to cut through [target]'s skull with \the [tool].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] has cut through [target]'s skull open with \the [tool].",		\
		"\blue You have cut through [target]'s skull open with \the [tool].")
		target.brain_op_stage = 2

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\red [user]'s hand slips, cracking [target]'s skull with \the [tool]!" , \
		"\red Your hand slips, cracking [target]'s skull with \the [tool]!" )
		target.apply_damage(10, BRUTE, "head")

/datum/surgery_step/brain/cut_brain
	required_tool = /obj/item/weapon/scalpel
	allowed_tools = list(/obj/item/weapon/shard, /obj/item/weapon/kitchenknife)

	min_duration = 80
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target.brain_op_stage == 2

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts separating connections to [target]'s brain with \the [tool].", \
		"You start separating connections to [target]'s brain with \the [tool].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] separates connections to [target]'s brain with \the [tool].",	\
		"\blue You separate connections to [target]'s brain with \the [tool].")
		target.brain_op_stage = 3

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\red [user]'s hand slips, cutting a vein in [target]'s brain with \the [tool]!", \
		"\red Your hand slips, cutting a vein in [target]'s brain with \the [tool]!")
		target.apply_damage(50, BRUTE, "head", 1)

/datum/surgery_step/brain/saw_spine
	required_tool = /obj/item/weapon/circular_saw

	min_duration = 50
	max_duration = 70

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target.brain_op_stage == 3

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts separating [target]'s brain from \his spine with \the [tool].", \
		"You start separating [target]'s brain from spine with \the [tool].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
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

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\red [user]'s hand slips, cutting a vein in [target]'s brain with \the [tool]!", \
		"\red Your hand slips, cutting a vein in [target]'s brain with \the [tool]!")
		target.apply_damage(30, BRUTE, "head", 1)
		if (ishuman(user))
			user:bloody_body(target)
			user:bloody_hands(target, 0)


//////////////////////////////////////////////////////////////////
//				METROID CORE EXTRACTION							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/metroid/
	can_use(mob/living/user, mob/living/carbon/metroid/target, target_zone, obj/item/tool)
		return istype(target, /mob/living/carbon/metroid/) && target.stat == 2

/datum/surgery_step/metroid/cut_flesh
	required_tool = /obj/item/weapon/scalpel
	allowed_tools = list(/obj/item/weapon/shard, /obj/item/weapon/kitchenknife)

	min_duration = 30
	max_duration = 50

	can_use(mob/living/user, mob/living/carbon/metroid/target, target_zone, obj/item/tool)
		return ..() && target.brain_op_stage == 0

	begin_step(mob/user, mob/living/carbon/metroid/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts cutting [target]'s flesh with \the [tool].", \
		"You start cutting [target]'s flesh with \the [tool].")

	end_step(mob/living/user, mob/living/carbon/metroid/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] cuts [target]'s flesh with \the [tool].",	\
		"\blue You cut [target]'s flesh with \the [tool], exposing the cores")
		target.brain_op_stage = 1

	fail_step(mob/living/user, mob/living/carbon/metroid/target, target_zone, obj/item/tool)
		user.visible_message("\red [user]'s hand slips, tearing [target]'s flesh with \the [tool]!", \
		"\red Your hand slips, tearing [target]'s flesh with \the [tool]!")

/datum/surgery_step/metroid/cut_innards
	required_tool = /obj/item/weapon/scalpel
	allowed_tools = list(/obj/item/weapon/shard, /obj/item/weapon/kitchenknife)

	min_duration = 30
	max_duration = 50

	can_use(mob/living/user, mob/living/carbon/metroid/target, target_zone, obj/item/tool)
		return ..() && target.brain_op_stage == 1

	begin_step(mob/user, mob/living/carbon/metroid/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts cutting [target]'s silky innards apart with \the [tool].", \
		"You start cutting [target]'s silky innards apart with \the [tool].")

	end_step(mob/living/user, mob/living/carbon/metroid/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] cuts [target]'s innards apart with \the [tool], exposing the cores",	\
		"\blue You cut [target]'s innards apart with \the [tool], exposing the cores")
		target.brain_op_stage = 2

	fail_step(mob/living/user, mob/living/carbon/metroid/target, target_zone, obj/item/tool)
		user.visible_message("\red [user]'s hand slips, tearing [target]'s innards with \the [tool]!", \
		"\red Your hand slips, tearing [target]'s innards with \the [tool]!")

/datum/surgery_step/metroid/saw_core
	required_tool = /obj/item/weapon/circular_saw

	min_duration = 50
	max_duration = 70

	can_use(mob/living/user, mob/living/carbon/metroid/target, target_zone, obj/item/tool)
		return ..() && target.brain_op_stage == 2 && target.cores > 0

	begin_step(mob/user, mob/living/carbon/metroid/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts cutting out one of [target]'s cores with \the [tool].", \
		"You start cutting out one of [target]'s cores with \the [tool].")

	end_step(mob/living/user, mob/living/carbon/metroid/target, target_zone, obj/item/tool)
		target.cores--
		user.visible_message("\blue [user] cuts out one of [target]'s cores with \the [tool].",,	\
		"\blue You cut out one of [target]'s cores with \the [tool]. [target.cores] cores left.")
		if(target.cores >= 0)
			new/obj/item/metroid_core(target.loc)
		if(target.cores <= 0)
			target.icon_state = "baby roro dead-nocore"

	fail_step(mob/living/user, mob/living/carbon/metroid/target, target_zone, obj/item/tool)
		user.visible_message("\red [user]'s hand slips, failing to cut core out!", \
		"\red Your hand slips, failing to cut core out!")