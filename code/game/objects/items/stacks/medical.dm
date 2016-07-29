<<<<<<< HEAD
/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'icons/obj/items.dmi'
	amount = 6
	max_amount = 6
	w_class = 1
	throw_speed = 3
	throw_range = 7
	burn_state = FLAMMABLE
	burntime = 5
	var/heal_brute = 0
	var/heal_burn = 0
	var/stop_bleeding = 0
	var/self_delay = 50

/obj/item/stack/medical/attack(mob/living/M, mob/user)

	if(M.stat == 2)
		var/t_him = "it"
		if(M.gender == MALE)
			t_him = "him"
		else if(M.gender == FEMALE)
			t_him = "her"
		user << "<span class='danger'>\The [M] is dead, you cannot help [t_him]!</span>"
		return

	if(!istype(M, /mob/living/carbon) && !istype(M, /mob/living/simple_animal))
		user << "<span class='danger'>You don't know how to apply \the [src] to [M]!</span>"
		return 1

	var/obj/item/bodypart/affecting
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		affecting = H.get_bodypart(check_zone(user.zone_selected))
		if(!affecting) //Missing limb?
			user << "<span class='warning'>[H] doesn't have \a [parse_zone(user.zone_selected)]!</span>"
			return
		if(stop_bleeding)
			if(H.bleedsuppress)
				user << "<span class='warning'>[H]'s bleeding is already bandaged!</span>"
				return
			else if(!H.bleed_rate)
				user << "<span class='warning'>[H] isn't bleeding!</span>"
				return


	if(isliving(M))
		if(!M.can_inject(user, 1))
			return

	if(user)
		if (M != user)
			if (istype(M, /mob/living/simple_animal))
				var/mob/living/simple_animal/critter = M
				if (!(critter.healable))
					user << "<span class='notice'> You cannot use [src] on [M]!</span>"
					return
				else if (critter.health == critter.maxHealth)
					user << "<span class='notice'> [M] is at full health.</span>"
					return
				else if(src.heal_brute < 1)
					user << "<span class='notice'> [src] won't help [M] at all.</span>"
					return
			user.visible_message("<span class='green'>[user] applies [src] on [M].</span>", "<span class='green'>You apply [src] on [M].</span>")
		else
			var/t_himself = "itself"
			if(user.gender == MALE)
				t_himself = "himself"
			else if(user.gender == FEMALE)
				t_himself = "herself"
			user.visible_message("<span class='notice'>[user] starts to apply [src] on [t_himself]...</span>", "<span class='notice'>You begin applying [src] on yourself...</span>")
			if(!do_mob(user, M, self_delay))
				return
			user.visible_message("<span class='green'>[user] applies [src] on [t_himself].</span>", "<span class='green'>You apply [src] on yourself.</span>")


	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		affecting = H.get_bodypart(check_zone(user.zone_selected))
		if(!affecting) //Missing limb?
			user << "<span class='warning'>[H] doesn't have \a [parse_zone(user.zone_selected)]!</span>"
			return
		if(stop_bleeding)
			if(!H.bleedsuppress) //so you can't stack bleed suppression
				H.suppress_bloodloss(stop_bleeding)
		if(affecting.status == ORGAN_ORGANIC) //Limb must be organic to be healed - RR
			if(affecting.heal_damage(src.heal_brute, src.heal_burn, 0))
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
	desc = "A theraputic gel pack and bandages designed to treat blunt-force trauma."
	icon_state = "brutepack"
	heal_brute = 40
	origin_tech = "biotech=2"
	self_delay = 20

/obj/item/stack/medical/gauze
	name = "medical gauze"
	desc = "A roll of elastic cloth that is extremely effective at stopping bleeding, but does not heal wounds."
	gender = PLURAL
	singular_name = "medical gauze"
	icon_state = "gauze"
	stop_bleeding = 1800
	self_delay = 20

/obj/item/stack/medical/gauze/improvised
	name = "improvised gauze"
	singular_name = "improvised gauze"
	desc = "A roll of cloth roughly cut from something that can stop bleeding, but does not heal wounds."
	stop_bleeding = 900

/obj/item/stack/medical/gauze/cyborg/
	materials = list()
	is_cyborg = 1
	cost = 250

/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Used to treat those nasty burn wounds."
	gender = PLURAL
	singular_name = "ointment"
	icon_state = "ointment"
	heal_burn = 40
	origin_tech = "biotech=2"
	self_delay = 20
=======
/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'icons/obj/items.dmi'
	amount = 5
	max_amount = 5
	restock_amount = 2
	w_class = W_CLASS_TINY
	throw_speed = 4
	throw_range = 10
	var/heal_brute = 0
	var/heal_burn = 0

/obj/item/stack/medical/attack(mob/living/carbon/M as mob, mob/user as mob)

	if(!istype(M))
		to_chat(user, "<span class='warning'>\The [src] cannot be applied to [M]!</span>")
		return 1

	if (!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return 1

	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.display_name == LIMB_HEAD)
			if(H.head && istype(H.head,/obj/item/clothing/head/helmet/space))
				to_chat(user, "<span class='warning'>You can't apply \the [src] through \the [H.head]!</span>")
				return 1
		else
			if(H.wear_suit && istype(H.wear_suit,/obj/item/clothing/suit/space))
				to_chat(user, "<span class='warning'>You can't apply \the [src] through \the [H.wear_suit]!</span>")
				return 1

		if(affecting.status & ORGAN_ROBOT)
			to_chat(user, "<span class='warning'>This isn't useful at all on a robotic limb.</span>")
			return 1

		if(affecting.status & ORGAN_PEG)
			to_chat(user, "<span class='warning'>This isn't useful at all on a peg limb.</span>")
			return 1

		H.UpdateDamageIcon()

	else

		M.heal_organ_damage((src.heal_brute/2), (src.heal_burn/2))
		user.visible_message( \
			"<span class='notice'>[user] applies \the [src] to [M].</span>", \
			"<span class='notice'>You apply \the [src] to [M].</span>" \
		)
		use(1)

	M.updatehealth()
/obj/item/stack/medical/bruise_pack
	name = "roll of gauze"
	singular_name = "gauze length"
	desc = "Some sterile gauze to wrap around bloody stumps."
	icon_state = "brutepack"
	origin_tech = "biotech=1"

/obj/item/stack/medical/bruise_pack/bandaid
	name = "small bandage"
	desc = "A small bandage to stop bleeding."
	icon_state = "bandaid"
	amount = 1
	max_amount = 1

/obj/item/stack/medical/bruise_pack/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return 1

	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open == 0)
			if(!affecting.bandage())
				to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.display_name] have already been bandaged.</span>")
				return 1
			else
				for(var/datum/wound/W in affecting.wounds)
					if(W.internal)
						continue
					if(W.current_stage <= W.max_bleeding_stage)
						user.visible_message("<span class='notice'>[user] bandages \the [W.desc] on [M]'s [affecting.display_name].</span>", \
										"<span class='notice'>You bandage \the [W.desc] on [M]'s [affecting.display_name].</span>")
						//H.add_side_effect("Itch")
					else if(istype(W,/datum/wound/bruise))
						user.visible_message("<span class='notice'>[user] places a bruise patch over \the [W.desc] on [M]'s [affecting.display_name].</span>", \
										"<span class='notice'>You place a bruise patch over \the [W.desc] on [M]'s [affecting.display_name].</span>")
					else
						user.visible_message("<span class='notice'>[user] places a bandaid over \the [W.desc] on [M]'s [affecting.display_name].</span>", \
										"<span class='notice'>You place a bandaid over \the [W.desc] on [M]'s [affecting.display_name].</span>")
				use(1)
		else
			if(can_operate(H))        //Checks if mob is lying down on table for surgery
				if(do_surgery(H,user,src))
					return
			else
				to_chat(user, "<span class='notice'>[H]'s [affecting.display_name] is cut wide open, you'll need more than a bandage!</span>")

/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Used to treat those nasty burns."
	gender = PLURAL
	singular_name = "ointment"
	icon_state = "ointment"
	origin_tech = "biotech=1"

/obj/item/stack/medical/ointment/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return 1

	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open == 0)
			if(!affecting.salve())
				to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.display_name] have already been salved.</span>")
				return 1
			else
				user.visible_message("<span class='notice'>[user] salves the wounds on [M]'s [affecting.display_name].</span>", \
										"<span class='notice'>You salve the wounds on [M]'s [affecting.display_name].</span>" )
				use(1)
		else
			if(can_operate(H))        //Checks if mob is lying down on table for surgery
				if(do_surgery(H,user,src))
					return
			else
				to_chat(user, "<span class='notice'>[H]'s [affecting.display_name] is cut wide open, you'll need more than some ointment!</span>")

/obj/item/stack/medical/bruise_pack/tajaran
	name = "\improper S'rendarr's Hand leaf"
	singular_name = "S'rendarr's Hand leaf"
	desc = "A poultice made of soft leaves that is rubbed on bruises."
	icon = 'icons/obj/harvest.dmi'
	icon_state = "cabbage"
	heal_brute = 5

/obj/item/stack/medical/ointment/tajaran
	name = "\improper Messa's Tear petals"
	singular_name = "Messa's Tear petals"
	desc = "A poultice made of cold, blue petals that is rubbed on burns."
	icon = 'icons/obj/harvest.dmi'
	icon_state = "ambrosiavulgaris"
	heal_burn = 5


/obj/item/stack/medical/advanced/bruise_pack
	name = "advanced trauma kit"
	singular_name = "advanced trauma kit"
	desc = "An advanced trauma kit for severe injuries."
	icon_state = "traumakit"
	heal_brute = 10
	origin_tech = "biotech=2"

/obj/item/stack/medical/advanced/bruise_pack/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return 1

	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open == 0)
			if(!affecting.bandage())
				to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.display_name] have already been treated.</span>")
				return 1
			else
				for(var/datum/wound/W in affecting.wounds)
					if(W.internal)
						continue
					if(W.current_stage <= W.max_bleeding_stage)
						user.visible_message("<span class='notice'>[user] cleans \the [W.desc] on [M]'s [affecting.display_name] and seals the edges with bioglue.</span>", \
										"<span class='notice'>You clean \the [W.desc] on [M]'s [affecting.display_name] and seal the edges with bioglue .</span>")
						//H.add_side_effect("Itch")
					else if(istype(W,/datum/wound/bruise))
						user.visible_message("<span class='notice'>[user] disinfects and places a medicine patch over \the [W.desc] on [M]'s [affecting.display_name].</span>", \
										"<span class='notice'>You disinfect and place a medicine patch over \the [W.desc] on [M]'s [affecting.display_name].</span>")
					else
						user.visible_message("<span class='notice'>[user] smears some bioglue over \the [W.desc] on [M]'s [affecting.display_name].</span>", \
										"<span class='notice'>You smear some bioglue over \the [W.desc] on [M]'s [affecting.display_name].</span>")
				affecting.heal_damage(rand(heal_brute, heal_brute + 5), 0)
				use(1)
		else
			if(can_operate(H))        //Checks if mob is lying down on table for surgery
				if(do_surgery(H,user,src))
					return
			else
				to_chat(user, "<span class='notice'>[H]'s [affecting.display_name] is cut wide open, even bioglue won't do!</span>")

/obj/item/stack/medical/advanced/ointment
	name = "advanced burn kit"
	singular_name = "advanced burn kit"
	desc = "An advanced treatment kit for severe burns."
	icon_state = "burnkit"
	heal_burn = 10
	origin_tech = "biotech=2"


/obj/item/stack/medical/advanced/ointment/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return 1

	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open == 0)
			if(!affecting.salve())
				to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.display_name] have already been salved.</span>")
				return 1
			else
				user.visible_message("<span class='notice'>[user] disinfects the wounds on [M]'s [affecting.display_name] and covers them with a regenerative membrane.</span>", \
										"<span class='notice'>You disinfect the wounds on [M]'s [affecting.display_name] and cover them with a regenerative membrane.</span>")
				affecting.heal_damage(0, rand(heal_burn, heal_burn + 5))
				use(1)
		else
			if(can_operate(H))        //Checks if mob is lying down on table for surgery
				if(do_surgery(H,user,src))
					return
			else
				to_chat(user, "<span class='notice'>[H]'s [affecting.display_name] is cut wide open, even a regenerative membrane won't do!</span>")

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
		if(!((affecting.name == LIMB_LEFT_ARM) || (affecting.name == LIMB_RIGHT_ARM) || (affecting.name == LIMB_LEFT_LEG) || (affecting.name == LIMB_RIGHT_LEG)))
			to_chat(user, "<span class='warning'>You can only apply splints on limbs!</span>")
			return
		if(affecting.status & ORGAN_SPLINTED)
			to_chat(user, "<span class='warning'>[M]'s [limb] is already splinted!</span>")
			return
		if (M != user)
			user.visible_message("<span class='warning'>[user] starts to apply \the [src] to [M]'s [limb].</span>", \
								"<span class='warning'>You start to apply \the [src] to [M]'s [limb].</span>", \
								"<span class='warning'>You hear something being wrapped.</span>")
		else
			var/datum/organ/external/OE = user.get_active_hand_organ()

			if(affecting.grasp_id == OE.grasp_id)
				to_chat(user, "<span class='warning'>You can't apply a splint to the arm you're using!</span>")
				return

			user.visible_message("<span class='warning'>[user] starts to apply \the [src] to their [limb].</span>", \
								"<span class='warning'>You start to apply \the [src] to your [limb].</span>", \
								"<span class='warning'>You hear something being wrapped.</span>")
		if(do_mob(user, M, 50))
			if (M != user)
				user.visible_message("<span class='warning'>[user] finishes applying \the [src] to [M]'s [limb].</span>", \
									"<span class='warning'>You finish applying \the [src] to [M]'s [limb].</span>", \
									"<span class='warning'>You hear something being wrapped.</span>")
			else
				if(prob(25))
					user.visible_message("<span class='warning'>[user] successfully applies \the [src] to their [limb].</span>", \
										"<span class='warning'>You successfully apply \the [src] to your [limb].</span>", \
										"<span class='warning'>You hear something being wrapped.</span>")
				else
					user.visible_message("<span class='warning'>[user] fumbles \the [src].</span>", \
										"<span class='warning'>You fumble \the [src].</span>", \
										"<span class='warning'>You hear something being wrapped.</span>")
					return
			affecting.status |= ORGAN_SPLINTED
			use(1)
		return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
