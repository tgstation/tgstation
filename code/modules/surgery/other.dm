//Procedures in this file: Inernal wound patching, Implant removal.
//////////////////////////////////////////////////////////////////
//					INTERNAL WOUND PATCHING						//
//////////////////////////////////////////////////////////////////


/datum/surgery_step/fix_vein
	priority = 2
	allowed_tools = list(
	/obj/item/weapon/FixOVein = 100, \
	/obj/item/weapon/cable_coil = 75
	)
	can_infect = 1
	blood_level = 1

	min_duration = 70
	max_duration = 90

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(!hasorgans(target))
			return 0

		var/datum/organ/external/affected = target.get_organ(target_zone)

		var/internal_bleeding = 0
		for(var/datum/wound/W in affected.wounds) if(W.internal)
			internal_bleeding = 1
			break

		return affected.open >= 2 && internal_bleeding

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts patching the damaged vein in [target]'s [affected.display_name] with \the [tool]." , \
		"You start patching the damaged vein in [target]'s [affected.display_name] with \the [tool].")
		target.custom_pain("The pain in [affected.display_name] is unbearable!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] has patched the damaged vein in [target]'s [affected.display_name] with \the [tool].", \
			"\blue You have patched the damaged vein in [target]'s [affected.display_name] with \the [tool].")

		for(var/datum/wound/W in affected.wounds) if(W.internal)
			affected.wounds -= W
			affected.update_damages()
		if (ishuman(user) && prob(40)) user:bloody_hands(target, 0)

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, smearing [tool] in the incision in [target]'s [affected.display_name]!" , \
		"\red Your hand slips, smearing [tool] in the incision in [target]'s [affected.display_name]!")
		affected.take_damage(5, 0)

/datum/surgery_step/fix_dead_tissue		//Debridement
	priority = 2
	allowed_tools = list(
		/obj/item/weapon/scalpel = 100,		\
		/obj/item/weapon/kitchenknife = 75,	\
		/obj/item/weapon/shard = 50, 		\
	)

	can_infect = 1
	blood_level = 1

	min_duration = 110
	max_duration = 160

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(!hasorgans(target))
			return 0

		if (target_zone == "mouth" || target_zone == "eyes")
			return 0

		var/datum/organ/external/affected = target.get_organ(target_zone)

		return affected.open >= 2 && (affected.status & ORGAN_DEAD)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts cutting away necrotic tissue in [target]'s [affected.display_name] with \the [tool]." , \
		"You start cutting away necrotic tissue in [target]'s [affected.display_name] with \the [tool].")
		target.custom_pain("The pain in [affected.display_name] is unbearable!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] has cut away necrotic tissue in [target]'s [affected.display_name] with \the [tool].", \
			"\blue You have cut away necrotic tissue in [target]'s [affected.display_name] with \the [tool].")
		affected.open = 3

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, slicing an artery inside [target]'s [affected.display_name] with \the [tool]!", \
		"\red Your hand slips, slicing an artery inside [target]'s [affected.display_name] with \the [tool]!")
		affected.createwound(CUT, 20, 1)

/datum/surgery_step/treat_necrosis
	priority = 2
	allowed_tools = list(
		/obj/item/weapon/reagent_containers/dropper = 100,
		/obj/item/weapon/reagent_containers/glass/bottle = 75,
		/obj/item/weapon/reagent_containers/glass/beaker = 75,
		/obj/item/weapon/reagent_containers/spray = 50,
		/obj/item/weapon/reagent_containers/glass/bucket = 50,
	)

	can_infect = 0
	blood_level = 0

	min_duration = 50
	max_duration = 60

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if (!istype(tool, /obj/item/weapon/reagent_containers))
			return 0

		var/obj/item/weapon/reagent_containers/container = tool
		if(!container.reagents.has_reagent("peridaxon"))
			return 0

		if(!hasorgans(target))
			return 0

		if (target_zone == "mouth" || target_zone == "eyes")
			return 0

		var/datum/organ/external/affected = target.get_organ(target_zone)
		return affected.open == 3 && (affected.status & ORGAN_DEAD)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts applying medication to the affected tissue in [target]'s [affected.display_name] with \the [tool]." , \
		"You start applying medication to the affected tissue in [target]'s [affected.display_name] with \the [tool].")
		target.custom_pain("Something in your [affected.display_name] is causing you a lot of pain!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)

		if (!istype(tool, /obj/item/weapon/reagent_containers))
			return

		var/obj/item/weapon/reagent_containers/container = tool

		var/trans = container.reagents.trans_to(target, container.amount_per_transfer_from_this)
		if (trans > 0)
			container.reagents.reaction(target, INGEST)	//technically it's contact, but the reagents are being applied to internal tissue

			if(container.reagents.has_reagent("peridaxon"))
				affected.status &= ~ORGAN_DEAD

			user.visible_message("\blue [user] applies [trans] units of the solution to affected tissue in [target]'s [affected.display_name]", \
				"\blue You apply [trans] units of the solution to affected tissue in [target]'s [affected.display_name] with \the [tool].")

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)

		if (!istype(tool, /obj/item/weapon/reagent_containers))
			return

		var/obj/item/weapon/reagent_containers/container = tool

		var/trans = container.reagents.trans_to(target, container.amount_per_transfer_from_this)
		container.reagents.reaction(target, INGEST)	//technically it's contact, but the reagents are being applied to internal tissue

		user.visible_message("\red [user]'s hand slips, applying [trans] units of the solution to the wrong place in [target]'s [affected.display_name] with the [tool]!" , \
		"\red Your hand slips, applying [trans] units of the solution to the wrong place in [target]'s [affected.display_name] with the [tool]!")

		//no damage or anything, just wastes medicine
