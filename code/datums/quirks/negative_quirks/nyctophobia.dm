/datum/quirk/nyctophobia
	name = "Nyctophobia"
	desc = "As far as you can remember, you've always been afraid of the dark. While in the dark without a light source, you instinctively act careful, and constantly feel a sense of dread."
	icon = FA_ICON_LIGHTBULB
	value = -3
	medical_record_text = "Patient demonstrates a fear of the dark. (Seriously?)"
	hardcore_value = 5
	mail_goodies = list(/obj/effect/spawner/random/engineering/flashlight)

/datum/quirk/nyctophobia/add(client/client_source)
	quirk_holder.AddComponentFrom(type, /datum/component/fearful, list(/datum/terror_handler/simple_source/nyctophobia))

/datum/quirk/nyctophobia/remove()
	quirk_holder.RemoveComponentSource(type, /datum/component/fearful)
