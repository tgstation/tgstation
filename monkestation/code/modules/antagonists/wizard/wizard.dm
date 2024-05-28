/datum/antagonist/wizard
	remove_from_manifest = TRUE

/datum/antagonist/wizard/on_gain()
	. = ..()
	ADD_TRAIT(owner, TRAIT_CANT_SIGN_SPELLS, REF(src))

/datum/antagonist/wizard/on_removal()
	REMOVE_TRAITS_IN(owner, REF(src))
	return ..()

/datum/antagonist/wizard/traitor // traitors that complete a final objective to become a wizard, this subtype is mainly for wizard look things
	name = "\improper Syndicate Space Wizard"
	roundend_category = "syndicate wizards/witches"
	allow_rename = FALSE
	remove_from_manifest = FALSE

// overrides the standard equipping, as to not delete the wizard's 50 traitor toys for no reason
/datum/antagonist/wizard/traitor/equip_wizard()
	return

// we do the equipping here, as to drop the traitor's items in a safe place where they can organize themselfes
/datum/antagonist/wizard/traitor/send_to_lair()
	. = ..()
	var/mob/living/carbon/human/ascended_traitor = owner.current
	if(!istype(ascended_traitor)) // safety check if you exist
		return

	// drop all their items, and equip their robe
	for(var/obj/item/item in ascended_traitor.contents)
		ascended_traitor.dropItemToGround(item)
		if(prob(75))
			step(item, pick(GLOB.alldirs))
			if(prob(50))
				step(item, pick(GLOB.alldirs))
	// MODsuits can make the previous proc fail to strip shoes/gloves... just make sure we get it all
	for(var/obj/item/below_modsuit_layer in ascended_traitor.contents)
		ascended_traitor.dropItemToGround(below_modsuit_layer)
	ascended_traitor.equipOutfit(outfit_type)

	// you can technically use a magical mirror to change your name, but this is convinient
	var/newname = sanitize_name(reject_bad_text(tgui_input_text(
		ascended_traitor,
		"You are [ascended_traitor.mind.name]. Would you like to change your name to something else now that you are all powerfull?",
		"Name change",
		ascended_traitor.mind.name,
		MAX_NAME_LEN
	)))
	if(newname)
		ascended_traitor.fully_replace_character_name(ascended_traitor.real_name, newname)
