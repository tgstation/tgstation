
/datum/hud/proc/unplayer_hud()
	return

/datum/hud/proc/ghost_hud()
	mymob.visible = getFromPool(/obj/screen)
	mymob.visible.icon = 'icons/mob/screen1_ghost.dmi'
	mymob.visible.icon_state = "visible0"
	mymob.visible.name = "visible"
	mymob.visible.screen_loc = ui_health

	mymob.flash = getFromPool(/obj/screen)
	mymob.flash.icon = 'icons/mob/screen1.dmi'
	mymob.flash.icon_state = "blank"
	mymob.flash.name = "flash"
	mymob.flash.screen_loc = ui_entire_screen
	mymob.flash.layer = 17

	mymob.client.reset_screen()

	mymob.client.screen += list(mymob.visible, mymob.flash)

/datum/hud/proc/corgi_hud()
	mymob.fire = getFromPool(/obj/screen)
	mymob.fire.icon = 'icons/mob/screen1_corgi.dmi'
	mymob.fire.icon_state = "fire0"
	mymob.fire.name = "fire"
	mymob.fire.screen_loc = ui_fire

	mymob.healths = getFromPool(/obj/screen)
	mymob.healths.icon = 'icons/mob/screen1_corgi.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_health

	mymob.pullin = getFromPool(/obj/screen)
	mymob.pullin.icon = 'icons/mob/screen1_corgi.dmi'
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.name = "pull"
	mymob.pullin.screen_loc = ui_construct_pull

	mymob.oxygen = getFromPool(/obj/screen)
	mymob.oxygen.icon = 'icons/mob/screen1_corgi.dmi'
	mymob.oxygen.icon_state = "oxy0"
	mymob.oxygen.name = "oxygen"
	mymob.oxygen.screen_loc = ui_oxygen

	mymob.toxin = getFromPool(/obj/screen)
	mymob.toxin.icon = 'icons/mob/screen1_corgi.dmi'
	mymob.toxin.icon_state = "tox0"
	mymob.toxin.name = "toxin"
	mymob.toxin.screen_loc = ui_toxin

	mymob.flash = getFromPool(/obj/screen)
	mymob.flash.icon = 'icons/mob/screen1.dmi'
	mymob.flash.icon_state = "blank"
	mymob.flash.name = "flash"
	mymob.flash.screen_loc = ui_entire_screen
	mymob.flash.layer = 17

	mymob.client.reset_screen()

	mymob.client.screen += list(mymob.fire, mymob.healths, mymob.pullin, mymob.oxygen, mymob.toxin, mymob.flash)

/datum/hud/proc/brain_hud(ui_style = 'icons/mob/screen1_Midnight.dmi')
	mymob.blind = getFromPool(/obj/screen)
	mymob.blind.icon = 'icons/mob/screen1_full.dmi'
	mymob.blind.icon_state = "blackimageoverlay"
	mymob.blind.name = " "
	mymob.blind.screen_loc = "1,1"
	mymob.blind.layer = 0

/datum/hud/proc/blob_hud(ui_style = 'icons/mob/screen1_Midnight.dmi')


	blobpwrdisplay = getFromPool(/obj/screen)
	blobpwrdisplay.name = "blob power"
	blobpwrdisplay.icon_state = "block"
	blobpwrdisplay.screen_loc = ui_health
	blobpwrdisplay.layer = 20

	blobhealthdisplay = getFromPool(/obj/screen)
	blobhealthdisplay.name = "blob health"
	blobhealthdisplay.icon_state = "block"
	blobhealthdisplay.screen_loc = ui_internal
	blobhealthdisplay.layer = 20

	mymob.client.reset_screen()

	mymob.client.screen += list(blobpwrdisplay, blobhealthdisplay)

/datum/hud/proc/shade_hud()


	mymob.healths = getFromPool(/obj/screen)
	mymob.healths.icon = 'icons/mob/screen1_shade.dmi'
	mymob.healths.icon_state = "shade_health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_construct_health

	mymob.pullin = getFromPool(/obj/screen)
	mymob.pullin.icon = 'icons/mob/screen1_shade.dmi'
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.name = "pull"
	mymob.pullin.screen_loc = ui_construct_pull

	mymob.purged = getFromPool(/obj/screen)
	mymob.purged.icon = 'icons/mob/screen1_shade.dmi'
	mymob.purged.icon_state = "purge0"
	mymob.purged.name = "purged"
	mymob.purged.screen_loc = ui_construct_purge

	mymob.zone_sel = getFromPool(/obj/screen/zone_sel)
	mymob.zone_sel.icon = 'icons/mob/screen1_shade.dmi'
	mymob.zone_sel.overlays.len = 0
	mymob.zone_sel.overlays += image('icons/mob/zone_sel.dmi', "[mymob.zone_sel.selecting]")

	mymob.flash = getFromPool(/obj/screen)
	mymob.flash.icon = 'icons/mob/screen1.dmi'
	mymob.flash.icon_state = "blank"
	mymob.flash.name = "flash"
	mymob.flash.screen_loc = ui_entire_screen
	mymob.flash.layer = 17

	mymob.client.reset_screen()

	mymob.client.screen += list(mymob.healths, mymob.pullin, mymob.zone_sel, mymob.purged, mymob.flash)

/datum/hud/proc/construct_hud()
	var/constructtype

	if(istype(mymob,/mob/living/simple_animal/construct/armoured) || istype(mymob,/mob/living/simple_animal/construct/behemoth))
		constructtype = "juggernaut"
	else if(istype(mymob,/mob/living/simple_animal/construct/builder))
		constructtype = "artificer"
	else if(istype(mymob,/mob/living/simple_animal/construct/wraith))
		constructtype = "wraith"
	else if(istype(mymob,/mob/living/simple_animal/construct/harvester))
		constructtype = "harvester"

	mymob.flash = getFromPool(/obj/screen)
	mymob.flash.icon = 'icons/mob/screen1.dmi'
	mymob.flash.icon_state = "blank"
	mymob.flash.name = "flash"
	mymob.flash.screen_loc = ui_entire_screen
	mymob.flash.layer = 17

	if(constructtype)
		mymob.fire = getFromPool(/obj/screen)
		mymob.fire.icon = 'icons/mob/screen1_construct.dmi'
		mymob.fire.icon_state = "fire0"
		mymob.fire.name = "fire"
		mymob.fire.screen_loc = ui_construct_fire

		mymob.healths = getFromPool(/obj/screen)
		mymob.healths.icon = 'icons/mob/screen1_construct.dmi'
		mymob.healths.icon_state = "[constructtype]_health0"
		mymob.healths.name = "health"
		mymob.healths.screen_loc = ui_construct_health

		mymob.pullin = getFromPool(/obj/screen)
		mymob.pullin.icon = 'icons/mob/screen1_construct.dmi'
		mymob.pullin.icon_state = "pull0"
		mymob.pullin.name = "pull"
		mymob.pullin.screen_loc = ui_construct_pull

		mymob.zone_sel = getFromPool(/obj/screen/zone_sel)
		mymob.zone_sel.icon = 'icons/mob/screen1_construct.dmi'
		mymob.zone_sel.overlays.len = 0
		mymob.zone_sel.overlays += image('icons/mob/zone_sel.dmi', "[mymob.zone_sel.selecting]")

		mymob.purged = getFromPool(/obj/screen)
		mymob.purged.icon = 'icons/mob/screen1_construct.dmi'
		mymob.purged.icon_state = "purge0"
		mymob.purged.name = "purged"
		mymob.purged.screen_loc = ui_construct_purge

	mymob.client.reset_screen()

	mymob.client.screen += list(mymob.fire, mymob.healths, mymob.pullin, mymob.zone_sel, mymob.purged, mymob.flash)

/datum/hud/proc/vampire_hud(ui_style = 'icons/mob/screen1_Midnight.dmi')


	vampire_blood_display = getFromPool(/obj/screen)
	vampire_blood_display.name = "Vampire Blood"
	vampire_blood_display.icon_state = "dark128"
	vampire_blood_display.screen_loc = "EAST-1:28,CENTER+2:15"
	vampire_blood_display.layer = 20

	mymob.client.screen += list(vampire_blood_display)

/datum/hud/proc/changeling_hud()
	vampire_blood_display = getFromPool(/obj/screen)
	vampire_blood_display.name = "Changeling Chems"
	vampire_blood_display.icon_state = "dark128"
	vampire_blood_display.screen_loc = "EAST-1:28,CENTER+2:15"
	vampire_blood_display.layer = 20

	mymob.client.screen += list(vampire_blood_display)


