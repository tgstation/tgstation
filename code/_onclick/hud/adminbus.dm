/datum/hud/proc/adminbus_hud()
	mymob.adminbus_bg = new /obj/screen()
	mymob.adminbus_bg.icon = 'icons/adminbus/fullscreen.dmi'
	mymob.adminbus_bg.icon_state = "HUD"
	mymob.adminbus_bg.name = "HUD"
	mymob.adminbus_bg.layer = 19
	mymob.adminbus_bg.screen_loc = ui_adminbus_bg

	mymob.adminbus_delete = new /obj/screen()
	mymob.adminbus_delete.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_delete.icon_state = "icon_delete"
	mymob.adminbus_delete.name = "Delete Bus"
	mymob.adminbus_delete.screen_loc = ui_adminbus_delete

	mymob.adminbus_delmobs = new /obj/screen()
	mymob.adminbus_delmobs.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_delmobs.icon_state = "icon_delmobs"
	mymob.adminbus_delmobs.name = "Delete Mobs"
	mymob.adminbus_delmobs.screen_loc = ui_adminbus_delmobs

	mymob.adminbus_spclowns = new /obj/screen()
	mymob.adminbus_spclowns.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_spclowns.icon_state = "icon_spclown"
	mymob.adminbus_spclowns.name = "Spawn Clowns"
	mymob.adminbus_spclowns.screen_loc = ui_adminbus_spclowns

	mymob.adminbus_spcarps = new /obj/screen()
	mymob.adminbus_spcarps.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_spcarps.icon_state = "icon_spcarp"
	mymob.adminbus_spcarps.name = "Spawn Carps"
	mymob.adminbus_spcarps.screen_loc = ui_adminbus_spcarps

	mymob.adminbus_spbears = new /obj/screen()
	mymob.adminbus_spbears.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_spbears.icon_state = "icon_spbear"
	mymob.adminbus_spbears.name = "Spawn Bears"
	mymob.adminbus_spbears.screen_loc = ui_adminbus_spbears

	mymob.adminbus_sptrees = new /obj/screen()
	mymob.adminbus_sptrees.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_sptrees.icon_state = "icon_sptree"
	mymob.adminbus_sptrees.name = "Spawn Trees"
	mymob.adminbus_sptrees.screen_loc = ui_adminbus_sptrees

	mymob.adminbus_spspiders = new /obj/screen()
	mymob.adminbus_spspiders.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_spspiders.icon_state = "icon_spspider"
	mymob.adminbus_spspiders.name = "Spawn Spiders"
	mymob.adminbus_spspiders.screen_loc = ui_adminbus_spspiders

	mymob.adminbus_spalien = new /obj/screen()
	mymob.adminbus_spalien.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_spalien.icon_state = "icon_spalien"
	mymob.adminbus_spalien.name = "Spawn Large Alien Queen"
	mymob.adminbus_spalien.screen_loc = ui_adminbus_spalien

	mymob.adminbus_loadsids = new /obj/screen()
	mymob.adminbus_loadsids.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_loadsids.icon_state = "icon_loadsids"
	mymob.adminbus_loadsids.name = "Spawn Loads of Captain Spare IDs"
	mymob.adminbus_loadsids.screen_loc = ui_adminbus_loadsids

	mymob.adminbus_loadsmoney = new /obj/screen()
	mymob.adminbus_loadsmoney.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_loadsmoney.icon_state = "icon_loadsmone"
	mymob.adminbus_loadsmoney.name = "Spawn Loads of Money"
	mymob.adminbus_loadsmoney.screen_loc = ui_adminbus_loadsmone

	mymob.adminbus_massrepair = new /obj/screen()
	mymob.adminbus_massrepair.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_massrepair.icon_state = "icon_massrepair"
	mymob.adminbus_massrepair.name = "Repair Surroundings"
	mymob.adminbus_massrepair.screen_loc = ui_adminbus_massrepair

	mymob.adminbus_massrejuv = new /obj/screen()
	mymob.adminbus_massrejuv.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_massrejuv.icon_state = "icon_massrejuv"
	mymob.adminbus_massrejuv.name = "Mass Rejuvination"
	mymob.adminbus_massrejuv.screen_loc = ui_adminbus_massrejuv

	mymob.adminbus_hook = new /obj/screen()
	mymob.adminbus_hook.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_hook.icon_state = "icon_hook"
	mymob.adminbus_hook.name = "Singularity Hook"
	mymob.adminbus_hook.screen_loc = ui_adminbus_hook

	mymob.adminbus_juke = new /obj/screen()
	mymob.adminbus_juke.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_juke.icon_state = "icon_jukebox"
	mymob.adminbus_juke.name = "Adminbus-mounted Jukebox"
	mymob.adminbus_juke.screen_loc = ui_adminbus_juke

	mymob.adminbus_tele = new /obj/screen()
	mymob.adminbus_tele.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_tele.icon_state = "icon_teleport"
	mymob.adminbus_tele.name = "Teleportation"
	mymob.adminbus_tele.screen_loc = ui_adminbus_tele

	mymob.adminbus_bumpers_1 = new /obj/screen()
	mymob.adminbus_bumpers_1.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_bumpers_1.icon_state = "icon_bumpers_1-on"
	mymob.adminbus_bumpers_1.name = "Capture Mobs"
	mymob.adminbus_bumpers_1.screen_loc = ui_adminbus_bumpers_1

	mymob.adminbus_bumpers_2 = new /obj/screen()
	mymob.adminbus_bumpers_2.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_bumpers_2.icon_state = "icon_bumpers_2-off"
	mymob.adminbus_bumpers_2.name = "Hit Mobs"
	mymob.adminbus_bumpers_2.screen_loc = ui_adminbus_bumpers_2

	mymob.adminbus_bumpers_3 = new /obj/screen()
	mymob.adminbus_bumpers_3.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_bumpers_3.icon_state = "icon_bumpers_3-off"
	mymob.adminbus_bumpers_3.name = "Gib Mobs"
	mymob.adminbus_bumpers_3.screen_loc = ui_adminbus_bumpers_3

	mymob.adminbus_door_0 = new /obj/screen()
	mymob.adminbus_door_0.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_door_0.icon_state = "icon_door_0-on"
	mymob.adminbus_door_0.name = "Close Door"
	mymob.adminbus_door_0.screen_loc = ui_adminbus_door_0

	mymob.adminbus_door_1 = new /obj/screen()
	mymob.adminbus_door_1.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_door_1.icon_state = "icon_door_1-off"
	mymob.adminbus_door_1.name = "Open Door"
	mymob.adminbus_door_1.screen_loc = ui_adminbus_door_1

	mymob.adminbus_roadlights_0 = new /obj/screen()
	mymob.adminbus_roadlights_0.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_roadlights_0.icon_state = "icon_lights_0-on"
	mymob.adminbus_roadlights_0.name = "Turn Off Headlights"
	mymob.adminbus_roadlights_0.screen_loc = ui_adminbus_roadlights_0

	mymob.adminbus_roadlights_1 = new /obj/screen()
	mymob.adminbus_roadlights_1.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_roadlights_1.icon_state = "icon_lights_1-off"
	mymob.adminbus_roadlights_1.name = "Dipped Headlights"
	mymob.adminbus_roadlights_1.screen_loc = ui_adminbus_roadlights_1

	mymob.adminbus_roadlights_2 = new /obj/screen()
	mymob.adminbus_roadlights_2.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_roadlights_2.icon_state = "icon_lights_2-off"
	mymob.adminbus_roadlights_2.name = "Main Headlights"
	mymob.adminbus_roadlights_2.screen_loc = ui_adminbus_roadlights_2

	mymob.adminbus_free = new /obj/screen()
	mymob.adminbus_free.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_free.icon_state = "icon_free"
	mymob.adminbus_free.name = "Release Passengers"
	mymob.adminbus_free.screen_loc = ui_adminbus_free

	mymob.adminbus_home = new /obj/screen()
	mymob.adminbus_home.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_home.icon_state = "icon_home"
	mymob.adminbus_home.name = "Send Passengers Back Home"
	mymob.adminbus_home.screen_loc = ui_adminbus_home

	mymob.adminbus_antag = new /obj/screen()
	mymob.adminbus_antag.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_antag.icon_state = "icon_antag"
	mymob.adminbus_antag.name = "Antag Madness!"
	mymob.adminbus_antag.screen_loc = ui_adminbus_antag

	mymob.adminbus_dellasers = new /obj/screen()
	mymob.adminbus_dellasers.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_dellasers.icon_state = "icon_delgiven"
	mymob.adminbus_dellasers.name = "Delete the given Infinite Laser Guns"
	mymob.adminbus_dellasers.screen_loc = ui_adminbus_dellasers

	mymob.adminbus_givelasers = new /obj/screen()
	mymob.adminbus_givelasers.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_givelasers.icon_state = "icon_givelasers"
	mymob.adminbus_givelasers.name = "Give Infinite Laser Guns to the Passengers"
	mymob.adminbus_givelasers.screen_loc = ui_adminbus_givelasers

	mymob.adminbus_delbombs = new /obj/screen()
	mymob.adminbus_delbombs.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_delbombs.icon_state = "icon_delgiven"
	mymob.adminbus_delbombs.name = "Delete the given Fuse-Bombs"
	mymob.adminbus_delbombs.screen_loc = ui_adminbus_delbombs

	mymob.adminbus_givebombs = new /obj/screen()
	mymob.adminbus_givebombs.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_givebombs.icon_state = "icon_givebombs"
	mymob.adminbus_givebombs.name = "Give Fuse-Bombs to the Passengers"
	mymob.adminbus_givebombs.screen_loc = ui_adminbus_givebombs

	mymob.adminbus_tdred = new /obj/screen()
	mymob.adminbus_tdred.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_tdred.icon_state = "icon_tdred"
	mymob.adminbus_tdred.name = "Send Passengers to the Thunderdome's Red Team"
	mymob.adminbus_tdred.screen_loc = ui_adminbus_tdred

	mymob.adminbus_tdarena = new /obj/screen()
	mymob.adminbus_tdarena.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_tdarena.icon_state = "icon_tdarena"
	mymob.adminbus_tdarena.name = "Split the Passengers between the two Thunderdome Teams"
	mymob.adminbus_tdarena.screen_loc = ui_adminbus_tdarena

	mymob.adminbus_tdgreen = new /obj/screen()
	mymob.adminbus_tdgreen.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_tdgreen.icon_state = "icon_tdgreen"
	mymob.adminbus_tdgreen.name = "Send Passengers to the Thunderdome's Green Team"
	mymob.adminbus_tdgreen.screen_loc = ui_adminbus_tdgreen

	mymob.adminbus_tdobs = new /obj/screen()
	mymob.adminbus_tdobs.icon = 'icons/adminbus/32x32.dmi'
	mymob.adminbus_tdobs.icon_state = "icon_tdobs"
	mymob.adminbus_tdobs.name = "Send Passengers to the Thunderdome's Observers' Lodge"
	mymob.adminbus_tdobs.screen_loc = ui_adminbus_tdobs

	mymob.client.screen += list(
							mymob.adminbus_bg,
							mymob.adminbus_delete,
							mymob.adminbus_delmobs,
							mymob.adminbus_spclowns,
							mymob.adminbus_spcarps,
							mymob.adminbus_spbears,
							mymob.adminbus_sptrees,
							mymob.adminbus_spspiders,
							mymob.adminbus_spalien,
							mymob.adminbus_loadsids,
							mymob.adminbus_loadsmoney,
							mymob.adminbus_massrepair,
							mymob.adminbus_massrejuv,
							mymob.adminbus_hook,
							mymob.adminbus_juke,
							mymob.adminbus_tele,
							mymob.adminbus_bumpers_1,
							mymob.adminbus_bumpers_2,
							mymob.adminbus_bumpers_3,
							mymob.adminbus_door_0,
							mymob.adminbus_door_1,
							mymob.adminbus_roadlights_0,
							mymob.adminbus_roadlights_1,
							mymob.adminbus_roadlights_2,
							mymob.adminbus_free,
							mymob.adminbus_home,
							mymob.adminbus_antag,
							mymob.adminbus_dellasers,
							mymob.adminbus_givelasers,
							mymob.adminbus_delbombs,
							mymob.adminbus_givebombs,
							mymob.adminbus_tdred,
							mymob.adminbus_tdarena,
							mymob.adminbus_tdgreen,
							mymob.adminbus_tdobs,
							)

	for(var/i=1;i<=16;i++)
		var/obj/screen/S = new /obj/screen()
		S.icon = 'icons/adminbus/32x32.dmi'
		S.icon_state = ""
		S.screen_loc = "[12-round(i/2)]:[16*((i-1)%2)],14:16"
		mymob.rearviews[i] = S

	for(var/i=1;i<=16;i++)
		mymob.client.screen += mymob.rearviews[i]


/datum/hud/proc/remove_adminbus_hud()
	for(var/i=1;i<=16;i++)
		mymob.client.screen -= mymob.rearviews[i]

	mymob.client.screen -= list(
		mymob.adminbus_bg,
		mymob.adminbus_delete,
		mymob.adminbus_delmobs,
		mymob.adminbus_spclowns,
		mymob.adminbus_spcarps,
		mymob.adminbus_spbears,
		mymob.adminbus_sptrees,
		mymob.adminbus_spspiders,
		mymob.adminbus_spalien,
		mymob.adminbus_loadsids,
		mymob.adminbus_loadsmoney,
		mymob.adminbus_massrepair,
		mymob.adminbus_massrejuv,
		mymob.adminbus_hook,
		mymob.adminbus_juke,
		mymob.adminbus_tele,
		mymob.adminbus_bumpers_1,
		mymob.adminbus_bumpers_2,
		mymob.adminbus_bumpers_3,
		mymob.adminbus_door_0,
		mymob.adminbus_door_1,
		mymob.adminbus_roadlights_0,
		mymob.adminbus_roadlights_1,
		mymob.adminbus_roadlights_2,
		mymob.adminbus_free,
		mymob.adminbus_home,
		mymob.adminbus_antag,
		mymob.adminbus_dellasers,
		mymob.adminbus_givelasers,
		mymob.adminbus_delbombs,
		mymob.adminbus_givebombs,
		mymob.adminbus_tdred,
		mymob.adminbus_tdarena,
		mymob.adminbus_tdgreen,
		mymob.adminbus_tdobs,
		)