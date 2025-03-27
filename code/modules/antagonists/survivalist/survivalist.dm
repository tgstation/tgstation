/datum/antagonist/survivalist
	name = "\improper Survivalist"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	suicide_cry = "FOR MYSELF!!"
	/// What do we display when you gain the antag datum?
	var/greet_message = ""
	/// Should we immediately print the objectives?
	var/announce_objectives = TRUE

/datum/antagonist/survivalist/forge_objectives()
	var/datum/objective/survive/survive = new
	survive.owner = owner
	objectives += survive

/datum/antagonist/survivalist/on_gain()
	owner.special_role = "survivalist"
	forge_objectives()
	. = ..()

/datum/antagonist/survivalist/greet()
	. = ..()
	to_chat(owner, "<B>[greet_message]</B>")
	if (announce_objectives)
		owner.announce_objectives()

/datum/antagonist/survivalist/guns
	greet_message = "Your own safety matters above all else, and the only way to ensure your safety is to stockpile weapons! Grab as many guns as possible, by any means necessary. Kill anyone who gets in your way."
	hardcore_random_bonus = TRUE

/datum/antagonist/survivalist/guns/forge_objectives()
	var/datum/objective/steal_n_of_type/summon_guns/guns = new
	guns.owner = owner
	objectives += guns
	..()

/datum/antagonist/survivalist/magic
	name = "Amateur Magician"
	greet_message = "Grow your newfound talent! Grab as many magical artefacts as possible, by any means necessary. Kill anyone who gets in your way."
	hardcore_random_bonus = TRUE

/datum/antagonist/survivalist/magic/greet()
	. = ..()
	to_chat(owner, span_notice("As a wonderful magician, you should remember that spellbooks don't mean anything if they are used up."))

/datum/antagonist/survivalist/magic/forge_objectives()
	var/datum/objective/steal_n_of_type/summon_magic/magic = new
	magic.owner = owner
	objectives += magic
	..()

/datum/antagonist/survivalist/magic/on_gain()
	. = ..()
	ADD_TRAIT(owner, TRAIT_MAGICALLY_GIFTED, REF(src))

/datum/antagonist/survivalist/magic/on_removal()
	REMOVE_TRAIT(owner, TRAIT_MAGICALLY_GIFTED, REF(src))
	return..()

/// Applied by the battle royale objective
/datum/antagonist/survivalist/battle_royale
	name = "Battle Royale Contestant"
	greet_message = "There has to be some way you can make it out of this alive..."
	announce_objectives = FALSE

/datum/antagonist/survivalist/battle_royale/on_gain()
	. = ..()
	if (isnull(owner.current))
		return
	RegisterSignals(owner.current, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING), PROC_REF(on_died))

/datum/antagonist/survivalist/battle_royale/greet()
	to_chat(owner, span_warning("[span_bold("You hear a tinny voice in your ear: ")] \
		Welcome contestant to Rumble Royale, the galaxy's greatest show! \n\
		You may have already heard our announcement, but we're glad to tell you that you are on live TV! \n\
		Your objective in this contest is simple: Within ten minutes be the last contestant left alive, to win a fabulous prize! \n\
		Your fellow contestants will be hearing this too, so you should grab a GPS quick and get hunting! \n\
		Noncompliance and removal of this implant is not recommended, and remember to smile for the cameras!"))

	return ..()

/datum/antagonist/survivalist/battle_royale/on_removal()
	if (isnull(owner.current))
		return ..()
	UnregisterSignal(owner.current, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING))
	if (owner.current.stat == DEAD)
		return ..()
	to_chat(owner, span_notice("Your body is flooded with relief. Against all the odds, you've made it out alive."))
	owner.current?.add_mood_event("battle_royale", /datum/mood_event/royale_survivor)
	return ..()

/// Add an objective to go to a specific place.
/datum/antagonist/survivalist/battle_royale/proc/set_target_area(target_area_name)
	var/datum/objective/custom/travel = new
	travel.owner = owner
	travel.explanation_text = "Reach the [target_area_name] before time runs out."
	objectives.Insert(1, travel)
	owner.announce_objectives()

/// Called if you fail to survive.
/datum/antagonist/survivalist/battle_royale/proc/on_died()
	SIGNAL_HANDLER
	owner.remove_antag_datum(type)

/datum/mood_event/royale_survivor
	description = "I made it out of Rumble Royale with my life."
	mood_change = 4
