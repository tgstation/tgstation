/datum/antagonist/spider
	name = "\improper Spider"
	antagpanel_category = ANTAG_GROUP_ARACHNIDS
	show_in_roundend = FALSE
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	/// Orders given to us by the queen
	var/directive

/datum/antagonist/spider/New(directive)
	. = ..()
	src.directive = directive

/datum/antagonist/spider/on_gain()
	forge_objectives(directive)
	. = ..()

/datum/antagonist/spider/greet()
	. = ..()
	owner.announce_objectives()

/datum/objective/spider
	explanation_text = "Spread the infestation."

/datum/objective/spider/New(directive)
	..()
	if(directive)
		explanation_text = "Your queen has given you a directive! Follow it at all costs: [directive]"

/datum/objective/spider/check_completion()
	return owner.current.stat != DEAD

/datum/antagonist/spider/forge_objectives()
	var/datum/objective/spider/objective = new(directive)
	objective.owner = owner
	objectives += objective
