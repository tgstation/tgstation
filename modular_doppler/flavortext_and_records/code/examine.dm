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

/mob/living/carbon/proc/get_extended_description_href(input_text)
	return "<a href='?src=[REF(src)];full_desc=1;examine_time=[world.time]'>[input_text]</a>"

/mob/living/carbon/proc/get_species_description_href(input_text)
	return "<a href='?src=[REF(src)];species_info=1;examine_time=[world.time]'>[input_text]</a>"

/mob/living/carbon/human/Topic(href, href_list)
	. = ..()

	if (href_list["full_desc"])
		// scuffed not-tgui flavor text stuff
		var/mob/viewer = usr
		var/can_see = (viewer in viewers(src))

		if (HAS_TRAIT(src, TRAIT_UNKNOWN))
			to_chat(viewer, span_notice("You can't discern a thing about them!"))
			return

		if (can_see)
			var/full_examine = span_slightly_larger(separator_hr("<em>[src]</em>"))
			var/short_desc = src.dna.features["flavor_short_desc"]
			var/extended_desc = src.dna.features["flavor_extended_desc"]
			var/headshot_url = src.dna.features["headshot_url"]
			var/ooc_notes = src.dna.features["ooc_notes"]

			//apply headshot
			full_examine += "<div class='large_img_by_text_container'>"
			if (length(headshot_url))
				full_examine += "<img src='[headshot_url]' alt='[src.name]'>"
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


			to_chat(viewer, examine_block(span_info(full_examine)))
			return
		else
			to_chat(viewer, span_notice("You're too far away to get a good look at [src]!"))
			return
	else if (href_list["species_info"])
		// return a blurb detailing their species
		var/mob/viewer = usr
		var/can_see = (viewer in viewers(src))
		if (can_see)
			var/species_name = src.dna.features["custom_species_name"] ? src.dna.features["custom_species_name"] : src.dna.species.name
			var/species_desc = src.dna.features["custom_species_desc"] ? src.dna.features["custom_species_desc"] : src.dna.species.get_species_description()

			var/full_examine = span_slightly_larger(separator_hr("<em>Species: [species_name]</em>"))
			full_examine += trim(species_desc)

			to_chat(viewer, examine_block(span_info(full_examine)))
			return




