/*
CONTAINS:
MEDICAL


*/


/obj/item/stack/medical/attack(mob/living/carbon/M as mob, mob/user as mob)
	var/heal_cap = 50
	var/ointment = istype(src, /obj/item/stack/medical/advanced/ointment) \
				||   istype(src, /obj/item/stack/medical/ointment)

	if(istype(src, /obj/item/stack/medical/advanced))
		heal_cap = 0

	if (M.stat == 2)
		var/t_him = "it"
		if (M.gender == MALE)
			t_him = "him"
		else if (M.gender == FEMALE)
			t_him = "her"
		user << "\red \The [M] is dead, you cannot help [t_him]!"
		return

	if (!istype(M))
		user << "\red \The [src] cannot be applied to \the [M]!"
		return 1

	if ( ! (istype(user, /mob/living/carbon/human) || \
			istype(user, /mob/living/silicon) || \
			istype(user, /mob/living/carbon/monkey) && ticker && ticker.mode.name == "monkey") )
		user << "\red You don't have the dexterity to do this!"
		return 1

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/affecting = H.get_organ("chest")

		if(istype(user, /mob/living/carbon/human))
			var/mob/living/carbon/human/user2 = user
			affecting = H.get_organ(check_zone(user2.zone_sel.selecting))
		else
			if(!istype(affecting, /datum/organ/external))
				affecting = H.get_organ("head")

		if(affecting.status & ORGAN_ROBOT)
			user << "Medical equipment for a robot arm?  Better get a welder..."
			return

		if(istype(src, /obj/item/stack/medical/splint))
			var/limb = affecting.getDisplayName()
			if(!((affecting.name == "l_arm") || (affecting.name == "r_arm") || (affecting.name == "l_leg") || (affecting.name == "r_leg")))
				user << "\red You can't apply a splint there!"
				return
			if(!(affecting.status & ORGAN_BROKEN))
				user << "\red [M]'s [limb] isn't broken!"
				return
			if(affecting.status & ORGAN_SPLINTED)
				user << "\red [M]'s [limb] is already splinted!"
				return
			if (M != user)
				user.visible_message("\red [user] starts to apply \the [src] to [M]'s [limb].", "\red You start to apply \the [src] to [M]'s [limb].", "\red You hear something being wrapped.")
			else
				if((!user.hand && affecting.name == "r_arm") || (user.hand && affecting.name == "l_arm"))
					user << "\red You can't apply a splint to the arm you're using!"
					return
				user.visible_message("\red [user] starts to apply \the [src] to their [limb].", "\red You start to apply \the [src] to your [limb].", "\red You hear something being wrapped.")
			if(do_after(user, 50))
				if (M != user)
					user.visible_message("\red [user] finishes applying \the [src] to [M]'s [limb].", "\red You finish applying \the [src] to [M]'s [limb].", "\red You hear something being wrapped.")
				else
					if(prob(25))
						user.visible_message("\red [user] successfully applies \the [src] to their [limb].", "\red You successfully apply \the [src] to your [limb].", "\red You hear something being wrapped.")
					else
						user.visible_message("\red [user] fumbles \the [src].", "\red You fumble \the [src].", "\red You hear something being wrapped.")
						return
				affecting.status |= ORGAN_SPLINTED
				use(1)
				M.update_clothing()
			return

		if (M.health < heal_cap)
			var/t_him = "it"
			if (M.gender == MALE)
				t_him = "him"
			else if (M.gender == FEMALE)
				t_him = "her"
			user << "\red \The [M] is wounded badly, this item cannot help [t_him]!"
			return

		if (user)
			if (M != user)
				if ( ointment )
					user.visible_message("\red \The [H]'s [affecting.display_name] burns have been salved with \a [src] by \the [user].",\
					"\red You salve \the [H]'s [affecting.display_name] burns with \the [src].",\
					"ou hear ointement being applied.")
				else
					user.visible_message("\red \The [H]'s [affecting.display_name] has been bandaged with \a [src] by \the [user].",\
					"\red You bandage \the [H]'s [affecting.display_name] with \the [src].",\
					"You hear gauze being ripped.")
			else
				var/t_his = "its"
				if (user.gender == MALE)
					t_his = "his"
				else if (user.gender == FEMALE)
					t_his = "her"
				if ( ointment )
					user.visible_message("\red \The [user] salves [t_his] [affecting.display_name] burns with \a [src].",\
					"\red You salve your [affecting.display_name] burns with \the [src].",\
					"You hear ointement being applied.")
				else
					user.visible_message("\red \The [user] bandages [t_his] [affecting.display_name] with \a [src].",\
					"\red You bandage your [affecting.display_name] with \the [src].",\
					"You hear gauze being ripped.")
		use(1)

		if (!ointment && (affecting.status & ORGAN_BLEEDING))
			affecting.status &= ~ORGAN_BLEEDING

		if(ointment)
			for(var/datum/wound/W in affecting.wounds)
				W.salved = 1
		else
			for(var/datum/wound/W in affecting.wounds)
				W.bandaged = 1

		// Don't do direct healing
		//if (affecting.heal_damage(src.heal_brute, src.heal_burn))
		//	H.UpdateDamageIcon()
		//else
		H.UpdateDamage()

		M.updatehealth()

	else
		if (M.health < heal_cap)
			var/t_him = "it"
			if (M.gender == MALE)
				t_him = "him"
			else if (M.gender == FEMALE)
				t_him = "her"
			user << "\red \The [M] is wounded badly, this item cannot help [t_him]!"
			return

		M.heal_organ_damage((src.heal_brute/2), (src.heal_burn/2))

		use(1)