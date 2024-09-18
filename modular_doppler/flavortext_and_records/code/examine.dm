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
