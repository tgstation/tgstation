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

/obj/item/stack/medical/bruise_pack/tajaran
	name = "\improper S'rendarr's Hand leaf"
	singular_name = "S'rendarr's Hand leaf"
	desc = "A soft leaf that is rubbed on bruises."
	icon = 'harvest.dmi'
	icon_state = "cabbage"
	heal_brute = 7

/obj/item/stack/medical/ointment/tajaran
	name = "\improper Messa's Tear leaf"
	singular_name = "Messa's Tear leaf"
	desc = "A cold leaf that is rubbed on burns."
	icon = 'harvest.dmi'
	icon_state = "ambrosiavulgaris"
	heal_burn = 7

/obj/item/stack/medical/advanced/bruise_pack
	name = "advanced trauma kit"
	singular_name = "advanced trauma kit"
	desc = "An advanced trauma kit for severe injuries."
	icon_state = "traumakit"
	heal_brute = 12
	origin_tech = "biotech=1"

/obj/item/stack/medical/advanced/ointment
	name = "advanced burn kit"
	singular_name = "advanced burn kit"
	desc = "An advanced treatment kit for severe burns."
	icon_state = "burnkit"
	heal_burn = 12
	origin_tech = "biotech=1"

/obj/item/stack/medical/splint
	name = "medical splint"
	singular_name = "medical splint"
	icon_state = "splint"
	amount = 5
	max_amount = 5

/obj/item/stack/medical/splint/single
	amount = 1
