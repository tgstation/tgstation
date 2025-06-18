
/datum/admins/proc/create_mob(mob/user)
	var/static/create_mob_html
	if (!create_mob_html)
		var/mobjs = null
		mobjs = jointext(typesof(/mob), ";")
		create_mob_html = file2text('html/create_object.html')
		create_mob_html = replacetext(create_mob_html, "Create Object", "Create Mob")
		create_mob_html = replacetext(create_mob_html, "null; /* object types */", "\"[mobjs]\";")

	user << browse(create_panel_helper(create_mob_html), "window=create_mob;size=425x475")

/**
 * Fully randomizes everything about a human, including DNA and name.
 */
/proc/randomize_human(mob/living/carbon/human/human, randomize_mutations = FALSE)
	human.gender = human.dna.species.sexes ? pick(MALE, FEMALE, PLURAL, NEUTER) : PLURAL
	human.physique = human.gender
	human.real_name = human.generate_random_mob_name()
	human.name = human.get_visible_name()
	human.set_hairstyle(random_hairstyle(human.gender), update = FALSE)
	human.set_facial_hairstyle(random_facial_hairstyle(human.gender), update = FALSE)
	human.set_haircolor("#[random_color()]", update = FALSE)
	human.set_facial_haircolor(human.hair_color, update = FALSE)
	human.set_eye_color(random_eye_color())
	human.skin_tone = pick(GLOB.skin_tones)
	human.dna.species.randomize_active_underwear_only(human)
	// Needs to be called towards the end to update all the UIs just set above
	human.dna.initialize_dna(newblood_type = random_human_blood_type(), create_mutation_blocks = randomize_mutations, randomize_features = TRUE)
	// Snowflake for Ethereals
	human.updatehealth()
	human.updateappearance(mutcolor_update = TRUE)

/**
 * Randomizes a human, but produces someone who looks exceedingly average (by most standards).
 *
 * (IE, no wacky hair styles / colors)
 */
/proc/randomize_human_normie(mob/living/carbon/human/human, randomize_mutations = FALSE, update_body = TRUE)
	// Sorry enbys but statistically you are not average enough
	human.gender = human.dna.species.sexes ? pick(MALE, FEMALE) : PLURAL
	human.physique = human.gender
	human.real_name = human.generate_random_mob_name()
	human.name = human.get_visible_name()
	human.set_eye_color(random_eye_color())
	human.skin_tone = pick(GLOB.skin_tones)
	// No underwear generation handled here
	var/picked_color = random_hair_color()
	human.set_haircolor(picked_color, update = FALSE)
	human.set_facial_haircolor(picked_color, update = FALSE)
	var/datum/sprite_accessory/hairstyle = SSaccessories.hairstyles_list[random_hairstyle(human.gender)]
	if(hairstyle && hairstyle.natural_spawn && !hairstyle.locked)
		human.set_hairstyle(hairstyle.name, update = FALSE)
	var/datum/sprite_accessory/facial_hair = SSaccessories.facial_hairstyles_list[random_facial_hairstyle(human.gender)]
	if(facial_hair && facial_hair.natural_spawn && !facial_hair.locked)
		human.set_facial_hairstyle(facial_hair.name, update = FALSE)
	// Normal DNA init stuff, these can generally be wacky but we care less, they're aliens after all
	human.dna.initialize_dna(newblood_type = random_human_blood_type(), create_mutation_blocks = randomize_mutations, randomize_features = TRUE)
	human.updatehealth()
	if(update_body)
		human.updateappearance(mutcolor_update = TRUE)
