/datum/quirk/empath
	name = "Empath"
	desc = "Whether it's a sixth sense or careful study of body language, it only takes you a quick glance at someone to understand how they feel."
	icon = FA_ICON_SMILE_BEAM
	value = 8
	gain_text = span_notice("You feel in tune with those around you.")
	lose_text = span_danger("You feel isolated from others.")
	medical_record_text = "Patient is highly perceptive of and sensitive to social cues, or may possibly have ESP. Further testing needed."
	mail_goodies = list(/obj/item/toy/foamfinger)

/datum/quirk/empath/add(client/client_source)
	quirk_holder.AddComponentFrom(REF(src), /datum/component/empathy)

/datum/quirk/empath/remove(client/client_source)
	quirk_holder.RemoveComponentSource(REF(src), /datum/component/empathy)
