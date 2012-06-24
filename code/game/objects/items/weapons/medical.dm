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
	if (M.health < 50)
		var/t_him = "it"
		if (M.gender == MALE)
			t_him = "him"
		else if (M.gender == FEMALE)
			t_him = "her"
		user << "\red \The [M] is wounded badly, this item cannot help [t_him]!"
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

		if (affecting.heal_damage(src.heal_brute, src.heal_burn))
			H.UpdateDamageIcon()
			if (user)
				if (M != user)
					user.visible_message("\red \The [H]'s [affecting.display_name] has been bandaged with \a [src] by \the [user].",\
						"\red You bandage \the [H]'s [affecting.display_name] with \the [src].",\
						"You hear gauze being ripped.")
				else
					var/t_his = "its"
					if (user.gender == MALE)
						t_his = "his"
					else if (user.gender == FEMALE)
						t_his = "her"
					user.visible_message("\red \The [user] bandages [t_his] [affecting.display_name] with \a [src].",\
						"\red You bandage your [affecting.display_name] with \the [src].",\
						"You hear gauze being ripped.")
			use(1)
		else
			user << "Nothing to patch up!"

		M.updatehealth()
	else
		M.heal_organ_damage((src.heal_brute/2), (src.heal_burn/2))

		use(1)

/obj/item/stack/medical/advanced/attack(mob/living/carbon/M as mob, mob/user as mob)
	if (M.stat == 2)
		var/t_him = "it"
		if (M.gender == MALE)
			t_him = "him"
		else if (M.gender == FEMALE)
			t_him = "her"
		user << "\red \The [M] is dead, you cannot help [t_him]!"
		return
	if (M.health < 0)
		var/t_him = "it"
		if (M.gender == MALE)
			t_him = "him"
		else if (M.gender == FEMALE)
			t_him = "her"
		user << "\red \The [M] is wounded badly, this item cannot help [t_him]!"
		return


	if (!istype(M))
		user << "\red \The [src] cannot be applied to [M]!"
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
			if(!istype(affecting, /datum/organ/external) || affecting:burn_dam <= 0)
				affecting = H.get_organ("head")

		if (affecting.heal_damage(src.heal_brute, src.heal_burn))
			H.UpdateDamageIcon()
			if (user)
				if (M != user)
					user.visible_message("\red \The [H]'s [affecting.display_name] has been bandaged with \a [src] by \the [user].",\
						"\red You bandage \the [H]'s [affecting.display_name] with \the [src].",\
						"You hear gauze being ripped.")
				else
					var/t_his = "its"
					if (user.gender == MALE)
						t_his = "his"
					else if (user.gender == FEMALE)
						t_his = "her"
					user.visible_message("\red \The [user] bandages [t_his] [affecting.display_name] with \a [src].",\
						"\red You bandage your [affecting.display_name] with \the [src].",\
						"You hear gauze being ripped.")
			use(1)

		M.updatehealth()
	else
		M.heal_organ_damage((src.heal_brute/2), (src.heal_burn/2))

		use(1)