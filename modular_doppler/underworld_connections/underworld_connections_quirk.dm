/datum/quirk/item_quirk/underworld_connections
	name = "Black Market Smuggler"
	desc = "You're in with the seedier elements of the galactic underworld, and can start with a customizable black market uplink; this customized version isn't easy to come by, and isn't the kind of thing just anyone would have. Security has suspicions about your dirty work, and it's been marked on your record."
	icon = FA_ICON_SUITCASE
	value = 8
	gain_text = span_notice("Your contacts to the underworld are close at hand.")
	lose_text = span_notice("Your contacts to the underworld have gone quiet.")
	medical_record_text = "Patient records may have been tampered with in the past."
	quirk_flags = QUIRK_HIDE_FROM_SCAN
	mail_goodies = list(/obj/item/storage/briefcase/secure)
	mob_trait = TRAIT_CRIMINAL_CONNECTIONS

/datum/quirk/item_quirk/underworld_connections/add_unique(client/client_source)
	if (ishuman(quirk_holder))
		var/obj/item/market_uplink/blackmarket/roundstart_uplink = new

		//customize the goddamn uplink
		var/uplink_skin =  client_source?.prefs.read_preference(/datum/preference/choiced/uplink_skin)
		var/list/uplink_skin_val = GLOB.possible_uplink_skins[uplink_skin]
		if (uplink_skin_val)
			roundstart_uplink.icon = uplink_skin_val[1]
			roundstart_uplink.icon_state = uplink_skin_val[2]

		var/uplink_name = client_source?.prefs.read_preference(/datum/preference/text/uplink_name)
		if (uplink_name)
			roundstart_uplink.name = uplink_name

		var/uplink_desc = client_source?.prefs.read_preference(/datum/preference/text/uplink_desc)
		if (uplink_desc)
			roundstart_uplink.desc = uplink_desc

		give_item_to_holder(
			roundstart_uplink,
			list(
				LOCATION_LPOCKET = ITEM_SLOT_LPOCKET,
				LOCATION_RPOCKET = ITEM_SLOT_RPOCKET,
				LOCATION_BACKPACK = ITEM_SLOT_BACKPACK,
				LOCATION_HANDS = ITEM_SLOT_HANDS,
			)
		)

/datum/quirk/item_quirk/underworld_connections/post_add()
	. = ..()

	// Make sure we've got a client/mind first (hence, post_add), then give us exploitables access - DONT DO THIS FOR NOW BECAUSE WE DON'T HAVE EXPLOITABLES YET
	//quirk_holder.mind.has_exploitables_override = TRUE
	//quirk_holder.mind.handle_exploitables()

	// Set us as 'suspected' on HUDs at roundstart and leave a note about our dark and mysterious past. No permits for us! If we're human.
	if (ishuman(quirk_holder))
		var/mob/living/carbon/human/human_holder = quirk_holder
		var/datum/record/crew/our_record = find_record(human_holder.name)
		if (our_record)
			our_record.wanted_status = WANTED_SUSPECT
			our_record.security_note += "DO NOT ISSUE WEAPON PERMITS. Subject has suspected links to covert criminal elements, and has been indicated as a priority smuggling suspect."

/datum/quirk/item_quirk/underworld_connections/remove()
	if (ishuman(quirk_holder))
		var/mob/living/carbon/human/human_holder = quirk_holder
		var/datum/record/crew/our_record = find_record(human_holder.name)
		if (isnull(our_record))
			return
		if (our_record.security_note)
			our_record.security_note = replacetext(our_record.security_note, "DO NOT ISSUE WEAPON PERMITS. Subject has suspected links to covert criminal elements, and has been indicated as a priority smuggling suspect.", "")
		if (!length(our_record.security_note)) // that was the only thing in the notes
			our_record.security_note = null
		if (isnull(our_record.security_note) && our_record.wanted_status == WANTED_SUSPECT) // only clear this if the security notes contain nothing but the quirk-generated note, just to be certain we are not accidentally resetting the wanted status for an unrelated crime
			our_record.wanted_status = WANTED_NONE

	//quirk_holder.mind.has_exploitables_override = FALSE -- readd this when we have exploitables
	//quirk_holder.mind.handle_exploitables()

/datum/quirk_constant_data/underworld_connections
	associated_typepath = /datum/quirk/item_quirk/underworld_connections
	customization_options = list(/datum/preference/choiced/uplink_skin, /datum/preference/text/uplink_name, /datum/preference/text/uplink_desc)

/datum/preference/choiced/uplink_skin
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "underworld_uplink_skin"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE

/// List of uplink skins, associated list where the value is a list containing icon dmi and then icon_state
GLOBAL_LIST_INIT(possible_uplink_skins, list(
	"Brick Phone" = list('icons/obj/antags/gang/cell_phone.dmi', "phone_off"),
	"Default Black Market Uplink" = list('icons/obj/devices/blackmarket.dmi', "uplink"),
	"Generic Radio" = list('icons/obj/devices/voice.dmi', "radio"),
	"Green Walkie Talkie" = list('icons/obj/devices/voice.dmi', "walkietalkie"),
	"Inconspicious PDA" = list('icons/obj/devices/modular_pda.dmi', "pda"),
	"Mining Radio" = list('icons/obj/devices/miningradio.dmi', "miningradio"),
	"Red Analogue Phone" = list('icons/obj/devices/voice.dmi', "red_phone"),
	"Red Walkie Talkie" = list('icons/obj/devices/voice.dmi', "nukietalkie"),
	"Syndicate Suspicious Phone" = list('icons/obj/antags/syndicate_tools.dmi', "suspiciousphone"),
	"Syndicate Tablet (Silicon)" = list('icons/obj/devices/modular_pda.dmi', "tablet-silicon-syndicate"),
))

/datum/preference/choiced/uplink_skin/init_possible_values()
	return assoc_to_keys(GLOB.possible_uplink_skins)

/datum/preference/choiced/uplink_skin/create_default_value()
	return "Default Black Market Uplink"

/datum/preference/choiced/uplink_skin/is_accessible(datum/preferences/preferences)
	if (!..())
		return FALSE

	return "Black Market Smuggler" in preferences.all_quirks

/datum/preference/choiced/uplink_skin/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/text/uplink_name
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "underworld_uplink_name"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE
	maximum_value_length = 32

/datum/preference/text/uplink_name/is_accessible(datum/preferences/preferences)
	if (!..())
		return FALSE

	return "Black Market Smuggler" in preferences.all_quirks

/datum/preference/text/uplink_name/serialize(input)
	return htmlrendertext(input)

/datum/preference/text/uplink_name/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/text/uplink_desc
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "underworld_uplink_desc"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/text/uplink_desc/is_accessible(datum/preferences/preferences)
	if (!..())
		return FALSE

	return "Black Market Smuggler" in preferences.all_quirks

/datum/preference/text/uplink_desc/serialize(input)
	return htmlrendertext(input)

/datum/preference/text/uplink_desc/apply_to_human(mob/living/carbon/human/target, value)
	return
