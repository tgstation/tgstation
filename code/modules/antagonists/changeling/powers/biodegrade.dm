/datum/action/changeling/biodegrade
	name = "Biodegrade"
	desc = "Dissolves restraints or other objects preventing free movement. Costs 30 chemicals."
	helptext = "This is obvious to nearby people, and can destroy standard restraints and closets."
	button_icon_state = "biodegrade"
	chemical_cost = 30 //High cost to prevent spam
	dna_cost = 2
	req_human = TRUE
	disabled_by_fire = FALSE

/datum/action/changeling/biodegrade/sting_action(mob/living/carbon/human/user)
	if(user.handcuffed)
		var/obj/O = user.get_item_by_slot(ITEM_SLOT_HANDCUFFED)
		if(!istype(O))
			return FALSE
		user.visible_message(span_warning("[user] vomits a glob of acid on [user.p_their()] [O]!"), \
			span_warning("We vomit acidic ooze onto our restraints!"))

		addtimer(CALLBACK(src, PROC_REF(dissolve_handcuffs), user, O), 3 SECONDS)
		log_combat(user, user.handcuffed, "melted handcuffs", addition = "(biodegrade)")
		..()
		return TRUE

	if(user.legcuffed)
		var/obj/O = user.get_item_by_slot(ITEM_SLOT_LEGCUFFED)
		if(!istype(O))
			return FALSE
		user.visible_message(span_warning("[user] vomits a glob of acid on [user.p_their()] [O]!"), \
			span_warning("We vomit acidic ooze onto our restraints!"))

		addtimer(CALLBACK(src, PROC_REF(dissolve_legcuffs), user, O), 3 SECONDS)
		log_combat(user, user.legcuffed, "melted legcuffs", addition = "(biodegrade)")
		..()
		return TRUE

	if(user.wear_suit?.breakouttime)
		var/obj/item/clothing/suit/S = user.get_item_by_slot(ITEM_SLOT_OCLOTHING)
		if(!istype(S))
			return FALSE
		user.visible_message(span_warning("[user] vomits a glob of acid across the front of [user.p_their()] [S]!"), \
			span_warning("We vomit acidic ooze onto our [user.wear_suit.name]!"))
		addtimer(CALLBACK(src, PROC_REF(dissolve_straightjacket), user, S), 3 SECONDS)
		log_combat(user, user.wear_suit, "melted [user.wear_suit]", addition = "(biodegrade)")
		..()
		return TRUE

	if(istype(user.loc, /obj/structure/closet))
		var/obj/structure/closet/C = user.loc
		if(!istype(C))
			return FALSE
		C.visible_message(span_warning("[C]'s hinges suddenly begin to melt and run!"))
		to_chat(user, span_warning("We vomit acidic goop onto the interior of [C]!"))
		addtimer(CALLBACK(src, PROC_REF(open_closet), user, C), 7 SECONDS)
		log_combat(user, user.loc, "melted locker", addition = "(biodegrade)")
		..()
		return TRUE

	if(istype(user.loc, /obj/structure/spider/cocoon))
		var/obj/structure/spider/cocoon/C = user.loc
		if(!istype(C))
			return FALSE
		C.visible_message(span_warning("[src] shifts and starts to fall apart!"))
		to_chat(user, span_warning("We secrete acidic enzymes from our skin and begin melting our cocoon..."))
		addtimer(CALLBACK(src, PROC_REF(dissolve_cocoon), user, C), 25) //Very short because it's just webs
		log_combat(user, user.loc, "melted cocoon", addition = "(biodegrade)")
		..()
		return TRUE

	var/obj/item/clothing/shoes/shoes = user.shoes
	if(istype(shoes) && shoes.tied == SHOES_KNOTTED && !(shoes.resistance_flags & (INDESTRUCTIBLE|UNACIDABLE|ACID_PROOF)))
		new /obj/effect/decal/cleanable/greenglow(shoes.drop_location())
		user.visible_message(
			span_warning("[user] vomits a glob of acid on [user.p_their()] tied up [shoes.name], melting [shoes.p_them()] into a pool of goo!"),
			span_warning("We vomit acidic ooze onto our tied up [shoes.name], melting [shoes.p_them()] into a pool of goo!"),
		)
		log_combat(user, shoes, "melted own shoes", addition = "(biodegrade)")
		qdel(shoes)
		..()
		return TRUE

	user.balloon_alert(user, "already free!")
	return FALSE

/datum/action/changeling/biodegrade/proc/dissolve_handcuffs(mob/living/carbon/human/user, obj/O)
	if(O && user.handcuffed == O)
		user.visible_message(span_warning("[O] dissolve[O.gender == PLURAL?"":"s"] into a puddle of sizzling goop."))
		new /obj/effect/decal/cleanable/greenglow(O.drop_location())
		qdel(O)

/datum/action/changeling/biodegrade/proc/dissolve_legcuffs(mob/living/carbon/human/user, obj/O)
	if(O && user.legcuffed == O)
		user.visible_message(span_warning("[O] dissolve[O.gender == PLURAL?"":"s"] into a puddle of sizzling goop."))
		new /obj/effect/decal/cleanable/greenglow(O.drop_location())
		qdel(O)

/datum/action/changeling/biodegrade/proc/dissolve_straightjacket(mob/living/carbon/human/user, obj/S)
	if(S && user.wear_suit == S)
		user.visible_message(span_warning("[S] dissolves into a puddle of sizzling goop."))
		new /obj/effect/decal/cleanable/greenglow(S.drop_location())
		qdel(S)

/datum/action/changeling/biodegrade/proc/open_closet(mob/living/carbon/human/user, obj/structure/closet/C)
	if(C && user.loc == C)
		C.visible_message(span_warning("[C]'s door breaks and opens!"))
		new /obj/effect/decal/cleanable/greenglow(C.drop_location())
		C.welded = FALSE
		C.locked = FALSE
		C.broken = TRUE
		C.open()
		to_chat(user, span_warning("We open the container restraining us!"))

/datum/action/changeling/biodegrade/proc/dissolve_cocoon(mob/living/carbon/human/user, obj/structure/spider/cocoon/C)
	if(C && user.loc == C)
		new /obj/effect/decal/cleanable/greenglow(C.drop_location())
		qdel(C) //The cocoon's destroy will move the changeling outside of it without interference
		to_chat(user, span_warning("We dissolve the cocoon!"))
