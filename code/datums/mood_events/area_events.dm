/** Use this type of mood event for a location a player visits
 *
 *	/area/
 *		var/mood_bonus // Bonus mood for being in this area
 *		var/mood_message // Mood message for being here, only shows up if mood_bonus != 0
 *		var/mood_trait // Does the mood bonus require a trait?
 *
 *  Do not put any /area/ types in this file location!
 **/

/datum/mood_event/area
	description = "" //Fill this out in the area
	mood_change = 0

/datum/mood_event/area/add_effects(_mood_change, _description)
	mood_change = _mood_change
	description = _description
