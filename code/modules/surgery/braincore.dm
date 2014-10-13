//Procedures in this file: Brain extraction. Brain fixing. Slime Core extraction.
//////////////////////////////////////////////////////////////////
//						BRAIN SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/brain/
	priority = 2
	blood_level = 1
	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return target_zone == "head" && hasorgans(target)

/datum/surgery_step/brain/saw_skull
	allowed_tools = list(
	/obj/item/weapon/circular_saw = 100, \
	/obj/item/weapon/hatchet = 75
	)

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
		target.apply_damage(max(10, tool.force), BRUTE, "head")

/datum/surgery_step/brain/cut_brain
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

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
	allowed_tools = list(
	/obj/item/weapon/circular_saw = 100, \
	/obj/item/weapon/hatchet = 75
	)

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
		msg_admin_attack("[user.name] ([user.ckey]) debrained [target.name] ([target.ckey]) with [tool.name] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
		if(!iscarbon(user))
			target.LAssailant = null
		else
			target.LAssailant = user

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
//				BRAIN DAMAGE FIXING								//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/brain/bone_chips
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100, 		\
	/obj/item/weapon/wirecutters = 75, 		\
	/obj/item/weapon/kitchen/utensil/fork = 20
	)

	min_duration = 80
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target.brain_op_stage == 2

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts taking out bone chips and out of [target]'s brain with \the [tool].", \
		"You start taking out bone chips and out of [target]'s brain with \the [tool].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] takes out all bone chips out of [target]'s brain with \the [tool].",	\
		"\blue You take out all bone chips out of [target]'s brain with \the [tool].")
		target.brain_op_stage = 3


	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\red [user]'s hand slips, jabbing \the [tool] in [target]'s brain!", \
		"\red Your hand slips, jabbing \the [tool] in [target]'s brain!")
		target.apply_damage(30, BRUTE, "head", 1)

/datum/surgery_step/brain/hematoma
	allowed_tools = list(
	/obj/item/weapon/FixOVein = 100, \
	/obj/item/weapon/cable_coil = 75
	)

	min_duration = 90
	max_duration = 110

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target.brain_op_stage == 3

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts mending hematoma in [target]'s brain with \the [tool].", \
		"You start mending hematoma in [target]'s brain with \the [tool].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] mends hematoma in [target]'s brain with \the [tool].",	\
		"\blue You mend hematoma in [target]'s brain with \the [tool].")
		var/datum/organ/internal/brain/sponge = target.internal_organs_by_name["brain"]
		if (sponge)
			sponge.damage = 0


	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\red [user]'s hand slips, bruising [target]'s brain with \the [tool]!", \
		"\red Your hand slips, bruising [target]'s brain with \the [tool]!")
		target.apply_damage(20, BRUTE, "head", 1)

//////////////////////////////////////////////////////////////////
//				SLIME CORE EXTRACTION							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/slime/
	can_use(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
		return istype(target, /mob/living/carbon/slime/) && target.stat == 2

/datum/surgery_step/slime/cut_flesh
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

	min_duration = 30
	max_duration = 50

	can_use(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
		return ..() && target.brain_op_stage == 0

	begin_step(mob/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts cutting [target]'s flesh with \the [tool].", \
		"You start cutting [target]'s flesh with \the [tool].")

	end_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] cuts [target]'s flesh with \the [tool].",	\
		"\blue You cut [target]'s flesh with \the [tool], exposing the cores")
		target.brain_op_stage = 1

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
		return ..() && target.brain_op_stage == 1

	begin_step(mob/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts cutting [target]'s silky innards apart with \the [tool].", \
		"You start cutting [target]'s silky innards apart with \the [tool].")

	end_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] cuts [target]'s innards apart with \the [tool], exposing the cores",	\
		"\blue You cut [target]'s innards apart with \the [tool], exposing the cores")
		target.brain_op_stage = 2

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
		return ..() && target.brain_op_stage == 2 && target.cores > 0

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
			var/origstate = initial(target.icon_state)
			target.icon_state = "[origstate] dead-nocore"


	fail_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
		user.visible_message("\red [user]'s hand slips, failing to cut core out!", \
		"\red Your hand slips, failing to cut core out!")