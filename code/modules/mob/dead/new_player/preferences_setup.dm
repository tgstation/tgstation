
	//The mob should have a gender you want before running this proc. Will run fine without H
/datum/preferences/proc/random_character(gender_override)
	if(randomise[SPECIES])
		random_species()
	else if(randomise[NAME])
		real_name = pref_species.random_name(gender,1)
	if(gender_override && !randomise[GENDER])
		gender = gender_override
	else
		gender = pick(MALE,FEMALE)
	if(randomise[AGE])
		age = rand(AGE_MIN,AGE_MAX)
	if(randomise[UNDERWEAR])
		underwear = random_underwear(gender)
	if(randomise[UNDERWEAR_COLOR])
		underwear_color = random_short_color()
	if(randomise[UNDERSHIRT])
		undershirt = random_undershirt(gender)
	if(randomise[SOCKS])
		socks = random_socks()
	if(randomise[BACKPACK])
		backpack = random_backpack()
	if(randomise[JUMPSUIT_STYLE])
		jumpsuit_style = pick(GLOB.jumpsuitlist)
	if(randomise[HAIRSTYLE])
		hairstyle = random_hairstyle(gender)
	if(randomise[FACIAL_HAIRSTYLE])
		facial_hairstyle = random_facial_hairstyle(gender)
	if(randomise[HAIR_COLOR])
		hair_color = random_short_color()
	if(randomise[FACIAL_HAIR_COLOR])
		facial_hair_color = random_short_color()
	else
		facial_hair_color = hair_color
	if(randomise[SKIN_TONE])
		skin_tone = random_skin_tone()
	if(randomise[EYE_COLOR])
		eye_color = random_eye_color()
	if(!pref_species)
		var/rando_race = pick(GLOB.roundstart_races)
		pref_species = new rando_race()
	features = random_features()

/datum/preferences/proc/random_species()
	var/random_species_type = GLOB.species_list[pick(GLOB.roundstart_races)]
	pref_species = new random_species_type
	if(randomise[NAME])
		real_name = pref_species.random_name(gender,1)

/datum/preferences/proc/update_preview_icon()
	// Determine what job is marked as 'High' priority, and dress them up as such.
	var/datum/job/previewJob
	var/highest_pref = 0
	for(var/job in job_preferences)
		if(job_preferences[job] > highest_pref)
			previewJob = SSjob.GetJob(job)
			highest_pref = job_preferences[job]

	if(previewJob)
		// Silicons only need a very basic preview since there is no customization for them.
		if(istype(previewJob,/datum/job/ai))
			parent.show_character_previews(image('icons/mob/ai.dmi', icon_state = resolve_ai_icon(preferred_ai_core_display), dir = SOUTH))
			return
		if(istype(previewJob,/datum/job/cyborg))
			parent.show_character_previews(image('icons/mob/robots.dmi', icon_state = "robot", dir = SOUTH))
			return

	// Set up the dummy for its photoshoot
	var/mob/living/carbon/human/dummy/mannequin = generate_or_wait_for_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)
	copy_to(mannequin, 1, TRUE, TRUE)

	if(previewJob)
		mannequin.job = previewJob.title
		previewJob.equip(mannequin, TRUE, preference_source = parent)

	COMPILE_OVERLAYS(mannequin)
	parent.show_character_previews(new /mutable_appearance(mannequin))
	unset_busy_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)