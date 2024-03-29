/**
 * A big final event to run when you complete seven rituals
 */
/datum/grand_finale
	/// Friendly name for selection menu
	var/name
	/// Tooltip description for selection menu
	var/desc
	/// An icon to display to represent the choice
	var/icon/icon
	/// Icon state to use to represent the choice
	var/icon_state
	/// Prevent especially dangerous options from being chosen until we're fine with the round ending
	var/minimum_time = 0
	/// Override the rune invocation time
	var/ritual_invoke_time = 30 SECONDS
	/// Provide an extremely loud radio message when this one starts
	var/dire_warning = FALSE
	/// Overrides the default colour you glow while channeling the rune, optional
	var/glow_colour

/**
 * Returns an entry for a radial menu for this choice.
 * Returns null if entry is abstract or invalid for current circumstances.
 */
/datum/grand_finale/proc/get_radial_choice()
	if (!name || !desc || !icon || !icon_state)
		return
	var/time_remaining_desc = ""
	if (minimum_time >= world.time - SSticker.round_start_time)
		time_remaining_desc = " <i>This ritual will be available to begin invoking in [DisplayTimeText(minimum_time - world.time - SSticker.round_start_time)]</i>"
	var/datum/radial_menu_choice/choice = new()
	choice.name = name
	choice.image = image(icon = icon, icon_state = icon_state)
	choice.info = desc + time_remaining_desc
	return choice

/**
 * Actually do the thing.
 * Arguments
 * * invoker - The wizard casting this.
 */
/datum/grand_finale/proc/trigger(mob/living/invoker)
	// Do something cool.

/// Tries to equip something into an inventory slot, then hands, then the floor.
/datum/grand_finale/proc/equip_to_slot_then_hands(mob/living/carbon/human/invoker, slot, obj/item/item)
	if(!item)
		return
	if(!invoker.equip_to_slot_if_possible(item, slot, disable_warning = TRUE))
		invoker.put_in_hands(item)

/// They are not going to take this lying down.
/datum/grand_finale/proc/create_vendetta(datum/mind/aggrieved_crewmate, datum/mind/wizard)
	aggrieved_crewmate.add_antag_datum(/datum/antagonist/wizard_prank_vendetta)
	var/datum/antagonist/wizard_prank_vendetta/antag_datum = aggrieved_crewmate.has_antag_datum(/datum/antagonist/wizard_prank_vendetta)
	var/datum/objective/assassinate/wizard_murder = new
	wizard_murder.owner = aggrieved_crewmate
	wizard_murder.target = wizard
	wizard_murder.explanation_text = "Kill [wizard.current.name], the one who did this."
	antag_datum.objectives += wizard_murder

	to_chat(aggrieved_crewmate.current, span_warning("No! This isn't right!"))
	aggrieved_crewmate.announce_objectives()

/**
 * Antag datum to give to people who want to kill the wizard.
 * This doesn't preclude other people choosing to want to kill the wizard, just these people are rewarded for it.
 */
/datum/antagonist/wizard_prank_vendetta
	name = "\improper Wizard Prank Victim"
	roundend_category = "wizard prank victims"
	show_in_antagpanel = FALSE
	antagpanel_category = ANTAG_GROUP_CREW
	show_name_in_check_antagonists = TRUE
	count_against_dynamic_roll_chance = FALSE
	silent = TRUE

/// Give everyone magic items, its so simple it feels pointless to give it its own file
/datum/grand_finale/magic
	name = "Evolution"
	desc = "The ultimate use of your gathered power! Give the crew their own magic, they'll surely realise that right and wrong have no meaning when you hold ultimate power!"
	icon = 'icons/obj/scrolls.dmi'
	icon_state = "scroll"

/datum/grand_finale/magic/trigger(mob/living/carbon/human/invoker)
	message_admins("[key_name(invoker)] summoned magic")
	summon_magic(survivor_probability = 20) // Wow, this one was easy!
