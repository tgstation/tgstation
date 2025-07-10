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
	. |= dissolve_restraints(user)
	. |= (user)
	..()
	if(!.)
		user.balloon_alert("not restrained")
		. = FALSE
	else
		. = TRUE
	return .

/datum/action/changeling/biodegrade/proc/dissolve_restraints(mob/living/carbon/human/user)
	var/list/restraints = list()
	if(istype(user.handcuffed))
		restraints.Add(user.handcuffed)
	if(istype(user.legcuffed))
		restraints.Add(user.legcuffed)
	if(istype(user.wear_suit) && user.wear_suit?.breakouttime)
		restraints.Add(user.wear_suit)
	if(!length(restraints))
		return NONE
	for(var/obj/item/restraining in restraints)
		user.visible_message(span_danger("[user] spews globs of corrosive fluid onto [restraining], destroying it!"))
		addtimer(CALLBACK(src, PROC_REF(biodegrade_breakout), user, restraining), (3 + restraints.Find(restraining)) SECONDS)
	return COMPONENT_DISSOLVED_RESTRAINTS

/datum/aciton/changeling/biodegrade/proc/biodegrade_breakout(mob/living/carbon/human/user, obj/item/dissolved_restraint)\
	new /obj/effect/decal/cleanable/greenglow(dissolved_item.drop_location())
	log_combat(user, dissolved_restraint, "melted [dissolved_restraint]", addition = "(biodegrade)")
	dissolved_item.atom_break()

/datum/action/changeling/biodegrade/proc/open_closet(mob/living/carbon/human/user)
	if(C && user.loc == C)
		C.visible_message(span_warning("[C]'s door breaks and opens!"))
		new /obj/effect/decal/cleanable/greenglow(C.drop_location())
		C.welded = FALSE
		C.locked = FALSE
		C.broken = TRUE
		C.open()
		to_chat(user, span_changeling("We open the container restraining us!"))
	return COMPONENT_CHANGELING_DISSOLVED_CLOSET
