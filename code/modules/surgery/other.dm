//Procedures in this file: Inernal wound patching, Implant removal.
//////////////////////////////////////////////////////////////////
//					INTERNAL WOUND PATCHING						//
//////////////////////////////////////////////////////////////////


/datum/surgery_step/fix_vein
	required_tool = /obj/item/weapon/FixOVein
	allowed_tools = list(/obj/item/weapon/cable_coil)
	can_infect = 1
	blood_level = 1

	min_duration = 70
	max_duration = 90

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)

		var/internal_bleeding = 0
		for(var/datum/wound/W in affected.wounds) if(W.internal)
			internal_bleeding = 1
			break

		return affected.open == 2 && internal_bleeding

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

//////////////////////////////////////////////////////////////////
//					IMPLANT REMOVAL SURGERY						//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/implant_removal
	required_tool = /obj/item/weapon/hemostat
	allowed_tools = list(/obj/item/weapon/wirecutters, /obj/item/weapon/kitchen/utensil/fork)

	min_duration = 80
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return affected.open == 2 && !(affected.status & ORGAN_BLEEDING)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts poking around inside the incision on [target]'s [affected.display_name] with \the [tool].", \
		"You start poking around inside the incision on [target]'s [affected.display_name] with \the [tool]" )
		target.custom_pain("The pain in your chest is living hell!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/chest/affected = target.get_organ(target_zone)

		var/find_prob = 0
		if (affected.implants.len)
			var/obj/item/weapon/implant/imp = affected.implants[1]
			if (imp.islegal())
				find_prob +=60
			else
				find_prob +=40
			if (isright(tool))
				find_prob +=20

		if (prob(find_prob))
			user.visible_message("\blue [user] takes something out of incision on [target]'s [affected.display_name] with \the [tool].", \
			"\blue You take something out of incision on [target]'s [affected.display_name]s with \the [tool]." )
			var/obj/item/weapon/implant/imp = affected.implants[1]
			affected.implants -= imp
			imp.loc = get_turf(target)
			imp.imp_in = null
			imp.implanted = 0
		else
			user.visible_message("\blue [user] could not find anything inside [target]'s [affected.display_name], and pulls \the [tool] out.", \
			"\blue You could not find anything inside [target]'s [affected.display_name]." )

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/chest/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, scraping tissue inside [target]'s [affected.display_name] with \the [tool]!", \
		"\red Your hand slips, scraping tissue inside [target]'s [affected.display_name] with \the [tool]!")
		affected.createwound(CUT, 20)
		if (affected.implants.len)
			var/fail_prob = 10
			if (!isright(tool))
				fail_prob += 30
			if (prob(fail_prob))
				var/obj/item/weapon/implant/imp = affected.implants[1]
				user.visible_message("\red Something beeps inside [target]'s [affected.display_name]!")
				playsound(imp.loc, 'sound/items/countdown.ogg', 75, 1, -3)
				spawn(25)
					imp.activate()