//The proceeding is a minor surgery for anal cheek removal.
///////////////////////////////////////////////////////////
////                                      BUTT REMOVAL ////
///////////////////////////////////////////////////////////

/datum/surgery_step/butt
	priority = 0
	can_infect = 0
	blood_level = 1
	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return target_zone == "groin" && hasorgans(target)


//And thus begins the madness.

/datum/surgery_step/butt/slice_cheek
	allowed_tools = list(
	/obj/item/weapon/circular_saw = 100, \
	/obj/item/weapon/hatchet = 75
	)

	min_duration = 50
	max_duration = 70

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target_zone == "groin" && target.op_stage.butt == 0 && istype(target)


	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] begins to slice [target]'s ass cheek with \the [tool].", \
		"You begin to slice [target]'s ass cheek with \the [tool].")
		target.custom_pain("You haven't felt a pain like this since college!",1)
		..()


	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] has sliced through [target]'s ass cheek with \the [tool].",		\
		"\blue You have sliced through [target]'s ass cheek with \the [tool].")
		target.op_stage.butt = 1



	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\red [user]'s hand slips, cutting [target]'s ass with \the [tool]!" , \
		"\red Your hand slips, cutting [target]'s ass with \the [tool]!" )
		target.apply_damage(max(10, tool.force), BRUTE, "groin")



/datum/surgery_step/butt/seperate_anus
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

	min_duration = 80
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target.op_stage.butt == 1


	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts shortening the end of [target]'s anus with \the [tool].", \
		"You start shortening the end of [target]'s anus with \the [tool].")
		target.custom_pain("It feels like that hamster is chewing its way out!",1)
		..()


	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] shortens the end of [target]'s anus with \the [tool].",	\
		"\blue You shorten [target]'s anus with \the [tool].")
		target.op_stage.butt = 2


	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\red [user]'s hand slips, cutting a vein in [target]'s anus with \the [tool]!", \
		"\red Your hand slips, cutting a vein in [target]'s anus with \the [tool]!")
		target.apply_damage(50, BRUTE, "groin", 1)



/datum/surgery_step/butt/saw_hip
	allowed_tools = list(
	/obj/item/weapon/circular_saw = 100, \
	/obj/item/weapon/hatchet = 75
	)

	min_duration = 50
	max_duration = 70

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target_zone == "groin" && target.op_stage.butt == 2

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] begins to cut off ends of [target]'s hip with \the [tool].", \
		"You begin to cut off ends of [target]'s hip with \the [tool].")
		target.custom_pain("THE PAIN!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] finishes cutting [target]'s hip with \the [tool].",		\
		"\blue You have cut [target]'s hip with \the [tool].")
		target.op_stage.butt = 3

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\red [user]'s hand slips, cracking [target]'s hip with \the [tool]!" , \
		"\red Your hand slips, cracking [target]'s hip with \the [tool]!" )
		target.apply_damage(max(10, tool.force), BRUTE, "groin")


/datum/surgery_step/butt/cauterize_butt
	allowed_tools = list(
	/obj/item/weapon/cautery = 100,			\
	/obj/item/clothing/mask/cigarette = 75,	\
	/obj/item/weapon/lighter = 50,			\
	/obj/item/weapon/weldingtool = 25
	)

	min_duration = 50
	max_duration = 70

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target_zone == "groin" && target.op_stage.butt == 3

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] begins to cauterize [target]'s ass with \the [tool].", \
		"You begin to cauterize [target]'s ass with \the [tool].")
		target.custom_pain("IT BUURNS!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] finishes cauterizing [target]'s ass with \the [tool].",		\
		"\blue You have cauterized [target]'s ass with \the [tool].")
		var/obj/item/clothing/head/butt/B = new(target.loc)
		B.transfer_buttdentity(target)
		target.op_stage.butt = 4

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\red [target] lets out a small fart, which gets set alight with [user]'s [tool]!" , \
		"\red [target] farts into the open flame, burning his anus!" )
		target.apply_damage(max(10, tool.force), BURN, "groin")
		playsound(get_turf(src), 'sound/effects/holler.ogg', 50, 1)



//why god.
