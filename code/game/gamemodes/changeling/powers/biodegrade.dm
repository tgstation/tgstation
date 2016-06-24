/obj/effect/proc_holder/changeling/biodegrade
	name = "Biodegrade"
	desc = "Dissolves restraints or other objects preventing free movement."
	helptext = "This is obvious to nearby people, and can destroy \
		standard restraints and closets."
	chemical_cost = 30 //High cost to prevent spam
	dna_cost = 2
	req_human = 1
	genetic_damage = 10
	max_genetic_damage = 0


/obj/effect/proc_holder/changeling/biodegrade/sting_action(mob/living/carbon/human/user)
	var/used = FALSE // only one form of shackles removed per use
	if(!user.restrained() && !istype(user.loc, /obj/structure/closet))
		user << "<span class='warning'>We are already free!</span>"
		return 0

	if(user.handcuffed)
		var/obj/O = user.get_item_by_slot(slot_handcuffed)
		if(!istype(O))
			return 0
		user.visible_message("<span class='warning'>[user] vomits a glob of \
			acid on \his [O]!</span>", \
			"<span class='warning'>We vomit acidic ooze onto our \
			restraints!</span>")

		addtimer(src, "dissolve_handcuffs", 30, FALSE, user, O)
		used = TRUE

	if(user.wear_suit && user.wear_suit.breakouttime && !used)
		var/obj/item/clothing/suit/S = user.get_item_by_slot(slot_wear_suit)
		if(!istype(S))
			return 0
		user.visible_message("<span class='warning'>[user] vomits a glob \
			of acid across the front of \his [S]!</span>", \
			"<span class='warning'>We vomit acidic ooze onto our straight \
			jacket!</span>")
		addtimer(src, "dissolve_straightjacket", 30, FALSE, user, S)
		used = TRUE


	if(istype(user.loc, /obj/structure/closet) && !used)
		var/obj/structure/closet/C = user.loc
		if(!istype(C))
			return 0
		C.visible_message("<span class='warning'>[C]'s hinges suddenly \
			begin to melt and run!</span>")
		user << "<span class='warning'>We vomit acidic goop onto the \
			interior of [C]!</span>"
		addtimer(src, "open_closet", 70, FALSE, user, C)
		used = TRUE

	if(used)
		feedback_add_details("changeling_powers","BD")
	return 1

/obj/effect/proc_holder/changeling/biodegrade/proc/dissolve_handcuffs(mob/living/carbon/human/user, obj/O)
	if(O && user.handcuffed == O)
		user.unEquip(O)
		O.visible_message("<span class='warning'>[O] dissolves into a \
			puddle of sizzling goop.</span>")
		O.loc = get_turf(user)
		qdel(O)

/obj/effect/proc_holder/changeling/biodegrade/proc/dissolve_straightjacket(mob/living/carbon/human/user, obj/S)
	if(S && user.wear_suit == S)
		user.unEquip(S)
		S.visible_message("<span class='warning'>[S] dissolves into a puddle of sizzling goop.</span>")
		S.loc = get_turf(user)
		qdel(S)

/obj/effect/proc_holder/changeling/biodegrade/proc/open_closet(mob/living/carbon/human/user, obj/structure/closet/C)
	if(C && user.loc == C)
		C.visible_message("<span class='warning'>[C]'s door breaks and \
			opens!</span>")
		C.welded = FALSE
		C.locked = FALSE
		C.broken = TRUE
		C.open()
		user << "<span class='warning'>We open the container restraining \
			us!</span>"
