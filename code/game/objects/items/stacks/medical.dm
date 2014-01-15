/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'icons/obj/items.dmi'
	amount = 5
	max_amount = 5
	w_class = 1
	throw_speed = 4
	throw_range = 20
	var/heal_brute = 0
	var/heal_burn = 0

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
		var/obj/item/organ/limb/affecting = H.get_organ(check_zone(user.zone_sel.selecting))

		if(affecting.status == ORGAN_ORGANIC) //Limb must be organic to be healed - RR
			if (affecting.heal_damage(src.heal_brute, src.heal_burn, 0))
				H.update_damage_overlays(0)

			M.updatehealth()
		else
			user << "<span class='notice'>Medicine won't work on a robotic limb!</span>"
	else
		M.heal_organ_damage((src.heal_brute/2), (src.heal_burn/2))


	use(1)



/obj/item/stack/medical/bruise_pack
	name = "bruise pack"
	singular_name = "bruise pack"
	desc = "A pack designed to treat blunt-force trauma."
	icon_state = "brutepack"
	heal_brute = 60
	origin_tech = "biotech=1"

/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Used to treat those nasty burns."
	gender = PLURAL
	singular_name = "ointment"
	icon_state = "ointment"
	heal_burn = 40
	origin_tech = "biotech=1"