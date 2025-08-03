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
	..()
	var/list/obj/restraints = list()
	var/obj/item/clothing/suit/straitjacket = user.get_item_by_slot(ITEM_SLOT_OCLOTHING)
	if(!straitjacket?.breakouttime)
		straitjacket = null
	var/obj/legcuffs = user.get_item_by_slot(ITEM_SLOT_LEGCUFFED)
	var/obj/handcuffs = user.get_item_by_slot(ITEM_SLOT_HANDCUFFED)
	var/obj/some_manner_of_cage = user.loc
	var/mob/living/space_invader = user.pulled_by
	if(!straitjacket && !legcuffs && !handcuffs && !some_manner_of_cage && !space_invader)
		user.balloon_alert(user, "already free!")
		return FALSE
	if(straitjacket)
		restraints.Add(straitjacket)
	if(legcuffs)
		restraints.Add(legcuffs)
	if(handcuffs)
		restraints.Add(handcuffs)
	if(some_manner_of_cage)
		restraints.Add(some_manner_of_cage)
	for(var/obj/restraint as anything in restraints)
		spew_acid(user, restraint)
	if(space_invader)
		punish_with_acid(user, space_invader)
	return TRUE

/datum/action/changeling/biodegrade/proc/spew_acid(mob/living/carbon/human/user, obj/restraint)
	if(restraint == user.loc)
		restraint.visible_message("Bubbling acid start spewing out of [src]...")
		addtimer(CALLBACK())



 /proc/punish_with_acid(mob/living/carbon/human/user, mob/living/hopeless_manhandler)
