/datum/preference/numeric/fov_darkness
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "fov_darkness"
	savefile_identifier = PREFERENCE_PLAYER

	minimum = 0
	maximum = 255

/datum/preference/numeric/fov_darkness/create_default_value()
	return 255

/datum/preference/numeric/fov_darkness/apply_to_client(client/client, value)
	if(client.mob && isliving(client.mob))
		var/mob/living/living_mob = client.mob
		if(!living_mob.fov_handler)
			return
		living_mob.fov_handler.visual_shadow.alpha = value
