/*
	Passport

	An ID card we hand to off-station actors who are expected to be identified as off-station.
	Has a unique icon and description.

*/

/obj/item/card/id/passport
	name = "passport"
	desc = "A passport, often issued to travelers in space so that they can prove their identities and get into places via fancy scanning technology on airlocks."
	icon = 'code/modules/stories_system/icons/passports.dmi'
	icon_state = "passport4_closed"
	trim = /datum/id_trim/job/assistant/tourist

/obj/item/card/id/passport/update_label()
	var/name_string = registered_name ? "[registered_name]'s Passport" : initial(name)
	name = "[name_string]"

/obj/item/card/id/passport/government
	name = "government passport"
	desc = "A passport, often issued to travelers in space so that they can prove their identities and get into places via fancy scanning technology on airlocks.\n\
	This passport's got a official watermark proving it's a governmental passport, often reserved for diplomats or official representatitves of a governmental body \
	and/or their staff."
	icon_state = "passport5_closed"
	trim = /datum/id_trim/job/assistant/government_official
	/// What goverment this is from, shown on the label
	var/government_seal = "Spinward Stellar Coalition"

/obj/item/card/id/passport/government/update_label()
	name = registered_name ? "[registered_name]'s Passport ([government_seal]" : "[initial(name)] ([government_seal])"

/obj/item/card/id/passport/government/inspector
	government_seal = "Regulatory Space Academy"
