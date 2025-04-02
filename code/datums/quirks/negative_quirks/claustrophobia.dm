/datum/quirk/claustrophobia
	name = "Claustrophobia"
	desc = "You are terrified of small spaces and certain jolly figures. If you are placed inside any container, locker, or machinery, a panic attack sets in and you struggle to breathe."
	icon = FA_ICON_BOX_OPEN
	value = -4
	medical_record_text = "Patient demonstrates a fear of tight spaces."
	hardcore_value = 5
	quirk_flags = QUIRK_HUMAN_ONLY
	mail_goodies = list(/obj/item/reagent_containers/syringe/convermol) // to help breathing

/datum/quirk/claustrophobia/add(client/client_source)
	quirk_holder.AddComponentFrom(type, /datum/component/fearful, list(/datum/terror_handler/simple_source/claustrophobia, /datum/terror_handler/simple_source/clausophobia))

/datum/quirk/claustrophobia/remove()
	quirk_holder.RemoveComponentSource(type, /datum/component/fearful)
