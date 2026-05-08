/datum/action/swap_arts
	name = "Remember the Basics" //this is dynamic, uses `update_button_name`
	desc = "LMB: See your movelist. RMB: Swap artstyle, if you have more than one."
	background_icon_state = "bg_martial_arts"
	button_icon_state = "martial"

	///The martial arts currently used for the name & help information.
	var/datum/martial_art/current_used_art

/datum/action/swap_arts/Destroy()
	current_used_art = null
	return ..()

/datum/action/swap_arts/New(Target, datum/martial_art/starting_style)
	current_used_art = starting_style
	return ..()

/datum/action/swap_arts/update_button_name(atom/movable/screen/movable/action_button/button, force, datum/martial_art/new_art)
	if(new_art)
		current_used_art = new_art
	name = "[current_used_art.help_verb]"
	var/mob/living/living_owner = owner
	if(LAZYLEN(living_owner.martial_arts) >= 2)
		name += "/Swap Style"
	return ..()

/datum/action/swap_arts/Trigger(mob/living/clicker, trigger_flags)
	. = ..()
	var/mob/living/living_owner = owner
	if(trigger_flags & TRIGGER_SECONDARY_ACTION && (LAZYLEN(living_owner.martial_arts) >= 2))
		clicker.cycle_style()
		return TRUE
	var/help_information = current_used_art.get_style_help()
	for(var/info in help_information)
		to_chat(clicker, info)
	return TRUE
