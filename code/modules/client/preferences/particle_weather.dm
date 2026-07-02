/// Whether or not to toggle ambient occlusion, the shadows around people
/datum/preference/toggle/particle_weather
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "particle_weather"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/particle_weather/apply_to_client(client/client, value)
	for(var/atom/movable/screen/plane_master/rendering_plate/particle_weather/plane_master as anything in client.mob?.hud_used?.get_true_plane_masters(RENDER_PLANE_PARTICLE_WEATHER))
		plane_master.update_state(client.mob)

	for(var/atom/movable/screen/plane_master/rendering_plate/particle_weather/emissive/plane_master as anything in client.mob?.hud_used?.get_true_plane_masters(RENDER_PLANE_EMISSIVE_PARTICLE_WEATHER))
		plane_master.update_state(client.mob)

	for(var/atom/movable/screen/plane_master/weather/plane_master as anything in client.mob?.hud_used?.get_true_plane_masters(WEATHER_PLANE))
		plane_master.update_state(client.mob)

	for(var/atom/movable/screen/plane_master/weather/particle/plane_master as anything in client.mob?.hud_used?.get_true_plane_masters(PARTICLE_WEATHER_PLANE))
		plane_master.update_state(client.mob)
