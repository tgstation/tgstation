/datum/quirk/nyctophobia
	name = "Nyctophobia"
	desc = "As far as you can remember, you've always been afraid of the dark. While in the dark without a light source, you instinctively act careful, and constantly feel a sense of dread."
	icon = FA_ICON_LIGHTBULB
	value = -3
	medical_record_text = "Patient demonstrates a fear of the dark. (Seriously?)"
	medical_symptom_text = "Experiences panic attacks and shortness of breath when in dark environments. \
		Medication such as Psicodine may lessen the severity of the reaction."
	hardcore_value = 5
	mail_goodies = list(/obj/effect/spawner/random/engineering/flashlight)
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_TRAUMALIKE

/datum/quirk/nyctophobia/add(client/client_source)
	quirk_holder.AddComponentFrom(type, /datum/component/fearful, list(/datum/terror_handler/simple_source/nyctophobia))

/datum/quirk/nyctophobia/remove()
	quirk_holder.RemoveComponentSource(type, /datum/component/fearful)
