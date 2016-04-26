#define ASSET_CACHE_SEND_TIMEOUT 2.5 SECONDS // Amount of time MAX to send an asset, if this get exceeded we cancel the sleeping.

//List of ALL assets for the above, format is list(filename = asset).
/var/list/asset_cache      = list()
/var/asset_cache_populated = FALSE

/client
	var/list/cache = list() // List of all assets sent to this client by the asset cache.
	var/list/completed_asset_jobs = list() // List of all completed jobs, awaiting acknowledgement.
	var/list/sending = list()
	var/last_asset_job = 0 // Last job done.

//This proc sends the asset to the client, but only if it needs it.
/proc/send_asset(var/client/client, var/asset_name, var/verify = TRUE)
	if(!istype(client))
		if(ismob(client))
			var/mob/M = client
			if(M.client)
				client = M.client

			else
				return 0

		else
			return 0

	while(!global.asset_cache_populated)
		sleep(5)

	if(!asset_cache.Find(asset_name))
		CRASH("Attempted to send nonexistant asset [asset_name] to [client.key]!")

	if(client.cache.Find(asset_name) || client.sending.Find(asset_name))
		return 0

	client << browse_rsc(asset_cache[asset_name], asset_name)
	if(!verify || !winexists(client, "asset_cache_browser")) // Can't access the asset cache browser, rip.
		if(!client) // winexist() waits for a response from the client, so we need to make sure the client still exists.
			return 0

		client.cache += asset_name
		return 1

	if(!client) // winexist() waits for a response from the client, so we need to make sure the client still exists.
		return 0

	client.sending |= asset_name
	var/job = ++client.last_asset_job

	client << browse({"
	<script>
		window.location.href="?asset_cache_confirm_arrival=[job]"
	</script>
	"}, "window=asset_cache_browser")

	var/t = 0
	var/timeout_time = ASSET_CACHE_SEND_TIMEOUT * client.sending.len
	while(client && !client.completed_asset_jobs.Find(job) && t < timeout_time) // Reception is handled in Topic()
		sleep(1) // Lock up the caller until this is received.
		t++

	if(client)
		client.sending -= asset_name
		client.cache |= asset_name
		client.completed_asset_jobs -= job

	return 1

/proc/send_asset_list(var/client/client, var/list/asset_list, var/verify = TRUE)
	if(!istype(client))
		if(ismob(client))
			var/mob/M = client
			if(M.client)
				client = M.client

			else
				return 0

		else
			return 0

	var/list/unreceived = asset_list - (client.cache + client.sending)
	if(!unreceived || !unreceived.len)
		return 0

	for(var/asset in unreceived)
		client << browse_rsc(asset_cache[asset], asset)

	if(!verify || !winexists(client, "asset_cache_browser")) // Can't access the asset cache browser, rip.
		if(!client) // winexist() waits for a response from the client, so we need to make sure the client still exists.
			return 0

		client.cache += unreceived
		return 1

	if(!client) // winexist() waits for a response from the client, so we need to make sure the client still exists.
		return 0

	client.sending |= unreceived
	var/job = ++client.last_asset_job

	client << browse({"
	<script>
		window.location.href="?asset_cache_confirm_arrival=[job]"
	</script>
	"}, "window=asset_cache_browser")

	var/t = 0
	var/timeout_time = ASSET_CACHE_SEND_TIMEOUT * client.sending.len
	while(client && !client.completed_asset_jobs.Find(job) && t < timeout_time) // Reception is handled in Topic()
		sleep(1) // Lock up the caller until this is received.
		t++

	if(client)
		client.sending -= unreceived
		client.cache |= unreceived
		client.completed_asset_jobs -= job

	return 1

//This proc "registers" an asset, it adds it to the cache for further use, you cannot touch it from this point on or you'll fuck things up.
//if it's an icon or something be careful, you'll have to copy it before further use.
/proc/register_asset(var/asset_name, var/asset)
	asset_cache |= asset_name
	asset_cache[asset_name] = asset


//From here on out it's populating the asset cache.

/proc/populate_asset_cache()
	for(var/type in typesof(/datum/asset) - list(/datum/asset, /datum/asset/simple))
		var/datum/asset/A = new type()

		A.register()

	global.asset_cache_populated = TRUE

//These datums are used to populate the asset cache, the proc "register()" does this.
/datum/asset/proc/register()
	return

//If you don't need anything complicated.
/datum/asset/simple
	var/assets = list()

/datum/asset/simple/register()
	for(var/asset_name in assets)
		register_asset(asset_name, assets[asset_name])

//DEFINITIONS FOR ASSET DATUMS START HERE.


/datum/asset/simple/pda
	assets = list(
		"pda_atmos.png"		= 'icons/pda_icons/pda_atmos.png',
		"pda_back.png"			= 'icons/pda_icons/pda_back.png',
		"pda_bell.png"			= 'icons/pda_icons/pda_bell.png',
		"pda_blank.png"		= 'icons/pda_icons/pda_blank.png',
		"pda_boom"				= 'icons/pda_icons/pda_boom.png',
		"pda_bucket.png"		= 'icons/pda_icons/pda_bucket.png',
		"pda_crate.png"			= 'icons/pda_icons/pda_crate.png',
		"pda_cuffs.png"			= 'icons/pda_icons/pda_cuffs.png',
		"pda_eject.png"			= 'icons/pda_icons/pda_eject.png',
		"pda_exit.png"			= 'icons/pda_icons/pda_exit.png',
		"pda_flashlight.png"	= 'icons/pda_icons/pda_flashlight.png',
		"pda_honk.png"			= 'icons/pda_icons/pda_honk.png',
		"pda_mail.png"			= 'icons/pda_icons/pda_mail.png',
		"pda_medical.png"		= 'icons/pda_icons/pda_medical.png',
		"pda_menu.png"		= 'icons/pda_icons/pda_menu.png',
		"pda_mule.png"			= 'icons/pda_icons/pda_mule.png',
		"pda_notes.png"		= 'icons/pda_icons/pda_notes.png',
		"pda_power.png"		= 'icons/pda_icons/pda_power.png',
		"pda_alert.png"			= 'icons/pda_icons/pda_alert.png',
		"pda_rdoor.png"		= 'icons/pda_icons/pda_rdoor.png',
		"pda_reagent.png"		= 'icons/pda_icons/pda_reagent.png',
		"pda_refresh.png"		= 'icons/pda_icons/pda_refresh.png',
		"pda_scanner.png"		= 'icons/pda_icons/pda_scanner.png',
		"pda_signaler.png"		= 'icons/pda_icons/pda_signaler.png',
		"pda_status.png"		= 'icons/pda_icons/pda_status.png',
		"pda_clock.png"			= 'icons/pda_icons/pda_clock.png',
		"pda_game.png"		= 'icons/pda_icons/pda_game.png',
		"pda_egg.png"			= 'icons/pda_icons/pda_egg.png',
		"pda_money.png"				= 'icons/pda_icons/pda_money.png',
		"pda_minimap_box.png"	= 'icons/pda_icons/pda_minimap_box.png',
		"pda_minimap_bg_notfound.png"	= 'icons/pda_icons/pda_minimap_bg_notfound.png',
		"pda_minimap_deff.png"					= 'icons/pda_icons/pda_minimap_deff.png',
		"pda_minimap_taxi.png"					= 'icons/pda_icons/pda_minimap_taxi.png',
		"pda_minimap_meta.png"				= 'icons/pda_icons/pda_minimap_meta.png',
		"pda_minimap_loc.gif"					= 'icons/pda_icons/pda_minimap_loc.gif',
		"pda_minimap_mkr.gif"					= 'icons/pda_icons/pda_minimap_mkr.gif'
	)

/datum/asset/simple/pda_snake
	assets = list(
		"snake_background.png"		= 'icons/pda_icons/snake_icons/snake_background.png',
		"snake_highscore.png"			= 'icons/pda_icons/snake_icons/snake_highscore.png',
		"snake_newgame.png"			= 'icons/pda_icons/snake_icons/snake_newgame.png',
		"snake_station.png"				= 'icons/pda_icons/snake_icons/snake_station.png',
		"snake_pause.png"				= 'icons/pda_icons/snake_icons/snake_pause.png',
		"snake_maze1.png"				= 'icons/pda_icons/snake_icons/snake_maze1.png',
		"snake_maze2.png"				= 'icons/pda_icons/snake_icons/snake_maze2.png',
		"snake_maze3.png"				= 'icons/pda_icons/snake_icons/snake_maze3.png',
		"snake_maze4.png"				= 'icons/pda_icons/snake_icons/snake_maze4.png',
		"snake_maze5.png"				= 'icons/pda_icons/snake_icons/snake_maze5.png',
		"snake_maze6.png"				= 'icons/pda_icons/snake_icons/snake_maze6.png',
		"snake_maze7.png"				= 'icons/pda_icons/snake_icons/snake_maze7.png',
		"pda_snake_arrow_north.png"	= 'icons/pda_icons/snake_icons/arrows/pda_snake_arrow_north.png',
		"pda_snake_arrow_east.png"		= 'icons/pda_icons/snake_icons/arrows/pda_snake_arrow_east.png',
		"pda_snake_arrow_west.png"		= 'icons/pda_icons/snake_icons/arrows/pda_snake_arrow_west.png',
		"pda_snake_arrow_south.png"	='icons/pda_icons/snake_icons/arrows/pda_snake_arrow_south.png',
		"snake_0.png"						= 'icons/pda_icons/snake_icons/numbers/snake_0.png',
		"snake_1.png"						= 'icons/pda_icons/snake_icons/numbers/snake_1.png',
		"snake_2.png"						= 'icons/pda_icons/snake_icons/numbers/snake_2.png',
		"snake_3.png"						= 'icons/pda_icons/snake_icons/numbers/snake_3.png',
		"snake_4.png"						= 'icons/pda_icons/snake_icons/numbers/snake_4.png',
		"snake_5.png"						= 'icons/pda_icons/snake_icons/numbers/snake_5.png',
		"snake_6.png"						= 'icons/pda_icons/snake_icons/numbers/snake_6.png',
		"snake_7.png"						= 'icons/pda_icons/snake_icons/numbers/snake_7.png',
		"snake_8.png"						= 'icons/pda_icons/snake_icons/numbers/snake_8.png',
		"snake_9.png"						= 'icons/pda_icons/snake_icons/numbers/snake_9.png',
		"pda_snake_body_east.png"			= 'icons/pda_icons/snake_icons/elements/pda_snake_body_east.png',
		"pda_snake_body_east_full.png"		= 'icons/pda_icons/snake_icons/elements/pda_snake_body_east_full.png',
		"pda_snake_body_west.png"			= 'icons/pda_icons/snake_icons/elements/pda_snake_body_west.png',
		"pda_snake_body_west_full.png"		= 'icons/pda_icons/snake_icons/elements/pda_snake_body_west_full.png',
		"pda_snake_body_north.png"			= 'icons/pda_icons/snake_icons/elements/pda_snake_body_north.png',
		"pda_snake_body_north_full.png"	= 'icons/pda_icons/snake_icons/elements/pda_snake_body_north_full.png',
		"pda_snake_body_south.png"			= 'icons/pda_icons/snake_icons/elements/pda_snake_body_south.png',
		"pda_snake_body_south_full.png"	= 'icons/pda_icons/snake_icons/elements/pda_snake_body_south_full.png',
		"pda_snake_bodycorner_eastnorth.png" 			= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_eastnorth.png',
		"pda_snake_bodycorner_eastnorth_full.png"	= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_eastnorth_full.png',
		"pda_snake_bodycorner_eastsouth.png"			= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_eastsouth.png',
		"pda_snake_bodycorner_eastsouth_full.png"	= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_eastsouth_full.png',
		"pda_snake_bodycorner_westnorth.png"			= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_westnorth.png',
		"pda_snake_bodycorner_westnorth_full.png"	= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_westnorth_full.png',
		"pda_snake_bodycorner_westsouth.png"			= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_westsouth.png',
		"pda_snake_bodycorner_westsouth_full.png"	= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_westsouth_full.png',
		"pda_snake_bodycorner_eastnorth2.png"			= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_eastnorth2.png',
		"pda_snake_bodycorner_eastnorth2_full.png"	= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_eastnorth2_full.png',
		"pda_snake_bodycorner_eastsouth2.png"		= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_eastsouth2.png',
		"pda_snake_bodycorner_eastsouth2_full.png"	= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_eastsouth2_full.png',
		"pda_snake_bodycorner_westnorth2.png"		= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_westnorth2.png',
		"pda_snake_bodycorner_westnorth2_full.png"	= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_westnorth2_full.png',
		"pda_snake_bodycorner_westsouth2.png"		= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_westsouth2.png',
		"pda_snake_bodycorner_westsouth2_full.png"	= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_westsouth2_full.png',
		"pda_snake_bodytail_east.png"		= 'icons/pda_icons/snake_icons/elements/pda_snake_bodytail_east.png',
		"pda_snake_bodytail_north.png"		= 'icons/pda_icons/snake_icons/elements/pda_snake_bodytail_north.png',
		"pda_snake_bodytail_south.png"		= 'icons/pda_icons/snake_icons/elements/pda_snake_bodytail_south.png',
		"pda_snake_bodytail_west.png"		= 'icons/pda_icons/snake_icons/elements/pda_snake_bodytail_west.png',
		"pda_snake_bonus1.png"		= 'icons/pda_icons/snake_icons/elements/pda_snake_bonus1.png',
		"pda_snake_bones2.png"		= 'icons/pda_icons/snake_icons/elements/pda_snake_bonus2.png',
		"pda_snake_bonus3.png"		= 'icons/pda_icons/snake_icons/elements/pda_snake_bonus3.png',
		"pda_snake_bonus4.png"		= 'icons/pda_icons/snake_icons/elements/pda_snake_bonus4.png',
		"pda_snake_bonus5.png"		= 'icons/pda_icons/snake_icons/elements/pda_snake_bonus5.png',
		"pda_snake_bonus6.png"		= 'icons/pda_icons/snake_icons/elements/pda_snake_bonus6.png',
		"pda_snake_egg.png"				= 'icons/pda_icons/snake_icons/elements/pda_snake_egg.png',
		"pda_snake_head_east.png"			= 'icons/pda_icons/snake_icons/elements/pda_snake_head_east.png',
		"pda_snake_head_east_open.png"	= 'icons/pda_icons/snake_icons/elements/pda_snake_head_east_open.png',
		"pda_snake_head_west.png"			= 'icons/pda_icons/snake_icons/elements/pda_snake_head_west.png',
		"pda_snake_head_west_open.png"	= 'icons/pda_icons/snake_icons/elements/pda_snake_head_west_open.png',
		"pda_snake_head_north.png"			= 'icons/pda_icons/snake_icons/elements/pda_snake_head_north.png',
		"pda_snake_head_north_open.png"	= 'icons/pda_icons/snake_icons/elements/pda_snake_head_north_open.png',
		"pda_snake_head_south.png"			= 'icons/pda_icons/snake_icons/elements/pda_snake_head_south.png',
		"pda_snake_head_south_open.png"	= 'icons/pda_icons/snake_icons/elements/pda_snake_head_south_open.png',
		"snake_volume0.png"		= 'icons/pda_icons/snake_icons/volume/snake_volume0.png',
		"snake_volume1.png"		= 'icons/pda_icons/snake_icons/volume/snake_volume1.png',
		"snake_volume2.png"		= 'icons/pda_icons/snake_icons/volume/snake_volume2.png',
		"snake_volume3.png"		= 'icons/pda_icons/snake_icons/volume/snake_volume3.png',
		"snake_volume4.png"		= 'icons/pda_icons/snake_icons/volume/snake_volume4.png',
		"snake_volume5.png"		= 'icons/pda_icons/snake_icons/volume/snake_volume5.png',
		"snake_volume6.png"		= 'icons/pda_icons/snake_icons/volume/snake_volume6.png'
	)

/datum/asset/simple/pda_mine
	assets = list(
		"minesweeper_counter_0.png"		= 'icons/pda_icons/minesweeper_icons/minesweeper_counter_0.png',
		"minesweeper_counter_1.png"		= 'icons/pda_icons/minesweeper_icons/minesweeper_counter_1.png',
		"minesweeper_counter_2.png"		= 'icons/pda_icons/minesweeper_icons/minesweeper_counter_2.png',
		"minesweeper_counter_3.png"		= 'icons/pda_icons/minesweeper_icons/minesweeper_counter_3.png',
		"minesweeper_counter_4.png"		= 'icons/pda_icons/minesweeper_icons/minesweeper_counter_4.png',
		"minesweeper_counter_5.png"		= 'icons/pda_icons/minesweeper_icons/minesweeper_counter_5.png',
		"minesweeper_counter_6.png"		= 'icons/pda_icons/minesweeper_icons/minesweeper_counter_6.png',
		"minesweeper_counter_7.png"		= 'icons/pda_icons/minesweeper_icons/minesweeper_counter_7.png',
		"minesweeper_counter_8.png"		= 'icons/pda_icons/minesweeper_icons/minesweeper_counter_8.png',
		"minesweeper_counter_9.png"		= 'icons/pda_icons/minesweeper_icons/minesweeper_counter_9.png',
		"minesweeper_tile_1.png"				= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_1.png',
		"minesweeper_tile_1_selected.png"	= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_1_selected.png',
		"minesweeper_tile_2.png"				= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_2.png',
		"minesweeper_tile_2_selected.png"	= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_2_selected.png',
		"minesweeper_tile_3.png"				= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_3.png',
		"minesweeper_tile_3_selected.png"	= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_3_selected.png',
		"minesweeper_tile_4.png"				= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_4.png',
		"minesweeper_tile_4_selected.png"	= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_4_selected.png',
		"minesweeper_tile_5.png"				= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_5.png',
		"minesweeper_tile_5_selected.png"	= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_5_selected.png',
		"minesweeper_tile_6.png"				= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_6.png',
		"minesweeper_tile_6_selected.png"	= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_6_selected.png',
		"minesweeper_tile_7.png"				= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_7.png',
		"minesweeper_tile_7_selected.png"	= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_7_selected.png',
		"minesweeper_tile_8.png"				= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_8.png',
		"minesweeper_tile_8_selected.png"	= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_8_selected.png',
		"minesweeper_tile_empty.png"					= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_empty.png',
		"minesweeper_tile_empty_selected.png"		= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_empty_selected.png',
		"minesweeper_tile_full.png"						= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_full.png',
		"minesweeper_tile_full_selected.png"			= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_full_selected.png',
		"minesweeper_tile_question.png"				= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_question.png',
		"minesweeper_tile_question_selected.png"	= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_question_selected.png',
		"minesweeper_tile_flag.png"						= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_flag.png',
		"minesweeper_tile_flag_selected.png"			= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_flag_selected.png',
		"minesweeper_tile_mine_unsplode.png"		= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_mine_unsplode.png',
		"minesweeper_tile_mine_splode.png"			= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_mine_splode.png',
		"minesweeper_tile_mine_wrong.png"			= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_mine_wrong.png',
		"minesweeper_frame_counter.png"				= 'icons/pda_icons/minesweeper_icons/minesweeper_frame_counter.png',
		"minesweeper_frame_smiley.png"				= 'icons/pda_icons/minesweeper_icons/minesweeper_frame_smiley.png',
		"minesweeper_border_bot.png"					= 'icons/pda_icons/minesweeper_icons/minesweeper_border_bot.png',
		"minesweeper_border_top.png"					= 'icons/pda_icons/minesweeper_icons/minesweeper_border_top.png',
		"minesweeper_border_right.png"					= 'icons/pda_icons/minesweeper_icons/minesweeper_border_right.png',
		"minesweeper_border_left.png"					= 'icons/pda_icons/minesweeper_icons/minesweeper_border_left.png',
		"minesweeper_border_cornertopleft.png"		= 'icons/pda_icons/minesweeper_icons/minesweeper_border_cornertopleft.png',
		"minesweeper_border_cornertopright.png"	= 'icons/pda_icons/minesweeper_icons/minesweeper_border_cornertopright.png',
		"minesweeper_border_cornerbotleft.png"		= 'icons/pda_icons/minesweeper_icons/minesweeper_border_cornerbotleft.png',
		"minesweeper_border_cornerbotright.png"	= 'icons/pda_icons/minesweeper_icons/minesweeper_border_cornerbotright.png',
		"minesweeper_bg_beginner.png"					= 'icons/pda_icons/minesweeper_icons/minesweeper_bg_beginner.png',
		"minesweeper_bg_intermediate.png"			= 'icons/pda_icons/minesweeper_icons/minesweeper_bg_intermediate.png',
		"minesweeper_bg_expert.png"					= 'icons/pda_icons/minesweeper_icons/minesweeper_bg_expert.png',
		"minesweeper_bg_custom.png"					= 'icons/pda_icons/minesweeper_icons/minesweeper_bg_custom.png',
		"minesweeper_flag.png"								= 'icons/pda_icons/minesweeper_icons/minesweeper_flag.png',
		"minesweeper_question.png"						= 'icons/pda_icons/minesweeper_icons/minesweeper_question.png',
		"minesweeper_settings.png"						= 'icons/pda_icons/minesweeper_icons/minesweeper_settings.png',
		"minesweeper_smiley_normal.png"				= 'icons/pda_icons/minesweeper_icons/minesweeper_smiley_normal.png',
		"minesweeper_smiley_press.png"				= 'icons/pda_icons/minesweeper_icons/minesweeper_smiley_press.png',
		"minesweeper_smiley_fear.png"					= 'icons/pda_icons/minesweeper_icons/minesweeper_smiley_fear.png',
		"minesweeper_smiley_dead.png"				= 'icons/pda_icons/minesweeper_icons/minesweeper_smiley_dead.png',
		"minesweeper_smiley_win.png"					= 'icons/pda_icons/minesweeper_icons/minesweeper_smiley_win.png'
	)

/datum/asset/simple/pda_spesspets
	assets = list(
		"spesspets_bg.png"		= 'icons/pda_icons/spesspets_icons/spesspets_bg.png',
		"spesspets_egg0.png"	= 'icons/pda_icons/spesspets_icons/spesspets_egg0.png',
		"spesspets_egg1.png"	= 'icons/pda_icons/spesspets_icons/spesspets_egg1.png',
		"spesspets_egg2.png"	= 'icons/pda_icons/spesspets_icons/spesspets_egg2.png',
		"spesspets_egg3.png"	= 'icons/pda_icons/spesspets_icons/spesspets_egg3.png',
		"spesspets_hatch.png"	= 'icons/pda_icons/spesspets_icons/spesspets_hatch.png',
		"spesspets_talk.png"		= 'icons/pda_icons/spesspets_icons/spesspets_talk.png',
		"spesspets_walk.png"		= 'icons/pda_icons/spesspets_icons/spesspets_walk.png',
		"spesspets_feed.png"		= 'icons/pda_icons/spesspets_icons/spesspets_feed.png',
		"spesspets_clean.png"	= 'icons/pda_icons/spesspets_icons/spesspets_clean.png',
		"spesspets_heal.png"		= 'icons/pda_icons/spesspets_icons/spesspets_heal.png',
		"spesspets_fight.png"		= 'icons/pda_icons/spesspets_icons/spesspets_fight.png',
		"spesspets_visit.png"		= 'icons/pda_icons/spesspets_icons/spesspets_visit.png',
		"spesspets_work.png"	= 'icons/pda_icons/spesspets_icons/spesspets_work.png',
		"spesspets_cash.png"		= 'icons/pda_icons/spesspets_icons/spesspets_cash.png',
		"spesspets_rate.png"		= 'icons/pda_icons/spesspets_icons/spesspets_rate.png',
		"spesspets_Corgegg.png"	= 'icons/pda_icons/spesspets_icons/spesspets_Corgegg.png',
		"spesspets_Chimpegg.png"	= 'icons/pda_icons/spesspets_icons/spesspets_Chimpegg.png',
		"spesspets_Borgegg.png"	= 'icons/pda_icons/spesspets_icons/spesspets_Borgegg.png',
		"spesspets_Syndegg.png"	= 'icons/pda_icons/spesspets_icons/spesspets_Syndegg.png',
		"spesspets_hunger.png"		= 'icons/pda_icons/spesspets_icons/spesspets_hunger.png',
		"spesspets_dirty.png"			= 'icons/pda_icons/spesspets_icons/spesspets_dirty.png',
		"spesspets_hurt.png"			= 'icons/pda_icons/spesspets_icons/spesspets_hurt.png',
		"spesspets_mine.png"		= 'icons/pda_icons/spesspets_icons/spesspets_mine.png',
		"spesspets_sleep.png"		= 'icons/pda_icons/spesspets_icons/spesspets_sleep.png'
	)


//Registers HTML I assets.
/datum/asset/HTML_interface/register()
	for(var/path in typesof(/datum/html_interface))
		var/datum/html_interface/hi = new path()
		hi.registerResources()

/datum/asset/simple/chartJS
	assets = list("Chart.js" = 'code/modules/html_interface/Chart.js')

/datum/asset/simple/power_chart
	assets = list("powerChart.js" = 'code/modules/power/powerChart.js')
