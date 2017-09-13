#define GONDOLA_HEIGHT_LONG "gondola_body_long"
#define GONDOLA_HEIGHT_AVERAGE "gondola_body_medium"
#define GONDOLA_HEIGHT_SHORT "gondola_body_short"

#define GONDOLA_COLOR_LIGHT "A87855"
#define GONDOLA_COLOR_AVERAGE "915E48"
#define GONDOLA_COLOR_DARK "683E2C"

#define GONDOLA_MOUSTACHE_LARGE "gondola_moustache_large"
#define GONDOLA_MOUSTACHE_SMALL "gondola_moustache_small"

#define GONDOLA_EYES_CLOSE "gondola_eyes_close"
#define GONDOLA_EYES_FAR "gondola_eyes_far"

//Gondolas

/mob/living/simple_animal/pet/gondola
	name = "gondola"
	real_name = "gondola"
	desc = "Gondola is the silent walker. Having no hands he embodies the Taoist principle of wu-wei (non-action) while his smiling facial expression shows his utter and complete acceptance of the world as it is. Its hide is extremely valuable."
	response_help = "pets"
	response_disarm = "bops"
	response_harm = "kicks"
	faction = list("gondola")
	turns_per_move = 10
	icon = 'icons/mob/gondolas.dmi'
	icon_state = null
	icon_living = null
	loot = list(/obj/effect/decal/cleanable/blood/gibs, /obj/item/stack/sheet/animalhide/gondola = 1)
	//Gondolas aren't affected by cold.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	maxHealth = 200
	health = 200
	del_on_death = TRUE

/mob/living/simple_animal/pet/gondola/Initialize()
	. = ..()
	CreateGondola()

/mob/living/simple_animal/pet/gondola/proc/CreateGondola()
	var/height = pick(GONDOLA_HEIGHT_LONG, GONDOLA_HEIGHT_AVERAGE, GONDOLA_HEIGHT_SHORT)
	var/mutable_appearance/body_overlay = mutable_appearance(icon, height)
	var/mutable_appearance/eyes_overlay = mutable_appearance(icon, "[pick(GONDOLA_EYES_CLOSE, GONDOLA_EYES_FAR)]")
	var/mutable_appearance/moustache_overlay = mutable_appearance(icon, "[pick(GONDOLA_MOUSTACHE_LARGE, GONDOLA_MOUSTACHE_SMALL)]")

	var/fur_color = "#[pick(GONDOLA_COLOR_LIGHT,GONDOLA_COLOR_AVERAGE,GONDOLA_COLOR_DARK)]"
	body_overlay.color = fur_color

	//Offset the face to match the Gondola's height.
	switch(height)
		if(GONDOLA_HEIGHT_AVERAGE)
			eyes_overlay.pixel_y -= 4
			moustache_overlay.pixel_y -= 4
		if(GONDOLA_HEIGHT_SHORT)
			eyes_overlay.pixel_y -= 8
			moustache_overlay.pixel_y -= 8

	add_overlay(body_overlay)
	add_overlay(eyes_overlay)
	add_overlay(moustache_overlay)

/mob/living/simple_animal/pet/gondola/IsVocal() //Gondolas are the silent walker.
	return FALSE

/mob/living/simple_animal/pet/gondola/emote()
	return