/obj/effect/proc_holder/changeling/biodegrade
	name = "Biodegrade"
	desc = "Dissolves restraints or other objects preventing free movement."
	helptext = "This is obvious to nearby people, and can destroy standard restraints and closets."
	chemical_cost = 30 //High cost to prevent spam
	dna_cost = 2
	req_human = 1
	genetic_damage = 10
	max_genetic_damage = 0


/obj/effect/proc_holder/changeling/biodegrade/sting_action(mob/living/carbon/human/user)
	var/used = 0
	if(!user.restrained() && !istype(user.loc, /obj/structure/closet))
		user << "<span class='warning'>We are already free!</span>"
		return 0

	if(user.handcuffed)
		used = 1
		var/obj/O = user.get_item_by_slot(slot_handcuffed)
		if(!O || !istype(O))
			return 0
		user.visible_message("<span class='warning'>[user] vomits a glob of acid on \his [O]!</span>", \
							 "<span class='warning'>We vomit acidic ooze onto our restraints!</span>")
		spawn(30)
			if(O && user.handcuffed == O)
				user.unEquip(O)
				O.visible_message("<span class='warning'>[O] dissolves into a puddle of sizzling goop.</span>")
				O.loc = get_turf(user)
				qdel(O)

	if(istype(user.wear_suit, /obj/item/clothing/suit/straight_jacket) && !used)
		used = 1
		var/obj/item/clothing/suit/straight_jacket/SJ = user.get_item_by_slot(slot_wear_suit)
		if(!SJ || !istype(SJ))
			return 0
		user.visible_message("<span class='warning'>[user] vomits a glob of acid across the front of \his [SJ]!</span>", \
							 "<span class='warning'>We vomit acidic ooze onto our straight jacket!</span>")
		spawn(30)
			if(SJ && user.wear_suit == SJ)
				user.unEquip(SJ)
				SJ.visible_message("<span class='warning'>[SJ] dissolves into a puddle of sizzling goop.</span>")
				SJ.loc = get_turf(user)
				qdel(SJ)

	if(istype(user.loc, /obj/structure/closet) && !used)
		used = 1
		var/obj/structure/closet/C = user.loc
		if(!C || !istype(C)) //The !C check slightly scares me, but...
			return 0
		C.visible_message("<span class='warning'>[C]'s hinges suddenly begin to melt and run!</span>")
		user << "<span class='warning'>We vomit acidic goop onto the interior of [C]!</span>"
		spawn(70)
			if(C && user.loc == C)
				C.visible_message("<span class='warning'>[C]'s door breaks and opens!</span>")
				C.welded = 0
				C.locked = 0
				C.broken = 1
				C.open()
				user << "<span class='warning'>We open the container restraining us!</span>"

	feedback_add_details("changeling_powers","BD")
	return 1
