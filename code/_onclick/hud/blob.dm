
/datum/hud/proc/blob_hud()
	mymob.gui_icons.blob_bgLEFT = getFromPool(/obj/screen/specialblob)
	mymob.gui_icons.blob_bgLEFT.icon = 'icons/mob/screen1_blob_fullscreen.dmi'
	mymob.gui_icons.blob_bgLEFT.icon_state = "backgroundLEFT"
	mymob.gui_icons.blob_bgLEFT.name = "Blob HUD"
	mymob.gui_icons.blob_bgLEFT.layer = 19
	mymob.gui_icons.blob_bgLEFT.screen_loc = ui_blob_bgLEFT
	mymob.gui_icons.blob_bgLEFT.mouse_opacity = 0

	mymob.gui_icons.blob_bgRIGHT = getFromPool(/obj/screen/specialblob)
	mymob.gui_icons.blob_bgRIGHT.icon = 'icons/mob/screen1_blob_fullscreen.dmi'
	mymob.gui_icons.blob_bgRIGHT.icon_state = "backgroundRIGHT"
	mymob.gui_icons.blob_bgRIGHT.name = "Blob HUD"
	mymob.gui_icons.blob_bgRIGHT.layer = 19
	mymob.gui_icons.blob_bgRIGHT.screen_loc = ui_blob_bgRIGHT
	mymob.gui_icons.blob_bgRIGHT.mouse_opacity = 0

	mymob.gui_icons.blob_coverLEFT = getFromPool(/obj/screen/specialblob)
	mymob.gui_icons.blob_coverLEFT.icon = 'icons/mob/screen1_blob_fullscreen.dmi'
	mymob.gui_icons.blob_coverLEFT.icon_state = "coverLEFT"
	mymob.gui_icons.blob_coverLEFT.name = "Points"
	mymob.gui_icons.blob_coverLEFT.layer = 21
	mymob.gui_icons.blob_coverLEFT.screen_loc = ui_blob_bgLEFT
	mymob.gui_icons.blob_coverLEFT.maptext_x = 1
	mymob.gui_icons.blob_coverLEFT.maptext_y = 126

	mymob.gui_icons.blob_coverRIGHT = getFromPool(/obj/screen/specialblob)
	mymob.gui_icons.blob_coverRIGHT.icon = 'icons/mob/screen1_blob_fullscreen.dmi'
	mymob.gui_icons.blob_coverRIGHT.icon_state = "coverRIGHT"
	mymob.gui_icons.blob_coverRIGHT.name = "Health"
	mymob.gui_icons.blob_coverRIGHT.layer = 21
	mymob.gui_icons.blob_coverRIGHT.screen_loc = ui_blob_bgRIGHT
	mymob.gui_icons.blob_coverRIGHT.maptext_x = 464
	mymob.gui_icons.blob_coverRIGHT.maptext_y = 126

	mymob.gui_icons.blob_powerbar = getFromPool(/obj/screen/specialblob)
	mymob.gui_icons.blob_powerbar.icon = 'icons/mob/screen1_blob_bars.dmi'
	mymob.gui_icons.blob_powerbar.icon_state = "points"
	mymob.gui_icons.blob_powerbar.name = "Points"
	mymob.gui_icons.blob_powerbar.layer = 20
	mymob.gui_icons.blob_powerbar.screen_loc = ui_blob_powerbar

	mymob.gui_icons.blob_healthbar = getFromPool(/obj/screen/specialblob)
	mymob.gui_icons.blob_healthbar.icon = 'icons/mob/screen1_blob_bars.dmi'
	mymob.gui_icons.blob_healthbar.icon_state = "health"
	mymob.gui_icons.blob_healthbar.name = "Health"
	mymob.gui_icons.blob_healthbar.layer = 20
	mymob.gui_icons.blob_healthbar.screen_loc = ui_blob_healthbar

	mymob.gui_icons.blob_spawnblob = getFromPool(/obj/screen/specialblob)
	mymob.gui_icons.blob_spawnblob.icon = 'icons/mob/screen1_blob.dmi'
	mymob.gui_icons.blob_spawnblob.icon_state = "blob1"
	mymob.gui_icons.blob_spawnblob.name = "Spawn Blob"
	mymob.gui_icons.blob_spawnblob.layer = 22
	mymob.gui_icons.blob_spawnblob.screen_loc = ui_blob_spawnblob

	mymob.gui_icons.blob_spawnstrong = getFromPool(/obj/screen/specialblob)
	mymob.gui_icons.blob_spawnstrong.icon = 'icons/mob/screen1_blob.dmi'
	mymob.gui_icons.blob_spawnstrong.icon_state = "strong1"
	mymob.gui_icons.blob_spawnstrong.name = "Spawn Strong Blob"
	mymob.gui_icons.blob_spawnstrong.layer = 22
	mymob.gui_icons.blob_spawnstrong.screen_loc = ui_blob_spawnstrong

	mymob.gui_icons.blob_spawnresource = getFromPool(/obj/screen/specialblob)
	mymob.gui_icons.blob_spawnresource.icon = 'icons/mob/screen1_blob.dmi'
	mymob.gui_icons.blob_spawnresource.icon_state = "resource1"
	mymob.gui_icons.blob_spawnresource.name = "Spawn Resource Blob"
	mymob.gui_icons.blob_spawnresource.layer = 22
	mymob.gui_icons.blob_spawnresource.screen_loc = ui_blob_spawnresource

	mymob.gui_icons.blob_spawnfactory = getFromPool(/obj/screen/specialblob)
	mymob.gui_icons.blob_spawnfactory.icon = 'icons/mob/screen1_blob.dmi'
	mymob.gui_icons.blob_spawnfactory.icon_state = "factory1"
	mymob.gui_icons.blob_spawnfactory.name = "Spawn Factory Blob"
	mymob.gui_icons.blob_spawnfactory.layer = 22
	mymob.gui_icons.blob_spawnfactory.screen_loc = ui_blob_spawnfactory

	mymob.gui_icons.blob_spawnnode = getFromPool(/obj/screen/specialblob)
	mymob.gui_icons.blob_spawnnode.icon = 'icons/mob/screen1_blob.dmi'
	mymob.gui_icons.blob_spawnnode.icon_state = "node1"
	mymob.gui_icons.blob_spawnnode.name = "Spawn Node Blob"
	mymob.gui_icons.blob_spawnnode.layer = 22
	mymob.gui_icons.blob_spawnnode.screen_loc = ui_blob_spawnnode

	mymob.gui_icons.blob_spawncore = getFromPool(/obj/screen/specialblob)
	mymob.gui_icons.blob_spawncore.icon = 'icons/mob/screen1_blob.dmi'
	mymob.gui_icons.blob_spawncore.icon_state = "core1"
	mymob.gui_icons.blob_spawncore.name = "Spawn Blob Core"
	mymob.gui_icons.blob_spawncore.layer = 22
	mymob.gui_icons.blob_spawncore.screen_loc = ui_blob_spawncore

	mymob.gui_icons.blob_ping = getFromPool(/obj/screen/specialblob)
	mymob.gui_icons.blob_ping.icon = 'icons/mob/screen1_blob.dmi'
	mymob.gui_icons.blob_ping.icon_state = "ping"
	mymob.gui_icons.blob_ping.name = "Call Overminds"
	mymob.gui_icons.blob_ping.layer = 22
	mymob.gui_icons.blob_ping.screen_loc = ui_blob_ping

	mymob.gui_icons.blob_rally = getFromPool(/obj/screen/specialblob)
	mymob.gui_icons.blob_rally.icon = 'icons/mob/screen1_blob.dmi'
	mymob.gui_icons.blob_rally.icon_state = "rally"
	mymob.gui_icons.blob_rally.name = "Rally Spores"
	mymob.gui_icons.blob_rally.layer = 22
	mymob.gui_icons.blob_rally.screen_loc = ui_blob_rally

	mymob.gui_icons.blob_taunt = getFromPool(/obj/screen/specialblob)
	mymob.gui_icons.blob_taunt.icon = 'icons/mob/screen1_blob.dmi'
	mymob.gui_icons.blob_taunt.icon_state = "taunt"
	mymob.gui_icons.blob_taunt.name = "Psionic Message"
	mymob.gui_icons.blob_taunt.layer = 22
	mymob.gui_icons.blob_taunt.screen_loc = ui_blob_taunt

	mymob.client.reset_screen()

	mymob.client.screen += list(
		mymob.gui_icons.blob_bgLEFT,
		mymob.gui_icons.blob_bgRIGHT,
		mymob.gui_icons.blob_coverLEFT,
		mymob.gui_icons.blob_coverRIGHT,
		mymob.gui_icons.blob_powerbar,
		mymob.gui_icons.blob_healthbar,
		mymob.gui_icons.blob_spawnblob,
		mymob.gui_icons.blob_spawnstrong,
		mymob.gui_icons.blob_spawnresource,
		mymob.gui_icons.blob_spawnfactory,
		mymob.gui_icons.blob_spawnnode,
		mymob.gui_icons.blob_spawncore,
		mymob.gui_icons.blob_ping,
		mymob.gui_icons.blob_rally,
		mymob.gui_icons.blob_taunt,
		)

	for(var/i=1;i<=24;i++)
		var/obj/screen/specialblob/S = getFromPool(/obj/screen/specialblob)
		S.icon = 'icons/mob/screen1_blob.dmi'
		S.icon_state = ""
		var/total_offset = -16 + (i * 20)
		S.screen_loc = "[1 + round(total_offset/32)]:[total_offset%32],NORTH:0"
		mymob.gui_icons.specialblobs[i] = S

	for(var/i=1;i<=24;i++)
		mymob.client.screen += mymob.gui_icons.specialblobs[i]

/*
/datum/hud/proc/remove_blob_hud()
	for(var/i=1;i<=24;i++)
		mymob.client.screen -= mymob.gui_icons.specialblobs[i]

	mymob.client.screen -= list(
		mymob.gui_icons.blob_bgLEFT,
		mymob.gui_icons.blob_bgRIGHT,
		mymob.gui_icons.blob_coverLEFT,
		mymob.gui_icons.blob_coverRIGHT,
		mymob.gui_icons.blob_powerbar,
		mymob.gui_icons.blob_healthbar,
		mymob.gui_icons.blob_spawnblob,
		mymob.gui_icons.blob_spawnstrong,
		mymob.gui_icons.blob_spawnresource,
		mymob.gui_icons.blob_spawnfactory,
		mymob.gui_icons.blob_spawnnode,
		mymob.gui_icons.blob_spawncore,
		mymob.gui_icons.blob_ping,
		mymob.gui_icons.blob_rally,
		mymob.gui_icons.blob_taunt,
		)
*/