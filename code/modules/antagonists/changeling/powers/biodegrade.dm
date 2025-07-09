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
	. = NONE
	. |= dissolve_handcuffs(user)
	. |= dissolve_legcuffs(user)
	. |= dissolve_straightjacket(user)
	. |= open_closet(user)
	. |= dissolve_cocoon(user)
	if(!.)

/datum/action/changeling/biodegrade/proc/dissolve_handcuffs(mob/living/carbon/human/user)
	if(!user.handcuffed)
		returwn NONE
	user.visible_message(span_warning("[user.handcuffed] dissolve[O.gender == PLURAL?"":"s"] into a puddle of sizzling goop."))
	new /obj/effect/decal/cleanable/greenglow(O.drop_location())
	qdel(O)
	return COMPONENT_CHANGELING_DISSOLVED_HANDCUFFS


/datum/action/changeling/biodegrade/proc/dissolve_legcuffs(mob/living/carbon/human/user)
	if(O && user.legcuffed == O)
		user.visible_message(span_warning("[O] dissolve[O.gender == PLURAL?"":"s"] into a puddle of sizzling goop."))
		new /obj/effect/decal/cleanable/greenglow(O.drop_location())
		qdel(O)
	return COMPONENT_CHANGELING_DISSOLVED_LEGCUFFS

/datum/action/changeling/biodegrade/proc/dissolve_straightjacket(mob/living/carbon/human/user)
	if(S && user.wear_suit == S)
		user.visible_message(span_warning("[S] dissolves into a puddle of sizzling goop."))
		new /obj/effect/decal/cleanable/greenglow(S.drop_location())
		qdel(S)
	return COMPONENT_CHANGLEING_DISSOLVED_STRAIGHTJACKET

/datum/action/changeling/biodegrade/proc/open_closet(mob/living/carbon/human/user)
	if(C && user.loc == C)
		C.visible_message(span_warning("[C]'s door breaks and opens!"))
		new /obj/effect/decal/cleanable/greenglow(C.drop_location())
		C.welded = FALSE
		C.locked = FALSE
		C.broken = TRUE
		C.open()
		to_chat(user, span_warning("We open the container restraining us!"))
	return COMPONENT_CHANGELING_DISSOLVED_CLOSET

/datum/action/changeling/biodegrade/proc/dissolve_cocoon(mob/living/carbon/human/user)
	if(C && user.loc == C)
		new /obj/effect/decal/cleanable/greenglow(C.drop_location())
		qdel(C) //The cocoon's destroy will move the changeling outside of it without interference
		to_chat(user, span_warning("We dissolve the cocoon!"))
	return COMPONENT_CHANGELING_DISSOLVED_COCOON
