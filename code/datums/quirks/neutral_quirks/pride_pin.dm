/datum/quirk/item_quirk/pride_pin
	name = "Patriotic Pin" // MASSMETA EDIT everythere replace [pride -> patriotic]
	desc = "Show off your patriotic with this changing patriotic pin!"
	icon = FA_ICON_RAINBOW
	value = 0
	gain_text = span_notice("You feel patriotic.") // EDIT
	lose_text = span_danger("You feel only slightly less patriotic than before.") // EDIT
	medical_record_text = "Patient appears to be patriotic."

/datum/quirk/item_quirk/pride_pin/add_unique(client/client_source)
	var/obj/item/clothing/accessory/patriotic/pin = new(get_turf(quirk_holder)) // EDIT

	var/pride_choice = client_source?.prefs?.read_preference(/datum/preference/choiced/pride_pin) || assoc_to_keys(GLOB.patriotic_flag_reskins)[1] // EDIT
	var/pride_reskin = GLOB.patriotic_flag_reskins[pride_choice]

	pin.current_skin = pride_choice
	pin.icon_state = pride_reskin

	give_item_to_holder(pin, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))
