/// Spit out a hint for using the voice interface
/datum/gizmo_effect/voice_hint/activate(atom/movable/holder, datum/gizmo_effect_combination/master, datum/gizmo_interface/interface)
	var/datum/component/gizmo_voice/voice = holder.GetComponent(/datum/component/gizmo_voice)

	holder.say(voice.active_words.Join(" "))

/// Pick a different language
/datum/gizmo_effect/language_change/activate(atom/movable/holder, datum/gizmo_effect_combination/master, datum/gizmo_interface/interface)
	holder.grant_random_uncommon_language("gizmo")
