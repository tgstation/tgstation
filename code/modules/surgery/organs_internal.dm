// Internal surgeries.
/datum/surgery_step/internal
	priority = 2
	can_infect = 1
	blood_level = 1

/datum/surgery_step/internal/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if (!hasorgans(target))
		return 0

	var/datum/organ/external/affected = target.get_organ(target_zone)
	return affected.open == (affected.encased ? 3 : 2)

//////////////////////////////////////////////////////////////////
//					ALIEN EMBRYO SURGERY						//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/internal/remove_embryo
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100,	\
	/obj/item/weapon/wirecutters = 75,	\
	/obj/item/weapon/kitchen/utensil/fork = 20
	)
	blood_level = 2

	min_duration = 80
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/embryo = 0
		for(var/obj/item/alien_embryo/A in target)
			embryo = 1
			break

		if (!hasorgans(target))
			return
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return ..() && embryo && affected.open == 3 && target_zone == "chest"

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/msg = "[user] starts to pull something out from [target]'s ribcage with \the [tool]."
		var/self_msg = "You start to pull something out from [target]'s ribcage with \the [tool]."
		user.visible_message(msg, self_msg)
		target.custom_pain("Something hurts horribly in your chest!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\red [user] rips the larva out of [target]'s ribcage!",
							 "You rip the larva out of [target]'s ribcage!")

		for(var/obj/item/alien_embryo/A in target)
			A.loc = A.loc.loc


//////////////////////////////////////////////////////////////////
//				CHEST INTERNAL ORGAN SURGERY					//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/internal/fix_organ
	allowed_tools = list(
	/obj/item/stack/medical/advanced/bruise_pack= 100,		\
	/obj/item/stack/medical/bruise_pack = 50,	\
	/obj/item/stack/medical/bruise_pack/tajaran = 75, 		\
	)

	min_duration = 70
	max_duration = 90

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		if (!hasorgans(target))
			return
		var/datum/organ/external/affected = target.get_organ(target_zone)

		var/is_organ_damaged = 0
		for(var/datum/organ/internal/I in affected.internal_organs)
			if(I.damage > 0)
				is_organ_damaged = 1
				break
		return ..() && is_organ_damaged

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/tool_name = "\the [tool]"
		if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
			tool_name = "regenerative membrane"
		if (istype(tool, /obj/item/stack/medical/bruise_pack))
			if (istype(tool, /obj/item/stack/medical/bruise_pack/tajaran))
				tool_name = "the poultice"
			else
				tool_name = "the bandaid"

		if (!hasorgans(target))
			return
		var/datum/organ/external/affected = target.get_organ(target_zone)

		for(var/datum/organ/internal/I in affected.internal_organs)
			if(I && I.damage > 0)
				if(I.robotic < 2)
					user.visible_message("[user] starts treating damage to [target]'s [I.name] with [tool_name].", \
					"You start treating damage to [target]'s [I.name] with [tool_name]." )

		target.custom_pain("The pain in your [affected.display_name] is living hell!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/tool_name = "\the [tool]"
		if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
			tool_name = "regenerative membrane"
		if (istype(tool, /obj/item/stack/medical/bruise_pack))
			if (istype(tool, /obj/item/stack/medical/bruise_pack/tajaran))
				tool_name = "the poultice"
			else
				tool_name = "the bandaid"

		if (!hasorgans(target))
			return
		var/datum/organ/external/affected = target.get_organ(target_zone)

		for(var/datum/organ/internal/I in affected.internal_organs)
			if(I && I.damage > 0)
				if(I.robotic < 2)
					user.visible_message("\blue [user] treats damage to [target]'s [I.name] with [tool_name].", \
					"\blue You treat damage to [target]'s [I.name] with [tool_name]." )
					I.damage = 0

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		if (!hasorgans(target))
			return
		var/datum/organ/external/affected = target.get_organ(target_zone)

		user.visible_message("\red [user]'s hand slips, getting mess and tearing the inside of [target]'s [affected.display_name] with \the [tool]!", \
		"\red Your hand slips, getting mess and tearing the inside of [target]'s [affected.display_name] with \the [tool]!")
		var/dam_amt = 2

		if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
			target.adjustToxLoss(5)

		else if (istype(tool, /obj/item/stack/medical/bruise_pack))
			if (istype(tool, /obj/item/stack/medical/bruise_pack/tajaran))
				target.adjustToxLoss(7)
			else
				dam_amt = 5
				target.adjustToxLoss(10)
				affected.createwound(CUT, 5)

		for(var/datum/organ/internal/I in affected.internal_organs)
			if(I && I.damage > 0)
				I.take_damage(dam_amt,0)

/datum/surgery_step/internal/fix_organ_robotic //For artificial organs
	allowed_tools = list(
	/obj/item/stack/nanopaste = 100,		\
	/obj/item/weapon/bonegel = 30, 		\
	/obj/item/weapon/screwdriver = 70,	\
	)

	min_duration = 70
	max_duration = 90

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		if (!hasorgans(target))
			return
		var/datum/organ/external/affected = target.get_organ(target_zone)

		var/is_organ_damaged = 0
		for(var/datum/organ/internal/I in affected.internal_organs)
			if(I.damage > 0 && I.robotic >= 2)
				is_organ_damaged = 1
				break
		return ..() && is_organ_damaged

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		if (!hasorgans(target))
			return
		var/datum/organ/external/affected = target.get_organ(target_zone)

		for(var/datum/organ/internal/I in affected.internal_organs)
			if(I && I.damage > 0)
				if(I.robotic >= 2)
					user.visible_message("[user] starts mending the damage to [target]'s [I.name]'s mechanisms.", \
					"You start mending the damage to [target]'s [I.name]'s mechanisms." )

		target.custom_pain("The pain in your [affected.display_name] is living hell!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		if (!hasorgans(target))
			return
		var/datum/organ/external/affected = target.get_organ(target_zone)

		for(var/datum/organ/internal/I in affected.internal_organs)

			if(I && I.damage > 0)
				if(I.robotic >= 2)
					user.visible_message("\blue [user] repairs [target]'s [I.name] with [tool].", \
					"\blue You repair [target]'s [I.name] with [tool]." )
					I.damage = 0

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		if (!hasorgans(target))
			return
		var/datum/organ/external/affected = target.get_organ(target_zone)

		user.visible_message("\red [user]'s hand slips, gumming up the mechanisms inside of [target]'s [affected.display_name] with \the [tool]!", \
		"\red Your hand slips, gumming up the mechanisms inside of [target]'s [affected.display_name] with \the [tool]!")

		target.adjustToxLoss(5)
		affected.createwound(CUT, 5)

		for(var/datum/organ/internal/I in affected.internal_organs)
			if(I)
				I.take_damage(rand(3,5),0)


/datum/surgery_step/internal/detatch_organ

	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

	min_duration = 90
	max_duration = 110

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		if (!..())
			return 0

		target.op_stage.current_organ = null

		var/list/attached_organs = list()
		for(var/organ in target.internal_organs_by_name)
			var/datum/organ/internal/I = target.internal_organs_by_name[organ]
			if(!I.status && I.parent_organ == target_zone)
				attached_organs |= organ

		var/organ_to_remove = input(user, "Which organ do you want to prepare for removal?") as null|anything in attached_organs
		if(!organ_to_remove)
			return 0

		target.op_stage.current_organ = organ_to_remove

		return ..() && organ_to_remove

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		var/datum/organ/external/affected = target.get_organ(target_zone)

		user.visible_message("[user] starts to separate [target]'s [target.op_stage.current_organ] with \the [tool].", \
		"You start to separate [target]'s [target.op_stage.current_organ] with \the [tool]." )
		target.custom_pain("The pain in your [affected.display_name] is living hell!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] has separated [target]'s [target.op_stage.current_organ] with \the [tool]." , \
		"\blue You have separated [target]'s [target.op_stage.current_organ] with \the [tool].")

		var/datum/organ/internal/I = target.internal_organs_by_name[target.op_stage.current_organ]
		if(I && istype(I))
			I.status |= ORGAN_CUT_AWAY

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, slicing an artery inside [target]'s [affected.display_name] with \the [tool]!", \
		"\red Your hand slips, slicing an artery inside [target]'s [affected.display_name] with \the [tool]!")
		affected.createwound(CUT, rand(30,50), 1)

/datum/surgery_step/internal/remove_organ

	allowed_tools = list(
	/obj/item/weapon/hemostat = 100,	\
	/obj/item/weapon/wirecutters = 75,	\
	/obj/item/weapon/kitchen/utensil/fork = 20
	)

	min_duration = 60
	max_duration = 80

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		if (!..())
			return 0

		target.op_stage.current_organ = null

		var/list/removable_organs = list()
		for(var/organ in target.internal_organs_by_name)
			var/datum/organ/internal/I = target.internal_organs_by_name[organ]
			if(I.status & ORGAN_CUT_AWAY && I.parent_organ == target_zone)
				removable_organs |= organ

		var/organ_to_remove = input(user, "Which organ do you want to remove?") as null|anything in removable_organs
		if(!organ_to_remove)
			return 0

		target.op_stage.current_organ = organ_to_remove
		return ..()

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts removing [target]'s [target.op_stage.current_organ] with \the [tool].", \
		"You start removing [target]'s [target.op_stage.current_organ] with \the [tool].")
		target.custom_pain("Someone's ripping out your [target.op_stage.current_organ]!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] has removed [target]'s [target.op_stage.current_organ] with \the [tool].", \
		"\blue You have removed [target]'s [target.op_stage.current_organ] with \the [tool].")

		// Extract the organ!
		if(target.op_stage.current_organ)

			var/datum/organ/external/affected = target.get_organ(target_zone)
			var/datum/organ/internal/I = target.internal_organs_by_name[target.op_stage.current_organ]

			var/obj/item/organ/O
			if(I && istype(I))
				O = I.remove(user)
				if(O && istype(O))

					// Stop the organ from continuing to reject.
					O.organ_data.rejecting = null

					// Transfer over some blood data, if the organ doesn't have data.
					var/datum/reagent/blood/organ_blood = O.reagents.reagent_list["blood"]
					if(!organ_blood || !organ_blood.data["blood_DNA"])
						target.vessel.trans_to(O, 5, 1, 1)

					// Kinda redundant, but I'm getting some buggy behavior.
					target.internal_organs_by_name[target.op_stage.current_organ] = null
					target.internal_organs_by_name -= target.op_stage.current_organ
					target.internal_organs -= O.organ_data
					affected.internal_organs -= O.organ_data
					O.removed(target,user)

			target.op_stage.current_organ = null

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, damaging the flesh in [target]'s [affected.display_name] with \the [tool]!", \
		"\red Your hand slips, damaging the flesh in [target]'s [affected.display_name] with \the [tool]!")
		affected.createwound(BRUISE, 20)

/datum/surgery_step/internal/replace_organ
	allowed_tools = list(
	/obj/item/organ = 100
	)

	min_duration = 60
	max_duration = 80

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		var/obj/item/organ/O = tool
		var/datum/organ/external/affected = target.get_organ(target_zone)

		var/organ_compatible
		var/organ_missing

		if(!istype(O))
			return 0

		if(target.species && target.species.has_organ[O.organ_tag])

			if(!O.health)
				user << "\red \The [O.organ_tag] is dead."
				return 0

			if(!target.internal_organs_by_name[O.organ_tag])
				organ_missing = 1
			else
				user << "\red \The [target] already has a [O.organ_tag]." //TODO: grammar.
				return 0

			if(O.organ_data && affected.name == O.organ_data.parent_organ)
				organ_compatible = 1
			else
				user << "\red \The [O.organ_tag] doesn't normally go in \the [affected.display_name]."
				return 0
		else
			user << "\red \A [target.species.name] doesn't normally have a [O.organ_tag]." //TODO: grammar.
			return 0

		return ..() && organ_missing && organ_compatible

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts transplanting \the [tool] into [target]'s [affected.display_name].", \
		"You start transplanting \the [tool] into [target]'s [affected.display_name].")
		target.custom_pain("Someone's rooting around in your [affected.display_name]!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] has transplanted \the [tool] into [target]'s [affected.display_name].", \
		"\blue You have transplanted \the [tool] into [target]'s [affected.display_name].")
		user.drop_item(tool)
		var/obj/item/organ/O = tool

		if(istype(O))

			if(!O.organ_data.transplant_data)
				O.organ_data.transplant_data = list()
				O.organ_data.transplant_data["species"] = target.species.name
				O.organ_data.transplant_data["blood_type"] = target.dna.b_type
				O.organ_data.transplant_data["blood_DNA"] = target.dna.unique_enzymes

			O.organ_data.owner = target
			target.internal_organs |= O.organ_data
			affected.internal_organs |= O.organ_data
			target.internal_organs_by_name[O.organ_tag] = O.organ_data
			O.organ_data.status |= ORGAN_CUT_AWAY
			O.replaced(target)

		del(O)

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\red [user]'s hand slips, damaging \the [tool]!", \
		"\red Your hand slips, damaging \the [tool]!")
		var/obj/item/organ/I = tool
		if(istype(I))
			I.organ_data.take_damage(rand(3,5),0)

/datum/surgery_step/internal/attach_organ
	allowed_tools = list(
	/obj/item/weapon/FixOVein = 100, \
	/obj/item/weapon/cable_coil = 75
	)

	min_duration = 100
	max_duration = 120

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		if (!..())
			return 0

		target.op_stage.current_organ = null

		var/list/removable_organs = list()
		for(var/organ in target.internal_organs_by_name)
			var/datum/organ/internal/I = target.internal_organs_by_name[organ]
			if(I.status & ORGAN_CUT_AWAY && I.parent_organ == target_zone)
				removable_organs |= organ

		var/organ_to_replace = input(user, "Which organ do you want to reattach?") as null|anything in removable_organs
		if(!organ_to_replace)
			return 0

		target.op_stage.current_organ = organ_to_replace
		return ..()

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] begins reattaching [target]'s [target.op_stage.current_organ] with \the [tool].", \
		"You start reattaching [target]'s [target.op_stage.current_organ] with \the [tool].")
		target.custom_pain("Someone's digging needles into your [target.op_stage.current_organ]!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] has reattached [target]'s [target.op_stage.current_organ] with \the [tool]." , \
		"\blue You have reattached [target]'s [target.op_stage.current_organ] with \the [tool].")

		var/datum/organ/internal/I = target.internal_organs_by_name[target.op_stage.current_organ]
		if(I && istype(I))
			I.status &= ~ORGAN_CUT_AWAY

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, damaging the flesh in [target]'s [affected.display_name] with \the [tool]!", \
		"\red Your hand slips, damaging the flesh in [target]'s [affected.display_name] with \the [tool]!")
		affected.createwound(BRUISE, 20)

//////////////////////////////////////////////////////////////////
//						HEART SURGERY							//
//////////////////////////////////////////////////////////////////
// To be finished after some tests.
// /datum/surgery_step/ribcage/heart/cut
//	allowed_tools = list(
//	/obj/item/weapon/scalpel = 100,		\
//	/obj/item/weapon/kitchenknife = 75,	\
//	/obj/item/weapon/shard = 50, 		\
//	)

//	min_duration = 30
//	max_duration = 40

//	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
//		return ..() && target.op_stage.ribcage == 2