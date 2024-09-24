/datum/preference/text/headshot
	category = PREFERENCE_CATEGORY_DOPPLER_LORE
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "headshot_url"
	maximum_value_length = MAX_MESSAGE_LEN
	var/list/stored_link = list()
	var/static/link_regex = regex("i.gyazo.com|files.byondhome.com|images2.imgbox.com|files.catbox.moe")
	var/static/list/valid_extensions = list("jpg", "png", "jpeg")

/datum/preference/text/headshot/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["headshot_url"] = value

/datum/preference/text/headshot/is_valid(value)
	if (!length(value))
		return TRUE

	var/find_index = findtext(value, "https://")
	if (find_index != 1)
		to_chat(usr, span_warning("Your link must be https!"))
		return

	var/sanity_check = findtext(value, ".")
	if (!sanity_check)
		to_chat(usr, span_warning("Your link doesn't appear to be valid!"))
		return

	var/list/value_split = splittext(value, ".")
	var/extension = value_split[length(value_split)]
	if (!(extension in valid_extensions))
		to_chat(usr, span_warning("The image must be one of the following extensions: '[english_list(valid_extensions)]'"))
		return

	find_index = findtext(value, link_regex)
	if(find_index != 9)
		to_chat(usr, span_warning("The image must be hosted on one of the following sites: 'Gyazo (i.gyazo.com), Byond (files.byondhome.com), Imgbox (images2.imgbox.com) or Catbox (files.catbox.moe)'"))
		return

	return TRUE

/datum/preference/text/headshot/silicon
	savefile_key = "silicon_headshot_url"

/datum/preference/text/headshot/silicon/apply_to_human(mob/living/carbon/human/target, value)
	return
