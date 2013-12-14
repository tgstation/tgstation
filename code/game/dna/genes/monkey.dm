/datum/dna/gene/monkey
	name="Monkey"

/datum/dna/gene/monkey/New()
	block=MONKEYBLOCK

/datum/dna/gene/monkey/can_activate(var/mob/M,var/flags)
	return istype(M, /mob/living/carbon/human) || istype(M,/mob/living/carbon/monkey)

/datum/dna/gene/monkey/activate(var/mob/living/M, var/connected, var/flags)
	if(!istype(M,/mob/living/carbon/human))
		return
	var/mob/living/carbon/human/H = M
	H.monkeyizing = 1
	var/list/implants = list() //Try to preserve implants.
	for(var/obj/item/weapon/implant/W in H)
		implants += W
		W.loc = null

	if(!connected)
		for(var/obj/item/W in (H.contents-implants))
			if (W==H.w_uniform) // will be teared
				continue
			H.drop_from_inventory(W)
		M.monkeyizing = 1
		M.canmove = 0
		M.icon = null
		M.invisibility = 101
		var/atom/movable/overlay/animation = new( M.loc )
		animation.icon_state = "blank"
		animation.icon = 'icons/mob/mob.dmi'
		animation.master = src
		flick("h2monkey", animation)
		sleep(48)
		del(animation)


	var/mob/living/carbon/monkey/O = null
	if(H.species.primitive)
		O = new H.species.primitive(src)
	else
		H.gib() //Trying to change the species of a creature with no primitive var set is messy.
		return

	if(M)
		if (M.dna)
			O.dna = M.dna
			M.dna = null

		if (M.suiciding)
			O.suiciding = M.suiciding
			M.suiciding = null


	for(var/datum/disease/D in M.viruses)
		O.viruses += D
		D.affected_mob = O
		M.viruses -= D


	for(var/obj/T in (M.contents-implants))
		del(T)

	O.loc = M.loc

	if(M.mind)
		M.mind.transfer_to(O)	//transfer our mind to the cute little monkey

	if (connected) //inside dna thing
		var/obj/machinery/dna_scannernew/C = connected
		O.loc = C
		C.occupant = O
		connected = null
	O.real_name = text("monkey ([])",copytext(md5(M.real_name), 2, 6))
	O.take_overall_damage(M.getBruteLoss() + 40, M.getFireLoss())
	O.adjustToxLoss(M.getToxLoss() + 20)
	O.adjustOxyLoss(M.getOxyLoss())
	O.stat = M.stat
	O.a_intent = "hurt"
	for (var/obj/item/weapon/implant/I in implants)
		I.loc = O
		I.implanted = O
//		O.update_icon = 1	//queue a full icon update at next life() call
	del(M)
	return

/datum/dna/gene/monkey/deactivate(var/mob/living/M, var/connected, var/flags)
	if(!istype(M,/mob/living/carbon/monkey))
		return
	var/mob/living/carbon/monkey/Mo = M
	Mo.monkeyizing = 1
	var/list/implants = list() //Still preserving implants
	for(var/obj/item/weapon/implant/W in Mo)
		implants += W
		W.loc = null
	if(!connected)
		for(var/obj/item/W in (Mo.contents-implants))
			Mo.drop_from_inventory(W)
		M.monkeyizing = 1
		M.canmove = 0
		M.icon = null
		M.invisibility = 101
		var/atom/movable/overlay/animation = new( M.loc )
		animation.icon_state = "blank"
		animation.icon = 'icons/mob/mob.dmi'
		animation.master = src
		flick("monkey2h", animation)
		sleep(48)
		del(animation)

	var/mob/living/carbon/human/O = new( src )
	if(Mo.greaterform)
		O.set_species(Mo.greaterform)

	if (M.dna.GetUIState(DNA_UI_GENDER))
		O.gender = FEMALE
	else
		O.gender = MALE

	if (M)
		if (M.dna)
			O.dna = M.dna
			M.dna = null

		if (M.suiciding)
			O.suiciding = M.suiciding
			M.suiciding = null

	for(var/datum/disease/D in M.viruses)
		O.viruses += D
		D.affected_mob = O
		M.viruses -= D

	//for(var/obj/T in M)
	//	del(T)

	O.loc = M.loc

	if(M.mind)
		M.mind.transfer_to(O)	//transfer our mind to the human

	if (connected) //inside dna thing
		var/obj/machinery/dna_scannernew/C = connected
		O.loc = C
		C.occupant = O
		connected = null

	var/i
	while (!i)
		var/randomname
		if (O.gender == MALE)
			randomname = capitalize(pick(first_names_male) + " " + capitalize(pick(last_names)))
		else
			randomname = capitalize(pick(first_names_female) + " " + capitalize(pick(last_names)))
		if (findname(randomname))
			continue
		else
			O.real_name = randomname
			i++
	O.UpdateAppearance()
	O.take_overall_damage(M.getBruteLoss(), M.getFireLoss())
	O.adjustToxLoss(M.getToxLoss())
	O.adjustOxyLoss(M.getOxyLoss())
	O.stat = M.stat
	for (var/obj/item/weapon/implant/I in implants)
		I.loc = O
		I.implanted = O
//		O.update_icon = 1	//queue a full icon update at next life() call
	del(M)
	return