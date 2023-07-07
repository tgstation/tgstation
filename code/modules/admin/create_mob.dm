
/datum/admins/proc/create_mob(mob/user)
	var/static/create_mob_html
	if (!create_mob_html)
		var/mobjs = null
		mobjs = jointext(typesof(/mob), ";")
		create_mob_html = file2text('html/create_object.html')
		create_mob_html = replacetext(create_mob_html, "Create Object", "Create Mob")
		create_mob_html = replacetext(create_mob_html, "null /* object types */", "\"[mobjs]\"")

	user << browse(create_panel_helper(create_mob_html), "window=create_mob;size=425x475")

/proc/randomize_human(mob/living/carbon/human/human)
	if(human.dna.species.sexes)
		human.gender = pick(MALE, FEMALE, PLURAL)
	else
		human.gender = PLURAL
	human.physique = human.gender
	human.real_name = human.dna?.species.random_name(human.gender) || random_unique_name(human.gender)
	human.name = human.real_name
	human.hairstyle = random_hairstyle(human.gender)
	human.facial_hairstyle = random_facial_hairstyle(human.gender)
	human.hair_color = "#[random_color()]"
	human.facial_hair_color = human.hair_color
	var/random_eye_color = random_eye_color()
	human.eye_color_left = random_eye_color
	human.eye_color_right = random_eye_color

	human.dna.blood_type = random_blood_type()
	human.dna.features["mcolor"] = "#[random_color()]"
	human.dna.species.randomize_active_underwear_only(human)

	for(var/datum/species/species_path as anything in subtypesof(/datum/species))
		var/datum/species/new_species = new species_path
		new_species.randomize_features(human)
	human.dna.species.spec_updatehealth(human)
	human.dna.update_dna_identity()
	human.updateappearance()
	human.update_body(is_creating = TRUE)
