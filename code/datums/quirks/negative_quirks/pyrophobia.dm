/datum/quirk/pyrophobia
	name = "Pyrophobia"
	desc = "You are terrified of fire and flames."
	icon = FA_ICON_FIRE_EXTINGUISHER
	value = -3
	medical_record_text = "Patient demonstrates a fear of fire."
	medical_symptom_text = "Experiences panic attacks and shortness of breath when near open flames. \
		Medication such as Psicodine may lessen the severity of the reaction."
	hardcore_value = 5
	quirk_flags = QUIRK_TRAUMALIKE

/datum/quirk/pyrophobia/add(client/client_source)
	. = ..()
	quirk_holder.AddComponentFrom(type, /datum/component/fearful, list( \
		/datum/terror_handler/force_stop_drop_roll, \
		/datum/terror_handler/is_stop_drop_rolling, \
		/datum/terror_handler/simple_source/pyrophobia, \
	))

/datum/quirk/pyrophobia/remove()
	. = ..()
	quirk_holder.RemoveComponentSource(type, /datum/component/fearful)

/datum/mood_event/pyrophobia
	description = "I see fire, and I don't like it!"
	mood_change = -1
	event_flags = MOOD_EVENT_FEAR

/datum/mood_event/pyrophobia/add_effects(fire_size = 0)
	mood_change = -1 * fire_size

/datum/mood_event/pyrophobia/be_replaced(datum/mood/home, datum/mood_event/new_event, fire_size = 0)
	mood_change = min(mood_change, -1 * fire_size)
	return BLOCK_NEW_MOOD
