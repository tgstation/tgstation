/datum/quirk/limp
	name = "Limp"
	desc = "Из-за старой травмы или физической слабости ваши ноги не позволяют вам бегать."
	value = -6
	icon = FA_ICON_CRUTCH

	mob_trait = TRAIT_LIMP

	medical_record_text = "У пациента наблюдается хроническая патология нижних конечностей, ограничивающая подвижность."

	gain_text = span_danger("Ваши ноги становятся слишком тяжелыми и болезненными для бега.")
	lose_text = span_notice("Боль и скованность в ногах проходят, вы снова можете свободно двигаться.")

/datum/quirk/limp/add()
	var/mob/living/L = quirk_holder

	if(L.move_intent == MOVE_INTENT_RUN)
		L.toggle_move_intent(MOVE_INTENT_WALK)

	RegisterSignal(L, COMSIG_MOB_PRE_TOGGLE_MOVE_INTENT, PROC_REF(on_intent_attempt))

/datum/quirk/limp/remove()
	var/mob/living/L = quirk_holder
	UnregisterSignal(L, COMSIG_MOB_PRE_TOGGLE_MOVE_INTENT, src)

/datum/quirk/limp/proc/on_intent_attempt(datum/source, target_intent)
	SIGNAL_HANDLER
	var/mob/living/L = source

	if(target_intent == MOVE_INTENT_RUN)
		to_chat(L, span_warning("Я физически не могу бежать!"))
		return COMPONENT_PREVENT_TOGGLE_MOVE_INTENT
