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

		if(affecting.display_name == "head")
			if(H.head && istype(H.head,/obj/item/clothing/head/helmet/space))
				user << "\red You can't apply [src] through [H.head]!"
				return 1
		else
			if(H.wear_suit && istype(H.wear_suit,/obj/item/clothing/suit/space))
				user << "\red You can't apply [src] through [H.wear_suit]!"
				return 1

		if(affecting.status & ORGAN_ROBOT)
			user << "\red This isn't useful at all on a robotic limb.."
			return 1

		if(affecting.status & ORGAN_PEG)
			user << "\red This isn't useful at all on a peg limb. It's fucking wood."
			return 1

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
	name = "roll of gauze"
	singular_name = "gauze length"
	desc = "Some sterile gauze to wrap around bloody stumps."
	icon_state = "brutepack"
	origin_tech = "biotech=1"

/obj/item/stack/medical/bruise_pack/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return 1

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open == 0)
			if(!affecting.bandage())
				user << "\red The wounds on [M]'s [affecting.display_name] have already been bandaged."
				return 1
			else
				for (var/datum/wound/W in affecting.wounds)
					if (W.internal)
						continue
					if (W.current_stage <= W.max_bleeding_stage)
						user.visible_message( 	"\blue [user] bandages \the [W.desc] on [M]'s [affecting.display_name].", \
										"\blue You bandage \the [W.desc] on [M]'s [affecting.display_name]." )
						//H.add_side_effect("Itch")
					else if (istype(W,/datum/wound/bruise))
						user.visible_message( 	"\blue [user] places a bruise patch over \the [W.desc] on [M]'s [affecting.display_name].", \
										"\blue You place a bruise patch over \the [W.desc] on [M]'s [affecting.display_name]." )
					else
						user.visible_message( 	"\blue [user] places a bandaid over \the [W.desc] on [M]'s [affecting.display_name].", \
										"\blue You place a bandaid over \the [W.desc] on [M]'s [affecting.display_name]." )
				use(1)
		else
			if (can_operate(H))        //Checks if mob is lying down on table for surgery
				if (do_surgery(H,user,src))
					return
			else
				user << "<span class='notice'>The [affecting.display_name] is cut open, you'll need more than a bandage!</span>"

/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Used to treat those nasty burns."
	gender = PLURAL
	singular_name = "ointment"
	icon_state = "ointment"
	heal_burn = 1
	origin_tech = "biotech=1"

/obj/item/stack/medical/ointment/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return 1

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open == 0)
			if(!affecting.salve())
				user << "\red The wounds on [M]'s [affecting.display_name] have already been salved."
				return 1
			else
				user.visible_message( 	"\blue [user] salves the wounds on [M]'s [affecting.display_name].", \
										"\blue You salve the wounds on [M]'s [affecting.display_name]." )
				use(1)
		else
			if (can_operate(H))        //Checks if mob is lying down on table for surgery
				if (do_surgery(H,user,src))
					return
			else
				user << "<span class='notice'>The [affecting.display_name] is cut open, you'll need more than some ointment!</span>"

/obj/item/stack/medical/bruise_pack/tajaran
	name = "\improper S'rendarr's Hand leaf"
	singular_name = "S'rendarr's Hand leaf"
	desc = "A poultice made of soft leaves that is rubbed on bruises."
	icon = 'icons/obj/harvest.dmi'
	icon_state = "cabbage"
	heal_brute = 7

/obj/item/stack/medical/ointment/tajaran
	name = "\improper Messa's Tear petals"
	singular_name = "Messa's Tear petals"
	desc = "A poultice made of cold, blue petals that is rubbed on burns."
	icon = 'icons/obj/harvest.dmi'
	icon_state = "ambrosiavulgaris"
	heal_burn = 7


/obj/item/stack/medical/advanced/bruise_pack
	name = "advanced trauma kit"
	singular_name = "advanced trauma kit"
	desc = "An advanced trauma kit for severe injuries."
	icon_state = "traumakit"
	heal_brute = 12
	origin_tech = "biotech=2"

/obj/item/stack/medical/advanced/bruise_pack/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return 1

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open == 0)
			if(!affecting.bandage())
				user << "\red The wounds on [M]'s [affecting.display_name] have already been treated."
				return 1
			else
				for (var/datum/wound/W in affecting.wounds)
					if (W.internal)
						continue
					if (W.current_stage <= W.max_bleeding_stage)
						user.visible_message( 	"\blue [user] cleans \the [W.desc] on [M]'s [affecting.display_name] and seals the edges with bioglue.", \
										"\blue You clean and seal \the [W.desc] on [M]'s [affecting.display_name]." )
						//H.add_side_effect("Itch")
					else if (istype(W,/datum/wound/bruise))
						user.visible_message( 	"\blue [user] places a medicine patch over \the [W.desc] on [M]'s [affecting.display_name].", \
										"\blue You place a medicine patch over \the [W.desc] on [M]'s [affecting.display_name]." )
					else
						user.visible_message( 	"\blue [user] smears some bioglue over \the [W.desc] on [M]'s [affecting.display_name].", \
										"\blue You smear some bioglue over \the [W.desc] on [M]'s [affecting.display_name]." )
				affecting.heal_damage(heal_brute,0)
				use(1)
		else
			if (can_operate(H))        //Checks if mob is lying down on table for surgery
				if (do_surgery(H,user,src))
					return
			else
				user << "<span class='notice'>The [affecting.display_name] is cut open, you'll need more than a bandage!</span>"

/obj/item/stack/medical/advanced/ointment
	name = "advanced burn kit"
	singular_name = "advanced burn kit"
	desc = "An advanced treatment kit for severe burns."
	icon_state = "burnkit"
	heal_burn = 12
	origin_tech = "biotech=2"


/obj/item/stack/medical/advanced/ointment/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return 1

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open == 0)
			if(!affecting.salve())
				user << "\red The wounds on [M]'s [affecting.display_name] have already been salved."
				return 1
			else
				user.visible_message( 	"\blue [user] covers the wounds on [M]'s [affecting.display_name] with regenerative membrane.", \
										"\blue You cover the wounds on [M]'s [affecting.display_name] with regenerative membrane." )
				affecting.heal_damage(0,heal_burn)
				use(1)
		else
			if (can_operate(H))        //Checks if mob is lying down on table for surgery
				if (do_surgery(H,user,src))
					return
			else
				user << "<span class='notice'>The [affecting.display_name] is cut open, you'll need more than a bandage!</span>"

/obj/item/stack/medical/splint
	name = "medical splints"
	singular_name = "medical splint"
	icon_state = "splint"
	amount = 5
	max_amount = 5

/obj/item/stack/medical/splint/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return 1

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/affecting = H.get_organ(user.zone_sel.selecting)
		var/limb = affecting.display_name
		if(!((affecting.name == "l_arm") || (affecting.name == "r_arm") || (affecting.name == "l_leg") || (affecting.name == "r_leg")))
			user << "\red You can't apply a splint there!"
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
		return
