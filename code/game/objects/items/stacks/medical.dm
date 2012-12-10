
//What is this even used for?

/obj/item/stack/medical/attack(mob/living/carbon/M as mob, mob/user as mob)
	if (M.stat == 2)
		var/t_him = "it"
		if (M.gender == MALE)
			t_him = "him"
		else if (M.gender == FEMALE)
			t_him = "her"
		user << "\red \The [M] is dead, you cannot help [t_him]!"
		return 1

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
		var/datum/organ/external/affecting = H.get_organ(user.zone_sel.selecting)
		if(affecting.status & ORGAN_ROBOT)
			user << "\red This isn't useful at all on a robotic limb.."
			return 1

		if(src.heal_brute)
			if(!affecting.bandage())
				user << "\red The wounds on [M]'s [affecting.display_name] have already been bandaged."
				return 1
			else
				user.visible_message( 	"\blue [user] bandages wounds on [M]'s [affecting.display_name].", \
										"\blue You bandage wounds on [M]'s [affecting.display_name]." )

		else if(src.heal_burn)
			if(!affecting.salve())
				user << "\red The wounds on [M]'s [affecting.display_name] have already been salved."
				return 1
			else
				user.visible_message( 	"\blue [user] salves wounds on [M]'s [affecting.display_name].", \
										"\blue You salve wounds on [M]'s [affecting.display_name]." )

		H.UpdateDamageIcon()
	else
		M.heal_organ_damage((src.heal_brute/2), (src.heal_burn/2))
		user.visible_message( \
			"\blue [M] has been applied with [src] by [user].", \
			"\blue You apply \the [src] to [M]." \
		)

	use(1)
	M.updatehealth()
