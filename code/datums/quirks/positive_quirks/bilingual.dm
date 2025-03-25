/datum/quirk/bilingual
	name = "Bilingual"
	desc = "Over the years you've picked up an extra language!"
	icon = FA_ICON_GLOBE
	value = 4
	gain_text = span_notice("Some of the words of the people around you certainly aren't common. Good thing you studied for this.")
	lose_text = span_notice("You seem to have forgotten your second language.")
	medical_record_text = "Patient speaks multiple languages."
	mail_goodies = list(/obj/item/taperecorder, /obj/item/clothing/head/frenchberet, /obj/item/clothing/mask/fakemoustache/italian)

/datum/quirk_constant_data/bilingual
	associated_typepath = /datum/quirk/bilingual
	customization_options = list(
		/datum/preference/choiced/language,
		/datum/preference/toggle/language_speakable,
		/datum/preference/choiced/language_skill,
	)

/datum/quirk/bilingual/add(client/client_source)
	var/wanted_language = client_source?.prefs.read_preference(/datum/preference/choiced/language)
	var/datum/language/language_type
	if(wanted_language == "Random")
		language_type = pick(GLOB.uncommon_roundstart_languages)
	else if(wanted_language)
		language_type = GLOB.language_types_by_name[wanted_language]
	if(!language_type || quirk_holder.has_language(language_type))
		language_type = /datum/language/uncommon
		if(quirk_holder.has_language(language_type))
			to_chat(quirk_holder, span_boldnotice("You are already familiar with the quirk in your preferences, so you did not learn one."))
			return
		to_chat(quirk_holder, span_boldnotice("You are already familiar with the quirk in your preferences, so you learned Galactic Uncommon instead."))

	var/speakable = client_source?.prefs.read_preference(/datum/preference/toggle/language_speakable)
	var/language_skill = client_source?.prefs.read_preference(/datum/preference/choiced/language_skill) || "100%"
	if(isnull(speakable) || speakable)
		quirk_holder.grant_language(language_type, SPOKEN_LANGUAGE|UNDERSTOOD_LANGUAGE, source = LANGUAGE_QUIRK)
	else if(language_skill == "100%")
		quirk_holder.grant_language(language_type, UNDERSTOOD_LANGUAGE, source = LANGUAGE_QUIRK)
	else
		quirk_holder.grant_partial_language(language_type, text2num(language_skill), source = LANGUAGE_QUIRK)

/datum/quirk/bilingual/remove()
	if(QDELING(quirk_holder))
		return
	quirk_holder.remove_all_languages(source = LANGUAGE_QUIRK)
	quirk_holder.remove_all_partial_languages(source = LANGUAGE_QUIRK)
