
//What is this even used for?

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

	if (user)
		if (M != user)
			user.visible_message( \
				"\blue [M] has been applied with [src] by [user].", \
				"\blue You apply \the [src] to [M]." \
			)
		else
			var/t_himself = "itself"
			if (user.gender == MALE)
				t_himself = "himself"
			else if (user.gender == FEMALE)
				t_himself = "herself"

			user.visible_message( \
				"\blue [M] applied [src] on [t_himself].", \
				"\blue You apply \the [src] on yourself." \
			)

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/affecting = H.get_organ("chest")

		if(istype(user, /mob/living/carbon/human))
			var/mob/living/carbon/human/user2 = user
			affecting = H.get_organ(check_zone(user2.zone_sel.selecting))
		else
			if(!istype(affecting, /datum/organ/external) || affecting:burn_dam <= 0)
				affecting = H.get_organ("head")

		// If we're targetting arms or legs, also heal the respective hand/foot
		if(affecting.name in list("l_arm","r_arm","l_leg","r_leg"))
			var/datum/organ/external/child
			if(affecting.name == "l_arm")
				child = H.get_organ("l_hand")
			else if(affecting.name == "r_arm")
				child = H.get_organ("r_hand")
			else if(affecting.name == "r_leg")
				child = H.get_organ("r_foot")
			else if(affecting.name == "l_leg")
				child = H.get_organ("l_foot")

			if (affecting.heal_damage(src.heal_brute, src.heal_burn) || child.heal_damage(src.heal_brute, src.heal_burn))
				H.UpdateDamageIcon()
		else
			if (affecting.heal_damage(src.heal_brute, src.heal_burn))
				H.UpdateDamageIcon()
		M.updatehealth()
	else
		M.heal_organ_damage((src.heal_brute/2), (src.heal_burn/2))

	use(1)
