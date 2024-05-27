/datum/quirk/item_quirk/pride_pin
	name = "Pride Pin"
	desc = "Show off your pride with this changing pride pin!"
	icon = FA_ICON_RAINBOW
	value = 0
	gain_text = span_notice("You feel fruity.")
	lose_text = span_danger("You feel only slightly less fruity than before.")
	medical_record_text = "Patient appears to be fruity."

/datum/quirk/item_quirk/pride_pin/add_unique(client/client_source)
	var/obj/item/clothing/accessory/pride/pin = new(get_turf(quirk_holder))

	var/pride_choice = client_source?.prefs?.read_preference(/datum/preference/choiced/pride_pin) || assoc_to_keys(GLOB.pride_pin_reskins)[1]
	var/pride_reskin = GLOB.pride_pin_reskins[pride_choice]

	pin.current_skin = pride_choice
	pin.icon_state = pride_reskin

	give_item_to_holder(pin, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))
