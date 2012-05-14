/*
CONTAINS:
MEDICAL


*/


/obj/item/stack/medical/attack(mob/living/carbon/M as mob, mob/user as mob)
	if (M.stat == 2)
		var/t_him = "it"
		if (M.gender == MALE)
			t_him = "him"
		else if (M.gender == FEMALE)
			t_him = "her"
		user << "\red \The [M] is dead, you cannot help [t_him]!"
		return

	if (!istype(M))
		user << "\red \The [src] cannot be applied to [M]!"
		return 1

	if ( ! (istype(user, /mob/living/carbon/human) || \
			istype(user, /mob/living/silicon) || \
			istype(user, /mob/living/carbon/monkey) && ticker && ticker.mode.name == "monkey") )
		user << "\red You don't have the dexterity to do this!"
		return 1

	var/stoppedblood = 0
	if(hasorgans(M))
		var/datum/organ/external/affecting = M:get_organ("chest")

		if(istype(user, /mob/living/carbon/human))
			var/mob/living/carbon/human/user2 = user
			affecting = M:get_organ(check_zone(user2.zone_sel.selecting))
		else
			if(!istype(affecting, /datum/organ/external) || affecting:burn_dam <= 0)
				affecting = M:get_organ("head")
		if(affecting.destroyed && !affecting.gauzed)
			user.visible_message("\red You do your best to stop the bleeding from [M]'s stump.", "\red [user] does [user.gender == MALE? "his" : "her"] best to stem [M]'s bleeding from [M.gender == MALE? "his" : "her"] stump.", "\red You hear something like gauze being ripped.")
			affecting.gauzed = 1
			use(1)
			return

		if(affecting.robot)
			user << "Medical equipment for a robot arm?  Better get a welder..."
			return

		for(var/datum/organ/wound/W in affecting.wounds)
			if(W.bleeding || !W.is_healing)
				if(heal_brute && W.wound_type == 2)
					continue
				if(heal_burn && W.wound_type < 2)
					continue
				if(W.wound_size > 3 && (W.bleeding || !W.is_healing))
					if(stoppedblood)
						stoppedblood += 1
						break
					W.bleeding = 0
					W.is_healing = 1
					stoppedblood = 1
				else if(W.wound_size <= 3)
					if(stoppedblood)
						stoppedblood += 1
						break
					W.stopbleeding()
					stoppedblood = 1

		if (user && stoppedblood)
			if (M != user)
				user.visible_message("\red [user] [heal_burn? "salves" : "bandages"] [stoppedblood - 1 ? "some of" : "the last of"] [M]'s cuts with [src].", "\red You [heal_burn? "salve" : "bandage up"] [stoppedblood - 1 ? "some of" : "the last of"] [M]'s [heal_burn? "burns" : "wounds"].", "\red You hear something like gauze being ripped.")
			else
				user.visible_message("\red [user] [heal_burn? "salves" : "bandages"] [stoppedblood - 1 ? "some of" : "the last of"] [user.gender == MALE? "his" : "her"] own cuts with [src].", "\red You [heal_burn? "salve" : "bandage up"] [stoppedblood - 1 ? "some of" : "the last of"] your [heal_burn? "burns" : "wounds"].", "\red You hear something like gauze being ripped.")
		else if(user)
			user << "\red Nothing to patch up!"
			return
	else
		M.heal_organ_damage((src.heal_brute/2), (src.heal_burn/2))

	use(1)

//	if (M.health < 50 && !stoppedblood)
//		var/t_him = "it"
//		if (M.gender == MALE)
//			t_him = "him"
//		else if (M.gender == FEMALE)
//			t_him = "her"
//		user << "\red \The [M] is wounded badly, this item cannot help [t_him]!"
//		return

//	if (user)
//		if (M != user)
//			user.visible_message( \
//				"\blue [M] has been applied with [src] by [user].", \
//				"\blue You apply \the [src] to [M]." \
//			)
//		else
//			var/t_himself = "itself"
//			if (user.gender == MALE)
//				t_himself = "himself"
//			else if (user.gender == FEMALE)
//				t_himself = "herself"

//			user.visible_message( \
//				"\blue [M] applied [src] on [t_himself].", \
//				"\blue You apply \the [src] on yourself." \
//			)

//	if (istype(M, /mob/living/carbon/human))
//		var/mob/living/carbon/human/H = M
//		var/datum/organ/external/affecting = H.get_organ("chest")

//		if(istype(user, /mob/living/carbon/human))
//			var/mob/living/carbon/human/user2 = user
//			affecting = H.get_organ(check_zone(user2.zone_sel.selecting))
//		else
//			if(!istype(affecting, /datum/organ/external) || affecting:burn_dam <= 0)
//				affecting = H.get_organ("head")
//
//		if (affecting.heal_damage(src.heal_brute, src.heal_burn))
//			H.UpdateDamageIcon()
//		M.updatehealth()




/obj/item/stack/medical/advanced/attack(mob/living/carbon/M as mob, mob/user as mob)
	if (M.stat == 2)
		var/t_him = "it"
		if (M.gender == MALE)
			t_him = "him"
		else if (M.gender == FEMALE)
			t_him = "her"
		user << "\red \The [M] is dead, you cannot help [t_him]!"
		return

	if (!istype(M))
		user << "\red \The [src] cannot be applied to [M]!"
		return 1

	if ( ! (istype(user, /mob/living/carbon/human) || \
			istype(user, /mob/living/silicon) || \
			istype(user, /mob/living/carbon/monkey) && ticker && ticker.mode.name == "monkey") )
		user << "\red You don't have the dexterity to do this!"
		return 1

	var/stoppedblood = 0
	if(hasorgans(M))
		var/datum/organ/external/affecting = M:get_organ("chest")

		if(istype(user, /mob/living/carbon/human))
			var/mob/living/carbon/human/user2 = user
			affecting = M:get_organ(check_zone(user2.zone_sel.selecting))
		else
			if(!istype(affecting, /datum/organ/external) || affecting:burn_dam <= 0)
				affecting = M:get_organ("head")
		if(affecting.destroyed && !affecting.gauzed)
			M.visible_message("\red You do your best to stop the bleeding from [M]'s stump.", "\red [user] does their best to stem [M]'s bleeding from [M.gender == MALE? "his" : "her"] stump.", "\red You hear something like gauze being ripped.")
			affecting.gauzed = 1
			use(1)
			return
		if(affecting.robot)
			user << "Medical equipment for a robot arm?  Better get a welder..."
			return

		for(var/datum/organ/wound/W in affecting.wounds)
			if(W.bleeding || !W.healing_state)
				if(heal_brute && W.wound_type == 2)
					continue
				if(heal_burn && W.wound_type < 2)
					continue
				if(stoppedblood)
					stoppedblood++
					break
				W.stopbleeding()
				stoppedblood = 1

		if (user && stoppedblood)
			if (M != user)
				user.visible_message("\red [user] [heal_burn? "salves" : "bandages"] [stoppedblood - 1 ? "some of" : "the last of"] [M]'s cuts with [src].", "\red You [heal_burn? "salve" : "bandage up"] [stoppedblood - 1 ? "some of" : "the last of"] [M]'s [heal_burn? "burns" : "wounds"].", "\red You hear something like gauze being ripped.")
			else
				user.visible_message("\red [user] [heal_burn? "salves" : "bandages"] [stoppedblood - 1 ? "some of" : "the last of"] [user.gender == MALE? "his" : "her"] own cuts with [src].", "\red You [heal_burn? "salve" : "bandage up"] [stoppedblood - 1 ? "some of" : "the last of"] your [heal_burn? "burns" : "wounds"].", "\red You hear something like gauze being ripped.")
		else if(user)
			user << "\red Nothing to patch up!"
			return
	else
		M.heal_organ_damage((src.heal_brute/2), (src.heal_burn/2))

	use(1)