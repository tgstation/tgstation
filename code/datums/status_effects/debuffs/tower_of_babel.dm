/datum/status_effect/tower_of_babel
	id = "tower_of_babel"
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/tower_of_babel
	var/possible_languages = GLOB.all_languages - /datum/language/codespeak

/datum/status_effect/tower_of_babel/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/tower_of_babel/on_apply()
	ADD_TRAIT(owner, TRAIT_DISCOORDINATED_TOOL_USER, "[type]")

	var/random_language = pick(possible_languages)
	owner.grant_language(random_language, source = LANGUAGE_BABEL)
	// block every language except the randomized one
	owner.add_blocked_language(GLOB.all_languages - random_language, source = LANGUAGE_BABEL)
	// this lets us bypass tongue language restrictions except for people who have stuff like mute,
	// no tongue, tongue tied, etc. curse of babel shouldn't let people who have a tongue disability speak
	ADD_TRAIT(owner, TRAIT_TOWER_OF_BABEL, "[type]")
	owner.add_mood_event(id, /datum/mood_event/tower_of_babel)

	owner.emote("mumble")

	return ..()

/datum/status_effect/tower_of_babel/on_remove()
	REMOVE_TRAIT(owner, TRAIT_DISCOORDINATED_TOOL_USER, "[type]")

	owner.clear_mood_event(id)

	// if user is affected by tower of babel, we remove the blocked languages
	owner.remove_blocked_language(GLOB.all_languages, source = LANGUAGE_BABEL)
	owner.remove_all_languages(source = LANGUAGE_BABEL)
	owner.update_atom_languages()

	REMOVE_TRAIT(owner, TRAIT_TOWER_OF_BABEL, TRAUMA_TRAIT)
	return ..()

// Used by wizard magic and tower of babel event
/datum/status_effect/tower_of_babel/magical
	id = "tower_of_babel_magic" // do we need a new id?
	duration = -1
	possible_languages = GLOB.all_languages // even codespeak is possible

/datum/status_effect/tower_of_babel/magical/on_apply()
	. = ..()
	if(!.)
		return

	owner.say(";Nimrod, the Tower of Babel has fallen!", forced = "tower of babel")
	owner.playsound_local(get_turf(owner), 'sound/magic/magic_block_mind.ogg', 75, vary = TRUE) // sound of creepy whispers
	to_chat(owner, span_reallybig(span_hypnophrase("You feel a magical force affecting your speech patterns!")))

/datum/status_effect/tower_of_babel/magical/on_remove()
	. = ..()
	if(!.)
		return

	REMOVE_TRAIT(owner, TRAIT_TOWER_OF_BABEL, TRAUMA_TRAIT)
	to_chat(owner, span_reallybig(span_hypnophrase("You feel the magical force affecting your speech patterns fade away...")))


/atom/movable/screen/alert/status_effect/tower_of_babel
	name = "Tower of babel"
	desc = "You seem to be babbling in a strange language..."
	icon_state = "convulsing"
