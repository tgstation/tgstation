
/datum/admins/proc/create_mob(mob/user)
	var/static/create_mob_html
	if (!create_mob_html)
		var/mobjs = null
		mobjs = jointext(typesof(/mob), ";")
		create_mob_html = file2text('html/create_object.html')
		create_mob_html = replacetext(create_mob_html, "Create Object", "Create Mob")
		create_mob_html = replacetext(create_mob_html, "null /* object types */", "\"[mobjs]\"")

	user << browse(create_panel_helper(create_mob_html), "window=create_mob;size=425x475")

/proc/randomize_human(mob/living/carbon/human/human, new_name = TRUE)
	human.gender = pick(MALE, FEMALE, PLURAL)
	human.physique = human.gender
	if(new_name)
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
	human.dna.species.randomize_active_underwear(human)

	for(var/all_species as anything in subtypesof(/datum/species))
		var/datum/species/all_species_type = GLOB.species_list[all_species]
		human.dna.species.randomize_features(human)

	human.update_body()
