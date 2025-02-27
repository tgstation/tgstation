/*
	/mob/living procs for both humans and silicons
*/

/mob/living/proc/get_extended_description_href(input_text)
	// Provides a href link with the `full_desc` arg, to be consumed by a Topic override (intended for flavour text descriptions)
	return "<a href='?src=[REF(src)];full_desc=1;examine_time=[world.time]'>[input_text]</a>"

/mob/living/proc/get_species_description_href(input_text)
	// Provides a href link with the `species_info` arg, to be consumed by a Topic override (intended for species/model descriptions)
	return "<a href='?src=[REF(src)];species_info=1;examine_time=[world.time]'>[input_text]</a>"

/mob/living/proc/get_exploitables_href(input_text)
	return "<a href='?src=[REF(src)];exploitables=1;examine_time=[world.time]'>[input_text]</a>"

/mob/living/proc/compile_examined_text(short_desc, extended_desc, headshot, ooc_notes)
	// Compiles the full examined description because I HATE code duplication
	var/full_examine = span_slightly_larger(separator_hr("<em>[src]</em>"))

	full_examine += "<div class='large_img_by_text_container'>"
	if (length(headshot)) // apply headshot
		full_examine += "<img src='[headshot]' alt='[src.name]'>"
	full_examine += "<div class='img_text'>"
	full_examine += jointext(list(
			"<i>[trim(short_desc)]</i><br>",
			trim(extended_desc)
	), "<br>")
	full_examine += "</div></div>"
	if (length(ooc_notes))
		full_examine += span_slightly_larger(separator_hr("<em>OOC Notes</em>"))
		full_examine += "<div class='ooc_notes'>"
		full_examine += trim(ooc_notes)
		full_examine += "</div>"

	return full_examine

/mob/living/proc/compile_species_info_text(species_name, species_desc, is_model = FALSE)
	// Compiles the species description block, with a switch for synthetic/model stuff, because I REALLY hate code duplication
	var/header_prefix = is_model ? "Model" : "Species"
	var/full_examine = span_slightly_larger(separator_hr("<em>[header_prefix]: [species_name]</em>"))

	full_examine += trim(species_desc)

	return full_examine

/*
	CARBONS (AKA FLESHBAGS)
*/
/mob/living/carbon/human/examine_title(mob/user, thats = FALSE)
	. = ..()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))

	var/species_visible
	var/species_name_string
	if(skipface || get_visible_name() == "Unknown")
		species_visible = FALSE
	else
		species_visible = TRUE

	if(!species_visible)
		species_name_string = ""
	else if (dna.features["custom_species_name"])
		species_name_string = ", [prefix_a_or_an(dna.features["custom_species_name"])] <EM>[dna.features["custom_species_name"]]</EM>"
	else
		species_name_string = ", [prefix_a_or_an(dna.species.name)] <EM>[dna.species.name]</EM>"

	. += species_name_string

/mob/living/carbon/human/Topic(href, href_list)
	. = ..()

	if (href_list["full_desc"])
		// scuffed not-tgui flavor text stuff
		var/mob/viewer = usr

		if (HAS_TRAIT(src, TRAIT_UNKNOWN))
			to_chat(viewer, span_notice("You can't discern a thing about them!"))
			return

		var/short_desc = src.dna.features["flavor_short_desc"]
		var/extended_desc = src.dna.features["flavor_extended_desc"]
		var/headshot_url = src.dna.features["headshot_url"]
		var/ooc_notes = src.dna.features["ooc_notes"]

		var/full_examine = compile_examined_text(short_desc, extended_desc, headshot_url, ooc_notes)

		to_chat(viewer, boxed_message(span_info(full_examine)))
		return

	else if (href_list["species_info"])
		// return a blurb detailing their species
		var/mob/viewer = usr

		var/species_name = src.dna.features["custom_species_name"] ? src.dna.features["custom_species_name"] : src.dna.species.name
		var/species_desc = src.dna.features["custom_species_desc"] ? src.dna.features["custom_species_desc"] : src.dna.species.get_species_description()

		var/full_examine = compile_species_info_text(species_name, species_desc, FALSE)

		to_chat(viewer, boxed_message(span_info(full_examine)))
		return

	else if (href_list["exploitables"])
		// show the vulnerable information ENCODED INTO THEIR VERY DNA!!!!
		var/mob/viewer = usr

		var/the_goss = src.dna.features["exploitables"] ? src.dna.features["exploitables"] : "Your contacts are unaware of anything involving this person."

		to_chat(viewer, boxed_message(span_orange(the_goss)))
		return
/*
	SILICONS (AKA HORRIBLE RUSTBUCKETS)
*/

/mob/living/silicon/robot/examine_title(mob/user, thats)
	. = ..()

	// much simpler for silicons since disguises aren't really a thing... for now
	var/model_name = READ_PREFS(src, text/silicon_model_name)
	if (model_name)
		. += ", [prefix_a_or_an(model_name)] <EM>[model_name]</EM>"


/mob/living/silicon/robot/Topic(href, href_list)
	. = ..()

	if (href_list["full_desc"])
		var/mob/viewer = usr

		if (HAS_TRAIT(src, TRAIT_UNKNOWN))
			to_chat(viewer, span_notice("You can't discern a thing about them!"))
			return

		var/short_desc = READ_PREFS(src, text/silicon_short_desc)
		var/extended_desc = READ_PREFS(src, text/silicon_extended_desc)
		var/headshot_url = READ_PREFS(src, text/headshot/silicon)
		var/ooc_notes = READ_PREFS(src, text/ooc_notes)

		var/full_examine = compile_examined_text(short_desc, extended_desc, headshot_url, ooc_notes)

		to_chat(viewer, boxed_message(span_info(full_examine)))
		return

	else if (href_list["species_info"])
		var/mob/viewer = usr

		var/model_name = READ_PREFS(src, text/silicon_model_name)
		var/model_desc = READ_PREFS(src, text/silicon_model_desc)

		var/full_examine = compile_species_info_text(model_name, model_desc, TRUE)

		to_chat(viewer, boxed_message(span_info(full_examine)))
		return

/*
	AIS (AKA ALSO HORRIBLE RUSTBUCKETS)
*/

/mob/living/silicon/ai/examine_title(mob/user, thats)
	. = ..()

	// much simpler for silicons since disguises aren't really a thing... for now
	var/model_name = READ_PREFS(src, text/silicon_model_name)
	if (model_name)
		. += ", [prefix_a_or_an(model_name)] <EM>[model_name]</EM>"


/mob/living/silicon/ai/Topic(href, href_list)
	. = ..()

	if (href_list["full_desc"])
		var/mob/viewer = usr

		if (HAS_TRAIT(src, TRAIT_UNKNOWN))
			to_chat(viewer, span_notice("You can't discern a thing about them!"))
			return

		var/short_desc = READ_PREFS(src, text/silicon_short_desc)
		var/extended_desc = READ_PREFS(src, text/silicon_extended_desc)
		var/headshot_url = READ_PREFS(src, text/headshot/silicon)
		var/ooc_notes = READ_PREFS(src, text/ooc_notes)

		var/full_examine = compile_examined_text(short_desc, extended_desc, headshot_url, ooc_notes)

		to_chat(viewer, boxed_message(span_info(full_examine)))
		return
	else if (href_list["species_info"])
		var/mob/viewer = usr

		var/model_name = READ_PREFS(src, text/silicon_model_name)
		var/model_desc = READ_PREFS(src, text/silicon_model_desc)

		var/full_examine = compile_species_info_text(model_name, model_desc, TRUE)

		to_chat(viewer, boxed_message(span_info(full_examine)))
		return
