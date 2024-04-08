/datum/slime_trait/endisnigh
	name = "Ash"
	desc = "This feels like a reference?"


/datum/slime_trait/endisnigh/on_add(mob/living/basic/slime/parent)
	. = ..()
	parent.slime_flags |= OVERWRITES_COLOR
	parent.icon_state_override = "ash"
	parent.overwrite_color = "#242234"
	SEND_SIGNAL(parent, EMOTION_BUFFER_UPDATE_OVERLAY_STATES, list())

/datum/slime_trait/endisnigh/on_remove(mob/living/basic/slime/parent)
	. = ..()
	parent.slime_flags &= ~OVERWRITES_COLOR
	parent.icon_state_override = null
	parent.overwrite_color = null
	SEND_SIGNAL(parent, EMOTION_BUFFER_UPDATE_OVERLAY_STATES, parent.emotion_states)
